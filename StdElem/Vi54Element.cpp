#include "stdafx.h"

#include "Vi54Element.h"
#include "Vi54SettingsDlg.h"

#include "StdElemApp.h"
#include "utils.h"

BEGIN_MESSAGE_MAP(CVi54ArchWnd, CElementWnd)
	ON_WM_CREATE()
	ON_COMMAND(ID_SETTINGS, OnSettings)
END_MESSAGE_MAP()

CVi54ArchWnd::CVi54ArchWnd(CElementBase* pElement) : CElementWnd(pElement) {
	updateSize();
}

CVi54ArchWnd::~CVi54ArchWnd() {
}

void CVi54ArchWnd::updateSize() {
	CVi54Element* pVi54Element = reinterpret_cast<CVi54Element*>(pElement);

	Size.cx = 72;
	Size.cy = 52 + (pVi54Element->freq==0 ? 15 : 0);

	if (m_hWnd) {
		WINDOWPLACEMENT Pls;
		GetWindowPlacement(&Pls);
		MoveWindow(Pls.rcNormalPosition.left, Pls.rcNormalPosition.top, Size.cx, Size.cy);
	}
}

void CVi54ArchWnd::DrawStatic(CDC* pDC) {
	CVi54Element* pVi54Element = reinterpret_cast<CVi54Element*>(pElement);

	CBrush grayBrush;
	grayBrush.CreateSolidBrush(theApp.GrayColor);

	CGdiObject* pOldPen, * pOldFont;
	CPen* pTempPen;
	if (pElement->ArchSelected)
		pTempPen = &theApp.SelectPen;
	else pTempPen = &theApp.DrawPen;
	pOldPen = pDC->SelectObject(pTempPen);

	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	pOldFont = pDC->SelectObject(&DrawFont);
	pDC->SetTextColor(theApp.DrawColor);
	pDC->SetBkColor(theApp.GrayColor);

	CGdiObject* pOldBrush = pDC->SelectObject(&grayBrush);
	pDC->Rectangle(6, 0, Size.cx-6, 37+1);
	pOldBrush = pDC->SelectObject(&theApp.BkBrush);
	if (pVi54Element->freq == 0) {
		pDC->Rectangle(6, 37, Size.cx - 6, 37 + 15 + 1);
	}
	else {
		pDC->Rectangle(6, 37, Size.cx - 6, 37 + 15);
	}
	pDC->MoveTo(Size.cx/2, 37);
	pDC->LineTo(Size.cx / 2, 37+15);

	if (pVi54Element->freq == 0) {
		pDC->Rectangle(6, 52, Size.cx - 6, 52 + 15);
	}
	pDC->SelectObject(pOldBrush);

	pDC->DrawText("��54", CRect(7, 7, Size.cx - 7, 7+15),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);
	CString addr;
	addr.Format("[%04Xh]", theApp.Vi54Port.Addresses[0] + pVi54Element->indexTimer);
	pDC->DrawText(addr, CRect(7, 19, Size.cx - 7, 19+15),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);

	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	for (int n = 0; n < pElement->PointCount; n++) {
		pDC->PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, WHITENESS);
		pDC->SelectObject(pTempPen);
		if (n == 0 || n == 2) {
			pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
			pDC->LineTo(pElement->ConPoint[n].x + 4, pElement->ConPoint[n].y);
		}
		else {
			pDC->MoveTo(pElement->ConPoint[n].x - 4, pElement->ConPoint[n].y);
			pDC->LineTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		}

		//������ �������, ���� ����
		if (!pElement->ConPin[n]) {
			pDC->SelectObject(&BluePen);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y + 3);
			pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y + 2);
			pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y - 3);
		}
		else { //��� �������
			pDC->SelectObject(pTempPen);
			if (n == 0 || n == 2) {
				pDC->MoveTo(0, pElement->ConPoint[n].y);
				pDC->LineTo(pElement->ConPoint[n].x + 1, pElement->ConPoint[n].y);
			}
			else {
				pDC->MoveTo(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y);
				pDC->LineTo(pElement->ConPoint[n].x + 3, pElement->ConPoint[n].y);
			}
		}
	}

	//��������������� ��������
	pDC->SelectObject(pOldPen);
	pDC->SelectObject(pOldFont);
}

