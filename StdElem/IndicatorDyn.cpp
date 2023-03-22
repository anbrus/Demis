// Indicator.cpp: implementation of the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "IndicatorDyn.h"

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

CIndicatorDyn::CIndicatorDyn(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
	, PinState(0)
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

	TipText = "Семисегм. дин. индикатор";
	IdIndex = 6;
	ActiveHigh = TRUE;
	memset(HighLighted, 0, sizeof(HighLighted));
	ActiveHigh = TRUE; ticksAfterLight = 0;

	pArchElemWnd = new CIndDArchWnd(this);
	pConstrElemWnd = new CIndDConstrWnd(this);

	PointCount = 9;
	for (int n = 0; n < 8; n++) {
		ConPoint[n].x = 2;
		ConPoint[n].y = 10 + n * 15;
		ConPin[n] = FALSE;
		PinType[n] = PT_INPUT;
	}

	ConPoint[8].x = 30;
	ConPoint[8].y = 128;
	ConPin[8] = FALSE;
	PinType[8] = PT_INPUT;

	PinState = 0;

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_IND_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
}

CIndicatorDyn::~CIndicatorDyn()
{
}

BOOL CIndicatorDyn::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Индикатор динамический: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
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

BOOL CIndicatorDyn::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&ActiveHigh, 4);

	return CElementBase::Save(hFile);
}

BOOL CIndicatorDyn::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->Create(ClassName, "Дин. индикатор", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd->Create(ClassName, "Дин. индикатор", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd->Size.cx, pConstrElemWnd->Size.cy), pConstrParentWnd, 0);

	return TRUE;
}

BOOL CIndicatorDyn::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);

	memset(HighLighted, 0, sizeof(HighLighted));
	PinState = 0;
	this->pTickCounter = pTickCounter;
	ticksAfterLight = 20 * TaktFreq / 1000;

	return TRUE;
}

//////////////////////////////////////////////////////////////////////
// CIndArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndDArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndDArchWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndDArchWnd::CIndDArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 60;
	Size.cy = 131;
}

CIndDArchWnd::~CIndDArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CIndConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndDConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndDConstrWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndDConstrWnd::CIndDConstrWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 35;
	Size.cy = 45;
}

CIndDConstrWnd::~CIndDConstrWnd()
{
}

void CIndicatorDyn::OnActiveHigh()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_UNCHECKED);
	ActiveHigh = TRUE;
	ModifiedFlag = TRUE;
}

void CIndicatorDyn::OnActiveLow()
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH, MF_BYCOMMAND | MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW, MF_BYCOMMAND | MF_CHECKED);
	ActiveHigh = FALSE;
	ModifiedFlag = TRUE;
}

void CIndDArchWnd::OnActiveHigh()
{
	((CIndicatorDyn*)pElement)->OnActiveHigh();
}

void CIndDArchWnd::OnActiveLow()
{
	((CIndicatorDyn*)pElement)->OnActiveLow();
}

void CIndDConstrWnd::OnActiveHigh()
{
	((CIndicatorDyn*)pElement)->OnActiveHigh();
}

void CIndDConstrWnd::OnActiveLow()
{
	((CIndicatorDyn*)pElement)->OnActiveLow();
}

void CIndicatorDyn::DrawSegments(CDC* pDC, bool isSelected, bool isArchMode, CPoint Pos)
{
	CGdiObject *pOldPen, *pOldBrush;
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
		colorBackground = RGB(0, 0, 0);
	}
	else {
		colorBackground = RGB(0, 0, 0);
	}
	for (int n = 0; n < 8; n++) {
		BOOL isOn = HighLighted[n] != 0;
		COLORREF c;
		if (EditMode) {
			c = colorBackground;
		}
		else {
			if (isOn) {
				float lum = luminance2(HighLighted[n], *pTickCounter, ticksAfterLight);
				c = RGB(round(255.0 * lum), 0, 0);
			}
			else {
				c = colorBackground;
			}
		}

		CBrush brush(c);
		pOldBrush=pDC->SelectObject(&brush);
		CPoint SegImage[6];
		memcpy(SegImage, IndImage[n], sizeof(SegImage));
		for (int i = 0; i < 6; i++) SegImage[i] += Pos;
		pDC->Polygon(SegImage, 6);
		pDC->SelectObject(pOldBrush);
	}
	pDC->SelectObject(pOldPen);
}

void CIndDArchWnd::DrawDynamic(CDC* pDC)
{
	CIndicatorDyn* pIndElement = reinterpret_cast<CIndicatorDyn*>(pElement);

	CString Temp;
	DWORD PinState = pIndElement->GetPinState();
	for (int n = 0; n < 8; n++) {
		BOOL NewBit = PinState & 1;

		CDC* pCharsDc;
		if (pIndElement->EditMode) {
			pCharsDc = &theApp.DrawOnWhiteChar;
		}else {
			if (NewBit)
				pCharsDc = &theApp.SelOnWhiteChar;
			else
				pCharsDc = &theApp.DrawOnWhiteChar;
		}
		pDC->BitBlt(8, 3 + n * 15, 8, 8, pCharsDc, n * 8, 0, SRCCOPY);
		PinState >>= 1;
	}

	pIndElement->DrawSegments(pDC, pIndElement->ArchSelected, true, CPoint(21, 40));
}

