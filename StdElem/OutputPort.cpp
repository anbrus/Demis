// OutputPort.cpp: implementation of the COutputPort class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ElemInterf.h"
#include "OutputPort.h"
#include "AddressDlg.h"
#include "..\definitions.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

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
		MessageBox(NULL, "���� ������: ����������� ������ ��������", "������", MB_ICONSTOP | MB_OK);
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

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->Create(ClassName, "���� ������", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy),
		CWnd::FromHandle(hArchParentWnd), 0);

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

static void createMemoryDC(CDC* pDC, CDC* pMemoryDC, int width, int height) {
	pMemoryDC->CreateCompatibleDC(pDC);
	CBitmap bmp;
	bmp.CreateCompatibleBitmap(pDC, width, height);
	HGDIOBJ hBmpOld = pMemoryDC->SelectObject(bmp);
	DeleteObject(hBmpOld);
	pMemoryDC->PatBlt(0, 0, width, height, WHITENESS);
}

int COutPortArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);

	createMemoryDC(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);
	
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
			pDC->BitBlt(WorkPntArray[n + 30].x - 3, WorkPntArray[n + 30].y - 4, 6, 8, &theApp.SelOnWhiteNumb, n * 8, 0, SRCCOPY);
		else pDC->BitBlt(WorkPntArray[n + 30].x - 3, WorkPntArray[n + 30].y - 4, 6, 8,
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
	pDC->SetBkColor(theApp.GrayColor);
	pDC->SetTextColor(theApp.DrawColor);

	CString Temp;

	CRect MainRect(WorkPntArray[0].x, WorkPntArray[0].y, WorkPntArray[1].x, WorkPntArray[1].y);
	MainRect.NormalizeRect();
	if (pElement->ArchSelected)
		pDC->FrameRect(MainRect, &SelectBrush);
	else pDC->FrameRect(MainRect, &NormalBrush);

	CBrush GrayBrush(theApp.GrayColor);
	CGdiObject* pOldBrush = pDC->SelectObject(&GrayBrush);
	CRect FillRect(WorkPntArray[2].x, WorkPntArray[2].y, WorkPntArray[3].x, WorkPntArray[3].y);
	FillRect.NormalizeRect();
	pDC->PatBlt(FillRect.left, FillRect.top, FillRect.Width(), FillRect.Height(), PATCOPY);
	pDC->SelectObject(pOldBrush);

	pDC->MoveTo(WorkPntArray[4].x, WorkPntArray[4].y);
	pDC->LineTo(WorkPntArray[5].x, WorkPntArray[5].y);

	//������ ��������
	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	pOldFont = pDC->SelectObject(&DrawFont);
	//���������� �����: n*3+6
	//���������� ������ ������: n*3+7
	//���������� ����� ������: n*3+8
	for (int n = 0; n < 8; n++) {
		pDC->PatBlt(WorkPntArray[n * 3 + 6].x - 2, WorkPntArray[n * 3 + 6].y - 2, 5, 5, WHITENESS);
		pDC->SelectObject(pTempPen);
		pDC->MoveTo(WorkPntArray[n * 3 + 7].x, WorkPntArray[n * 3 + 7].y);
		pDC->LineTo(WorkPntArray[n * 3 + 6].x, WorkPntArray[n * 3 + 6].y);

		//������ �������, ���� ����
		if (!pElement->ConPin[n]) {
			pDC->SelectObject(&BluePen);
			pDC->MoveTo(WorkPntArray[n * 3 + 6].x - 2, WorkPntArray[n * 3 + 6].y - 2);
			pDC->LineTo(WorkPntArray[n * 3 + 6].x + 3, WorkPntArray[n * 3 + 6].y + 3);
			pDC->MoveTo(WorkPntArray[n * 3 + 6].x - 2, WorkPntArray[n * 3 + 6].y + 2);
			pDC->LineTo(WorkPntArray[n * 3 + 6].x + 3, WorkPntArray[n * 3 + 6].y - 3);
		}
		else { //��� �������
			pDC->SelectObject(pTempPen);
			pDC->MoveTo(WorkPntArray[n * 3 + 6].x, WorkPntArray[n * 3 + 6].y);
			pDC->LineTo(WorkPntArray[n * 3 + 8].x, WorkPntArray[n * 3 + 8].y);
		}
	}
	//����� ������ �����
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
	Temp.Format("(     h)", pElement->Addresses[0] & 0xFFFF);
	pDC->DrawText(Temp, CRect(X, Y + 2 * 13, X + 35, Y + 3 * 13), DT_CENTER | DT_SINGLELINE | DT_TOP);

	//��������������� ��������
	pDC->SelectObject(pOldPen);
	pDC->SelectObject(pOldFont);
}

