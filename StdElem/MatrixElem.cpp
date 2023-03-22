// LedElement.cpp: implementation of the CMatrixElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "MatrixElem.h"

#include "StdElemApp.h"
#include "utils.h"


#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMatrixElement::CMatrixElement(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
{
	IdIndex = 10;
	MatrixSize.cx = 8; MatrixSize.cy = 8;
	memset(HighLighted, 0, sizeof(HighLighted));
	ActiveHigh = TRUE; ticksAfterLight = 0;

	CreateConPoints();

	pArchElemWnd = new CMatrixArchWnd(this);
	pConstrElemWnd = new CMatrixConstrWnd(this);

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_MATRIX_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
}

CMatrixElement::~CMatrixElement()
{
}

BOOL CMatrixElement::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Матричный индикатор: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	File.Read(&MatrixSize, sizeof(MatrixSize));
	File.Read(&ActiveHigh, 4);

	if (ActiveHigh) {
		PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
		PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
	}
	else {
		PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_UNCHECKED);
		PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_CHECKED);
	}

	CreateConPoints();
	reinterpret_cast<CMatrixArchWnd*>(pArchElemWnd)->Resize();
	reinterpret_cast<CMatrixConstrWnd*>(pConstrElemWnd)->Resize();

	return CElementBase::Load(hFile);
}

BOOL CMatrixElement::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&MatrixSize, sizeof(MatrixSize));
	File.Write(&ActiveHigh, 4);

	return CElementBase::Save(hFile);
}

BOOL CMatrixElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->Create(ClassName, "Матричный индикатор", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd->Create(ClassName, "Матричный индикатор", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd->Size.cx, pConstrElemWnd->Size.cy), pConstrParentWnd, 0);

	UpdateTipText();

	return TRUE;
}

BOOL CMatrixElement::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	memset(HighLighted, 0, sizeof(HighLighted));
	PinState = 0;
	this->pTickCounter = pTickCounter;
	ticksAfterLight = 20 * TaktFreq / 1000;
	if (!bEditMode) {
		if(pArchElemWnd->IsWindowEnabled())
			pArchElemWnd->SetRedraw(true);
		if(pConstrElemWnd->IsWindowEnabled())
			pConstrElemWnd->SetRedraw(true);
	}

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CMatrixArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CMatrixArchWnd, CElementWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_COMMAND(ID_MATRIX_SIZE, OnMatrixSize)
	ON_WM_CREATE()
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

void CMatrixArchWnd::Resize() {
	Size.cx = ((CMatrixElement*)pElement)->MatrixSize.cx * 15 + 26;
	Size.cy = ((CMatrixElement*)pElement)->MatrixSize.cy * 15 + 44;
}

CMatrixArchWnd::CMatrixArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Resize();
}

CMatrixArchWnd::~CMatrixArchWnd()
{

}

//////////////////////////////////////////////////////////////////////
// CMatrixConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CMatrixConstrWnd, CElementWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_COMMAND(ID_MATRIX_SIZE, OnMatrixSize)
	ON_WM_CREATE()
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

void CMatrixConstrWnd::Resize() {
	SqrSize = 7;
	Size.cx = ((CMatrixElement*)pElement)->MatrixSize.cx*SqrSize + 1;
	Size.cy = ((CMatrixElement*)pElement)->MatrixSize.cy*SqrSize + 1;
}

CMatrixConstrWnd::CMatrixConstrWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Resize();
}

CMatrixConstrWnd::~CMatrixConstrWnd()
{

}

void CMatrixElement::OnActiveHigh()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
	ActiveHigh = TRUE;
	ModifiedFlag = TRUE;
}

void CMatrixElement::OnActiveLow()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_CHECKED);
	ActiveHigh = FALSE;
	ModifiedFlag = TRUE;
}

void CMatrixArchWnd::OnActiveHigh()
{
	((CMatrixElement*)pElement)->OnActiveHigh();
}

void CMatrixArchWnd::OnActiveLow()
{
	((CMatrixElement*)pElement)->OnActiveLow();
}

void CMatrixConstrWnd::OnActiveHigh()
{
	((CMatrixElement*)pElement)->OnActiveHigh();
}

void CMatrixConstrWnd::OnActiveLow()
{
	((CMatrixElement*)pElement)->OnActiveLow();
}

void CMatrixArchWnd::OnMatrixSize()
{
	((CMatrixElement*)pElement)->OnMatrixSize();
}

void CMatrixConstrWnd::OnMatrixSize()
{
	((CMatrixElement*)pElement)->OnMatrixSize();
}

bool CMatrixElement::IsRedrawRequired() {
	for (int x = 0; x < MatrixSize.cx; x++) {
		for (int y = 0; y < MatrixSize.cx; y++) {
			if (HighLighted[x][y] >= 0) {
				return true;
			}
		}
	}

	return false;
}