void CIndDConstrWnd::DrawDynamic(CDC* pDC)
{
	CIndicatorDyn* pIndElement = reinterpret_cast<CIndicatorDyn*>(pElement);

	pIndElement->DrawSegments(pDC, pIndElement->ConstrSelected, false, CPoint(0, 0));
}

void CIndDConstrWnd::Redraw(int64_t ticks) {
	CIndicatorDyn* pIndElement = reinterpret_cast<CIndicatorDyn*>(pElement);

	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = pIndElement->IsRedrawRequired();
}

int CIndDConstrWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

void CIndDConstrWnd::Draw(CDC* pDC) {
	CIndicatorDyn* pIndElement = reinterpret_cast<CIndicatorDyn*>(pElement);
	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CIndDConstrWnd::DrawStatic(CDC* pDC)
{
	pDC->PatBlt(0, 0, Size.cx, Size.cy, BLACKNESS);
}

void CIndDArchWnd::Redraw(int64_t ticks) {
	CIndicatorDyn* pIndElement = reinterpret_cast<CIndicatorDyn*>(pElement);

	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = pIndElement->IsRedrawRequired();
}

int CIndDArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

void CIndDArchWnd::Draw(CDC* pDC) {
	CIndicatorDyn* pIndElement = reinterpret_cast<CIndicatorDyn*>(pElement);
	std::lock_guard<std::mutex> lock(pIndElement->mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CIndDArchWnd::DrawStatic(CDC* pDC)
{
	CGdiObject* pOldPen;
	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	CBrush SelectBrush(theApp.SelectColor);
	CBrush NormalBrush(theApp.DrawColor);

	if (pElement->ArchSelected)
		pDC->FrameRect(CRect(6, 0, Size.cx, Size.cy - 6), &SelectBrush);
	else pDC->FrameRect(CRect(6, 0, Size.cx, Size.cy - 6), &NormalBrush);

	CBrush BackBrush(RGB(0, 0, 0));
	CGdiObject* pOldBrush = pDC->SelectObject(&BackBrush);
	pDC->PatBlt(17, 1, Size.cx - 18, Size.cy - 8, PATCOPY);
	pDC->SelectObject(pOldBrush);

	CPen* pTempPen;
	if (pElement->ArchSelected) pTempPen = &theApp.SelectPen;
	else pTempPen = &theApp.DrawPen;
	pOldPen = pDC->SelectObject(pTempPen);

	pDC->MoveTo(16, 0);
	pDC->LineTo(16, Size.cy - 6);

	//Рисуем проводки
	for (int n = 0; n < 8; n++) {
		pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		pDC->LineTo(pElement->ConPoint[n].x + 4, pElement->ConPoint[n].y);
	}
	pDC->MoveTo(pElement->ConPoint[8].x, pElement->ConPoint[8].y);
	pDC->LineTo(pElement->ConPoint[8].x, pElement->ConPoint[8].y - 4);

	for (int n = 0; n < 8; n++) {
		pDC->PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, WHITENESS);
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
	pDC->PatBlt(pElement->ConPoint[8].x - 2, pElement->ConPoint[8].y - 2, 5, 5, WHITENESS);
	if (pElement->ConPin[8]) {
		pDC->SelectObject(pTempPen);
		pDC->MoveTo(pElement->ConPoint[8].x, pElement->ConPoint[8].y + 2);
		pDC->LineTo(pElement->ConPoint[8].x, pElement->ConPoint[8].y - 3);
	}
	else {
		pDC->SelectObject(&BluePen);
		pDC->MoveTo(pElement->ConPoint[8].x - 2, pElement->ConPoint[8].y - 2);
		pDC->LineTo(pElement->ConPoint[8].x + 3, pElement->ConPoint[8].y + 3);
		pDC->MoveTo(pElement->ConPoint[8].x - 2, pElement->ConPoint[8].y + 2);
		pDC->LineTo(pElement->ConPoint[8].x + 3, pElement->ConPoint[8].y - 3);
	}

	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
}

bool CIndicatorDyn::IsRedrawRequired() {
	for (int n = 0; n < 8; n++) {
		if (HighLighted[n] >= 0) {
			return true;
		}
	}

	return false;
}

void CIndicatorDyn::SetPinState(DWORD NewState)
{
	if (NewState == PinState) return;

	PinState = NewState;

	std::lock_guard<std::mutex> lock(mutexDraw);

	DWORD bitsOn = 0;
	if (ActiveHigh) {
		bitsOn = NewState & 0x000000FF;
		if (NewState & 0x00000100) bitsOn=0;
	}
	else {
		bitsOn = ~(NewState & 0x000000FF);
		if ((NewState & 0x00000100) == 0) bitsOn = 0;
	}

	for (int n = 0; n < 8; n++) {
		if (bitsOn & 1)
			HighLighted[n] = -1;
		else {
			if (HighLighted[n] == -1)
				HighLighted[n] = *pTickCounter + ticksAfterLight;
		}
		bitsOn >>= 1;
	}

	if (pArchElemWnd->IsWindowEnabled()) {
		pArchElemWnd->scheduleRedraw();
	}
	if (pConstrElemWnd->IsWindowEnabled()) {
		pConstrElemWnd->scheduleRedraw();
	}
}

DWORD CIndicatorDyn::GetPinState()
{
	return PinState;
}
