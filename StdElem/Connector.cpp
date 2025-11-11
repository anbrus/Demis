#include "stdafx.h"
#include "Connector.h"
#include "StdElemApp.h"

#include <VersionHelpers.h>
#include <algorithm>
#include <format>

#undef min
#undef max

Connector::Connector(BOOL ArchMode, int id) : CElementBase(ArchMode, id) {
	IdIndex = 13;
	PointCount = 2;

	ConPoint[0].x = 2; ConPoint[0].y = 2;
	ConPin[0] = FALSE; PinType[0] = PT_INPUT;

	ConPoint[1].x = 20 - 3; ConPoint[1].y = 2;
	ConPin[1] = FALSE; PinType[1] = PT_OUTPUT;

	handleLocations.push_back(ConPoint[0]);
	handleLocations.push_back(CPoint((ConPoint[0].x + ConPoint[1].x)/2, (ConPoint[0].y + ConPoint[1].y) / 2));
	handleLocations.push_back(ConPoint[1]);

	pArchElemWnd = new ConnectorArchWnd(this);

	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	PopupMenu.LoadMenu(IDR_CONNECTOR_MENU);
}

Connector::~Connector() {

}

void Connector::SetPinState(DWORD NewState) {
	pinState = NewState & 1 | (NewState & 1) << 1;
	theApp.pHostInterface->OnPinStateChanged(pinState, id);
}

DWORD Connector::GetPinState() {
	return pinState;
}

void Connector::UpdateTipText() {
	TipText = "Соединение";
}

BOOL Connector::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) {
	return TRUE;
}

BOOL Connector::Show(HWND hArchParentWnd, HWND hConstrParentWnd) {
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS, ::LoadCursor(NULL, IDC_ARROW));
	DWORD styleEx = 0; // IsWindows8OrGreater() ? WS_EX_LAYERED : 0;
	pArchElemWnd.value()->CreateEx(styleEx, ClassName, "Соединение", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
		CRect(0, 0, pArchElemWnd.value()->Size.cx, pArchElemWnd.value()->Size.cy), pArchParentWnd, 0);

	//pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	reinterpret_cast<ConnectorArchWnd*>(pArchElemWnd.value())->updateSize();
	UpdateTipText();

	return TRUE;
}

BOOL Connector::Save(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	int32_t count = handleLocations.size();
	File.Write(&count, sizeof(count));

	for (const CPoint point : handleLocations) {
		int32_t x = point.x;
		int32_t y = point.y;
		File.Write(&x, sizeof(x));
		File.Write(&y, sizeof(y));
	}

	return TRUE;
}

BOOL Connector::Load(HANDLE hFile) {
	CFile File(hFile);

	int32_t Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Соединитель: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	int32_t count;
	File.Read(&count, sizeof(count));

	handleLocations.clear();

	for (int n = 0; n < count; n++) {
		int32_t x;
		int32_t y;
		File.Read(&x, sizeof(x));
		File.Read(&y, sizeof(y));
		handleLocations.push_back(CPoint(x, y));
	}

	ConPoint[0] = handleLocations[0];
	ConPoint[1] = handleLocations[handleLocations.size() - 1];

	return TRUE;
}


ConnectorArchWnd::ConnectorArchWnd(CElementBase* pElement) : CElementWnd(pElement) {
	Size.cx = 20;
	Size.cy = 10;
}

ConnectorArchWnd::~ConnectorArchWnd() {

}

BEGIN_MESSAGE_MAP(ConnectorArchWnd, CElementWnd)
	ON_WM_CREATE()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_COMMAND(ID_SETTINGS, OnSettings)
END_MESSAGE_MAP()

void ConnectorArchWnd::OnSettings()
{
	reinterpret_cast<Connector*>(pElement)->OnSettings();
}


