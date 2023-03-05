// ArchView.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "ArchView.h"
#include "ArchFrame.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CArchView

IMPLEMENT_DYNCREATE(CArchView, CScrollView)

#define VIEW_WIDTH 4096
#define VIEW_HEIGHT 4096

CArchView::CArchView()
{
	pDoc = NULL;
	ConfigMode = TRUE;
	SelectedCount = 0; MoveMode = FALSE; CopyMode = FALSE;
}

CArchView::~CArchView()
{
}

BEGIN_MESSAGE_MAP(CArchView, CScrollView)
	//{{AFX_MSG_MAP(CArchView)
	ON_WM_MOUSEMOVE()
	ON_COMMAND(ID_ARCHELEM_DEL, OnArchElemDel)
	ON_WM_LBUTTONDOWN()
	ON_COMMAND(ID_ARCHMODE, OnArchMode)
	ON_COMMAND(ID_CONSTRMODE, OnConstrMode)
	ON_UPDATE_COMMAND_UI(ID_ARCHELEM_DEL, OnUpdateArchElemDel)
	ON_WM_LBUTTONUP()
	ON_MESSAGE(WMU_ADD_ELEMENT_BY_NAME, OnAddElementByName)
	ON_MESSAGE(WMU_ELEMENT_LBUTTONDOWN, OnElementLButtonDown)
	ON_MESSAGE(WMU_ELEMENT_LBUTTONUP, OnElementLButtonUp)
	ON_MESSAGE(WMU_ELEMENT_MOUSEMOVE, OnElementMouseMove)
	ON_WM_KEYDOWN()
	ON_WM_KEYUP()
	ON_WM_ERASEBKGND()
	ON_COMMAND(ID_FILE_PRINT, OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, OnFilePrintPreview)
	ON_WM_TIMER()
	ON_WM_DESTROY()
	//}}AFX_MSG_MAP
	ON_UPDATE_COMMAND_UI_RANGE(ID_ADD_ELEMENT0, ID_ADD_ELEMENT255, OnUpdateAddElement)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CArchView drawing

void CArchView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();

	CSize sizeTotal;
	pDoc = (CArchDoc*)GetDocument();
	pDoc->pView = this;
	sizeTotal.cx = VIEW_WIDTH;
	sizeTotal.cy = VIEW_HEIGHT;
	SetScrollSizes(MM_TEXT, sizeTotal);

	SetClassLong(m_hWnd, GCL_HBRBACKGROUND, NULL);

}

/////////////////////////////////////////////////////////////////////////////
// CArchView diagnostics

#ifdef _DEBUG
void CArchView::AssertValid() const
{
	CScrollView::AssertValid();
}

