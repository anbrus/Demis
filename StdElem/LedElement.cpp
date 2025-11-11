// LedElement.cpp: implementation of the CLedElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "LedElement.h"

#include "StdElemApp.h"
#include "utils.h"

#include <VersionHelpers.h>

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CLedElement::CLedElement(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
{
	IdIndex = 2;
	HighLighted = FALSE; ActiveHigh = TRUE;
	PointCount = 1;
	ConPoint[0].x = 2; ConPoint[0].y = 5;
	ConPin[0] = FALSE; PinType[0] = PT_INPUT;

	Color = RGB(255, 0, 0);

	pArchElemWnd = new CLedArchWnd(this);
	pConstrElemWnd = new CLedConstrWnd(this);

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_LED_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
}

CLedElement::~CLedElement()
{
}

BOOL CLedElement::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Светодиод: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	File.Read(&Color, 4);
	File.Read(&ActiveHigh, 4);

	if (ActiveHigh) {
		PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
		PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
	}
	else {
		PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_UNCHECKED);
		PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_CHECKED);
	}

	return CElementBase::Load(hFile);
}

BOOL CLedElement::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&Color, 4);
	File.Write(&ActiveHigh, 4);

	return CElementBase::Save(hFile);
}

BOOL CLedElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd) {
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	DWORD styleEx = IsWindows8OrGreater() ? WS_EX_LAYERED : 0;
	pArchElemWnd.value()->CreateEx(styleEx, ClassName, "Светодиод", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd.value()->Size.cx, pArchElemWnd.value()->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd.value()->Create(ClassName, "Светодиод", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd.value()->Size.cx, pConstrElemWnd.value()->Size.cy), pConstrParentWnd, 0);

	pArchElemWnd.value()->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	UpdateTipText();

	return TRUE;
}

BOOL CLedElement::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	HighLighted = FALSE;

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CLedArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CLedArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CLedArchWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_COMMAND(ID_SELECT_COLOR, OnSelectColor)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CLedArchWnd::CLedArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 5 * 2 + 6;
	Size.cy = 5 * 2;
}

CLedArchWnd::~CLedArchWnd()
{

}

//////////////////////////////////////////////////////////////////////
// CLedConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CLedConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CLedConstrWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_COMMAND(ID_SELECT_COLOR, OnSelectColor)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

int CLedArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

int CLedConstrWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

CLedConstrWnd::CLedConstrWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 5 * 2;
	Size.cy = 5 * 2;
}

CLedConstrWnd::~CLedConstrWnd()
{

}

void CLedElement::OnActiveHigh()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
	ActiveHigh = TRUE;
	ModifiedFlag = TRUE;
}

void CLedElement::OnActiveLow()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_CHECKED);
	ActiveHigh = FALSE;
	ModifiedFlag = TRUE;
}

void CLedArchWnd::OnActiveHigh()
{
	((CLedElement*)pElement)->OnActiveHigh();
}

void CLedArchWnd::OnActiveLow()
{
	((CLedElement*)pElement)->OnActiveLow();
}

void CLedConstrWnd::OnActiveHigh()
{
	((CLedElement*)pElement)->OnActiveHigh();
}

void CLedConstrWnd::OnActiveLow()
{
	((CLedElement*)pElement)->OnActiveLow();
}

void CLedArchWnd::DrawDynamic(CDC* pDC)
{
	//Выбираем нужную заливку
	COLORREF c;
	if (((CLedElement*)pElement)->HighLighted) c = reinterpret_cast<CLedElement*>(pElement)->Color;
	else c = RGB(254, 254, 254);
	//Рисуем светодиод
	pDC->FillSolidRect(CRect(6+1, 1, Size.cx - 1, Size.cy - 1), c);
}

void CLedConstrWnd::DrawDynamic(CDC* pDC)
{
	//Выбираем нужную заливку
	COLORREF c;
	if (((CLedElement*)pElement)->HighLighted) c = reinterpret_cast<CLedElement*>(pElement)->Color;
	else c = RGB(255, 255, 255);
	//Рисуем светодиод
	pDC->FillSolidRect(CRect(1, 1, Size.cx-1, Size.cy-1), c);
}

