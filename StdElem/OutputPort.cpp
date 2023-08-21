// OutputPort.cpp: implementation of the COutputPort class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ElemInterf.h"
#include "OutputPort.h"
#include "AddressDlg.h"
#include "..\definitions.h"
#include "utils.h"

#include <VersionHelpers.h>

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

constexpr int idxRectMain1 = 0;
constexpr int idxRectMain2 = 1;
constexpr int idxRectFilled1 = 2;
constexpr int idxRectFilled2 = 3;
constexpr int idxRectValues1 = 4;
constexpr int idxRectValues2 = 5;
constexpr int idxVerticalLine1 = 6;
constexpr int idxVerticalLine2 = 7;
constexpr int idxWidth = 8;
constexpr int idxHeight = 9;
constexpr int idxFirstPoint = 10;
constexpr int idxFirstValue = 34;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COutputPort::COutputPort(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
{
	IdIndex = 1;
	Value = 0;
	Addresses.push_back(0);
	
	pArchElemWnd = new COutPortArchWnd(this);
	pConstrElemWnd = NULL;

	PointCount = 8;
	for (int n = 0; n < 8; n++) {
		//ConPoint[n].x=pArchElemWnd->Size.cx-3;
		//ConPoint[n].y=10+n*15;
		ConPin[n] = FALSE;
		PinType[n] = PT_OUTPUT;
	}

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_OUTPUT_PORT_MENU);
	AfxSetResourceHandle(hInstOld);
}

COutputPort::~COutputPort()
{
}

BOOL COutputPort::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "Порт вывода: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	File.Read(&Addresses[0], 4);

	return CElementBase::Load(hFile);
}

BOOL COutputPort::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&Addresses[0], 4);

	return CElementBase::Save(hFile);
}

BOOL COutputPort::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	((COutPortArchWnd*)pArchElemWnd)->InitializePoints();

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS, ::LoadCursor(NULL, IDC_ARROW));
	DWORD styleEx = IsWindows8OrGreater() ? WS_EX_LAYERED : 0;
	pArchElemWnd->CreateEx(styleEx, ClassName, "Порт вывода", WS_VISIBLE | WS_CHILD,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy),
		CWnd::FromHandle(hArchParentWnd), 0);

	pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	reinterpret_cast<COutPortArchWnd*>(pArchElemWnd)->updateMenu(PopupMenu);
	UpdateTipText();

	return TRUE;
}

BOOL COutputPort::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	if (bEditMode) Value = 0;
	else Value = 0;

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CLedArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(COutPortArchWnd, CElementWnd)
	ON_COMMAND(ID_ADDRESS, OnAddress)
	ON_COMMAND_RANGE(ID_OUTPUTS_RIGHT, ID_OUTPUTS_UP, OnRotate)
	ON_WM_CREATE()
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COutPortArchWnd::COutPortArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
}

COutPortArchWnd::~COutPortArchWnd()
{
}

int COutPortArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);

	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);
	
	return 0;
}

void COutPortArchWnd::DrawDynamic(CDC* pDC)
{
	DWORD NewVal = ((COutputPort*)pElement)->Value;
	int HiByte = (NewVal >> 4) & 0x0F;
	int LoByte = NewVal & 0x0F;

	CDC *pNumbDC = &theApp.DrawOnGrayNumb;

	int X = 0, Y = 0;
	switch (Angle) {
	case 0: X = 4; Y = 4; break;
	case 90: X = 4; Y = 1; break;
	case 180: X = 21; Y = 4; break;
	case 270: X = 4; Y = 19; break;
	}
	pDC->BitBlt(X + 8, Y + 13 * 2 + 4, 6, 8, pNumbDC, HiByte * 8, 0, SRCCOPY);
	pDC->BitBlt(X + 14, Y + 13 * 2 + 4, 6, 8, pNumbDC, LoByte * 8, 0, SRCCOPY);

	for (int n = 0; n < 8; n++) {
		BOOL BitSetted = (NewVal&(1 << n)) > 0;
		if (BitSetted)
			pDC->BitBlt(WorkPntArray[idxFirstValue+n].x - 3, WorkPntArray[idxFirstValue + n].y - 4, 6, 8, &theApp.SelOnWhiteNumb, n * 8, 0, SRCCOPY);
		else pDC->BitBlt(WorkPntArray[idxFirstValue + n].x - 3, WorkPntArray[idxFirstValue + n].y - 4, 6, 8,
			&theApp.DrawOnWhiteNumb, n * 8, 0, SRCCOPY);
	}
}