void CMatrixArchWnd::Redraw(int64_t ticks) {
	CMatrixElement* pMatrixElement = reinterpret_cast<CMatrixElement*>(pElement);

	std::lock_guard<std::mutex> lock(pMatrixElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC, FALSE);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = pMatrixElement->IsRedrawRequired();
}

void CMatrixConstrWnd::Redraw(int64_t ticks) {
	CMatrixElement* pMatrixElement = reinterpret_cast<CMatrixElement*>(pElement);

	std::lock_guard<std::mutex> lock(pMatrixElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC, FALSE);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = pMatrixElement->IsRedrawRequired();
}

void CMatrixArchWnd::DrawDynamic(CDC *pDC, BOOL Redraw)
{
	CMatrixElement* pMatrixElement = reinterpret_cast<CMatrixElement*>(pElement);

	CBrush HighLightBrush(theApp.SelectColor);
	CBrush NoLightBrush(theApp.BlackColor);

	int cx = pMatrixElement->MatrixSize.cx;
	int cy = pMatrixElement->MatrixSize.cy;
	int x, y;
	//Подписываем контакты
	BYTE VertInput = (BYTE)(pMatrixElement->PinState >> 1);
	BYTE HorInput = (BYTE)(pMatrixElement->PinState >> (cy + 1));
	//Вертикальные
	CDC *pNumbDC;
	for (y = 0; y < cy; y++) {
		if (((VertInput >> y) & 1)) pNumbDC = &theApp.SelOnWhiteNumb;
		else pNumbDC = &theApp.DrawOnWhiteNumb;
		pDC->BitBlt(12, y * 15 + 25, 8, 8, pNumbDC, y * 8, 0, SRCCOPY);
	}
	//Горизонтальные
	CDC *pCharDC;
	for (x = 0; x < cx; x++) {
		if (((HorInput >> x) & 1)) pCharDC = &theApp.SelOnWhiteChar;
		else pCharDC = &theApp.DrawOnWhiteChar;
		pDC->BitBlt(27 + x * 15, cy * 15 + 25, 8, 8, pCharDC, x * 8, 0, SRCCOPY);
	}

	//Раскрашиваем матрицу
	for (x = 0; x < cx; x++) {
		int64_t* pCol = pMatrixElement->HighLighted[x];
		for (y = 0; y < cy; y++) {
			if (pCol[y]) {
				float lum = luminance2(pCol[y], *pMatrixElement->pTickCounter, pMatrixElement->ticksAfterLight);
				COLORREF c = RGB(round(255.0 * lum), 0, 0);
				pDC->FillSolidRect(CRect(24 + x * 15, 22 + y * 15, 38 + x * 15, 36 + y * 15), c);
			}
			else {
				pDC->FillSolidRect(CRect(24 + x * 15, 22 + y * 15, 38 + x * 15, 36 + y * 15), theApp.BlackColor);
			}
		}
	}
}

void CMatrixConstrWnd::DrawDynamic(CDC *pDC, BOOL Redraw)
{
	CMatrixElement* pMatrixElement = reinterpret_cast<CMatrixElement*>(pElement);

	int x, y, GrX, GrY;
	for (x = 0, GrX = 0; x < pMatrixElement->MatrixSize.cx; x++, GrX += SqrSize) {
		int64_t* pCol = pMatrixElement->HighLighted[x];
		for (y = 0, GrY = 0; y < pMatrixElement->MatrixSize.cy; y++, GrY += SqrSize) {
			if (!pMatrixElement->EditMode) {
				float lum = luminance2(pCol[y], *pMatrixElement->pTickCounter, pMatrixElement->ticksAfterLight);
				COLORREF c = RGB(round(255.0 * lum), 0, 0);
				pDC->FillSolidRect(CRect(GrX + 1, GrY + 1, GrX + SqrSize, GrY + SqrSize), c);
			}
			else {
				pDC->FillSolidRect(CRect(GrX + 1, GrY + 1, GrX + SqrSize, GrY + SqrSize), RGB(0, 0, 0));
			}
		}
	}
}