void COutputPort::UpdateTipText()
{
	TipText.Format("���� ������ [%04Xh]", Addresses[0]);
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
	TRACE("������� ��������� ��������� ������� � ����� ������\n");
}

DWORD COutputPort::GetPinState()
{
	return Value;
}


void COutPortArchWnd::InitializePoints()
{
	int PntNumber = 0;
	OrgPntArray.SetSize(40);
	//���������� ��������� ��������������: 0,1
	OrgPntArray[PntNumber].x = 0; OrgPntArray[PntNumber].y = 0;
	PntNumber++;
	OrgPntArray[PntNumber].x = 60 - 6; OrgPntArray[PntNumber].y = 125;
	PntNumber++;
	//���������� ������������ ��������������: 2,3
	OrgPntArray[PntNumber].x = 1; OrgPntArray[PntNumber].y = 1;
	PntNumber++;
	OrgPntArray[PntNumber].x = 60 - 17; OrgPntArray[PntNumber].y = 125 - 1;
	PntNumber++;
	//���������� ������������ �����: 4,5
	OrgPntArray[PntNumber].x = 60 - 17; OrgPntArray[PntNumber].y = 0;
	PntNumber++;
	OrgPntArray[PntNumber].x = 60 - 17; OrgPntArray[PntNumber].y = 125;
	PntNumber++;
	//���������� ���������
	int n;
	for (n = 0; n < 8; n++) {
		//���������� �����: n*3+6
		OrgPntArray[PntNumber].x = 60 - 3;
		OrgPntArray[PntNumber].y = 10 + n * 15;
		PntNumber++;
		//���������� ������ ������: n*3+7
		OrgPntArray[PntNumber].x = 60 - 3 - 3;
		OrgPntArray[PntNumber].y = 10 + n * 15;
		PntNumber++;
		//���������� ����� ������: n*3+8
		OrgPntArray[PntNumber].x = 60 - 3 + 3;
		OrgPntArray[PntNumber].y = 10 + n * 15;
		PntNumber++;
	}
	//���������� �������� - ������� �����: n+30
	for (n = 0; n < 8; n++) {
		OrgPntArray[PntNumber].x = 60 - 12;
		OrgPntArray[PntNumber].y = 11 + n * 15;
		PntNumber++;
	}
	//������ � ������
	OrgPntArray[PntNumber].x = 60;
	OrgPntArray[PntNumber].y = 125;
	PntNumber++;

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
		pElement->ConPoint[n].x = WorkPntArray[n * 3 + 6].x;
		pElement->ConPoint[n].y = WorkPntArray[n * 3 + 6].y;
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
	MemoryDC.DeleteDC();
	createMemoryDC(&dc, &MemoryDC, Size.cx, Size.cy);
	Invalidate();
	GetParent()->SendMessage(WMU_ARCHELEM_CONNECT, 0, pElement->id);
}

void COutPortArchWnd::updateMenu(CMenu& PopupMenu) {
	PopupMenu.CheckMenuItem(ID_OUTPUTS_RIGHT, MF_BYCOMMAND | (Angle == 0 ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_OUTPUTS_DOWN, MF_BYCOMMAND | (Angle == 90 ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_OUTPUTS_LEFT, MF_BYCOMMAND | (Angle == 180 ? MF_CHECKED : MF_UNCHECKED));
	PopupMenu.CheckMenuItem(ID_OUTPUTS_UP, MF_BYCOMMAND | (Angle == 270 ? MF_CHECKED : MF_UNCHECKED));
}
