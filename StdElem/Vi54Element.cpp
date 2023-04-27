#include "stdafx.h"

#include "Vi54Element.h"
#include "Vi54SettingsDlg.h"

#include "StdElemApp.h"
#include "utils.h"

#include "Vi54IoPort.h"

#include <VersionHelpers.h>

Vi54IoPort CVi54Element::Vi54Port(TRUE, -1);
std::shared_ptr<CElement> CVi54Element::pVi54Router = nullptr;
CElement* CVi54Element::pCounter[3] = { nullptr, nullptr, nullptr };

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
	Size.cy = 52 + (pVi54Element->isFixedFreq ? 0 : 15);

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
	if (!pVi54Element->isFixedFreq) {
		pDC->Rectangle(6, 37, Size.cx - 6, 37 + 15 + 1);
	}
	else {
		pDC->Rectangle(6, 37, Size.cx - 6, 37 + 15);
	}
	pDC->MoveTo(Size.cx/2, 37);
	pDC->LineTo(Size.cx / 2, 37+15);

	if (!pVi54Element->isFixedFreq) {
		pDC->Rectangle(6, 52, Size.cx - 6, 52 + 15);
	}
	pDC->SelectObject(pOldBrush);

	pDC->DrawText("ВИ54", CRect(7, 7, Size.cx - 7, 7+15),
		DT_CENTER | DT_SINGLELINE | DT_VCENTER);
	CString addr;
	if (pVi54Element->indexTimer >= 0)
		addr.Format("[%04Xh]", CVi54Element::Vi54Port.Addresses[0] + pVi54Element->indexTimer);
	else
		addr = "[----]";

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

	//Восстанавливаем контекст
	pDC->SelectObject(pOldPen);
	pDC->SelectObject(pOldFont);
}

void CVi54ArchWnd::DrawDynamic(CDC* pDC) {
	CVi54Element* pVi54Element = reinterpret_cast<CVi54Element*>(pElement);

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

	if (!pVi54Element->isFixedFreq) {
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
	indexTimer = -1;

	for (int n = 0; n < 3; n++) {
		if (pCounter[n] == nullptr) {
			indexTimer = n;
			pCounter[indexTimer] = this;
			break;
		}
	}

	pArchElemWnd = new CVi54ArchWnd(this);

	updatePoints();

	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	PopupMenu.LoadMenu(IDR_TIMER_MENU);
}

CVi54Element::~CVi54Element() {
	for (int n = 0; n < 3; n++) {
		if (pCounter[n] == this) {
			pCounter[n] = nullptr;
		}
	}
}

void CVi54Element::updatePoints() {
	PointCount = 2 + (isFixedFreq ? 0 : 1);

	ConPoint[0].x = 2; ConPoint[0].y = 44;
	ConPin[0] = FALSE; PinType[0] = PT_INPUT;

	ConPoint[1].x = 69; ConPoint[1].y = 44;
	ConPin[1] = FALSE; PinType[1] = PT_OUTPUT;

	if (!isFixedFreq) {
		ConPoint[2].x = 2; ConPoint[2].y = 59;
		ConPin[2] = FALSE; PinType[2] = PT_INPUT;
	}
}

BOOL CVi54Element::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	DWORD styleEx = IsWindows8OrGreater() ? WS_EX_LAYERED : 0;
	pArchElemWnd->CreateEx(styleEx, ClassName, "Таймер", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);

	pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	UpdateTipText();

	return TRUE;
}

void CVi54Element::UpdateTipText()
{
	if (indexTimer >= 0) {
		TipText = std::format("Канал {} таймера", indexTimer + 1).c_str();
	}
	else {
		TipText = std::format("Канал ? таймера").c_str();
	}
}

