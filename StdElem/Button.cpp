// Button.cpp: implementation of the CButtonElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "Button.h"
#include "TextDlg.h"
#include "ElemInterf.h"
#include "..\definitions.h"
#include "StdElemApp.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CButtonElement::CButtonElement(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
{
	IdIndex = 3; Text = "Кнопка";
	Pressed = FALSE; NormalOpened = TRUE;
	Fixable = FALSE; Drebezg = FALSE;
	PointCount = 1;
	ConPoint[0].x = 30; ConPoint[0].y = 9;
	ConPin[0] = FALSE; PinType[0] = PT_OUTPUT;

	pArchElemWnd = new CBtnArchWnd(this);
	pConstrElemWnd = new CBtnConstrWnd(this);

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_BUTTON_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_NORMAL_OPENED, MF_BYCOMMAND | MF_CHECKED);
}

CButtonElement::~CButtonElement()
{
}

BOOL CButtonElement::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Кнопка: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	DWORD BitAttrib;
	File.Read(&BitAttrib, 4);
	NormalOpened = BitAttrib & 1;
	Fixable = BitAttrib & 2;
	Drebezg = BitAttrib & 4;
	int TextLen;
	File.Read(&TextLen, 4);
	char* NewText = new char[TextLen + 1];
	File.Read(NewText, TextLen);
	NewText[TextLen] = 0;
	Text = NewText;
	delete NewText;

	PopupMenu.CheckMenuItem(ID_NORMAL_OPENED, MF_BYCOMMAND |
		(NormalOpened ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_NORMAL_CLOSED, MF_BYCOMMAND |
		(NormalOpened ? MF_UNCHECKED : MF_CHECKED));
	PopupMenu.CheckMenuItem(ID_FIXABLE, MF_BYCOMMAND |
		(Fixable ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_DREBEZG, MF_BYCOMMAND |
		(Drebezg ? MF_CHECKED : MF_UNCHECKED));

	return CElementBase::Load(hFile);
}

BOOL CButtonElement::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	DWORD BitAttrib = (NormalOpened ? 1 : 0) +
		(Fixable ? 2 : 0) +
		(Drebezg ? 4 : 0);
	DWORD Reserved = 0;
	File.Write(&BitAttrib, 4);
	int TextLen = Text.GetLength();
	File.Write(&TextLen, 4);
	File.Write((char*)(LPCTSTR)Text, TextLen);

	return CElementBase::Save(hFile);
}

BOOL CButtonElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->Create(ClassName, "Кнопка", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd->Create(ClassName, "Кнопка", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd->Size.cx, pConstrElemWnd->Size.cy), pConstrParentWnd, 0);
	((CBtnConstrWnd*)pConstrElemWnd)->UpdateSize();

	UpdateTipText();
	ChangePinState();

	return TRUE;
}

BOOL CButtonElement::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	Pressed = FALSE;
	CurState = NormalOpened ? 0 : 1;
	ticksDrebezgEnd = 0;
	this->pTickCounter = pTickCounter;
	CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
	ChangePinState();
	if (!bEditMode && !NormalOpened) {
		theApp.pHostInterface->OnPinStateChanged(CurState, id);
	}

	return TRUE;
}

//////////////////////////////////////////////////////////////////////
// CBtnArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CBtnArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CBtnArchWnd)
	ON_COMMAND(ID_LABEL_TEXT, OnLabelText)
	ON_COMMAND(ID_NORMAL_CLOSED, OnNormalClosed)
	ON_COMMAND(ID_NORMAL_OPENED, OnNormalOpened)
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_COMMAND(ID_FIXABLE, OnFixable)
	ON_COMMAND(ID_DREBEZG, OnDrebezg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBtnArchWnd::CBtnArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 33; Size.cy = 12;
}

CBtnArchWnd::~CBtnArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CBtnConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CBtnConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CBtnConstrWnd)
	ON_COMMAND(ID_LABEL_TEXT, OnLabelText)
	ON_COMMAND(ID_NORMAL_CLOSED, OnNormalClosed)
	ON_COMMAND(ID_NORMAL_OPENED, OnNormalOpened)
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_COMMAND(ID_FIXABLE, OnFixable)
	ON_COMMAND(ID_DREBEZG, OnDrebezg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBtnConstrWnd::CBtnConstrWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 15; Size.cy = 15;
}