void ConnectorArchWnd::updateSize() {
	Connector* pConnector = reinterpret_cast<Connector*>(pElement);

	WINDOWPLACEMENT pls;
	GetWindowPlacement(&pls);

	const auto iterMinX = std::min_element(pConnector->handleLocations.cbegin(), pConnector->handleLocations.cend(),
		[](const CPoint& a, const CPoint& b) { return a.x < b.x; }
	);
	const auto iterMaxX = std::max_element(pConnector->handleLocations.cbegin(), pConnector->handleLocations.cend(),
		[](const CPoint& a, const CPoint& b) { return a.x < b.x; }
	);
	const auto iterMinY = std::min_element(pConnector->handleLocations.cbegin(), pConnector->handleLocations.cend(),
		[](const CPoint& a, const CPoint& b) { return a.y < b.y; }
	);
	const auto iterMaxY = std::max_element(pConnector->handleLocations.cbegin(), pConnector->handleLocations.cend(),
		[](const CPoint& a, const CPoint& b) { return a.y < b.y; }
	);
	int dx = 2 - iterMinX->x;
	std::for_each(pConnector->handleLocations.begin(), pConnector->handleLocations.end(), [dx](CPoint& p) { p.x += dx; });
	int dy = 2 - iterMinY->y;
	std::for_each(pConnector->handleLocations.begin(), pConnector->handleLocations.end(), [dy](CPoint& p) { p.y += dy; });
	Size.cx = iterMaxX->x + 3;
	Size.cy = iterMaxY->y + 3;

	int x = pls.rcNormalPosition.left - dx;
	int y = pls.rcNormalPosition.top - dy;

	pRgn = std::make_shared<CRgn>();
	pRgn->CreateRectRgn(pConnector->handleLocations[0].x - 2, pConnector->handleLocations[0].y - 2, pConnector->handleLocations[0].x + 3, pConnector->handleLocations[0].y + 3);
	for (size_t n = 1; n < pConnector->handleLocations.size(); n++) {
		const CPoint& pointPrev = pConnector->handleLocations[n - 1];
		const CPoint& pointCur = pConnector->handleLocations[n];

		if (n % 2 == 0) {
			//    |
			//    |
			//    |
			//     ---*
			CRgn rgn1;
			rgn1.CreateRectRgn(pointPrev.x - 2, pointPrev.y, pointPrev.x + 3, pointCur.y + 3);
			CRgn rgn2;
			rgn2.CreateRectRgn(pointPrev.x - 2, pointCur.y - 2, pointCur.x, pointCur.y + 3);
			pRgn->CombineRgn(pRgn.get(), &rgn1, RGN_OR);
			pRgn->CombineRgn(pRgn.get(), &rgn2, RGN_OR);
		}
		else {
			// ___
			//    |
			//    |
			//    *
			CRgn rgn1;
			rgn1.CreateRectRgn(pointPrev.x, pointPrev.y - 2, pointCur.x + 3, pointPrev.y + 3);
			CRgn rgn2;
			rgn2.CreateRectRgn(pointCur.x - 2, pointPrev.y - 2, pointCur.x + 3, pointCur.y);
			pRgn->CombineRgn(pRgn.get(), &rgn1, RGN_OR);
			pRgn->CombineRgn(pRgn.get(), &rgn2, RGN_OR);
		}
	}
	CRgn rgn;
	const CPoint& pointLast = pConnector->handleLocations[pConnector->handleLocations.size() - 1];
	rgn.CreateRectRgn(pointLast.x - 2, pointLast.y - 2, pointLast.x + 3, pointLast.y + 3);
	pRgn->CombineRgn(pRgn.get(), &rgn, RGN_OR);

	SetWindowRgn(*pRgn.get(), FALSE);
	MoveWindow(x, y, Size.cx, Size.cy, FALSE);
	CRect rectUpdate = pls.rcNormalPosition;
	rectUpdate.left = std::min(static_cast<int>(rectUpdate.left), x);
	rectUpdate.top = std::min(static_cast<int>(rectUpdate.top), y);
	rectUpdate.right = std::max(rectUpdate.right, x + Size.cx);
	rectUpdate.bottom = std::max(rectUpdate.bottom, y + Size.cy);
	GetParent()->RedrawWindow(&rectUpdate, nullptr, RDW_UPDATENOW | RDW_ERASE | RDW_INVALIDATE| RDW_ALLCHILDREN);
}

