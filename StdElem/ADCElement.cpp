// Button.cpp: implementation of the CADCElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ADCElement.h"
#include "..\definitions.h"
#include "utils.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CADCElement::CADCElement(BOOL ArchMode, int id)
	: CElementBase(ArchMode, id)
{
	IdIndex = 8;
	SliderState = 0; Delay = 10; StartState = 0; ReadyState = 0;
	LoLimit = "0.00"; HiLimit = "10.24";
	HiPrecision = FALSE;

	pArchElemWnd = new CADCArchWnd(this);
	pConstrElemWnd = new CADCConstrWnd(this);

	ChangePinConfiguration();

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	PopupMenu.LoadMenu(IDR_ADC_MENU);
	PopupMenu.CheckMenuItem(ID_HI_PRECISION, MF_BYCOMMAND | MF_UNCHECKED);
	AfxSetResourceHandle(hInstOld);
}

CADCElement::~CADCElement()
{
}

BOOL CADCElement::Load(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "АЦП: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}
	File.Read(&Delay, sizeof(Delay));

	int StrLen;
	char s[16];

	File.Read(&StrLen, 4);
	if (StrLen > 15) return FALSE;
	File.Read(&s, StrLen);
	s[StrLen] = 0;
	LoLimit = s;

	File.Read(&StrLen, 4);
	if (StrLen > 15) return FALSE;
	File.Read(&s, StrLen);
	s[StrLen] = 0;
	HiLimit = s;

	File.Read(&HiPrecision, 4);

	if (HiPrecision)
		PopupMenu.CheckMenuItem(ID_HI_PRECISION, MF_BYCOMMAND | MF_CHECKED);
	else
		PopupMenu.CheckMenuItem(ID_HI_PRECISION, MF_BYCOMMAND | MF_UNCHECKED);

	return CElementBase::Load(hFile);
}

BOOL CADCElement::Save(HANDLE hFile)
{
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&Delay, sizeof(Delay));

	int StrLen;

	StrLen = LoLimit.GetLength();
	if (StrLen > 15) StrLen = 15;
	File.Write(&StrLen, 4);
	File.Write((LPCTSTR)LoLimit, StrLen);

	StrLen = HiLimit.GetLength();
	if (StrLen > 15) StrLen = 15;
	File.Write(&StrLen, 4);
	File.Write((LPCTSTR)HiLimit, StrLen);

	File.Write(&HiPrecision, 4);

	return CElementBase::Save(hFile);
}

BOOL CADCElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->CreateEx(WS_EX_LAYERED, ClassName, "АЦП", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);
	pConstrElemWnd->Create(ClassName, "АЦП", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS,
		CRect(0, 0, pConstrElemWnd->Size.cx, pConstrElemWnd->Size.cy), pConstrParentWnd, 0);

	pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	ChangePinConfiguration();
	((CADCArchWnd*)pArchElemWnd)->SetRange(HiPrecision);
	((CADCConstrWnd*)pConstrElemWnd)->SetRange(HiPrecision);

	UpdateTipText();

	return TRUE;
}

BOOL CADCElement::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	SliderState = 0; StartState = 0; ReadyState = 0;
	DelayTicks = Delay * (TaktFreq / 1000);
	StartState = 0;
	State = -1;

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CADCArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CADCArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CADCArchWnd)
	ON_WM_CREATE()
	ON_WM_VSCROLL()
	ON_COMMAND(ID_DELAY, OnDelay)
	ON_COMMAND(ID_LIMITS, OnLimits)
	ON_COMMAND(ID_HI_PRECISION, OnHiPrecision)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CADCArchWnd::CADCArchWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 60 + 6 + 16;
	Size.cy = 8 * 15 + 2 * 10;
}

CADCArchWnd::~CADCArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CADCConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CADCConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CADCConstrWnd)
	ON_WM_CREATE()
	ON_WM_VSCROLL()
	ON_COMMAND(ID_DELAY, OnDelay)
	ON_COMMAND(ID_LIMITS, OnLimits)
	ON_COMMAND(ID_HI_PRECISION, OnHiPrecision)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CADCConstrWnd::CADCConstrWnd(CElementBase* pElement) : CElementWnd(pElement)
{
	Size.cx = 29 + 31;
	Size.cy = 92;
}