BOOL CVi54Element::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) {
	counter = nullptr;
	this->pTickCounter = pTickCounter;
	if (bEditMode) {
		if (pVi54Router.get() == this) {
			pVi54Router.reset();
		}
		if (idInstructionListener >= 0) {
			theApp.pHostInterface->DeleteInstructionListener(idInstructionListener);
			idInstructionListener = -1;
		}
	}
	else {
		if (indexTimer >= 0 && indexTimer<=2) {
			if (!pVi54Router) {
				pVi54Router = shared_from_this();
			}
			counter = &Vi54Port.Vi54.GetCounter(indexTimer);
		}

		if (isFixedFreq) {
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

	Vi54Port.Vi54.Reset();
	PinState = 0;

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

void CVi54Element::updateClk() {
	if (!counter) return;

	int64_t nanosClock;
	if (isRealtime) {
		LARGE_INTEGER li;
		::QueryPerformanceCounter(&li);
		nanosClock = 1000000000L * (li.QuadPart - timeStart) / perfFreq;
	}
	else {
		nanosClock = 1000000000L * (*pTickCounter) / theApp.pHostInterface->TaktFreq;
	}
	bool outPrev = counter->GetOut();
	bool outOld = outPrev;
	bool outNew = outPrev;
	for (int64_t nanos = nanosPrevClk + nanosFreq; nanos < nanosClock; nanos += nanosFreq) {
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
	for (int n = 0; n < 3; n++) {
		if (pCounter[n] == nullptr || pCounter[n] == this)
			Dlg.validCounterNumbers.insert(n);
	}
	Dlg.address = static_cast<uint16_t>(Vi54Port.Addresses[0]);
	Dlg.indexTimer = indexTimer;
	Dlg.freq = freq;
	Dlg.isFixedFreq = isFixedFreq;
	if (Dlg.DoModal() == IDOK) {
		indexTimer = Dlg.indexTimer;
		freq = Dlg.freq;
		isFixedFreq = Dlg.isFixedFreq;
		Vi54Port.Addresses[0] = Dlg.address;

		for (int n = 0; n < 3; n++) {
			if (pCounter[n] == this)
				pCounter[n] = nullptr;
		}
		pCounter[indexTimer] = this;

		ModifiedFlag = TRUE;

		pArchElemWnd->GetParent()->SendMessage(WMU_ARCHELEM_DISCONNECT, 0, id);
		updatePoints();
		reinterpret_cast<CVi54ArchWnd*>(pArchElemWnd)->updateSize();
		pArchElemWnd->GetParent()->SendMessage(WMU_ARCHELEM_CONNECT, 0, id);

		for (CWnd* pChild = pArchParentWnd->GetWindow(GW_CHILD); pChild != NULL; pChild = pChild->GetWindow(GW_HWNDNEXT))
		{
			pChild->Invalidate(FALSE);
		}
		UpdateTipText();
	}
}

void CVi54Element::SetPortData(DWORD Address, DWORD Data) {
	if (indexTimer < 0) return;

	Vi54Port.Vi54.Write(Address - Vi54Port.Addresses[0], static_cast<uint8_t>(Data));

	Vi54Counter& counter = Vi54Port.Vi54.GetCounter(indexTimer);
	bool outNew = counter.GetOut();
	bool outOld = (PinState & 2) != 0;
	if (outNew != outOld) {
		PinState = PinState & (0xffffffff ^ 2) | (outNew ? 2 : 0);
		theApp.pHostInterface->OnPinStateChanged(PinState, id);
		pArchElemWnd->scheduleRedraw();
	}
}

DWORD CVi54Element::GetPortData(DWORD Address) {
	if (indexTimer < 0) return 0;

	return Vi54Port.Vi54.Read(Address - Vi54Port.Addresses[0]);
}

BOOL CVi54Element::Save(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&Vi54Port.Addresses[0], 4);
	File.Write(&indexTimer, 4);
	File.Write(&freq, 4);
	File.Write(&isFixedFreq, 4);

	return CElementBase::Save(hFile);
}

BOOL CVi54Element::Load(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "ВИ54: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	File.Read(&Vi54Port.Addresses[0], 4);
	File.Read(&indexTimer, 4);
	if (indexTimer < 0 || indexTimer>2) indexTimer = -1;
	File.Read(&freq, 4);
	File.Read(&isFixedFreq, 4);

	updatePoints();
	reinterpret_cast<CVi54ArchWnd*>(pArchElemWnd)->updateSize();

	for (int n = 0; n < 3; n++) {
		if (pCounter[n] == this)
			pCounter[n]=nullptr;
	}
	if(indexTimer>=0)
		pCounter[indexTimer] = this;

	return CElementBase::Load(hFile);
}

std::vector<DWORD> CVi54Element::GetAddresses() {
	if (indexTimer < 0) return std::vector<DWORD>();

	if (!pVi54Router) {
		pVi54Router = shared_from_this();
	}

	std::vector<DWORD> res;
	res.push_back(Vi54Port.Addresses[0] + indexTimer);
	if (pVi54Router.get() == this)
		res.push_back(Vi54Port.Addresses[0]+3);

	return res;
}

void CVi54Element::SetPinState(DWORD NewState) {
	if (!counter) return;

	bool gate = (NewState & 1) > 0;
	counter->SetGate(gate);
	if (!isFixedFreq) {
		bool clk = (NewState & 4) > 0;
		counter->SetClk(clk);
	}

	bool outNew = counter->GetOut();
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