void CArchView::Dump(CDumpContext& dc) const
{
	CScrollView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CArchView message handlers

BOOL CArchView::OnEraseBkgnd(CDC* pDC)
{
	CRect ClRect;
	GetClientRect(ClRect);
	pDC->PatBlt(ClRect.left, ClRect.top, ClRect.Width(), ClRect.Height(), WHITENESS);

	return CScrollView::OnEraseBkgnd(pDC);
}

BOOL CArchView::PreCreateWindow(CREATESTRUCT& cs)
{
	//cs.style&=~WS_CLIPSIBLINGS;
	cs.style |= WS_CLIPCHILDREN;

	return CScrollView::PreCreateWindow(cs);
}

void CArchView::OnMouseMove(UINT nFlags, CPoint point)
{
	CScrollView::OnMouseMove(nFlags, point);

	if (!MoveMode) return;

	if (nFlags == MK_LBUTTON) {
		CPen Pen(PS_DOT, 1, RGB(0, 0, 0));
		CClientDC DC(this);
		DC.SetROP2(R2_XORPEN);
		CPen *pOldPen = DC.SelectObject(&Pen);

		DC.MoveTo(StartMousePoint);
		DC.LineTo(point.x, StartMousePoint.y);
		DC.LineTo(point.x, point.y);
		DC.LineTo(StartMousePoint.x, point.y);
		DC.LineTo(StartMousePoint.x, StartMousePoint.y);

		DC.MoveTo(StartMousePoint);
		DC.LineTo(LastMousePoint.x, StartMousePoint.y);
		DC.LineTo(LastMousePoint.x, LastMousePoint.y);
		DC.LineTo(StartMousePoint.x, LastMousePoint.y);
		DC.LineTo(StartMousePoint.x, StartMousePoint.y);

		DC.SelectObject(pOldPen);
		LastMousePoint = point;
	}
}

/*
По нажатию левой кнопки мыши:
1. Ни один не выделен:
	  выделяем текущий
2. Выделен один текущий
	  ничего не делаем
3. Выделен один не текущий
	  снять выделение с другого, выделить текущий
4. Выделено несколько, в том числе текущий
	  ничего не делаем
5. Выделено несколько, текущий не выделен
	  снять выделение с других, выделить текущий
*/

LPARAM CArchView::OnElementLButtonDown(WPARAM nFlags, LPARAM hElement)
{
	CPoint point;
	GetCursorPos(&point);
	CElement *pElement = pDoc->Elements[(DWORD)hElement];

	MoveMode = TRUE; CopyMode = FALSE;
	HWND hCaptureWnd = (HWND)(ArchMode ? pElement->get_hArchWnd() : pElement->get_hConstrWnd());
	if (hCaptureWnd) ::SetCapture(hCaptureWnd);
	StartMousePoint = point;

	if (nFlags == MK_LBUTTON) { //На клавиатуре ничего не нажато
	  //Если щелчок на выделенном элементе, то ничего не делаем
		if (!(ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected())) {
			//Иначе выделяем текущий и снимаем выделение с остальных
			for (CElement* pElement2 : pDoc->Elements) {
				if (pElement2 == NULL) continue;

				if (ArchMode ? pElement2->get_bArchSelected() : pElement2->get_bConstrSelected()) {
					SelectedCount--;
					if (ArchMode) pElement2->put_bArchSelected(FALSE);
					else pElement2->put_bConstrSelected(FALSE);
					HWND hWnd = (HWND)(ArchMode ? pElement2->get_hArchWnd() :
						pElement2->get_hConstrWnd());
					if (hWnd) ::InvalidateRect(hWnd, NULL, FALSE);
				}
			}
			if (ArchMode) pElement->put_bArchSelected(TRUE);
			else pElement->put_bConstrSelected(TRUE);
			HWND hWnd = (HWND)(ArchMode ? pElement->get_hArchWnd() : pElement->get_hConstrWnd());
			if (hWnd) ::InvalidateRect(hWnd, NULL, FALSE);
			SelectedCount++;
		}
	}
	if ((nFlags&MK_CONTROL) && (nFlags&MK_LBUTTON)) {
		pDoc->CopySelected();
		CopyMode = TRUE;
	}

	if (ArchMode) DeconnectSelected();

	return 0;
}

/*
Отпустили клавишу с Ctrl:
	  если CopyMode!=TRUE тогда инвертировать текущий
Отпустили клавишу без Ctrl:
1. Ни один не выделен:
	  ничего не делаем
2. Выделен один текущий
	  ничего не делаем
3. Выделен один не текущий
	  ничего не делаем
4. Выделено несколько, в том числе текущий
	  снимаем выделение со всех кроме текущего
5. Выделено несколько, текущий не выделен
	  ничего не делаем
Если после перемещения, ничего не делаем
*/

LPARAM CArchView::OnElementLButtonUp(WPARAM nFlags, LPARAM hElement)
{
	CPoint point;
	GetCursorPos(&point);
	CElement *pElement = pDoc->Elements[(DWORD)hElement];

	switch (nFlags) {
	case 0:
		if ((SelectedCount > 1) &&
			(ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected()) &&
			!MoveMode) {
			for (CElement* pElement2 : pDoc->Elements) {
				if (pElement2 == NULL) continue;
				if (pElement2 == pElement) continue;

				if (ArchMode&&pElement2->get_bArchSelected()) {
					pElement2->put_bArchSelected(FALSE);
					HWND hWnd = (HWND)pElement2->get_hArchWnd();
					if (hWnd) ::InvalidateRect(hWnd, NULL, FALSE);
				}
				if (!ArchMode&&pElement2->get_bConstrSelected()) {
					pElement2->put_bConstrSelected(FALSE);
					HWND hWnd = (HWND)pElement2->get_hConstrWnd();
					if (hWnd) ::InvalidateRect(hWnd, NULL, FALSE);
				}
			}
			SelectedCount = 1;
		}
		break;
	case MK_SHIFT: //Shift key pressed
		if (ArchMode) {
			if (pElement->get_bArchSelected()) SelectedCount--;
			else SelectedCount++;
			pElement->put_bArchSelected(!pElement->get_bArchSelected());
		}
		else {
			if (pElement->get_bConstrSelected()) SelectedCount--;
			else SelectedCount++;
			pElement->put_bConstrSelected(!pElement->get_bConstrSelected());
		}

		HWND hElemWnd = (HWND)(ArchMode ? pElement->get_hArchWnd() : pElement->get_hConstrWnd());
		if (hElemWnd) ::InvalidateRect(hElemWnd, NULL, TRUE);
		break;
	}

	if (ArchMode) ConnectSelected();

	::ReleaseCapture();
	MoveMode = FALSE; CopyMode = FALSE;
	return 0;
}

LPARAM CArchView::OnElementMouseMove(WPARAM nFlags, LPARAM hElement)
{
	if (!(nFlags&MK_LBUTTON)) return 0;
	if (!MoveMode) return 0;

	CPoint point;
	GetCursorPos(&point);

	BOOL Moved = FALSE;
	int ShiftX = point.x - StartMousePoint.x,
		ShiftY = point.y - StartMousePoint.y;
	StartMousePoint = point;
	if (MoveSelected(ShiftX, ShiftY)) {
		MoveMode = TRUE;
		pDoc->SetModifiedFlag();
	}

	return 0;
}

void CArchView::OnArchElemDel()
{
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if ((ArchMode&&pDoc->Elements[n]->get_bArchSelected()) || (!ArchMode&&pDoc->Elements[n]->get_bConstrSelected())) {
			DeconnectElement(n);
		}
	}
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if ((ArchMode&&pDoc->Elements[n]->get_bArchSelected()) || (!ArchMode&&pDoc->Elements[n]->get_bConstrSelected())) {
			pDoc->DeleteElement(n);
		}
	}
	RedrawWindow();
}

void CArchView::OnLButtonDown(UINT nFlags, CPoint point)
{
	CScrollView::OnLButtonDown(nFlags, point);

	MoveMode = TRUE; CopyMode = FALSE;
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if (ArchMode) {
			if (pDoc->Elements[n]->get_bArchSelected()) {
				pDoc->Elements[n]->put_bArchSelected(FALSE);
				HWND hWnd = (HWND)pDoc->Elements[n]->get_hArchWnd();
				if (hWnd) ::InvalidateRect(hWnd, NULL, FALSE);
			}
		}
		else {
			if (pDoc->Elements[n]->get_bConstrSelected()) {
				pDoc->Elements[n]->put_bConstrSelected(FALSE);
				HWND hWnd = (HWND)pDoc->Elements[n]->get_hConstrWnd();
				if (hWnd) ::InvalidateRect(hWnd, NULL, FALSE);
			}
		}
	}
	SelectedCount = 0;
	m_StatusBar.SetPaneText(0, "");
	StartMousePoint = point; LastMousePoint = point;
	SetCapture();
}