CADCConstrWnd::~CADCConstrWnd()
{
}

void CADCConstrWnd::Draw(CDC* pDC)
{
	DWORD Value = ((CADCElement*)pElement)->SliderState;
	if (((CADCElement*)pElement)->HiPrecision) Slider.SetPos(65535 - Value);
	else Slider.SetPos(255 - Value);

	CBrush SelectBrush(theApp.SelectColor);
	CBrush NormalBrush(theApp.DrawColor);

	CRect MainRect(0, 0, Size.cx, Size.cy);
	if (pElement->ConstrSelected)
		pDC->FrameRect(MainRect, &SelectBrush);
	else pDC->FrameRect(MainRect, &NormalBrush);

	CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
	CGdiObject* pOldBrush = pDC->SelectObject(&GrayBrush);
	pDC->PatBlt(29, 1, Size.cx - 29 - 1, Size.cy - 2, PATCOPY);
	pDC->SelectObject(pOldBrush);

	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	CGdiObject* pOldFont = pDC->SelectObject(&DrawFont);

	pDC->SetTextColor(theApp.DrawColor);

	pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
	//Подписи к слайдеру
	pDC->DrawText(((CADCElement*)pElement)->LoLimit, CRect(30, Size.cy - 18, Size.cx - 1, Size.cy - 7),
		DT_LEFT | DT_SINGLELINE | DT_BOTTOM);
	pDC->DrawText(((CADCElement*)pElement)->HiLimit, CRect(30, 1, Size.cx - 1, 21),
		DT_LEFT | DT_SINGLELINE | DT_BOTTOM);

	pDC->SelectObject(pOldFont);
}

int CADCArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	Slider.Create(TBS_VERT | TBS_RIGHT | TBS_AUTOTICKS | WS_VISIBLE | WS_CHILD,
		CRect(7, 33, 36, Size.cy - 15), this, 1);
	Slider.SetRange(0, 255);
	Slider.SetPageSize(64);
	Slider.SetTicFreq(64);
	Slider.SetPos(255);

	return 0;
}