void ConnectorArchWnd::Draw(CDC* pDC) {
	Connector* pConnector = reinterpret_cast<Connector*>(pElement);

	CDC dcMem;
	dcMem.CreateCompatibleDC(pDC);
	CBitmap bmp;
	bmp.CreateCompatibleBitmap(pDC, Size.cx, Size.cy);
	HGDIOBJ hBmpOld = dcMem.SelectObject(bmp);
	DeleteObject(hBmpOld);
	dcMem.PatBlt(0, 0, Size.cx, Size.cy, WHITENESS);

	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	CGdiObject* pOldPen = dcMem.SelectObject(&BluePen);
	CBrush brush(RGB(254, 254, 254));
	CGdiObject* pOldBrush = dcMem.SelectObject(&brush);
	for (int n = 0; n < pElement->PointCount; n++) {
		//Рисуем крестик
		if (!pElement->ConPin[n]) {
			dcMem.PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, RGB(254, 254, 254));

			dcMem.SelectObject(&BluePen);
			dcMem.MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2);
			dcMem.LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y + 3);
			dcMem.MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y + 2);
			dcMem.LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y - 3);
		}
	}

	COLORREF c;
	if (pElement->ArchSelected) {
		dcMem.SelectObject(&theApp.SelectPen);
		c = theApp.SelectColor;
	}
	else {
		dcMem.SelectObject(&theApp.DrawPen);
		c = theApp.DrawColor;
	}

	//Рисуем палочку
	if (pElement->ConPin[0]) {
		dcMem.PatBlt(pElement->ConPoint[0].x - 2, pElement->ConPoint[0].y - 2, 5, 5, RGB(255, 255, 255));
		dcMem.MoveTo(pElement->ConPoint[0].x, pElement->ConPoint[0].y);
		dcMem.LineTo(-1, pElement->ConPoint[0].y);
	}
	if (pElement->ConPin[1]) {
		dcMem.PatBlt(pElement->ConPoint[1].x - 2, pElement->ConPoint[1].y - 2, 5, 5, RGB(255, 255, 255));
		dcMem.MoveTo(pElement->ConPoint[1].x, pElement->ConPoint[1].y);
		if(pConnector->handleLocations.size() % 2 == 0) {
			// Дорисовать вертикальный отрезок
			if(pConnector->handleLocations[pConnector->handleLocations.size() - 2].y > pElement->ConPoint[1].y)
				// Вверх
				dcMem.LineTo(pElement->ConPoint[1].x, pElement->ConPoint[1].y - 3);
			else
				//Вниз
				dcMem.LineTo(pElement->ConPoint[1].x, pElement->ConPoint[1].y + 3);
		}
		else {
			// Дорисовать горизонтальный отрезок
			dcMem.LineTo(pElement->ConPoint[1].x+3, pElement->ConPoint[1].y);
		}
	}

	dcMem.MoveTo(pConnector->handleLocations[0]);
	for (size_t n = 1; n < pConnector->handleLocations.size(); n++) {
		bool isConPoint = n == 0 || n == pConnector->handleLocations.size() - 1;

		const CPoint& locPrev = pConnector->handleLocations[n - 1];
		const CPoint& locCur = pConnector->handleLocations[n];
		bool isHandleVisible = pConnector->ArchSelected && !isConPoint && abs(locCur.y - locPrev.y) > 3;
		if (n % 2 == 1) {
			// ___
			//    |
			//    |
			//    *
			dcMem.LineTo(locCur.x, locPrev.y);
			if (isHandleVisible) {
				dcMem.LineTo(locCur.x, locCur.y - 2);
				dcMem.MoveTo(locCur.x, locCur.y + 2);
			}
			else
				dcMem.LineTo(locCur.x, locCur.y);
		}
		else {
			//    |
			//    |
			//    |
			//     ---*
			dcMem.LineTo(locPrev.x, locCur.y);
			if (isHandleVisible) {
				dcMem.LineTo(locCur.x - 2, locCur.y);
				dcMem.MoveTo(locCur.x + 2, locCur.y);
			}
			else
				dcMem.LineTo(locCur.x, locCur.y);
		}
		if (isHandleVisible) {
			if (idxHandleCaptured == n)
				dcMem.FillSolidRect(locCur.x - 2, locCur.y - 2, 5, 5, c);
			else
				dcMem.FillSolidRect(locCur.x - 2, locCur.y - 2, 5, 5, c);
				//dcMem.Rectangle(locCur.x - 2, locCur.y - 2, locCur.x + 3, locCur.y + 3);
		}
	}

	dcMem.SelectObject(pOldBrush);
	dcMem.SelectObject(pOldPen);

	pDC->BitBlt(0, 0, Size.cx, Size.cy, &dcMem, 0, 0, SRCCOPY);
	dcMem.DeleteDC();
	DeleteObject(&bmp);
}

void ConnectorArchWnd::Redraw(int64_t ticks) {

}

int ConnectorArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	return 0;
}