void CArchView::OnArchMode()
{
	ToolBar.GetToolBarCtrl().CheckButton(ID_ARCHMODE, TRUE);
	ToolBar.GetToolBarCtrl().CheckButton(ID_CONSTRMODE, FALSE);
	ArchMode = TRUE;

	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		HWND hArchWnd = (HWND)pDoc->Elements[n]->get_hArchWnd();
		HWND hConstrWnd = (HWND)pDoc->Elements[n]->get_hConstrWnd();
		if (hConstrWnd) ::ShowWindow(hConstrWnd, SW_HIDE);
		if (hArchWnd) ::ShowWindow(hArchWnd, SW_SHOW);
		if (hConstrWnd) ::EnableWindow(hConstrWnd, FALSE);
		if (hArchWnd) ::EnableWindow(hArchWnd, TRUE);
	}
}

void CArchView::OnConstrMode()
{
	ToolBar.GetToolBarCtrl().CheckButton(ID_CONSTRMODE, TRUE);
	ToolBar.GetToolBarCtrl().CheckButton(ID_ARCHMODE, FALSE);
	ArchMode = FALSE;

	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		HWND hArchWnd = (HWND)pDoc->Elements[n]->get_hArchWnd();
		HWND hConstrWnd = (HWND)pDoc->Elements[n]->get_hConstrWnd();
		if (hArchWnd) ::ShowWindow(hArchWnd, SW_HIDE);
		if (hConstrWnd) ::ShowWindow(hConstrWnd, SW_SHOW);
		if (hArchWnd) ::EnableWindow(hArchWnd, FALSE);
		if (hConstrWnd) ::EnableWindow(hConstrWnd, TRUE);
	}
}

BOOL CArchView::Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID, CCreateContext* pContext)
{
	if (CWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, nID, pContext)) {
		m_StatusBar.Create(GetParent());

		Ind[0] = ID_ARCH_STATUS;
		Ind[1] = ID_FPS;
		Ind[2] = ID_INSTR_COUNTER;
		m_StatusBar.SetIndicators(Ind, 3);

		m_StatusBar.SetPaneStyle(0, SBPS_STRETCH | SBPS_NORMAL);

		m_StatusBar.SetPaneInfo(1, ID_FPS, SBPS_NORMAL, 60);
		m_StatusBar.SetPaneInfo(2, ID_INSTR_COUNTER, SBPS_NORMAL, 100);

		ToolBar.CreateEx(GetParent(), TBSTYLE_FLAT | TBSTYLE_TRANSPARENT);
		ToolBar.LoadToolBar(IDR_ARCHTYPE);

		ToolBar.GetToolBarCtrl().CheckButton(ID_ARCHMODE, TRUE);
		ToolBar.GetToolBarCtrl().CheckButton(ID_CONSTRMODE, FALSE);
		ReBar.Create(GetParent());
		ReBar.AddBar(&ToolBar);

		ToolBar.SetBarStyle(ToolBar.GetBarStyle() | CBRS_TOOLTIPS | CBRS_FLYBY);
		CreateElementButtons();

		ArchMode = TRUE;

		((CFrameWnd*)GetParent())->ShowControlBar(&ToolBar, TRUE, FALSE);

		return TRUE;
	}
	return FALSE;
}

void CArchView::OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint)
{
	if (!pDoc) return;
	if (ArchMode) OnArchMode();
	else OnConstrMode();
}

void CArchView::OnDestroy() {
	if (!ConfigMode) {
		ConfigMode = true;
		KillTimer(1);
		if (threadRedraw.joinable()) threadRedraw.join();
	}
}

void CArchView::ChangeMode(BOOL bConfigMode)
{
	ConfigMode = bConfigMode;
	((CArchFrame*)GetParent())->ChangeMode(bConfigMode);
	if (ConfigMode) KillTimer(1);
	else SetTimer(1, 500, NULL);

	if (ConfigMode) {
		if (threadRedraw.joinable()) threadRedraw.join();
		m_StatusBar.SetPaneText(2, "");
		m_StatusBar.SetPaneText(1, "");
	}else {
		threadRedraw = std::thread(redrawChangedElements, this);
	}
}

BOOL CArchView::OnPreparePrinting(CPrintInfo* pInfo)
{
	if (DoPreparePrinting(pInfo)) {
		return TRUE;
	}
	return FALSE;
}