CBtnConstrWnd::~CBtnConstrWnd()
{
}

void CBtnConstrWnd::UpdateSize()
{
	if (((CButtonElement*)pElement)->Text.IsEmpty()) {
		Size.cx = 15; Size.cy = 15;
	}
	else {
		CClientDC DC(this);

		CGdiObject* pOldFont;
		pOldFont = DC.SelectStockObject(ANSI_VAR_FONT);

		CRect DrawRect(0, 0, 1000, 1000);
		DC.DrawText(((CButtonElement*)pElement)->Text, DrawRect, DT_CENTER | DT_CALCRECT);
		DrawRect.right = 5 * (DrawRect.right / 5) + 5;
		DrawRect.bottom = 5 * (DrawRect.bottom / 5) + 5;

		Size.cx = DrawRect.Width() + 10;
		Size.cy = DrawRect.Height() + 10;

		DC.SelectObject(pOldFont);
	}

	WINDOWPLACEMENT Pls;
	Pls.length = sizeof(Pls);
	::GetWindowPlacement(m_hWnd, &Pls);
	CRect Rect(Pls.rcNormalPosition);
	Rect.right = Rect.left + Size.cx;
	Rect.bottom = Rect.top + Size.cy;
	MoveWindow(Rect);
	RedrawWindow();
}

void CBtnConstrWnd::OnLabelText()
{
	((CButtonElement*)pElement)->OnLabelText(this);
}

void CButtonElement::OnLabelText(CElementWnd* pParentWnd)
{
	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);

	CTextDlg Dlg(pParentWnd);
	Dlg.SetText((char*)(LPCTSTR)Text);
	if (Dlg.DoModal() == IDOK) {
		Text = Dlg.GetText();
		((CBtnConstrWnd*)pConstrElemWnd)->UpdateSize();
		UpdateTipText();
		ModifiedFlag = TRUE;
	}

	AfxSetResourceHandle(hInstOld);
}

void CBtnArchWnd::OnLabelText()
{
	((CButtonElement*)pElement)->OnLabelText(this);
}

void CBtnArchWnd::OnNormalClosed()
{
	((CButtonElement*)pElement)->OnNormalClosed();
}

void CBtnArchWnd::OnNormalOpened()
{
	((CButtonElement*)pElement)->OnNormalOpened();
}

void CBtnConstrWnd::OnNormalClosed()
{
	((CButtonElement*)pElement)->OnNormalClosed();
}

void CBtnConstrWnd::OnNormalOpened()
{
	((CButtonElement*)pElement)->OnNormalOpened();
}

void CButtonElement::OnNormalOpened()
{
	NormalOpened = TRUE;
	PopupMenu.CheckMenuItem(ID_NORMAL_OPENED, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_NORMAL_CLOSED, MF_BYCOMMAND | MF_UNCHECKED);
	pArchElemWnd->RedrawWindow();
	pConstrElemWnd->RedrawWindow();
	ModifiedFlag = TRUE;
}

void CButtonElement::OnNormalClosed()
{
	NormalOpened = FALSE;
	PopupMenu.CheckMenuItem(ID_NORMAL_OPENED, MF_BYCOMMAND | MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_NORMAL_CLOSED, MF_BYCOMMAND | MF_CHECKED);
	pArchElemWnd->RedrawWindow();
	pConstrElemWnd->RedrawWindow();
	ModifiedFlag = TRUE;
}

void CBtnArchWnd::OnLButtonDown(UINT nFlags, CPoint point)
{
	if (!pElement->EditMode) {
		SetCapture();
		((CButtonElement*)pElement)->OnLButtonDown();
		RedrawWindow();
		((CButtonElement*)pElement)->pConstrElemWnd->RedrawWindow();
	}
	else	CElementWnd::OnLButtonDown(nFlags, point);
}