void CVi54ArchWnd::DrawDynamic(CDC* pDC) {
	CVi54Element* pVi54Element = reinterpret_cast<CVi54Element*>(pElement);
	Vi54Counter& counter = theApp.Vi54Port.Vi54.GetCounter(pVi54Element->indexTimer);

	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	CGdiObject *pOldFont = pDC->SelectObject(&DrawFont);
	pDC->SetBkColor(theApp.BkColor);
	
	DWORD pinState = pVi54Element->GetPinState();
	if(pinState & 1)
		pDC->SetTextColor(theApp.OnColor);
	else
		pDC->SetTextColor(theApp.DrawColor);
	pDC->DrawText("Gate", CRect(9, 37 + 1, Size.cx / 2, 52 - 2),
		DT_LEFT | DT_SINGLELINE | DT_VCENTER);

	if (pinState & 2)
		pDC->SetTextColor(theApp.OnColor);
	else
		pDC->SetTextColor(theApp.DrawColor);
	pDC->DrawText("Out", CRect(Size.cx / 2, 37 + 1, Size.cx - 9, 52 - 2),
		DT_RIGHT | DT_SINGLELINE | DT_VCENTER);

	if (pVi54Element->freq == 0) {
		if (pinState & 4)
			pDC->SetTextColor(theApp.OnColor);
		else
			pDC->SetTextColor(theApp.DrawColor);
		pDC->DrawText("Clk", CRect(9, 52 + 1, Size.cx / 2, 67 - 2),
			DT_LEFT | DT_SINGLELINE | DT_VCENTER);
	}

	pDC->SelectObject(pOldFont);
}


int CVi54ArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, 68);

	return 0;
}

void CVi54ArchWnd::Draw(CDC* pDC) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CVi54ArchWnd::Redraw(int64_t ticks) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}

void CVi54ArchWnd::OnSettings() {
	reinterpret_cast<CVi54Element*>(pElement)->OnSettings();
}

CVi54Element::CVi54Element(BOOL ArchMode, int id) : CElementBase(ArchMode, id) {
	IdIndex = 11;
	indexTimer = 0;

	pArchElemWnd = new CVi54ArchWnd(this);

	updatePoints();

	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	PopupMenu.LoadMenu(IDR_TIMER_MENU);
}

CVi54Element::~CVi54Element() {
}

void CVi54Element::updatePoints() {
	PointCount = 2 + (freq>0 ? 0 : 1);

	ConPoint[0].x = 2; ConPoint[0].y = 44;
	ConPin[0] = FALSE; PinType[0] = PT_INPUT;

	ConPoint[1].x = 69; ConPoint[1].y = 44;
	ConPin[1] = FALSE; PinType[1] = PT_OUTPUT;

	if (freq == 0) {
		ConPoint[2].x = 2; ConPoint[2].y = 59;
		ConPin[2] = FALSE; PinType[2] = PT_INPUT;
	}
}

BOOL CVi54Element::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	pArchElemWnd->CreateEx(WS_EX_LAYERED, ClassName, "������", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);

	pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	UpdateTipText();

	return TRUE;
}

void CVi54Element::UpdateTipText()
{
	TipText = "������";
}