void CArchView::OnUpdateArchElemDel(CCmdUI* pCmdUI)
{
	int SelCount = 0, ElementIndex;
	CElement* pElement;
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if ((ArchMode&&pDoc->Elements[n]->get_bArchSelected()) ||
			(!ArchMode&&pDoc->Elements[n]->get_bConstrSelected())) {
			SelCount++;
			pElement = pDoc->Elements[n];
			ElementIndex = n;
		}
	}
	pCmdUI->Enable(SelCount > 0);
	if (SelCount == 1) {
		struct _ConListElem {
			CElement* pElement;
			CString PinNumber;
		}ConList[8];

		int ConnectedCount = 0, MaxConCount = 8;
		for (int n = 0; n < MaxConCount; n++) ConList[n].pElement = NULL;
		int ElPointCount = pElement->get_nPointCount();
		for (int n = 0; n < ElPointCount; n++) {
			PointList *pPnt = &ConData[ElementIndex][n];
			POSITION Pos = pPnt->GetHeadPosition();
			while (Pos) {
				ConPoint &CP = pPnt->GetNext(Pos);
				if (CP.pElement) {
					CString *pStr = NULL;
					for (int i = 0; i < ConnectedCount; i++) {
						if (CP.pElement == ConList[i].pElement) {
							pStr = &ConList[i].PinNumber;
							break;
						}
					}
					if (!pStr && (ConnectedCount < MaxConCount)) {
						pStr = &ConList[ConnectedCount].PinNumber;
						ConList[ConnectedCount].pElement = CP.pElement;
						ConnectedCount++;
					}
					if (pStr) {
						CString s;
						s.Format("%d", CP.PinNumber);
						if (pStr->GetLength() > 0) *pStr += ",";
						*pStr += s;
					}
				}
			}
		}

		CString Tip;
		if (ConnectedCount) {
			Tip = " подключён к ";
			for (int i = 0; i < ConnectedCount; i++) {
				CString TipText = ConList[i].pElement->get_sTipText();
				Tip += "\"" + TipText + "\"";
				Tip += " (" + ConList[i].PinNumber + "), ";
			}
		}
		if (Tip.GetLength()) Tip = Tip.Left(Tip.GetLength() - 2);

		CString TipText = pElement->get_sTipText();
		m_StatusBar.SetPaneText(0, TipText + Tip);
	}
	else m_StatusBar.SetPaneText(0, "");
}

void CArchView::OnUpdateAddElement(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(ConfigMode);
}

void CArchView::OnLButtonUp(UINT nFlags, CPoint point)
{
	CScrollView::OnLButtonUp(nFlags, point);

	CopyMode = FALSE;
	if (!MoveMode) return;

	CPen Pen(PS_DOT, 1, RGB(0, 0, 0));
	CClientDC DC(this);
	DC.SetROP2(R2_XORPEN);
	CPen *pOldPen = DC.SelectObject(&Pen);

	DC.MoveTo(StartMousePoint);
	DC.LineTo(LastMousePoint.x, StartMousePoint.y);
	DC.LineTo(LastMousePoint.x, LastMousePoint.y);
	DC.LineTo(StartMousePoint.x, LastMousePoint.y);
	DC.LineTo(StartMousePoint.x, StartMousePoint.y);

	DC.SelectObject(pOldPen);
	ReleaseCapture();

	CRect SelRect(StartMousePoint, LastMousePoint);
	SelRect.NormalizeRect();
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		WINDOWPLACEMENT ElemPlace;
		ElemPlace.length = sizeof(ElemPlace);
		HWND hWnd = (HWND)(ArchMode ? pDoc->Elements[n]->get_hArchWnd() :
			pDoc->Elements[n]->get_hConstrWnd());
		if (!hWnd) continue;

		::GetWindowPlacement(hWnd, &ElemPlace);
		if (SelRect.PtInRect(CPoint(ElemPlace.rcNormalPosition.left, ElemPlace.rcNormalPosition.top)) &&
			SelRect.PtInRect(CPoint(ElemPlace.rcNormalPosition.right, ElemPlace.rcNormalPosition.bottom))) {
			if (ArchMode) {
				if (!pDoc->Elements[n]->get_bArchSelected()) {
					pDoc->Elements[n]->put_bArchSelected(TRUE);
					::InvalidateRect(hWnd, NULL, FALSE);
				}
			}
			else {
				if (!pDoc->Elements[n]->get_bConstrSelected()) {
					pDoc->Elements[n]->put_bConstrSelected(TRUE);
					::InvalidateRect(hWnd, NULL, FALSE);
				}
			}
			SelectedCount++;
		}
		else {
			if (ArchMode) {
				if (pDoc->Elements[n]->get_bArchSelected()) {
					pDoc->Elements[n]->put_bArchSelected(FALSE);
					::InvalidateRect(hWnd, NULL, FALSE);
				}
			}
			else {
				if (pDoc->Elements[n]->get_bConstrSelected()) {
					pDoc->Elements[n]->put_bConstrSelected(FALSE);
					::InvalidateRect(hWnd, NULL, FALSE);
				}
			}
		}
	}
	MoveMode = FALSE;
}

LPARAM CArchView::OnAddElementByName(WPARAM wParam, LPARAM lParam)
{
	pDoc->AddElement((LPCTSTR)wParam, (LPCTSTR)lParam, TRUE);
	return 0;
}