void CBtnArchWnd::OnLButtonUp(UINT nFlags, CPoint point)
{
	if (!pElement->EditMode) {
		ReleaseCapture();
		((CButtonElement*)pElement)->OnLButtonUp();
		RedrawWindow();
		((CButtonElement*)pElement)->pConstrElemWnd->RedrawWindow();
	}
	else	CElementWnd::OnLButtonUp(nFlags, point);
}

void CBtnConstrWnd::OnLButtonDown(UINT nFlags, CPoint point)
{
	if (!pElement->EditMode) {
		SetCapture();
		((CButtonElement*)pElement)->OnLButtonDown();
		RedrawWindow();
		((CButtonElement*)pElement)->pArchElemWnd->RedrawWindow();
	}
	else	CElementWnd::OnLButtonDown(nFlags, point);
}

void CBtnConstrWnd::OnLButtonUp(UINT nFlags, CPoint point)
{
	if (!pElement->EditMode) {
		ReleaseCapture();
		((CButtonElement*)pElement)->OnLButtonUp();
		RedrawWindow();
		((CButtonElement*)pElement)->pArchElemWnd->RedrawWindow();
	}
	else	CElementWnd::OnLButtonUp(nFlags, point);
}

void CBtnConstrWnd::OnFixable()
{
	((CButtonElement*)pElement)->OnFixable();
}

void CBtnArchWnd::OnFixable()
{
	((CButtonElement*)pElement)->OnFixable();
}

void CButtonElement::OnFixable()
{
	Fixable = !Fixable;
	PopupMenu.CheckMenuItem(ID_FIXABLE, MF_BYCOMMAND |
		(Fixable ? MF_CHECKED : MF_UNCHECKED));
	Pressed = FALSE;
	pArchElemWnd->RedrawWindow();
	pConstrElemWnd->RedrawWindow();
	ModifiedFlag = TRUE;
}

void CBtnConstrWnd::OnDrebezg()
{
	((CButtonElement*)pElement)->OnDrebezg();
}

void CBtnArchWnd::OnDrebezg()
{
	((CButtonElement*)pElement)->OnDrebezg();
}

void CButtonElement::OnDrebezg()
{
	Drebezg = !Drebezg;
	PopupMenu.CheckMenuItem(ID_DREBEZG, MF_BYCOMMAND |
		(Drebezg ? MF_CHECKED : MF_UNCHECKED));
	Pressed = FALSE;
	pArchElemWnd->RedrawWindow();
	pConstrElemWnd->RedrawWindow();
	ModifiedFlag = TRUE;
}

void CBtnConstrWnd::Draw(CDC* pDC)
{
	CRect BtnRect(0, 0, Size.cx, Size.cy);

	if (((CButtonElement*)pElement)->Pressed)
		pDC->Draw3dRect(&BtnRect, RGB(0, 0, 0), GetSysColor(COLOR_BTNFACE));
	else pDC->Draw3dRect(&BtnRect, GetSysColor(COLOR_BTNFACE), RGB(0, 0, 0));

	CBrush FaceBrush(GetSysColor(COLOR_BTNFACE));
	CGdiObject* pOldBrush = pDC->SelectObject(&FaceBrush);
	pDC->PatBlt(1, 1, Size.cx - 2, Size.cy - 2, PATCOPY);
	pDC->SelectObject(pOldBrush);

	CGdiObject* pOldFont = pDC->SelectStockObject(ANSI_VAR_FONT);
	if (pElement->ConstrSelected) pDC->SetTextColor(theApp.SelectColor);
	else pDC->SetTextColor(theApp.DrawColor);
	pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
	if (((CButtonElement*)pElement)->Pressed)
		pDC->DrawText(((CButtonElement*)pElement)->Text,
			CRect(6, 6, BtnRect.right - 4, BtnRect.bottom - 4), DT_CENTER);
	else
		pDC->DrawText(((CButtonElement*)pElement)->Text,
			CRect(5, 5, BtnRect.right - 5, BtnRect.bottom - 5), DT_CENTER);
	pDC->SelectObject(pOldFont);
}