void CLedArchWnd::Draw(CDC* pDC) {
	CLedElement* pLedElement = reinterpret_cast<CLedElement*>(pElement);
	std::lock_guard<std::mutex> lock(pLedElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CLedArchWnd::DrawStatic(CDC* pDC)
{
	//сам светодиод
	CBrush brush(pElement->ArchSelected ? theApp.SelectColor : theApp.DrawColor);
	CRect rect(6, 0, Size.cx, Size.cy);
	pDC->FrameRect(&rect, &brush);

	CGdiObject* pOldPen;
	pDC->PatBlt(pElement->ConPoint[0].x - 2, pElement->ConPoint[0].y - 2, 5, 5, WHITENESS);
	//Рисуем крестик, если надо
	if (!pElement->ConPin[0]) {
		CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
		pOldPen = pDC->SelectObject(&BluePen);
		pDC->MoveTo(pElement->ConPoint[0].x - 2, pElement->ConPoint[0].y - 2);
		pDC->LineTo(pElement->ConPoint[0].x + 3, pElement->ConPoint[0].y + 3);
		pDC->MoveTo(pElement->ConPoint[0].x - 2, pElement->ConPoint[0].y + 2);
		pDC->LineTo(pElement->ConPoint[0].x + 3, pElement->ConPoint[0].y - 3);
	}
	else { //или палочку
		if (pElement->ArchSelected)
			pOldPen = pDC->SelectObject(&theApp.SelectPen);
		else pOldPen = pDC->SelectObject(&theApp.DrawPen);
		pDC->MoveTo(0, pElement->ConPoint[0].y);
		pDC->LineTo(6, pElement->ConPoint[0].y);
	}
	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
}

void CLedConstrWnd::Draw(CDC* pDC)
{
	CLedElement* pLedElement = reinterpret_cast<CLedElement*>(pElement);
	std::lock_guard<std::mutex> lock(pLedElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CLedConstrWnd::DrawStatic(CDC *pDC) {
	CBrush brush(pElement->ConstrSelected ? theApp.SelectColor : theApp.DrawColor);
	pDC->FrameRect(CRect(0, 0, Size.cx, Size.cy), &brush);
}

void CLedElement::UpdateTipText()
{
	TipText = "Светодиод";
}

void CLedElement::SetPinState(DWORD NewState)
{
	BOOL OldVal = HighLighted;
	HighLighted = (NewState & 1) ^ (!ActiveHigh);
	if (OldVal == HighLighted) return;

	if (pArchElemWnd.value()->IsWindowEnabled()) {
		pArchElemWnd.value()->Invalidate();
	}
	if (pConstrElemWnd.value()->IsWindowEnabled()) {
		pConstrElemWnd.value()->Invalidate();
	}
}


void CLedArchWnd::OnSelectColor()
{
	((CLedElement*)pElement)->OnSelectColor();
}

void CLedConstrWnd::OnSelectColor()
{
	((CLedElement*)pElement)->OnSelectColor();
}

void CLedElement::OnSelectColor()
{
	CColorDialog Dlg(Color);
	if (Dlg.DoModal() == IDOK) {
		Color = Dlg.GetColor();
		if (pArchElemWnd.value()->IsWindowEnabled()) pArchElemWnd.value()->Invalidate();
		if (pConstrElemWnd.value()->IsWindowEnabled()) pConstrElemWnd.value()->Invalidate();
		ModifiedFlag = 1;
	}
}

void CLedArchWnd::Redraw(int64_t ticks) {
	CLedElement* pLedElement = reinterpret_cast<CLedElement*>(pElement);

	std::lock_guard<std::mutex> lock(pLedElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}

void CLedConstrWnd::Redraw(int64_t ticks) {
	CLedElement* pLedElement = reinterpret_cast<CLedElement*>(pElement);

	std::lock_guard<std::mutex> lock(pLedElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}