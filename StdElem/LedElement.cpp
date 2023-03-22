// LedElement.cpp: implementation of the CLedElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "LedElement.h"

#include "StdElemApp.h"

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

BOOL CLedElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->Create(ClassName, "Светодиод", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd->Create(ClassName, "Светодиод", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd->Size.cx, pConstrElemWnd->Size.cy), pConstrParentWnd, 0);

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
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

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

void CLedArchWnd::DrawValue(CDC* pDC)
{
	CGdiObject* pOldBrush, * pOldPen;
	if (!pElement->EditMode) pOldPen = pDC->SelectObject(&theApp.DrawPen);

	CBrush HighLightBrush(((CLedElement*)pElement)->Color);
	CBrush NoLightBrush(theApp.BkColor);
	//Выбираем нужную заливку
	if (((CLedElement*)pElement)->HighLighted) pOldBrush = pDC->SelectObject(&HighLightBrush);
	else pOldBrush = pDC->SelectObject(&NoLightBrush);
	pDC->Rectangle(6, 0, Size.cx, Size.cy);
	pDC->SelectObject(pOldBrush);
	if (!pElement->EditMode) pDC->SelectObject(pOldPen);
}

void CLedConstrWnd::DrawValue(CDC* pDC)
{
	CGdiObject* pOldPen, * pOldBrush;
	if (!pElement->EditMode) pOldPen = pDC->SelectObject(&theApp.DrawPen);
	CBrush HighLightBrush(((CLedElement*)pElement)->Color);
	CBrush NoLightBrush(theApp.BkColor);
	//Выбираем нужную заливку
	if (((CLedElement*)pElement)->HighLighted) pOldBrush = pDC->SelectObject(&HighLightBrush);
	else pOldBrush = pDC->SelectObject(&NoLightBrush);
	//Рисуем светодиод
	pDC->Rectangle(0, 0, Size.cx, Size.cy);
	pDC->SelectObject(pOldBrush);
	if (!pElement->EditMode) pDC->SelectObject(pOldPen);
}

void CLedArchWnd::Draw(CDC* pDC)
{
	CGdiObject* pOldPen;
	if (pElement->ArchSelected)
		pOldPen = pDC->SelectObject(&theApp.SelectPen);
	else pOldPen = pDC->SelectObject(&theApp.DrawPen);
	int CenterY = Size.cy / 2;
	//Рисуем проводок
	pDC->MoveTo(2, CenterY); pDC->LineTo(6, CenterY);
	//и сам светодиод
	DrawValue(pDC);
	//Рисуем крестик, если надо
	if (!pElement->ConPin[0]) {
		CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
		pDC->SelectObject(&BluePen);
		pDC->MoveTo(0, CenterY - 2); pDC->LineTo(5, CenterY + 3);
		pDC->MoveTo(0, CenterY + 2); pDC->LineTo(5, CenterY - 3);
	}
	else { //или палочку
		pDC->MoveTo(0, CenterY); pDC->LineTo(5, CenterY);
	}
	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
}

void CLedConstrWnd::Draw(CDC* pDC)
{
	CGdiObject* pOldPen;
	if (pElement->ConstrSelected)
		pOldPen = pDC->SelectObject(&theApp.SelectPen);
	else pOldPen = pDC->SelectObject(&theApp.DrawPen);
	DrawValue(pDC);
	pDC->SelectObject(pOldPen);
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

	if (pArchElemWnd->IsWindowEnabled()) {
		pArchElemWnd->Invalidate();
	}
	if (pConstrElemWnd->IsWindowEnabled()) {
		pConstrElemWnd->Invalidate();
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
		if (pArchElemWnd->IsWindowEnabled()) pArchElemWnd->Invalidate();
		if (pConstrElemWnd->IsWindowEnabled()) pConstrElemWnd->Invalidate();
		ModifiedFlag = 1;
	}
}

void CLedArchWnd::Redraw(int64_t ticks) {

}

void CLedConstrWnd::Redraw(int64_t ticks) {

}