void CADCArchWnd::Draw(CDC* pDC)
{
	std::lock_guard<std::mutex> lock(mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CADCArchWnd::DrawStatic(CDC* pDC)
{
	CADCElement* pAdcElement = reinterpret_cast<CADCElement*>(pElement);

	CGdiObject* pOldPen, * pOldFont;
	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	CBrush SelectBrush(theApp.SelectColor);
	CBrush NormalBrush(theApp.DrawColor);
	CPen* pTempPen;
	if (pElement->ArchSelected)
		pTempPen = &theApp.SelectPen;
	else pTempPen = &theApp.DrawPen;
	pOldPen = pDC->SelectObject(pTempPen);
	pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));

	CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
	CGdiObject* pOldBrush = pDC->SelectObject(&GrayBrush);
	pDC->PatBlt(7, 1, Size.cx - 24, Size.cy - 15, PATCOPY);
	pDC->SelectObject(pOldBrush);

	pDC->SetTextColor(theApp.DrawColor);

	CString Temp;

	CRect MainRect(6, 0, Size.cx - 6, Size.cy);
	if (pElement->ArchSelected)
		pDC->FrameRect(MainRect, &SelectBrush);
	else pDC->FrameRect(MainRect, &NormalBrush);
	pDC->MoveTo(Size.cx - 17, 0); pDC->LineTo(Size.cx - 17, Size.cy - 15);
	pDC->MoveTo(6, Size.cy - 15); pDC->LineTo(Size.cx - 6, Size.cy - 15);
	pDC->MoveTo(Size.cx / 2, Size.cy - 15); pDC->LineTo(Size.cx / 2, Size.cy);

	//Рисуем проводки
	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	pOldFont = pDC->SelectObject(&DrawFont);
	for (int n = 0; n < pElement->PointCount; n++) {
		pDC->PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, WHITENESS);
		pDC->SelectObject(pTempPen);
		if (n == 0) {
			pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
			pDC->LineTo(pElement->ConPoint[n].x + 4, pElement->ConPoint[n].y);
		}
		else {
			pDC->MoveTo(pElement->ConPoint[n].x - 4, pElement->ConPoint[n].y);
			pDC->LineTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		}

		//Рисуем крестик, если надо
		if (!pElement->ConPin[n]) {
			pDC->SelectObject(&BluePen);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y + 3);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y + 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y - 3);
		}
		else { //или палочку
			pDC->SelectObject(pTempPen);
			if (n == 0) {
				pDC->MoveTo(0, pElement->ConPoint[n].y);
				pDC->LineTo(pElement->ConPoint[n].x + 1, pElement->ConPoint[n].y);
			}
			else {
				pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y);
				pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y);
			}
		}
	}
	//Текст внутри порта
	pDC->DrawText("ADC", CRect(7, 5, Size.cx - 16, 18),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);

	//Подписи к слайдеру
	pDC->DrawText(pAdcElement->LoLimit,
		CRect(37, Size.cy - 37, Size.cx - 16, Size.cy - 22),
		DT_LEFT | DT_SINGLELINE | DT_BOTTOM);
	pDC->DrawText(pAdcElement->HiLimit,
		CRect(37, 40, Size.cx - 16, 52),
		DT_LEFT | DT_SINGLELINE | DT_TOP);

	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
	pDC->SelectObject(pOldFont);

	if (pAdcElement->HiPrecision) {
		if (Slider.GetPos()!= 65535 - pAdcElement->SliderState)
			Slider.SetPos(65535 - pAdcElement->SliderState);
	}
	else {
		if (Slider.GetPos() != 255 - pAdcElement->SliderState)
			Slider.SetPos(255 - pAdcElement->SliderState);
	}
}

void CADCElement::UpdateTipText()
{
	TipText = "АЦП";
}

DWORD CADCElement::GetPinState()
{
	DWORD Res = 0;
	if (ReadyState) Res = (SliderState << 2) | (ReadyState << 1) | StartState;
	else Res = StartState;

	return Res;
}

int CADCConstrWnd::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CElementWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

	Slider.Create(TBS_VERT | TBS_RIGHT | TBS_AUTOTICKS | WS_VISIBLE | WS_CHILD,
		CRect(1, 1, 29, Size.cy - 1), this, 1);
	Slider.SetRange(0, 255);
	Slider.SetPageSize(64);
	Slider.SetTicFreq(64);
	Slider.SetPos(255);

	return 0;
}

void CADCArchWnd::DrawDynamic(CDC* pDC)
{
	CADCElement* pAdcElement = reinterpret_cast<CADCElement*>(pElement);

	DWORD Value = pAdcElement->SliderState;

	CGdiObject* pOldFont;
	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	pOldFont = pDC->SelectObject(&DrawFont);
	pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
	pDC->SetTextColor(theApp.DrawColor);
	CString Temp;
	Temp.Format("(%04Xh)", Value);
	pDC->FillSolidRect(7, 18, Size.cx - 25, 31 - 18, GetSysColor(COLOR_BTNFACE));
	pDC->DrawText(Temp, CRect(7, 18, Size.cx - 16, 31),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);

	if (pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
	else pDC->SetTextColor(theApp.DrawColor);

	pDC->SetBkColor(theApp.BkColor);
	pDC->FillSolidRect(Size.cx - 16, 1, 9, Size.cy-16, theApp.BkColor);
	DWORD CurVal = pElement->GetPinState() >> 2;
	CDC* pNumDC;
	for (int n = 0; n < pElement->PointCount - 2; n++) {
		if ((CurVal & (1 << n))) pNumDC = &theApp.SelOnWhiteNumb;
		else pNumDC = &theApp.DrawOnWhiteNumb;
		pDC->BitBlt(Size.cx - 15, 4 + n * 15, 8, 8, pNumDC, n * 8, 0, SRCCOPY);
	}

	if (pElement->GetPinState() & 1)
		pDC->SetTextColor(theApp.OnColor);
	else
		pDC->SetTextColor(theApp.DrawColor);
	pDC->FillSolidRect(7, Size.cy - 14, 34, 13, theApp.BkColor);
	pDC->DrawText("Start", CRect(8, Size.cy - 12, 30, Size.cy - 1), DT_LEFT | DT_SINGLELINE | DT_BOTTOM);
	if (pAdcElement->ReadyState)
		pDC->SetTextColor(theApp.OnColor);
	else
		pDC->SetTextColor(theApp.DrawColor);
	pDC->FillSolidRect(42, Size.cy - 14, 33, 13, theApp.BkColor);
	pDC->DrawText("Rdy", CRect(Size.cx - 36, Size.cy - 12, Size.cx - 9, Size.cy - 1), DT_RIGHT | DT_SINGLELINE | DT_BOTTOM);

	//Восстанавливаем контекст
	pDC->SelectObject(pOldFont);
}

void CADCArchWnd::Redraw(int64_t ticks) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}