void CMatrixArchWnd::DrawStatic(CDC *pDC) {
	//Рисуем крестики, если надо
	int cx = ((CMatrixElement*)pElement)->MatrixSize.cx;
	int cy = ((CMatrixElement*)pElement)->MatrixSize.cy;

	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	CGdiObject* pOldPen = pDC->SelectObject(&BluePen);
	for (int n = 0; n < pElement->PointCount; n++) {
		pDC->PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, WHITENESS);
		if (!pElement->ConPin[n]) {
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y + 3);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y + 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y - 3);
		}
	}

	CPen DoublePen;
	if (pElement->ArchSelected) DoublePen.CreatePen(PS_SOLID, 2, theApp.SelectColor);
	else DoublePen.CreatePen(PS_SOLID, 2, theApp.DrawColor);
	pDC->SelectObject(&DoublePen);

	//Общий вывод
	pDC->Rectangle(23, 7, 25 + cx * 15, 22);
	//Вертикальные ячейки
	for (int n = 0; n < cy; n++) {
		pDC->Rectangle(8, n * 15 + 21, 24, n * 15 + 38);
	}
	//Горизонтальные ячейки
	for (int n = 0; n < cx; n++) {
		pDC->Rectangle(23 + n * 15, cy * 15 + 22, n * 15 + 40, cy * 15 + 38);
	}
	//Делаем жирную обводную линию справа
	pDC->MoveTo(cx * 15 + 24, 22);
	pDC->LineTo(cx * 15 + 24, cy * 15 + 23);

	if (pElement->ArchSelected) pDC->SelectObject(&theApp.SelectPen);
	else pDC->SelectObject(&theApp.DrawPen);

	//Рисуем светодиодную матрицу
	CBrush Brush;
	if (pElement->ArchSelected) Brush.CreateSolidBrush(theApp.SelectColor);
	else Brush.CreateSolidBrush(RGB(64, 64, 64));
	int x, y;
	for (x = 0; x < ((CMatrixElement*)pElement)->MatrixSize.cx; x++) {
		for (y = 0; y < ((CMatrixElement*)pElement)->MatrixSize.cy; y++) {
			pDC->FrameRect(CRect(23 + x * 15, 21 + y * 15, 39 + x * 15, 37 + y * 15), &Brush);
		}
	}

	//Рисуем букву E
	int X = 23 + cx * 15 / 2;
	int Y = 9;
	pDC->MoveTo(X - 3, Y); pDC->LineTo(X - 3, Y + 8);
	pDC->MoveTo(X - 3, Y); pDC->LineTo(X + 4, Y);
	pDC->MoveTo(X - 3, Y + 4); pDC->LineTo(X + 4, Y + 4);
	pDC->MoveTo(X - 3, Y + 8); pDC->LineTo(X + 4, Y + 8);

	//Рисуем выводы
	if (pElement->ConPin[0]) {
		pDC->MoveTo(pElement->ConPoint[0].x, pElement->ConPoint[0].y - 2);
		pDC->LineTo(pElement->ConPoint[0].x, pElement->ConPoint[0].y + 3);
	}
	for (int n = 1; n < cy + 1; n++) {
		if (pElement->ConPin[n]) {
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y);
		}
	}
	for (int n = 1 + cy; n < cy + cx + 1; n++) {
		if (pElement->ConPin[n]) {
			pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
			pDC->LineTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y + 3);
		}
	}

	pDC->MoveTo(pElement->ConPoint[0].x, pElement->ConPoint[0].y);
	pDC->LineTo(pElement->ConPoint[0].x, pElement->ConPoint[0].y + 5);
	for (int n = 1; n < cy + 1; n++) {
		pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		pDC->LineTo(pElement->ConPoint[n].x + 5, pElement->ConPoint[n].y);
	}
	for (int n = 1 + cy; n < cy + cx + 1; n++) {
		pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		pDC->LineTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y - 5);
	}
	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
}