void COutPortArchWnd::OnAddress()
{
	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	CAddressDlg Dlg(this);
	Dlg.SetAddress((WORD)pElement->Addresses[0]);
	if (Dlg.DoModal() == IDOK) {
		pElement->Addresses[0] = (DWORD)Dlg.GetAddress();
		RedrawWindow();
		pElement->ModifiedFlag = TRUE;
		((COutputPort*)pElement)->UpdateTipText();
	}
	AfxSetResourceHandle(hInstOld);
}

void COutPortArchWnd::Redraw(int64_t ticks) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	m_isRedrawRequired = false;
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	CClientDC DC(this);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void COutPortArchWnd::Draw(CDC *pDC) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void COutPortArchWnd::DrawStatic(CDC *pDC)
{
	CGdiObject *pOldPen, *pOldFont;
	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	CBrush SelectBrush(theApp.SelectColor);
	CBrush NormalBrush(theApp.DrawColor);
	CPen* pTempPen;
	if (pElement->ArchSelected)
		pTempPen = &theApp.SelectPen;
	else pTempPen = &theApp.DrawPen;
	pOldPen = pDC->SelectObject(pTempPen);

	CString Temp;

	CRect MainRect(WorkPntArray[idxRectMain1].x, WorkPntArray[idxRectMain1].y, WorkPntArray[idxRectMain2].x, WorkPntArray[idxRectMain2].y);
	MainRect.NormalizeRect();
	if (pElement->ArchSelected)
		pDC->FrameRect(MainRect, &SelectBrush);
	else pDC->FrameRect(MainRect, &NormalBrush);

	CBrush GrayBrush(theApp.GrayColor);
	CGdiObject* pOldBrush = pDC->SelectObject(&GrayBrush);
	CRect FillRect(WorkPntArray[idxRectFilled1].x, WorkPntArray[idxRectFilled1].y, WorkPntArray[idxRectFilled2].x, WorkPntArray[idxRectFilled2].y);
	FillRect.NormalizeRect();
	pDC->PatBlt(FillRect.left, FillRect.top, FillRect.Width(), FillRect.Height(), PATCOPY);
	pDC->SelectObject(pOldBrush);

	pDC->MoveTo(WorkPntArray[idxVerticalLine1].x, WorkPntArray[idxVerticalLine1].y);
	pDC->LineTo(WorkPntArray[idxVerticalLine2].x, WorkPntArray[idxVerticalLine2].y);

	CRect ValuesRect(WorkPntArray[idxRectValues1].x, WorkPntArray[idxRectValues1].y, WorkPntArray[idxRectValues2].x, WorkPntArray[idxRectValues2].y);
	pDC->FillSolidRect(ValuesRect.left, ValuesRect.top, ValuesRect.Width(), ValuesRect.Height(), RGB(254, 254, 254));


	//Рисуем проводки
	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	pOldFont = pDC->SelectObject(&DrawFont);
	pDC->SetBkColor(theApp.GrayColor);
	pDC->SetTextColor(theApp.DrawColor);
	//Координаты точки: n*3+6
	//Координаты начала вывода: n*3+7
	//Координаты конца вывода: n*3+8
	for (int n = 0; n < 8; n++) {
		pDC->PatBlt(WorkPntArray[idxFirstPoint + n * 3 + 0].x - 2, WorkPntArray[idxFirstPoint + n * 3 + 0].y - 2, 5, 5, WHITENESS);
		pDC->SelectObject(pTempPen);
		pDC->MoveTo(WorkPntArray[idxFirstPoint + n * 3 + 1].x, WorkPntArray[idxFirstPoint + n * 3 + 1].y);
		pDC->LineTo(WorkPntArray[idxFirstPoint + n * 3 + 0].x, WorkPntArray[idxFirstPoint + n * 3 + 0].y);

		//Рисуем крестик, если надо
		if (!pElement->ConPin[n]) {
			pDC->SelectObject(&BluePen);
			pDC->MoveTo(WorkPntArray[idxFirstPoint + n * 3 + 0].x - 2, WorkPntArray[idxFirstPoint + n * 3 + 0].y - 2);
			pDC->LineTo(WorkPntArray[idxFirstPoint + n * 3 + 0].x + 3, WorkPntArray[idxFirstPoint + n * 3 + 0].y + 3);
			pDC->MoveTo(WorkPntArray[idxFirstPoint + n * 3 + 0].x - 2, WorkPntArray[idxFirstPoint + n * 3 + 0].y + 2);
			pDC->LineTo(WorkPntArray[idxFirstPoint + n * 3 + 0].x + 3, WorkPntArray[idxFirstPoint + n * 3 + 0].y - 3);
		}
		else { //или палочку
			pDC->SelectObject(pTempPen);
			pDC->MoveTo(WorkPntArray[idxFirstPoint + n * 3 + 0].x, WorkPntArray[idxFirstPoint + n * 3 + 0].y);
			pDC->LineTo(WorkPntArray[idxFirstPoint + n * 3 + 2].x, WorkPntArray[idxFirstPoint + n * 3 + 2].y);
		}
	}
	//Текст внутри порта
	int X = 0, Y = 0;
	switch (Angle) {
	case 0: X = 4; Y = 4; break;
	case 90: X = 4; Y = 1; break;
	case 180: X = 21; Y = 4; break;
	case 270: X = 4; Y = 19; break;
	}
	pDC->DrawText("RGOUT", CRect(X, Y, X + 36, Y + 14),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);
	Temp.Format("[%04Xh]", pElement->Addresses[0] & 0xFFFF);
	pDC->DrawText(Temp, CRect(X, Y + 13, X + 36, Y + 2 * 13),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);
	Temp.Format("(     h)");
	pDC->DrawText(Temp, CRect(X, Y + 2 * 13, X + 35, Y + 3 * 13), DT_CENTER | DT_SINGLELINE | DT_TOP);

	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
	pDC->SelectObject(pOldFont);
}