void CBtnArchWnd::Draw(CDC* pDC)
{
	CGdiObject* pOldPen;

	if (pElement->ArchSelected)
		pOldPen = pDC->SelectObject(&theApp.SelectPen);
	else pOldPen = pDC->SelectObject(&theApp.DrawPen);

	//Рисуем кнопку
	//Надпись +5В
	CFont UFont;
	UFont.CreatePointFont(60, "Arial Cyr");
	CGdiObject* pOldFont = pDC->SelectObject(&UFont);
	if (pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
	else pDC->SetTextColor(theApp.DrawColor);
	pDC->SetBkColor(theApp.BkColor);
	if (pElement->FreePinLevel == 0) pDC->DrawText("+5В", CRect(0, -1, 16, 8), DT_LEFT | DT_TOP | DT_SINGLELINE);
	else pDC->DrawText("GND", CRect(-1, -1, 17, 8), DT_LEFT | DT_TOP | DT_SINGLELINE);
	pDC->SelectObject(pOldFont);

	//Сама кнопка
	pDC->MoveTo(0, 9); pDC->LineTo(16, 9);
	if ((((CButtonElement*)pElement)->Pressed ? 1 : 0) ^
		(((CButtonElement*)pElement)->NormalOpened ? 1 : 0))
		pDC->LineTo(25, 0);
	else pDC->LineTo(25, 9);
	pDC->MoveTo(25, 9); pDC->LineTo(31, 9);

	//Рисуем крестик, если надо
	if (!pElement->ConPin[0]) {
		CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
		pDC->SelectObject(&BluePen);
		pDC->MoveTo(28, 11); pDC->LineTo(33, 6);
		pDC->MoveTo(28, 7); pDC->LineTo(33, 12);
	}
	else { //или палочку
		pDC->MoveTo(30, 9); pDC->LineTo(33, 9);
	}
	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
}

void CButtonElement::UpdateTipText()
{
	TipText.Format("Кнопка \"%s\"", Text);
}

void CButtonElement::OnLButtonDown()
{
	if (Fixable) Pressed = !Pressed;
	else Pressed = TRUE;

	if (Drebezg) {
		int64_t msDrebezg = distributionDrebezg(rndEngine);
		ticksDrebezgEnd = *pTickCounter + msDrebezg * TaktFreq / 1000000;
		theApp.pHostInterface->SetTickTimer(*pTickCounter + 18, 0, id, [this](DWORD) { OnTickTimer(); });
	}
	else {
		CurState = (Pressed ? 1 : 0) ^ (NormalOpened ? 0 : 1) ^ FreePinLevel;
		theApp.pHostInterface->OnPinStateChanged(CurState, id);
	}
}

void CButtonElement::OnLButtonUp()
{
	if (!Fixable) {
		Pressed = FALSE;
		if (Drebezg) {
			int64_t msDrebezg = distributionDrebezg(rndEngine);
			ticksDrebezgEnd = *pTickCounter + msDrebezg * TaktFreq / 1000000;
			theApp.pHostInterface->SetTickTimer(*pTickCounter + 18, 0, id, [this](DWORD) { OnTickTimer(); });
		}
		else {
			CurState = (Pressed ? 1 : 0) ^ (NormalOpened ? 0 : 1) ^ FreePinLevel;
			theApp.pHostInterface->OnPinStateChanged(CurState, id);
		}
	}
}

void CButtonElement::ChangePinState()
{
}

DWORD CButtonElement::GetPinState()
{
	return CurState;
}

void CButtonElement::OnTickTimer()
{
	if (ticksDrebezgEnd > *pTickCounter) {
		CurState = distributionBinary(rndEngine);
		theApp.pHostInterface->OnPinStateChanged(CurState, id);
		theApp.pHostInterface->SetTickTimer(*pTickCounter+18, 0, id, [this](DWORD) { OnTickTimer(); });
	}
	else {
		CurState = (Pressed ? 1 : 0) ^ (NormalOpened ? 0 : 1) ^ FreePinLevel;
		theApp.pHostInterface->OnPinStateChanged(CurState, id);
	}
}