void CADCArchWnd::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)
{
	if (((CADCElement*)pElement)->HiPrecision) ((CADCElement*)pElement)->SliderState = 65535 - Slider.GetPos();
	else ((CADCElement*)pElement)->SliderState = 255 - Slider.GetPos();

	scheduleRedraw();
}

void CADCConstrWnd::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)
{
	if (((CADCElement*)pElement)->HiPrecision) ((CADCElement*)pElement)->SliderState = 65535 - Slider.GetPos();
	else ((CADCElement*)pElement)->SliderState = 255 - Slider.GetPos();
}

void CADCArchWnd::OnDelay()
{
	((CADCElement*)pElement)->OnDelay();
}

void CADCConstrWnd::OnDelay()
{
	((CADCElement*)pElement)->OnDelay();
}

void CADCElement::OnDelay()
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	CADCDelayDlg Dlg;
	Dlg.Delay = Delay;
	if (Dlg.DoModal() == IDOK) {
		Delay = Dlg.Delay;
		ModifiedFlag = TRUE;
	}
}
/////////////////////////////////////////////////////////////////////////////
// CADCDelayDlg dialog


CADCDelayDlg::CADCDelayDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CADCDelayDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCDelayDlg)
	Delay = 0;
	//}}AFX_DATA_INIT
}


void CADCDelayDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CADCDelayDlg)
	DDX_Text(pDX, IDC_DELAY, Delay);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CADCDelayDlg, CDialog)
	//{{AFX_MSG_MAP(CADCDelayDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CADCDelayDlg message handlers

void CADCElement::SetPinState(DWORD NewState)
{
	State = -1;

	DWORD OldStartState = StartState;
	StartState = NewState & 1;

	//Если фронт
	if ((OldStartState != StartState) && (OldStartState == 0)) {
		if (DelayTicks) {
			ReadyState = 0;
			theApp.pHostInterface->SetTickTimer(*pTickCounter+DelayTicks, id, [this](DWORD) { OnTickTimer(); });
		}
		else {
			ReadyState = 1;
		}
	}

	theApp.pHostInterface->OnPinStateChanged(GetPinState(), id);

	if (pArchElemWnd->IsWindowEnabled()) {
		pArchElemWnd->scheduleRedraw();
	}
}

void CADCConstrWnd::OnLimits()
{
	((CADCElement*)pElement)->OnLimits();
}

void CADCArchWnd::OnLimits()
{
	((CADCElement*)pElement)->OnLimits();
}

void CADCElement::OnLimits()
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	CADCLimitsDlg Dlg;
	Dlg.m_LoLimit = LoLimit;
	Dlg.m_HiLimit = HiLimit;
	if (Dlg.DoModal() == IDOK) {
		LoLimit = Dlg.m_LoLimit;
		HiLimit = Dlg.m_HiLimit;
		pArchElemWnd->RedrawWindow();
		pConstrElemWnd->RedrawWindow();
		ModifiedFlag = TRUE;
	}
}
/////////////////////////////////////////////////////////////////////////////
// CADCLimitsDlg dialog