static void moveHandle(const CRect& rect, const CSize& sizeMax, std::vector<CPoint>& handleLocations, int idxHandle, CPoint point) {
	bool isConPoint = idxHandle == 0 || idxHandle == handleLocations.size() - 1;

	CPoint& pointHandle = handleLocations[idxHandle];
	long minX;
	if (idxHandle == 0) minX = -rect.left;
	else minX = handleLocations[idxHandle-1].x + 4 * idxHandle;
	long maxX;
	if (idxHandle == handleLocations.size() - 1) maxX = sizeMax.cx - 3;
	else maxX = handleLocations[idxHandle + 1].x - 4 * (handleLocations.size() - idxHandle - 1);
	long minY = -rect.top;
	long maxY = sizeMax.cy - 3;
	if (isConPoint) {
		pointHandle.x = std::min(maxX, std::max(minX, point.x));
		pointHandle.y = std::min(maxY, std::max(minY, point.y));
	}
	else if (idxHandle % 2 == 0) {
		pointHandle.y = std::min(maxY, std::max(minY, point.y));
	}
	else if (idxHandle % 2 == 1) {
		pointHandle.x = std::min(maxX, std::max(minX, point.x));
	}

	if (idxHandle % 2 == 0) {
		if (idxHandle > 1) {
			handleLocations[idxHandle - 1].y = (handleLocations[idxHandle].y + handleLocations[idxHandle - 2].y) / 2;
			if (point.x - handleLocations[idxHandle - 1].x < 3) {
				moveHandle(rect, sizeMax, handleLocations, idxHandle - 1, CPoint(point.x - 3, handleLocations[idxHandle - 1].y));
			}
		}
		if (idxHandle < static_cast<int>(handleLocations.size()) - 2) {
			handleLocations[idxHandle + 1].y = (handleLocations[idxHandle].y + handleLocations[idxHandle + 2].y) / 2;
			if (handleLocations[idxHandle + 1].x - point.x < 3) {
				moveHandle(rect, sizeMax, handleLocations, idxHandle + 1, CPoint(point.x + 3, handleLocations[idxHandle + 1].y));
			}
		}
	}
	else {
		if (idxHandle > 1) {
			handleLocations[idxHandle - 1].x = (handleLocations[idxHandle].x + handleLocations[idxHandle - 2].x) / 2;
		}
		if (idxHandle < static_cast<int>(handleLocations.size()) - 2) {
			handleLocations[idxHandle + 1].x = (handleLocations[idxHandle].x + handleLocations[idxHandle + 2].x) / 2;
		}
	}
}

