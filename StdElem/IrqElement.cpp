#include "stdafx.h"
#include "IrqElement.h"
#include "IrqSettingsDlg.h"

#include "StdElemApp.h"
#include "utils.h"

#include <VersionHelpers.h>

BEGIN_MESSAGE_MAP(CIrqArchWnd, CElementWnd)
	ON_WM_CREATE()
	ON_COMMAND(ID_SETTINGS, OnSettings)
END_MESSAGE_MAP()

CIrqArchWnd::CIrqArchWnd(CElementBase* pElement) : CElementWnd(pElement) {
	Size.cx = 60;
	Size.cy = 19;
}

CIrqArchWnd::~CIrqArchWnd() {

}

void CIrqArchWnd::DrawStatic(CDC* pDC) {
	IrqElement* pIrqElement = reinterpret_cast<IrqElement*>(pElement);

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
	pDC->SetBkColor(theApp.BkColor);

	CGdiObject* pOldBrush = pDC->SelectObject(&theApp.BkBrush);
	pDC->Rectangle(6 , 0, Size.cx, Size.cy);
	pDC->SelectObject(pOldBrush);

	CPen BluePen(PS_SOLID, 0, RGB(0, 0, 255));
	for (int n = 0; n < pElement->PointCount; n++) {
		pDC->PatBlt(pElement->ConPoint[n].x - 2, pElement->ConPoint[n].y - 2, 5, 5, WHITENESS);
		pDC->SelectObject(pTempPen);
		pDC->MoveTo(pElement->ConPoint[n].x, pElement->ConPoint[n].y);
		pDC->LineTo(pElement->ConPoint[n].x + 4, pElement->ConPoint[n].y);

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

void CIrqArchWnd::DrawDynamic(CDC* pDC) {
	IrqElement* pIrqElement = reinterpret_cast<IrqElement*>(pElement);

	CFont DrawFont;
	DrawFont.CreatePointFont(80, "Arial Cyr");
	CGdiObject* pOldFont = pDC->SelectObject(&DrawFont);
	pDC->SetBkColor(theApp.BkColor);

	DWORD pinState = pIrqElement->GetPinState();
	if (pinState & 1)
		pDC->SetTextColor(theApp.OnColor);
	else
		pDC->SetTextColor(theApp.DrawColor);
	std::string text;
	if (pIrqElement->irqNumber == 2)
		text = "NMI";
	else
		text = std::format("INT {:02X}h", pIrqElement->irqNumber);
	pDC->DrawText(text.c_str(), CRect(9+2, 1 + 1, Size.cx-1, Size.cy - 1),
		DT_LEFT | DT_SINGLELINE | DT_VCENTER);

	pDC->SelectObject(pOldFont);
}


int CIrqArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) {
	CClientDC dc(this);
	createCompatibleDc(&dc, &MemoryDC, lpCreateStruct->cx, lpCreateStruct->cy);

	return 0;
}

void CIrqArchWnd::Draw(CDC* pDC) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	DrawStatic(&MemoryDC);
	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	pDC->BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);
}

void CIrqArchWnd::Redraw(int64_t ticks) {
	std::lock_guard<std::mutex> lock(mutexDraw);

	CClientDC DC(this);

	DrawDynamic(&MemoryDC);

	CRect rect;
	GetWindowRect(&rect);
	DC.BitBlt(0, 0, rect.Width(), rect.Height(), &MemoryDC, 0, 0, SRCCOPY);

	m_isRedrawRequired = false;
}

void CIrqArchWnd::OnSettings() {
	reinterpret_cast<IrqElement*>(pElement)->OnSettings();
}


IrqElement::IrqElement(BOOL ArchMode, int id) : CElementBase(ArchMode, id) {
	IdIndex = 12;

	pArchElemWnd = new CIrqArchWnd(this);

	updatePoints();

	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	PopupMenu.LoadMenu(IDR_IRQ_MENU);
}

IrqElement::~IrqElement() {

}

DWORD IrqElement::GetPinState() {
	return PinState;
}

BOOL IrqElement::Save(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version = 0x00010000;
	File.Write(&Version, 4);

	File.Write(&irqNumber, 4);
	File.Write(&activeHigh, 4);

	return CElementBase::Save(hFile);
}

BOOL IrqElement::Load(HANDLE hFile) {
	CFile File(hFile);

	DWORD Version;
	File.Read(&Version, 4);
	if (Version != 0x00010000) {
		MessageBox(NULL, "IRQ: неизвестная версия элемента", "Ошибка", MB_ICONSTOP | MB_OK);
		return FALSE;
	}

	File.Read(&irqNumber, 4);
	File.Read(&activeHigh, 4);

	return CElementBase::Load(hFile);
}

void IrqElement::OnSettings() {
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	IrqSettingsDlg Dlg;
	Dlg.irqNumber = irqNumber;
	Dlg.activeHigh = activeHigh;
	if (Dlg.DoModal() == IDOK) {
		irqNumber = Dlg.irqNumber;
		activeHigh = Dlg.activeHigh;
		ModifiedFlag = TRUE;
		UpdateTipText();
		pArchElemWnd->Invalidate();
	}
}

BOOL IrqElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	if (!CElementBase::Show(hArchParentWnd, hConstrParentWnd)) return FALSE;

	CString ClassName = AfxRegisterWndClass(CS_DBLCLKS,
		::LoadCursor(NULL, IDC_ARROW));
	DWORD styleEx = IsWindows8OrGreater() ? WS_EX_LAYERED : 0;
	pArchElemWnd->CreateEx(styleEx, ClassName, "IRQ", WS_VISIBLE | WS_OVERLAPPED | WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
		CRect(0, 0, pArchElemWnd->Size.cx, pArchElemWnd->Size.cy), pArchParentWnd, 0);

	pArchElemWnd->SetLayeredWindowAttributes(RGB(255, 255, 255), 255, LWA_COLORKEY);

	UpdateTipText();

	return TRUE;
}

void IrqElement::UpdateTipText()
{
	TipText.Format("Запрос прерывания %d", irqNumber);
}

BOOL IrqElement::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) {
	PinState = 0;
	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

void IrqElement::updatePoints() {
	PointCount = 1;

	ConPoint[0].x = 2; ConPoint[0].y = 10;
	ConPin[0] = FALSE; PinType[0] = PT_INPUT;
}

void IrqElement::SetPinState(DWORD NewState) {
	if ((NewState & 1) == (PinState & 1)) return;

	PinState = NewState;

	bool activated = (NewState & 1) == (activeHigh ? 1 : 0);
	if (activated) {
		theApp.pHostInterface->Interrupt(irqNumber);
	}

	pArchElemWnd->scheduleRedraw();
}