void COutputPort::UpdateTipText()
{
	TipText.Format("Порт вывода [%04Xh]", Addresses[0]);
}

void COutputPort::SetPortData(DWORD Addresses, DWORD Data)
{
	if (Data == Value) return;

	DWORD OldValue = Value;
	Value = Data;
	if (pArchElemWnd->IsWindowEnabled()) {
		((COutPortArchWnd*)pArchElemWnd)->scheduleRedraw();
	}
	theApp.pHostInterface->OnPinStateChanged(Value, id);
}

void COutputPort::SetPinState(DWORD NewState)
{
	TRACE("Попытка установки состояния выводов у порта вывода\n");
}

DWORD COutputPort::GetPinState()
{
	return Value;
}

void COutPortArchWnd::InitializePoints()
{
	int PntNumber = 0;
	OrgPntArray.SetSize(42);
	//Координаты основного прямоугольника: 0,1
	OrgPntArray[idxRectMain1].x = 0; OrgPntArray[idxRectMain1].y = 0;
	PntNumber++;
	OrgPntArray[idxRectMain2].x = 60 - 6; OrgPntArray[idxRectMain2].y = 125;
	PntNumber++;
	//Координаты закрашенного прямоугольника: 2,3
	OrgPntArray[idxRectFilled1].x = 1; OrgPntArray[idxRectFilled1].y = 1;
	PntNumber++;
	OrgPntArray[idxRectFilled2].x = 60 - 17; OrgPntArray[idxRectFilled2].y = 125 - 1;
	PntNumber++;
	//Координаты белого прямоугольника: 4,5
	OrgPntArray[idxRectValues1].x = 60-17+1; OrgPntArray[idxRectValues1].y = 1;
	PntNumber++;
	OrgPntArray[idxRectValues2].x = 60 - 6-1; OrgPntArray[idxRectValues2].y = 125 - 1;
	PntNumber++;
	//Координаты вертикальной линии: 6,7
	OrgPntArray[idxVerticalLine1].x = 60 - 17; OrgPntArray[idxVerticalLine1].y = 0;
	PntNumber++;
	OrgPntArray[idxVerticalLine2].x = 60 - 17; OrgPntArray[idxVerticalLine2].y = 125;
	PntNumber++;
	//Ширина и высота
	OrgPntArray[idxWidth].x = 60;
	OrgPntArray[idxHeight].y = 125;
	PntNumber++;
	//Координаты контактов
	int n;
	for (n = 0; n < 8; n++) {
		//Координаты точки: n*3+8
		OrgPntArray[idxFirstPoint + n * 3].x = 60 - 3;
		OrgPntArray[idxFirstPoint + n * 3].y = 10 + n * 15;
		PntNumber++;
		//Координаты начала вывода: n*3+9
		OrgPntArray[idxFirstPoint + n * 3 + 1].x = 60 - 3 - 3;
		OrgPntArray[idxFirstPoint + n * 3 + 1].y = 10 + n * 15;
		PntNumber++;
		//Координаты конца вывода: n*3+10
		OrgPntArray[idxFirstPoint + n * 3 + 2].x = 60 - 3 + 3;
		OrgPntArray[idxFirstPoint + n * 3 + 2].y = 10 + n * 15;
		PntNumber++;
	}
	//Координаты надписей - номеров битов: n+32
	for (n = 0; n < 8; n++) {
		OrgPntArray[idxFirstValue + n].x = 60 - 12;
		OrgPntArray[idxFirstValue + n].y = 11 + n * 15;
		PntNumber++;
	}

	//Angle=90;
	SetAngle(Angle);
	int MaxX = -10000, MaxY = -10000, MinX = 10000, MinY = 10000;
	for (n = 0; n < WorkPntArray.GetSize(); n++) {
		if (WorkPntArray[n].x > MaxX) MaxX = WorkPntArray[n].x;
		if (WorkPntArray[n].y > MaxY) MaxY = WorkPntArray[n].y;
		if (WorkPntArray[n].x < MinX) MinX = WorkPntArray[n].x;
		if (WorkPntArray[n].y < MinY) MinY = WorkPntArray[n].y;
	}
	for (n = 0; n < WorkPntArray.GetSize(); n++) {
		WorkPntArray[n].x -= MinX;
		WorkPntArray[n].y -= MinY;
	}
	Size.cx = MaxX - MinX;
	Size.cy = MaxY - MinY;

	for (n = 0; n < 8; n++) {
		pElement->ConPoint[n].x = WorkPntArray[idxFirstPoint + n * 3].x;
		pElement->ConPoint[n].y = WorkPntArray[idxFirstPoint + n * 3].y;
	}
}