void CArchView::FindIntersections(CElement* pElement)
{
	CRect IntRect;
	if (!(pElement->get_nType()&ET_ARCH)) return;

	//Находим один ближайший элемент
	CPoint MinDist(10, 10);
	CElement* pNearestEl = NULL;
	WINDOWPLACEMENT Pls1, Pls2;
	Pls1.length = sizeof(Pls1);
	Pls2.length = sizeof(Pls2);
	::GetWindowPlacement((HWND)pElement->get_hArchWnd(), &Pls1);
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if (!(pDoc->Elements[n]->get_nType()&ET_ARCH)) continue;
		if (pDoc->Elements[n] == pElement) continue;

		::GetWindowPlacement((HWND)pDoc->Elements[n]->get_hArchWnd(), &Pls2);
		if (IntRect.IntersectRect(&Pls1.rcNormalPosition, &Pls2.rcNormalPosition)) {
			CPoint TempDist = GetMinDist(pDoc->Elements[n], pElement);
			if ((abs(MinDist.x) >= abs(TempDist.x)) && (abs(MinDist.y) >= abs(TempDist.y))) {
				MinDist = TempDist;
				pNearestEl = pDoc->Elements[n];
			}
		}
	}

	if ((abs(MinDist.x) > 3) || (abs(MinDist.y) > 3)) return;

	//Пододвигаем элемент так, чтобы соединить его с ближайшим элементом
	if ((abs(MinDist.x) < 3) && (abs(MinDist.y) < 3)) {
		WINDOWPLACEMENT Pls;
		Pls.length = sizeof(Pls);
		::GetWindowPlacement((HWND)pElement->get_hArchWnd(), &Pls);
		CRect MovedRect(Pls.rcNormalPosition);
		MovedRect.OffsetRect(-MinDist.x, -MinDist.y);
		::MoveWindow((HWND)pElement->get_hArchWnd(),
			MovedRect.left, MovedRect.top,
			MovedRect.Width(), MovedRect.Height(), TRUE);
	}

	//Подсоединяем все совпавшие выводы
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if (pDoc->Elements[n] == pElement) continue;

		::GetWindowPlacement((HWND)pDoc->Elements[n]->get_hArchWnd(), &Pls2);
		if (IntRect.IntersectRect(&Pls1.rcNormalPosition, &Pls2.rcNormalPosition)) {
			ConnectElements(pElement, pDoc->Elements[n]);
		}
	}
}

CPoint CArchView::GetMinDist(CElement* pFixedElement, CElement* pMovedElement)
{
	CPoint Res(10, 10);

	if (pMovedElement->get_nPointCount() <= 0) return Res;
	if (pFixedElement->get_nPointCount() <= 0) return Res;

	WINDOWPLACEMENT Pls;
	Pls.length = sizeof(Pls);
	::GetWindowPlacement((HWND)pMovedElement->get_hArchWnd(), &Pls);
	CRect MovedRect(Pls.rcNormalPosition);
	::GetWindowPlacement((HWND)pFixedElement->get_hArchWnd(), &Pls);
	CRect FixedRect(Pls.rcNormalPosition);
	//Перебираем точки фиксированного
	DWORD FixPntCnt = pFixedElement->get_nPointCount();
	for (DWORD n = 0; n < FixPntCnt; n++) {
		DWORD Pnt = pFixedElement->GetPointPos(n);
		CPoint FixPnt(LOWORD(Pnt), HIWORD(Pnt));
		//Перебор точек двигаемого
		int MovPntCnt = pMovedElement->get_nPointCount();
		for (int m = 0; m < MovPntCnt; m++) {
			//Проверим типы точек
			if ((pMovedElement->GetPinType(m) == pFixedElement->GetPinType(n)) &&
				(pMovedElement->GetPinType(m) != (PT_INPUT | PT_OUTPUT))) continue;

			Pnt = pMovedElement->GetPointPos(m);
			CPoint MovPnt(LOWORD(Pnt), HIWORD(Pnt));
			CPoint TempPnt;
			TempPnt.x = MovedRect.left + MovPnt.x - FixedRect.left - FixPnt.x;
			TempPnt.y = MovedRect.top + MovPnt.y - FixedRect.top - FixPnt.y;
			if ((abs(Res.x) >= abs(TempPnt.x)) && (abs(Res.y) >= abs(TempPnt.y))) Res = TempPnt;
		}
	}

	return Res;
}

BOOL CArchView::ConnectElements(CElement* pMovedElement, CElement* pFixedElement)
{
	if (pMovedElement->get_nPointCount() <= 0) return FALSE;
	if (pFixedElement->get_nPointCount() <= 0) return FALSE;

	//Подсоединяем элемент
	int DistX, DistY;
	WINDOWPLACEMENT Pls;
	Pls.length = sizeof(Pls);
	::GetWindowPlacement((HWND)pMovedElement->get_hArchWnd(), &Pls);
	CRect MovedRect(Pls.rcNormalPosition);
	::GetWindowPlacement((HWND)pFixedElement->get_hArchWnd(), &Pls);
	CRect FixedRect(Pls.rcNormalPosition);
	int FixPntCnt = pFixedElement->get_nPointCount();
	for (int n = 0; n < FixPntCnt; n++) { //Перебор точек фиксированного
		DWORD Pnt = pFixedElement->GetPointPos(n);
		CPoint FixPnt(LOWORD(Pnt), HIWORD(Pnt));
		//Перебор точек двигаемого
		int MovPntCnt = pMovedElement->get_nPointCount();
		for (int m = 0; m < MovPntCnt; m++) {
			//Проверим типы точек
			if ((pMovedElement->GetPinType(m) == pFixedElement->GetPinType(n)) &&
				(pMovedElement->GetPinType(m) != (PT_INPUT | PT_OUTPUT))) continue;

			DWORD Pnt = pMovedElement->GetPointPos(m);
			CPoint MovPnt(LOWORD(Pnt), HIWORD(Pnt));
			DistX = MovedRect.left + MovPnt.x - FixedRect.left - FixPnt.x;
			DistY = MovedRect.top + MovPnt.y - FixedRect.top - FixPnt.y;
			if ((DistX == 0) && (DistY == 0)) {
				//Находим индексы обоих элементов в массиве
				int FixedIndex = -1, MovedIndex = -1;
				for (size_t i = 0; i < pDoc->Elements.size(); i++) {
					if (pDoc->Elements[i] == NULL) continue;
					if (pDoc->Elements[i] == pFixedElement) FixedIndex = i;
					if (pDoc->Elements[i] == pMovedElement) MovedIndex = i;
				}
				//Проверим не соединены ли они уже и соединим при необходимости
				ConPoint CP;
				BOOL Found;
				POSITION Pos;

				CP.pElement = pFixedElement;
				CP.PinNumber = n;
				Found = FALSE;
				Pos = ConData[MovedIndex][m].GetHeadPosition();
				while (Pos) {
					ConPoint CPLst = ConData[MovedIndex][m].GetNext(Pos);
					if (memcmp(&CPLst, &CP, sizeof(ConPoint)) == 0) { Found = TRUE; break; }
				}
				if (!Found) ConData[MovedIndex][m].AddTail(CP);
				pMovedElement->ConnectPin(m, TRUE);

				CP.pElement = pMovedElement;
				CP.PinNumber = m;
				Found = FALSE;
				Pos = ConData[FixedIndex][n].GetHeadPosition();
				while (Pos) {
					ConPoint CPLst = ConData[FixedIndex][n].GetNext(Pos);
					if (memcmp(&CPLst, &CP, sizeof(ConPoint)) == 0) { Found = TRUE; break; }
				}
				if (!Found) ConData[FixedIndex][n].AddTail(CP);
				pFixedElement->ConnectPin(n, TRUE);
				break;
			}
		}
	}
	::InvalidateRect((HWND)pFixedElement->get_hArchWnd(), NULL, TRUE);
	::InvalidateRect((HWND)pMovedElement->get_hArchWnd(), NULL, TRUE);

	return TRUE;
}