BOOL CVi54Element::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) {
	if (bEditMode) {
		if (theApp.pVi54Router.get() == this) {
			theApp.pVi54Router.reset();
		}
		if (idInstructionListener >= 0) {
			theApp.pHostInterface->DeleteInstructionListener(idInstructionListener);
			idInstructionListener = -1;
		}
	}
	else {
		if (!theApp.pVi54Router) {
			theApp.pVi54Router = shared_from_this();
		}

		counter = &theApp.Vi54Port.Vi54.GetCounter(indexTimer);
		if (freq > 0) {
			int ticksPerClk = theApp.pHostInterface->TaktFreq / freq;
			if (ticksPerClk < 12) {
				idInstructionListener = theApp.pHostInterface->AddInstructionListener([this](int64_t ticks) { OnInstructionListener(ticks);  });
			}
			else {
				theApp.pHostInterface->SetTickTimer(ticksPerClk, ticksPerClk, id, [this](DWORD) { updateClk(); });
			}
			LARGE_INTEGER li;
			::QueryPerformanceFrequency(&li);
			perfFreq = li.QuadPart;
			nanosFreq = 1000000000L / freq;
			::QueryPerformanceCounter(&li);
			timeStart = li.QuadPart;
			nanosPrevClk = 0;
		}
	}

	theApp.Vi54Port.Vi54.Reset();
	PinState = 0;

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

void CVi54Element::updateClk() {
	LARGE_INTEGER li;
	::QueryPerformanceCounter(&li);
	int64_t nanosWallClock = 1000000000L * (li.QuadPart - timeStart) / perfFreq;
	bool outPrev = counter->GetOut();
	bool outOld = outPrev;
	bool outNew = outPrev;
	for (int64_t nanos = nanosPrevClk + nanosFreq; nanos < nanosWallClock; nanos += nanosFreq) {
		counter->SetClk(true);
		outNew = counter->GetOut();
		if (outNew != outOld) {
			PinState = PinState & (0xffffffff ^ 2) | (counter->GetOut() ? 2 : 0);
			theApp.pHostInterface->OnPinStateChanged(PinState, id);
			outOld = outNew;
		}
		counter->SetClk(false);
		outNew = counter->GetOut();
		if (outNew != outOld) {
			PinState = PinState & (0xffffffff ^ 2) | (counter->GetOut() ? 2 : 0);
			theApp.pHostInterface->OnPinStateChanged(PinState, id);
			outOld = outNew;
		}
		nanosPrevClk = nanos;
	}
	if (outPrev != outNew)
		pArchElemWnd->scheduleRedraw();
}

void CVi54Element::OnInstructionListener(int64_t ticks) {
	updateClk();
}

void CVi54Element::OnSettings() {
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	Vi54SettingsDlg Dlg;
	Dlg.indexTimer = indexTimer;
	Dlg.SetBaseAddress(static_cast<uint16_t>(theApp.Vi54Port.Addresses[0]));
	Dlg.SetFreq(freq);
	if (Dlg.DoModal() == IDOK) {
		indexTimer = Dlg.indexTimer;
		freq = Dlg.GetFreq();
		theApp.Vi54Port.Addresses[0] = Dlg.GetBaseAddress();
		ModifiedFlag = TRUE;

		pArchElemWnd->GetParent()->SendMessage(WMU_ARCHELEM_DISCONNECT, 0, id);
		updatePoints();
		reinterpret_cast<CVi54ArchWnd*>(pArchElemWnd)->updateSize();
		pArchElemWnd->GetParent()->SendMessage(WMU_ARCHELEM_CONNECT, 0, id);

		for (CWnd* pChild = pArchParentWnd->GetWindow(GW_CHILD); pChild != NULL; pChild = pChild->GetWindow(GW_HWNDNEXT))
		{
			pChild->Invalidate(FALSE);
		}
	}
}

void CVi54Element::SetPortData(DWORD Address, DWORD Data) {
	theApp.Vi54Port.Vi54.Write(Address - theApp.Vi54Port.Addresses[0], static_cast<uint8_t>(Data));

	Vi54Counter& counter = theApp.Vi54Port.Vi54.GetCounter(indexTimer);
	bool outNew = counter.GetOut();
	bool outOld = (PinState & 2) != 0;
	if (outNew != outOld) {
		PinState = PinState & (0xffffffff ^ 2) | (outNew ? 2 : 0);
		theApp.pHostInterface->OnPinStateChanged(PinState, id);
		pArchElemWnd->scheduleRedraw();
	}
}

DWORD CVi54Element::GetPortData(DWORD Address) {
	return theApp.Vi54Port.Vi54.Read(Address - theApp.Vi54Port.Addresses[0]);
}

BOOL CVi54Element::Save(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&theApp.Vi54Port.Addresses[0], 4);
	File.Write(&indexTimer, 4);
	File.Write(&freq, 4);

	return CElementBase::Save(hFile);
}

BOOL CVi54Element::Load(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "��54: ����������� ������ ��������", "������", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	File.Read(&theApp.Vi54Port.Addresses[0], 4);
	File.Read(&indexTimer, 4);
	File.Read(&freq, 4);

	updatePoints();
	reinterpret_cast<CVi54ArchWnd*>(pArchElemWnd)->updateSize();

	return CElementBase::Load(hFile);
}

std::vector<DWORD> CVi54Element::GetAddresses() {
	if (!theApp.pVi54Router) {
		theApp.pVi54Router = shared_from_this();
	}

	std::vector<DWORD> res;
	res.push_back(theApp.Vi54Port.Addresses[0] + indexTimer);
	if (theApp.pVi54Router.get() == this)
		res.push_back(theApp.Vi54Port.Addresses[0]+3);

	return res;
}

void CVi54Element::SetPinState(DWORD NewState) {
	Vi54Counter& counter = theApp.Vi54Port.Vi54.GetCounter(indexTimer);

	bool gate = (NewState & 1) > 0;
	counter.SetGate(gate);
	if (freq == 0) {
		bool clk = (NewState & 4) > 0;
		counter.SetClk(clk);
	}

	bool outNew = counter.GetOut();
	bool outOld = (PinState & 2) != 0;
	PinState = NewState & (0xffffffff ^ 2) | (outNew ? 2 : 0);
	if (outNew != outOld) {
		theApp.pHostInterface->OnPinStateChanged(PinState, id);
	}

	pArchElemWnd->scheduleRedraw();
}

DWORD CVi54Element::GetPinState() {
	return PinState;
}