CADCLimitsDlg::CADCLimitsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CADCLimitsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCLimitsDlg)
	m_HiLimit = _T("");
	m_LoLimit = _T("");
	//}}AFX_DATA_INIT
}


void CADCLimitsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CADCLimitsDlg)
	DDX_Text(pDX, IDC_HILIMIT, m_HiLimit);
	DDV_MaxChars(pDX, m_HiLimit, 5);
	DDX_Text(pDX, IDC_LOLIMIT, m_LoLimit);
	DDV_MaxChars(pDX, m_LoLimit, 5);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CADCLimitsDlg, CDialog)
	//{{AFX_MSG_MAP(CADCLimitsDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CADCLimitsDlg message handlers

void CADCElement::OnTickTimer()
{
	ReadyState = 1;

	DWORD stateNew = GetPinState();
	if (stateNew == State) return;

	State = stateNew;
	theApp.pHostInterface->OnPinStateChanged(State, id);

	if (pArchElemWnd->IsWindowEnabled()) {
		pArchElemWnd->scheduleRedraw();
	}
}

void CADCArchWnd::OnHiPrecision()
{
	((CADCElement*)pElement)->OnHiPrecision();
}

void CADCConstrWnd::OnHiPrecision()
{
	((CADCElement*)pElement)->OnHiPrecision();
}

void CADCElement::OnHiPrecision()
{
	HiPrecision = !HiPrecision;
	if (HiPrecision)
		PopupMenu.CheckMenuItem(ID_HI_PRECISION, MF_BYCOMMAND | MF_CHECKED);
	else
		PopupMenu.CheckMenuItem(ID_HI_PRECISION, MF_BYCOMMAND | MF_UNCHECKED);

	ChangePinConfiguration();

	((CADCArchWnd*)pArchElemWnd)->SetRange(HiPrecision);
	((CADCConstrWnd*)pConstrElemWnd)->SetRange(HiPrecision);
	pArchElemWnd->Invalidate();
	pConstrElemWnd->Invalidate();

	ModifiedFlag = TRUE;
}

void CADCElement::ChangePinConfiguration()
{
	//0-Start, 1-Ready, 2-...-Data
	if (HiPrecision) PointCount = 18;
	else PointCount = 10;

	ConPoint[0].x = 2; ConPoint[0].y = (PointCount - 2) * 15 + 2 * 10 - 7;
	ConPin[0] = FALSE; PinType[0] = PT_INPUT;

	ConPoint[1].x = pArchElemWnd->Size.cx - 3;
	ConPoint[1].y = PointCount * 15 - 5 - 12;
	ConPin[1] = FALSE; PinType[1] = PT_OUTPUT;

	for (int n = 2; n < PointCount; n++) {
		ConPoint[n].x = pArchElemWnd->Size.cx - 3;
		ConPoint[n].y = n * 15 - 20;
		ConPin[n] = FALSE; PinType[n] = PT_OUTPUT;
	}
}

void CADCArchWnd::SetRange(BOOL HiPrecision)
{
	if (HiPrecision) {
		Slider.SetRange(0, 65535);
		Size.cx = 60 + 6 + 16;
		Size.cy = 16 * 15 + 2 * 10;
	}
	else {
		Slider.SetRange(0, 255);
		Size.cx = 60 + 6 + 16;
		Size.cy = 8 * 15 + 2 * 10;
	}

	WINDOWPLACEMENT Pls;
	GetWindowPlacement(&Pls);
	MoveWindow(Pls.rcNormalPosition.left, Pls.rcNormalPosition.top, Size.cx, Size.cy);
	Slider.MoveWindow(7, 33, 29, Size.cy - 15 - 33);

	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, Size.cx, Size.cy);

	GetParent()->Invalidate();
}

void CADCConstrWnd::SetRange(BOOL HiPrecision)
{
	if (HiPrecision) Slider.SetRange(0, 65535);
	else Slider.SetRange(0, 255);
}
