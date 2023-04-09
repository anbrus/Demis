// Indicator.cpp: implementation of the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "Indicator.h"

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

CIndicator::CIndicator(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
{
	int IndWidth = 34;
	int IndHeight = 44;

	POINT TempImg[8][6] = {
	  {//0
		{ 2,          2 },
		{ 4,          4 },
		{ 4,          IndHeight / 2 - 2 },
		{ 2,          IndHeight / 2 },
		{ 0,          IndHeight / 2 - 2 },
		{ 0,          4 }
	  },
	  {//1
		{ 2,          2 },
		{ 4,          0 },
		{ IndWidth - 14,0 },
		{ IndWidth - 12,2 },
		{ IndWidth - 14,4 },
		{ 4,          4 }
	  },
	  {//2
		{ IndWidth - 12,2 },
		{ IndWidth - 10,4 },
		{ IndWidth - 10,IndHeight / 2 - 2 },
		{ IndWidth - 12,IndHeight / 2 },
		{ IndWidth - 14,IndHeight / 2 - 2 },
		{ IndWidth - 14,4 }
	  },
	  {//3
		{ IndWidth - 12,IndHeight / 2 },
		{ IndWidth - 10,IndHeight / 2 + 2 },
		{ IndWidth - 10,IndHeight - 4 },
		{ IndWidth - 12,IndHeight - 2 },
		{ IndWidth - 14,IndHeight - 4 },
		{ IndWidth - 14,IndHeight / 2 + 2 }
	  },
	  {//4
		{ 2,          IndHeight - 2 },
		{ 4,          IndHeight - 4 },
		{ IndWidth - 14,IndHeight - 4 },
		{ IndWidth - 12,IndHeight - 2 },
		{ IndWidth - 14,IndHeight - 0 },
		{ 4,          IndHeight - 0 }
	  },
	  {//5
		{ 2,          IndHeight / 2 },
		{ 4,          IndHeight / 2 + 2 },
		{ 4,          IndHeight - 4 },
		{ 2,          IndHeight - 2 },
		{ 0,          IndHeight - 4 },
		{ 0,          IndHeight / 2 + 2 }
	  },
	  {//6
		{ 2,          IndHeight / 2 },
		{ 4,          IndHeight / 2 - 2 },
		{ IndWidth - 14,IndHeight / 2 - 2 },
		{ IndWidth - 12,IndHeight / 2 },
		{ IndWidth - 14,IndHeight / 2 + 2 },
		{ 4,          IndHeight / 2 + 2 }
	  },
	  {//7
		{ IndWidth - 5, IndHeight - 5 },
		{ IndWidth - 0, IndHeight - 5 },
		{ IndWidth - 0, IndHeight - 0 },
		{ IndWidth - 5, IndHeight - 0 },
		{ IndWidth - 5, IndHeight - 0 },
		{ IndWidth - 5, IndHeight - 0 },
	  }
	};

	memcpy(IndImage, TempImg, sizeof(TempImg));

	TipText = "Семисегментный индикатор";
	IdIndex = 5;
	ActiveHigh = TRUE; HighLight = 0;

	pArchElemWnd = new CIndArchWnd(this);
	pConstrElemWnd = new CIndConstrWnd(this);

	PointCount = 8;
	for (int n = 0; n < PointCount; n++) {
		ConPoint[n].x = 2;
		ConPoint[n].y = 10 + n * 15;
		ConPin[n] = FALSE;
		PinType[n] = PT_INPUT;
	}

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_IND_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
}

CIndicator::~CIndicator()
{
}

BOOL CIndicator::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Индикатор: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

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

BOOL CIndicator::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&ActiveHigh, 4);

	return CElementBase::Save(hFile);
}

BOOL CIndicator::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	DWORD styleEx = IsWindows8OrGreater() ? WS_EX_LAYERED : 0;
	pArchElemWnd->CreateEx(styleEx, ClassName, "Индикатор", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd->Create(ClassName, "Индикатор", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd->Size.cx, pConstrElemWnd->Size.cy), pConstrParentWnd, 0);

	pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	return TRUE;
}

BOOL CIndicator::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);

	if (ActiveHigh) HighLight = 0;
	else HighLight = 0xFFFFFFFF;
	if (bEditMode) HighLight = 0;

	return TRUE;
}

//////////////////////////////////////////////////////////////////////
// CIndArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndArchWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndArchWnd::CIndArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 60;
	Size.cy = 125;
}

CIndArchWnd::~CIndArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CIndConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndConstrWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndConstrWnd::CIndConstrWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 35;
	Size.cy = 45;
}

CIndConstrWnd::~CIndConstrWnd()
{
}

void CIndicator::OnActiveHigh()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
	ActiveHigh = TRUE;
	ModifiedFlag = TRUE;
}

void CIndicator::OnActiveLow()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_CHECKED);
	ActiveHigh = FALSE;
	ModifiedFlag = TRUE;
}

void CIndArchWnd::OnActiveHigh()
{
	((CIndicator*)pElement)->OnActiveHigh();
}

void CIndArchWnd::OnActiveLow()
{
	((CIndicator*)pElement)->OnActiveLow();
}

void CIndConstrWnd::OnActiveHigh()
{
	((CIndicator*)pElement)->OnActiveHigh();
}

void CIndConstrWnd::OnActiveLow()
{
	((CIndicator*)pElement)->OnActiveLow();
}