BOOL CALLBACK EnumChildProc(HWND hwnd, LPARAM lParam)
{
	if (!IsWindowEnabled(hwnd)) return TRUE;

	CDC* pDC = (CDC*)lParam;

	CDC DC;
	CBitmap Bmp;
	WINDOWPLACEMENT Pls;
	Pls.length = sizeof(Pls);
	::GetWindowPlacement(hwnd, &Pls);
	CRect ElemRect(Pls.rcNormalPosition);

	DC.CreateCompatibleDC(pDC);
	Bmp.CreateCompatibleBitmap(pDC, ElemRect.Width(), ElemRect.Height());
	DC.SelectObject(&Bmp);
	::SendMessage(hwnd, WM_PRINT, (WPARAM)DC.m_hDC, 0);
	::BitBlt(pDC->m_hDC, ElemRect.left, ElemRect.top, ElemRect.Width(), ElemRect.Height(),
		DC.m_hDC, 0, 0, SRCCOPY);

	return TRUE;
}

void CArchView::OnPrint(CDC* pDC, CPrintInfo* pInfo)
{
	pDC->SetMapMode(MM_ISOTROPIC);
	pDC->SetWindowExt(72, 72);
	pDC->SetViewportExt(pDC->GetDeviceCaps(LOGPIXELSX),
		pDC->GetDeviceCaps(LOGPIXELSY));
	EnumChildWindows(m_hWnd, EnumChildProc, (LPARAM)pDC);
	pDC->SetWindowOrg(0, 0);
	pDC->SetWindowExt(1, 1);
	pDC->SetViewportExt(1, 1);

	CScrollView::OnPrint(pDC, pInfo);
}

void CArchView::OnDraw(CDC* pDC)
{
}

void CArchView::OnPinStateChanged(DWORD PinState, int hElement)
{
	//1. Перебираем все выводы элемента
	//2. Перебираем все входы элементов, подключенных к текущему выводу
	//3. Ищем элемент в кэше, и если его там нет, заносим его туда
	//4. Рассчитываем новое состояние элемента в кэше
	//5. Перебираем все элементы кэша и устанавливаем состояние реальных элементов

	if (theApp.pDebugArchDoc == NULL) return;

	CElement* pElement = pDoc->Elements[(DWORD)hElement];
	PointList* pConData = ConData[(DWORD)hElement];

	int PointCount = pElement->get_nPointCount();

	struct _ElData {
		CElement* pElement;
		DWORD PinState;
	}ElData[MAX_CONNECT_POINT * 4];
	int CachedCount = 0;

	for (int n = 0; n < PointCount; n++) {
		POSITION Pos = pConData[n].GetHeadPosition();
		while (Pos) {
			//Получим данные о выводе подключённого элемента
			ConPoint Point = pConData[n].GetNext(Pos);
			//Нас интересуют только входы
			if (!(Point.pElement->GetPinType(Point.PinNumber)&PT_INPUT)) continue;

			BOOL Found = FALSE;
			int i = 0;
			for (i = 0; i < CachedCount; i++) {
				if (ElData[i].pElement == Point.pElement) {
					Found = TRUE;
					break;
				}
			}
			if (!Found) {
				i = CachedCount;
				ElData[i].pElement = Point.pElement;
				ElData[i].PinState = Point.pElement->GetPinState();
				CachedCount++;
			}

			DWORD NewState = ElData[i].PinState;

			NewState &= ~(1 << Point.PinNumber);
			NewState |= PinState&(1 << n) ? (1 << Point.PinNumber) : 0;
			ElData[i].PinState = NewState;
		}
	}

	for (int i = 0; i < CachedCount; i++) {
		ElData[i].pElement->SetPinState(ElData[i].PinState);
	}
}