void ConnectorArchWnd::OnLButtonDown(UINT nFlags, CPoint point) {
	Connector* pConnector = reinterpret_cast<Connector*>(pElement);

	if (pElement->ArchSelected) {
		for (size_t n = 0; n < pConnector->handleLocations.size(); n++) {
			const CPoint& pointHandle = pConnector->handleLocations[n];
			if (abs(point.x - pointHandle.x) <= 3 && abs(point.y - pointHandle.y) <= 3) {
				idxHandleCaptured = n;
				pointMouse = point;
				SetCapture();
				SetWindowPos(&wndTop, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
				return;
			}
		}
	}

	CElementWnd::OnLButtonDown(nFlags, point);
}

void ConnectorArchWnd::OnLButtonUp(UINT nFlags, CPoint point) {
	if (idxHandleCaptured >= 0) {
		Connector* pConnector = reinterpret_cast<Connector*>(pElement);

		WINDOWPLACEMENT pls;
		GetWindowPlacement(&pls);
		CRect rectParent;
		GetParent()->GetWindowRect(&rectParent);
		CSize sizeMax(
			rectParent.Width() - pls.rcNormalPosition.left - 20,
			rectParent.Height() - pls.rcNormalPosition.top - 20
		);

		std::pair<int, int> nearestConPair = { -1, -1 };
		if (idxHandleCaptured == 0) {
			nearestConPair = theApp.pHostInterface->GetNearestConPoint(pls.rcNormalPosition.left + point.x, pls.rcNormalPosition.top + point.y, PT_OUTPUT);
		}
		else if (idxHandleCaptured == pConnector->handleLocations.size() - 1) {
			nearestConPair = theApp.pHostInterface->GetNearestConPoint(pls.rcNormalPosition.left + point.x, pls.rcNormalPosition.top + point.y, PT_INPUT);
		}
		if (nearestConPair.first > 0 && nearestConPair.second > 0) {
			CPoint nearestConPoint = CPoint(nearestConPair.first-pls.rcNormalPosition.left, nearestConPair.second-pls.rcNormalPosition.top);
			moveHandle(pls.rcNormalPosition, sizeMax,  pConnector->handleLocations, idxHandleCaptured, nearestConPoint);
			updateSize();
			pConnector->ConPoint[0] = pConnector->handleLocations[0];
			pConnector->ConPoint[1] = pConnector->handleLocations[pConnector->handleLocations.size() - 1];
			GetParent()->SendMessage(WMU_ARCHELEM_CONNECT, 0, pConnector->id);
		}
		ReleaseCapture();
		idxHandleCaptured = -1;
		pointMouse = CPoint(-1, -1);
		Invalidate(FALSE);
		pConnector->ModifiedFlag = TRUE;
	}
	else {
		CElementWnd::OnLButtonUp(nFlags, point);
	}
}

void ConnectorArchWnd::OnMouseMove(UINT nFlags, CPoint point) {
	if (idxHandleCaptured < 0) {
		CElementWnd::OnMouseMove(nFlags, point);
		return;
	}
	if (pointMouse == point) return;
	pointMouse = point;

	Connector* pConnector = reinterpret_cast<Connector*>(pElement);

	WINDOWPLACEMENT pls;
	GetWindowPlacement(&pls);
	CRect rectParent;
	GetParent()->GetWindowRect(&rectParent);
	CSize sizeMax(
		rectParent.Width() - pls.rcNormalPosition.left-20,
		rectParent.Height() - pls.rcNormalPosition.top-20
	);

	moveHandle(pls.rcNormalPosition, sizeMax, pConnector->handleLocations, idxHandleCaptured, point);

	pConnector->ConPoint[0] = pConnector->handleLocations[0];
	pConnector->ConPoint[1] = pConnector->handleLocations[pConnector->handleLocations.size() - 1];

	updateSize();
}

void Connector::OnSettings() {
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	
	ConnectorDlg dlg;
	dlg.countLegs = handleLocations.size() - 1;
	if (dlg.DoModal() == IDOK) {
		size_t countHandle = dlg.countLegs + 1;
		WINDOWPLACEMENT pls;
		pArchElemWnd.value()->GetWindowPlacement(&pls);
		CRect rectParent;
		pArchElemWnd.value()->GetParent()->GetWindowRect(&rectParent);
		CSize sizeMax(
			rectParent.Width() - pls.rcNormalPosition.left - 20,
			rectParent.Height() - pls.rcNormalPosition.top - 20
		);

		if (countHandle < handleLocations.size()) {
			while (countHandle < handleLocations.size()) {
				handleLocations.erase(handleLocations.end() - 2, handleLocations.end() - 1);
				moveHandle(pls.rcNormalPosition, sizeMax, handleLocations, handleLocations.size() - 1, handleLocations[handleLocations.size() - 1]);
			}
		}
		else if (countHandle > handleLocations.size()) {
			int dx = (handleLocations[handleLocations.size() - 1].x - handleLocations[handleLocations.size() - 2].x) / (countHandle - handleLocations.size()) / 2;
			while (countHandle > handleLocations.size()) {
				CPoint loc = handleLocations [handleLocations.size() - 2];
				if (handleLocations.size() % 2 == 0) {
					// Добавляем вертикальную дугу
					loc.x += dx;
					loc.y = (handleLocations[handleLocations.size() - 1].y + loc.y) / 2;
				}else {
					// Добавляем горизонтальную дугу
					loc.x += dx;
				}
				handleLocations.insert(handleLocations.end() - 1, loc);
				moveHandle(pls.rcNormalPosition, rectParent.Size(), handleLocations, handleLocations.size() - 2, handleLocations[handleLocations.size() - 2]);
			}
		}
		ConnectorArchWnd* pWnd = reinterpret_cast<ConnectorArchWnd*>(pArchElemWnd.value());
		pWnd->updateSize();
		ConPoint[0] = handleLocations[0];
		ConPoint[1] = handleLocations[handleLocations.size() - 1];
		pArchElemWnd.value()->Invalidate(FALSE);

		ModifiedFlag = true;
	}
}

ConnectorDlg::ConnectorDlg(CWnd* pParent /*=NULL*/)
	: CDialog(ConnectorDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCLimitsDlg)
	//}}AFX_DATA_INIT
}


void ConnectorDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);

	int idxCountLegs = countLegs - 1;

	DDX_Radio(pDX, IDC_TYPE_1, idxCountLegs);

	if (pDX->m_bSaveAndValidate) {
		countLegs = idxCountLegs + 1;
	}
}


BEGIN_MESSAGE_MAP(ConnectorDlg, CDialog)
END_MESSAGE_MAP()