void COutPortArchWnd::OnRotate(UINT nId)
{
	GetParent()->SendMessage(WMU_ARCHELEM_DISCONNECT, 0, pElement->id);
	switch (nId) {
	case ID_OUTPUTS_RIGHT:
		SetAngle(0);
		break;
	case ID_OUTPUTS_DOWN:
		SetAngle(90);
		break;
	case ID_OUTPUTS_LEFT:
		SetAngle(180);
		break;
	case ID_OUTPUTS_UP:
		SetAngle(270);
		break;
	}

	updateMenu(pElement->PopupMenu);

	InitializePoints();

	WINDOWPLACEMENT pls;
	GetWindowPlacement(&pls);
	MoveWindow(pls.rcNormalPosition.left, pls.rcNormalPosition.top, Size.cx, Size.cy);

	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, Size.cx, Size.cy);
	Invalidate();
	GetParent()->SendMessage(WMU_ARCHELEM_CONNECT, 0, pElement->id);
}

void COutPortArchWnd::updateMenu(CMenu& PopupMenu) {
	PopupMenu.CheckMenuItem(ID_OUTPUTS_RIGHT, MF_BYCOMMAND | (Angle == 0 ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_OUTPUTS_DOWN, MF_BYCOMMAND | (Angle == 90 ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_OUTPUTS_LEFT, MF_BYCOMMAND | (Angle == 180 ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_OUTPUTS_UP, MF_BYCOMMAND | (Angle == 270 ? MF_CHECKED : MF_UNCHECKED));
}