void CIndicator::DrawSegments(CDC* pDC, bool isSelected, bool isArchMode, CPoint Pos)
{
	CGdiObject* pOldPen, * pOldBrush;
	CPen Pen;
	if (EditMode) {
		if (isSelected) {
			pOldPen = pDC->SelectObject(&theApp.SelectPen);
		}
		else {
			Pen.CreatePen(PS_SOLID, 0, RGB(72, 72, 72));
			pOldPen = pDC->SelectObject(&Pen);
		}
	}
	else {
		Pen.CreatePen(PS_SOLID, 0, RGB(72, 72, 72));
		pOldPen = pDC->SelectObject(&Pen);
	}
	COLORREF colorBackground;
	if (isArchMode) {
		colorBackground = theApp.GrayColor;
	}
	else {
		colorBackground = RGB(255, 255, 255);
	}
	for (int n = 0; n < 8; n++) {
		BOOL isOn = (HighLight & (1<<n)) != 0;
		COLORREF c;
		if (EditMode) {
			c = colorBackground;
		}
		else {
			if (isOn) {
				c = RGB(255, 0, 0);
			}
			else {
				c = colorBackground;
			}
		}

		CBrush brush(c);
		pOldBrush = pDC->SelectObject(&brush);
		CPoint SegImage[6];
		memcpy(SegImage, IndImage[n], sizeof(SegImage));
		for (int i = 0; i < 6; i++) SegImage[i] += Pos;
		pDC->Polygon(SegImage, 6);
		pDC->SelectObject(pOldBrush);
	}
	pDC->SelectObject(pOldPen);
}

void CIndArchWnd::DrawDynamic(CDC* pDC)
{
	CIndicator* pIndElement = reinterpret_cast<CIndicator*>(pElement);

	DWORD PinState = pIndElement->GetPinState();
	for (int n = 0; n < 8; n++) {
		BOOL NewBit = PinState & 1;

		CDC* pCharsDc;
		if (pIndElement->EditMode) {
			pCharsDc = &theApp.DrawOnWhiteChar;
		}
		else {
			if (NewBit)
				pCharsDc = &theApp.SelOnWhiteChar;
			else
				pCharsDc = &theApp.DrawOnWhiteChar;
		}
		pDC->BitBlt(8, 3 + n * 15, 8, 8, pCharsDc, n * 8, 0, SRCCOPY);
	}
	((CIndicator*)pElement)->DrawSegments(pDC, pElement->ArchSelected, true, CPoint(21, 40));
}

int CIndConstrWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

void CIndConstrWnd::DrawDynamic(CDC* pDC)
{
	CIndicator* pIndElement = reinterpret_cast<CIndicator*>(pElement);

	pIndElement->DrawSegments(pDC, pIndElement->ConstrSelected, false, CPoint(0, 0));
}

void CIndConstrWnd::Draw(CDC* pDC)
{
	CIndicator* pIndElement = reinterpret_cast<CIndicator*>(pElement);
	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CIndConstrWnd::DrawStatic(CDC* pDC)
{
	pDC->PatBlt(0, 0, Size.cx, Size.cy, WHITENESS);
}

void CIndConstrWnd::Redraw(int64_t ticks) {
	CIndicator* pIndElement = reinterpret_cast<CIndicator*>(pElement);

	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}

int CIndArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

void CIndArchWnd::Draw(CDC* pDC) {
	CIndicator* pIndElement = reinterpret_cast<CIndicator*>(pElement);
	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CIndArchWnd::DrawStatic(CDC* pDC)
{
	CGdiObject* pOldPen;
	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	CBrush SelectBrush(theApp.SelectColor);
	CBrush NormalBrush(theApp.DrawColor);

	if (pElement->ArchSelected)
		pDC->FrameRect(CRect(6, 0, Size.cx, Size.cy), &SelectBrush);
	else pDC->FrameRect(CRect(6, 0, Size.cx, Size.cy), &NormalBrush);
	pDC->FillSolidRect(CRect(6 + 1, 1, 16, Size.cy - 1), RGB(254, 254, 254));
	pDC->FillSolidRect(CRect(17, 1, Size.cx - 1, Size.cy - 1), theApp.GrayColor);

	CPen* pTempPen;
	if (pElement->ArchSelected) pTempPen = &theApp.SelectPen;
	else pTempPen = &theApp.DrawPen;
	pOldPen = pDC->SelectObject(pTempPen);

	pDC->MoveTo(16, 0);
	pDC->LineTo(16, Size.cy);

	//Рисуем проводки
	for (int n = 0; n < 8; n++) {
		pDC->PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, WHITENESS);
		pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		pDC->LineTo(pElement->ConPoint[n].x + 4, pElement->ConPoint[n].y);
	}
	for (int n = 0; n < 8; n++) {
		//Рисуем палочку или крестик
		if (pElement->ConPin[n]) {
			pDC->SelectObject(pTempPen);
			pDC->MoveTo(0, pElement->ConPoint[n].y);
			pDC->LineTo(6, pElement->ConPoint[n].y);
		}
		else {
			pDC->SelectObject(&BluePen);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y + 3);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y + 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y - 3);
		}
	}

	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
}

void CIndArchWnd::Redraw(int64_t ticks) {
	CIndicator* pIndElement = reinterpret_cast<CIndicator*>(pElement);

	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}

void CIndicator::SetPinState(DWORD NewState)
{
	DWORD OldHighLight = HighLight;
	if (ActiveHigh) HighLight = NewState;
	else HighLight = ~NewState;
	if (OldHighLight == HighLight) return;

	if (pArchElemWnd->IsWindowEnabled()) {
		pArchElemWnd->scheduleRedraw();
	}
	if (pConstrElemWnd->IsWindowEnabled()) {
		pConstrElemWnd->scheduleRedraw();
	}
}

DWORD CIndicator::GetPinState()
{
	return ActiveHigh ? HighLight : ~HighLight;
}