DWORD CArchView::GetPinState(int ElementIndex)
{
	if (theApp.pDebugArchDoc == NULL) return 0;

	CElement* pElement = pDoc->Elements[ElementIndex];
	PointList* pConData = ConData[ElementIndex];

	int PointCount = pElement->get_nPointCount();

	struct _ElData {
		CElement* pElement;  //Указатель на подключённый элемент
		DWORD PinState;        //Состояние выводов подключённого элемента
	}ElData[MAX_CONNECT_POINT * 4];
	int CachedCount = 0;

	//Переберём все контакты текущего элемента
	//И запомним подключенные элементы и состояние их выводов
	DWORD NewState = 0;
	for (int n = 0; n < PointCount; n++) {
		NewState &= ~(1 << n);
		POSITION Pos = pConData[n].GetHeadPosition();
		//Переберём все контакты, подключенные к n-му контакту тек. элемента
		while (Pos) {
			//Получим данные о контакте подключённого элемента
			ConPoint Point = pConData[n].GetNext(Pos);

			BOOL Found = FALSE;
			int i = 0;
			for (i = 0; i < CachedCount; i++) {
				if (ElData[i].pElement == Point.pElement) {
					Found = TRUE;
					break;
				}
			}
			if (!Found) {
				i = CachedCount;
				ElData[i].pElement = Point.pElement;
				ElData[i].PinState = Point.pElement->GetPinState();
				CachedCount++;
			}

			if ((ElData[i].PinState >> Point.PinNumber) & 1)
				NewState |= (1 << n);
		}
	}

	return NewState;
}

void CArchView::DeconnectElement(int ElemIndex)
{
	PointList* pSelPoint = ConData[ElemIndex];
	//Перебираем все выводы заданного элемента
	int ElPntCnt = pDoc->Elements[ElemIndex]->get_nPointCount();
	for (int i = 0; i < ElPntCnt; i++) {
		if (pSelPoint[i].IsEmpty()) continue;

		//Теперь переберём все связи i-й точки заданного элемента
		//и отключим подключённые к ней элементы
		POSITION Pos = pSelPoint[i].GetHeadPosition();
		while (Pos) {
			//Отключим и перерисуем
			ConPoint& CP = pSelPoint[i].GetNext(Pos);

			//Находим индекс подсоединённого элемента
			BOOL Found = FALSE;
			size_t m = 0;
			for (m = 0; m < pDoc->Elements.size(); m++) {
				if (CP.pElement == pDoc->Elements[m]) { Found = TRUE; break; }
			}
			if (!Found) MessageBox("Ошибка отсоединения элемента", "Ошибка", MB_OK | MB_ICONSTOP);
			//Отключаем от соответствующего вывода m-го элемента текущий элемент
			//for(int j=0; j<pDoc->Element[m]->nPointCount; j++) {
			if (!ConData[m][CP.PinNumber].IsEmpty()) {
				POSITION Pos2 = ConData[m][CP.PinNumber].GetHeadPosition();
				while (Pos2) {
					POSITION OldPos = Pos2;
					ConPoint &CP2 = ConData[m][CP.PinNumber].GetNext(Pos2);
					if (CP2.pElement == pDoc->Elements[ElemIndex]) {
						ConData[m][CP.PinNumber].RemoveAt(OldPos);
						pDoc->Elements[m]->ConnectPin(CP.PinNumber, FALSE);
					}
				}
			}
			::InvalidateRect((HWND)pDoc->Elements[m]->get_hArchWnd(), NULL, TRUE);
		}
		pSelPoint[i].RemoveAll();
		//Все подключенные элементы отключены, отключаем заданный
		pDoc->Elements[ElemIndex]->ConnectPin(i, FALSE);
	}
	//Теперь перерисуем заданный элемент
	HWND hWnd = (HWND)pDoc->Elements[ElemIndex]->get_hArchWnd();
	if (hWnd) ::InvalidateRect((HWND)pDoc->Elements[ElemIndex]->get_hArchWnd(), NULL, TRUE);
}

BOOL CArchView::MoveSelected(int ShiftX, int ShiftY)
{
	BOOL Moved = FALSE;

	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if (ArchMode ? pDoc->Elements[n]->get_bArchSelected() : pDoc->Elements[n]->get_bConstrSelected()) {
			WINDOWPLACEMENT Pls;
			Pls.length = sizeof(Pls);
			HWND hWnd = (HWND)pDoc->Elements[n]->get_hArchWnd();
			::GetWindowPlacement((HWND)(ArchMode ? pDoc->Elements[n]->get_hArchWnd() :
				pDoc->Elements[n]->get_hConstrWnd()), &Pls);
			CRect CurRect(Pls.rcNormalPosition);
			CurRect.OffsetRect(GetScrollPos(SB_HORZ), GetScrollPos(SB_VERT));
			if ((ShiftX != 0) || (ShiftY != 0)) {
				CurRect.left += ShiftX; CurRect.right += ShiftX;
				CurRect.top += ShiftY; CurRect.bottom += ShiftY;

				if (CurRect.top < 0) {
					CurRect.bottom -= CurRect.top;
					CurRect.top = 0;
				}
				if (CurRect.left < 0) {
					CurRect.right -= CurRect.left;
					CurRect.left = 0;
				}

				if (CurRect.bottom > VIEW_HEIGHT - 1) {
					CurRect.top -= CurRect.bottom - VIEW_HEIGHT + 1;
					CurRect.bottom = VIEW_HEIGHT - 1;
				}
				if (CurRect.right > VIEW_WIDTH - 1) {
					CurRect.left -= CurRect.right - VIEW_WIDTH + 1;
					CurRect.right = VIEW_WIDTH - 1;
				}

				int dy = GetScrollPos(SB_VERT);
				int dx = GetScrollPos(SB_HORZ);
				if (ArchMode) {
					HWND hWnd = (HWND)pDoc->Elements[n]->get_hArchWnd();
					if (hWnd) ::MoveWindow(hWnd,
						CurRect.left - dx, CurRect.top - dy, CurRect.Width(), CurRect.Height(),
						TRUE);
				}
				else {
					HWND hWnd = (HWND)pDoc->Elements[n]->get_hConstrWnd();
					if (hWnd) ::MoveWindow(hWnd,
						CurRect.left - dx, CurRect.top - dy, CurRect.Width(), CurRect.Height(),
						TRUE);
				}
				Moved = TRUE;
			}
		}
	}
	return Moved;
}