void CMatrixArchWnd::Draw(CDC *pDC)
{
	CMatrixElement* pMatrixElement = reinterpret_cast<CMatrixElement*>(pElement);
	std::lock_guard<std::mutex> lock(pMatrixElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC, TRUE);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CMatrixConstrWnd::Draw(CDC *pDC)
{
	CMatrixElement* pMatrixElement = reinterpret_cast<CMatrixElement*>(pElement);
	std::lock_guard<std::mutex> lock(pMatrixElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC, TRUE);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CMatrixConstrWnd::DrawStatic(CDC *pDC)
{
	CBrush Brush;
	if (pElement->ConstrSelected) Brush.CreateSolidBrush(theApp.SelectColor);
	else Brush.CreateSolidBrush(RGB(64, 64, 64));

	for (int x = 0; x < ((CMatrixElement*)pElement)->MatrixSize.cx; x++) {
		for (int y = 0; y < ((CMatrixElement*)pElement)->MatrixSize.cy; y++) {
			pDC->FrameRect(CRect(x*SqrSize, y*SqrSize, x*SqrSize + SqrSize + 1, y*SqrSize + SqrSize + 1), &Brush);
		}
	}
}

void CMatrixElement::UpdateTipText()
{
	TipText = "Матричный индикатор";
}

void CMatrixElement::SetPinState(DWORD NewState)
{
	if (NewState == PinState) return;

	BYTE LightState = ActiveHigh ? 1 : 0;
	BYTE Enabler = (BYTE)(NewState & 1);
	PinState = NewState;

	std::lock_guard<std::mutex> lock(mutexDraw);

	if (Enabler != LightState) {
		for (int VertBit = 0; VertBit < MatrixSize.cy; VertBit++) {
			for (int HorBit = 0; HorBit < MatrixSize.cx; HorBit++) {
				if(HighLighted[HorBit][VertBit]==-1)
					HighLighted[HorBit][VertBit] = *pTickCounter+ticksAfterLight;
			}
		}
	}
	else {
		BYTE VertMask = (1 << MatrixSize.cy) - 1;
		BYTE HorMask = (1 << MatrixSize.cx) - 1;
		BYTE VertInput = (BYTE)(NewState >> 1)&VertMask;
		BYTE HorInput = (BYTE)(NewState >> (MatrixSize.cy + 1))&HorMask;

		for (int VertBit = 0; VertBit < MatrixSize.cy; VertBit++) {
			for (int HorBit = 0; HorBit < MatrixSize.cx; HorBit++) {
				if (((HorInput >> HorBit)&(VertInput >> VertBit) & 1) == LightState) {
					HighLighted[HorBit][VertBit] = -1;
				}
				else {
					if (HighLighted[HorBit][VertBit]==-1)
						HighLighted[HorBit][VertBit] = *pTickCounter + ticksAfterLight;
				}
			}
		}
	}

	if (pArchElemWnd->IsWindowEnabled()) {
		pArchElemWnd->scheduleRedraw();
	}
	if (pConstrElemWnd->IsWindowEnabled()) {
		pConstrElemWnd->scheduleRedraw();
	}
}


DWORD CMatrixElement::GetPinState()
{
	return PinState;
}

void CMatrixElement::CreateConPoints()
{
	PointCount = MatrixSize.cx + MatrixSize.cy + 1;
	ConPoint[0].x = 23 + (MatrixSize.cx * 15) / 2;
	ConPoint[0].y = 2;
	//Вертикальные входы
	int n;
	for (n = 1; n < MatrixSize.cy + 1; n++) {
		ConPoint[n].x = 2;
		ConPoint[n].y = n * 15 + 14;
	}
	//Горизонтальные входы
	for (n = MatrixSize.cy + 1; n < PointCount; n++) {
		ConPoint[n].x = (n - MatrixSize.cy - 1) * 15 + 30;
		ConPoint[n].y = MatrixSize.cy * 15 + 41;
	}

	for (n = 0; n < PointCount; n++) { ConPin[n] = FALSE; PinType[n] = PT_INPUT; }
}
/////////////////////////////////////////////////////////////////////////////
// CMatrixSizeDlg dialog


CMatrixElement::CMatrixSizeDlg::CMatrixSizeDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMatrixSizeDlg::IDD, pParent)
{
	m_XSize = -1;
	m_YSize = -1;
}


void CMatrixElement::CMatrixSizeDlg::DoDataExchange(CDataExchange* pDX)
{
	if (!pDX->m_bSaveAndValidate) {
		m_XSize -= 5; m_YSize -= 7;
	}

	CDialog::DoDataExchange(pDX);
	DDX_CBIndex(pDX, IDC_X, m_XSize);
	DDX_CBIndex(pDX, IDC_Y, m_YSize);

	if (pDX->m_bSaveAndValidate) {
		m_XSize += 5; m_YSize += 7;
	}
}


BEGIN_MESSAGE_MAP(CMatrixElement::CMatrixSizeDlg, CDialog)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMatrixSizeDlg message handlers

void CMatrixElement::OnMatrixSize()
{
	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);

	CMatrixSizeDlg Dlg;
	Dlg.m_XSize = MatrixSize.cx;
	Dlg.m_YSize = MatrixSize.cy;
	if (Dlg.DoModal() == IDOK) {
		MatrixSize.cx = Dlg.m_XSize;
		MatrixSize.cy = Dlg.m_YSize;

		CreateConPoints();

		((CMatrixArchWnd*)pArchElemWnd)->Recreate();
		((CMatrixConstrWnd*)pConstrElemWnd)->Recreate();

		ModifiedFlag = TRUE;
	}
	AfxSetResourceHandle(hInstOld);
}

void CMatrixArchWnd::Recreate() {
	Resize();
	WINDOWPLACEMENT pls;
	GetWindowPlacement(&pls);
	MoveWindow(pls.rcNormalPosition.left, pls.rcNormalPosition.top, Size.cx, Size.cy);

	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, Size.cx, Size.cy);
	Invalidate();
}

void CMatrixConstrWnd::Recreate() {
	Resize();
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, Size.cx, Size.cy);
	Invalidate();
}

int CMatrixArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

int CMatrixConstrWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}