void CArchView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags)
{
	BOOL Deconnect = ((nFlags & 0x4000) == 0) && ArchMode;

	switch (nChar) {
	case VK_LEFT:
		if (Deconnect) DeconnectSelected();
		MoveSelected(-1, 0);
		break;
	case VK_RIGHT:
		if (Deconnect) DeconnectSelected();
		MoveSelected(1, 0);
		break;
	case VK_UP:
		if (Deconnect) DeconnectSelected();
		MoveSelected(0, -1);
		break;
	case VK_DOWN:
		if (Deconnect) DeconnectSelected();
		MoveSelected(0, 1);
		break;
	}

	CScrollView::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CArchView::OnKeyUp(UINT nChar, UINT nRepCnt, UINT nFlags)
{
	switch (nChar) {
	case VK_LEFT:
		ConnectSelected();
		break;
	case VK_RIGHT:
		ConnectSelected();
		break;
	case VK_UP:
		ConnectSelected();
		break;
	case VK_DOWN:
		ConnectSelected();
		break;
	}

	CScrollView::OnKeyUp(nChar, nRepCnt, nFlags);
}

void CArchView::DeconnectSelected()
{
	pDoc->SetModifiedFlag();
	for (size_t n = 0; n < pDoc->Elements.size(); n++) {
		if (pDoc->Elements[n] == NULL) continue;
		if (!pDoc->Elements[n]->get_bArchSelected()) continue;
		DeconnectElement(n);
	}
}

void CArchView::ConnectSelected()
{
	if (ArchMode) {
		for (size_t i = 0; i < pDoc->Elements.size(); i++) {
			if (pDoc->Elements[i] == NULL) continue;
			if ((!CopyMode&&pDoc->Elements[i]->get_bArchSelected()) || CopyMode)
				FindIntersections(pDoc->Elements[i]);
		}
	}
}

void CArchView::redrawChangedElements(CArchView* pArchView) {
	int frames = 0;
	std::chrono::time_point<std::chrono::steady_clock> time_start = std::chrono::steady_clock::now();
	int64_t freqPerfCounter;
	LARGE_INTEGER li;
	QueryPerformanceFrequency(&li);
	freqPerfCounter = li.QuadPart;
	const int64_t countFrame = freqPerfCounter/100;

	while (!pArchView->ConfigMode) {
		QueryPerformanceCounter(&li);
		int64_t countFrameStart = li.QuadPart;

		for (CElement* pElement : pArchView->pDoc->Elements) {
			if (pElement == nullptr) continue;

			if (pArchView->ArchMode) {
				if (pElement->IsArchRedrawRequired()) {
					pElement->RedrawArchWnd(theApp.pEmData->Ticks);
				}
			}
			else {
				if (pElement->IsConstrRedrawRequired()) {
					pElement->RedrawConstrWnd(theApp.pEmData->Ticks);
				}
			}
		}

		frames++;
		std::chrono::time_point<std::chrono::steady_clock> now = std::chrono::steady_clock::now();
		int64_t seconds = std::chrono::duration_cast<std::chrono::seconds>(now - time_start).count();
		if (seconds > 0) {
			pArchView->fps = frames;
			frames = 0;
			time_start = now;
		}

		int64_t countFrameEnd = countFrameStart + countFrame;
		while (true) {
			QueryPerformanceCounter(&li);
			if (li.QuadPart >= countFrameEnd) break;
		}
	}
}

void CArchView::OnTimer(UINT nIDEvent)
{
	int Sec = (int)(theApp.pEmData->Ticks / theApp.Data.TaktFreq);
	int Min = Sec / 60;
	int Hour = Min / 60;
	Sec = Sec % 60;
	Min = Min % 60;
	std::string sCounter = std::format("Время: {:02}:{:02}:{:02}", Hour, Min, Sec);
	m_StatusBar.SetPaneText(2, sCounter.c_str());

	std::string sFps = std::format("К/С: {}", fps);
	m_StatusBar.SetPaneText(1, sFps.c_str());
}

BOOL CArchView::CreateElementButtons()
{
	CToolBarCtrl &TBCtrl = ToolBar.GetToolBarCtrl();

	CString LibGUID, ClsGUID;
	LONG Index = 0, ElIndex = 0;
	for (const auto pair : theApp.ElementLibraries) {
		CElemLib *pElemLib = pair.second;

		if (pElemLib->getElementsCount() == 0) { Index++; continue; }
		for (DWORD n = 0; n < pElemLib->getElementsCount(); n++) {
			CString ElemName = pElemLib->GetElementName(n);
			BtnBmp[ElIndex] = CBitmap::FromHandle(pElemLib->GetElementIcon(n));

			TBBUTTON Btn = { TBCtrl.AddBitmap(1,BtnBmp[ElIndex]),ID_ADD_ELEMENT0 + ElIndex,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0 };
			TBCtrl.InsertButton(0, &Btn);
			ElIndex++;
		}

		CString SubMenuName = pElemLib->getLibraryName();

		Index++;
	}

	return TRUE;
}
