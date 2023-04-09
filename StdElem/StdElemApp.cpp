#include "stdafx.h"
#include "resource.h"
#include <initguid.h>
#include "StdElemApp.h"

#include "InputPort.h"
#include "OutputPort.h"
#include "LedElement.h"
#include "Button.h"
#include "Label.h"
#include "Indicator.h"
#include "IndicatorDyn.h"
#include "kbdelement.h"
#include "ADCElement.h"
#include "BeepElement.h"
#include "matrixelem.h"
#include "vi54element.h"
#include "IrqElement.h"

BEGIN_MESSAGE_MAP(CStdElemApp, CWinApp)
END_MESSAGE_MAP()

CStdElemApp theApp;

BOOL CStdElemApp::InitInstance()
{
	BkColor = RGB(254, 254, 254);
	GrayColor = RGB(0xe0, 0xe0, 0xe0);
	BlackColor = RGB(0, 0, 0);
	DrawColor = RGB(0, 0, 0);
	SelectColor = RGB(0xFF, 0x6D, 0x00);//GetSysColor(COLOR_HIGHLIGHT);
	OnColor = RGB(255, 0, 0);
	BkBrush.CreateSolidBrush(BkColor);
	DrawPen.CreatePen(PS_SOLID, 0, DrawColor);
	SelectPen.CreatePen(PS_SOLID, 0, SelectColor);

	CBitmap NumbBmp, CharBmp;
	CDC OrigDC;

	OrigDC.CreateCompatibleDC(NULL);
	DWORD Planes = OrigDC.GetDeviceCaps(PLANES);
	DWORD BitsPixel = OrigDC.GetDeviceCaps(BITSPIXEL);

	HINSTANCE hInstOld = AfxGetResourceHandle();
	HMODULE hDll = GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	NumbBmp.LoadBitmap(IDB_NUMBERS);
	CharBmp.LoadBitmap(IDB_CHARS);

	ElementId[0].Icon.LoadMappedBitmap(IDB_INPUT_PORT);
	ElementId[1].Icon.LoadMappedBitmap(IDB_OUT_PORT);
	ElementId[2].Icon.LoadMappedBitmap(IDB_LED_ELEMENT);
	ElementId[3].Icon.LoadMappedBitmap(IDB_BUTTON_ELEMENT);
	ElementId[4].Icon.LoadMappedBitmap(IDB_LABEL);
	ElementId[5].Icon.LoadMappedBitmap(IDB_INDICATOR_ELEMENT);
	ElementId[6].Icon.LoadMappedBitmap(IDB_INDIC_DYN_ELEMENT);
	ElementId[7].Icon.LoadMappedBitmap(IDB_KBD_ELEMENT);
	ElementId[8].Icon.LoadMappedBitmap(IDB_ADC_ELEMENT);
	ElementId[9].Icon.LoadMappedBitmap(IDB_BEEP_ELEMENT);
	ElementId[10].Icon.LoadMappedBitmap(IDB_MATRIX_ELEMENT);
	ElementId[11].Icon.LoadMappedBitmap(IDB_VI54_ELEMENT);
	ElementId[12].Icon.LoadMappedBitmap(IDB_IRQ_ELEMENT);

	AfxSetResourceHandle(hInstOld);

	//Numbers
	CGdiObject *pOldBitmap = OrigDC.SelectObject(&NumbBmp);

	DrawOnWhiteNumb.CreateCompatibleDC(NULL);
	DrawOnWhiteNumbBmp.CreateBitmap(128, 8, Planes, BitsPixel, NULL);
	DrawOnWhiteNumb.SelectObject(&DrawOnWhiteNumbBmp);
	DrawOnWhiteNumb.SetBkColor(BkColor);
	DrawOnWhiteNumb.BitBlt(0, 0, 128, 8, &OrigDC, 0, 0, SRCCOPY);

	DrawOnGrayNumb.CreateCompatibleDC(NULL);
	DrawOnGrayNumbBmp.CreateBitmap(128, 8, Planes, BitsPixel, NULL);
	DrawOnGrayNumb.SelectObject(&DrawOnGrayNumbBmp);
	DrawOnGrayNumb.SetBkColor(theApp.GrayColor);
	DrawOnGrayNumb.BitBlt(0, 0, 128, 8, &OrigDC, 0, 0, SRCCOPY);

	SelOnWhiteNumb.CreateCompatibleDC(NULL);
	SelOnWhiteNumbBmp.CreateBitmap(128, 8, Planes, BitsPixel, NULL);
	SelOnWhiteNumb.SelectObject(&SelOnWhiteNumbBmp);
	SelOnWhiteNumb.SetBkColor(BkColor);
	SelOnWhiteNumb.BitBlt(0, 0, 128, 8, &OrigDC, 0, 0, SRCCOPY);

	int x, y;
	for (y = 0; y < 8; y++) {
		for (x = 0; x < 128; x++) {
			DWORD OldCol = SelOnWhiteNumb.GetPixel(x, y);
			if (!OldCol) {
				SelOnWhiteNumb.SetPixelV(x, y, OnColor);
				OldCol = SelOnWhiteNumb.GetPixel(x, y);
			}
		}
	}

	SelOnGrayNumb.CreateCompatibleDC(NULL);
	SelOnGrayNumbBmp.CreateBitmap(128, 8, Planes, BitsPixel, NULL);
	SelOnGrayNumb.SelectObject(&SelOnGrayNumbBmp);
	SelOnGrayNumb.SetBkColor(theApp.GrayColor);
	SelOnGrayNumb.BitBlt(0, 0, 128, 8, &OrigDC, 0, 0, SRCCOPY);

	for (y = 0; y < 8; y++) {
		for (x = 0; x < 128; x++) {
			DWORD OldCol = SelOnGrayNumb.GetPixel(x, y);
			if (!OldCol)
				SelOnGrayNumb.SetPixelV(x, y, OnColor);
		}
	}

	//Chars
	OrigDC.SelectObject(&CharBmp);

	DrawOnWhiteChar.CreateCompatibleDC(NULL);
	DrawOnWhiteCharBmp.CreateBitmap(128, 8, Planes, BitsPixel, NULL);
	DrawOnWhiteChar.SelectObject(&DrawOnWhiteCharBmp);
	DrawOnWhiteChar.SetBkColor(BkColor);
	DrawOnWhiteChar.BitBlt(0, 0, 128, 8, &OrigDC, 0, 0, SRCCOPY);

	SelOnWhiteChar.CreateCompatibleDC(NULL);
	SelOnWhiteCharBmp.CreateBitmap(128, 8, Planes, BitsPixel, NULL);
	SelOnWhiteChar.SelectObject(&SelOnWhiteCharBmp);
	SelOnWhiteChar.SetBkColor(BkColor);
	SelOnWhiteChar.BitBlt(0, 0, 128, 8, &OrigDC, 0, 0, SRCCOPY);

	for (y = 0; y < 8; y++) {
		for (x = 0; x < 128; x++) {
			DWORD OldCol = SelOnWhiteChar.GetPixel(x, y);
			if (!OldCol)
				SelOnWhiteChar.SetPixelV(x, y, OnColor);
		}
	}

	OrigDC.SelectObject(pOldBitmap);

	CString pathHelp = m_pszHelpFilePath;
	pathHelp.Replace("StdElem.CHM", "Demis.chm");
	free((void*)m_pszHelpFilePath);
	m_pszHelpFilePath = _tcsdup(pathHelp);


	return CWinApp::InitInstance();
}

int CStdElemApp::ExitInstance()
{
	return CWinApp::ExitInstance();
}

CStdElemApp::CStdElemApp()
{
	EnableHtmlHelp();

	m_ElementsCount = 13;

	CString CurClsId("{6B4C02AF-DC58-4935-B438-552DEBB72761}");

	ElementId[0].Type = ET_ARCH | ET_INPUTPORT;
	ElementId[0].Name = "Порт ввода";
	ElementId[0].ClsId = CurClsId;

	ElementId[1].Type = ET_ARCH | ET_OUTPUTPORT;
	ElementId[1].Name = "Порт вывода";
	ElementId[1].ClsId = CurClsId;

	ElementId[2].Type = ET_ARCH | ET_CONSTR;
	ElementId[2].Name = "Светодиод";
	ElementId[2].ClsId = CurClsId;

	ElementId[3].Type = ET_ARCH | ET_CONSTR;
	ElementId[3].Name = "Кнопка";
	ElementId[3].ClsId = CurClsId;

	ElementId[4].Type = ET_ARCH | ET_CONSTR;
	ElementId[4].Name = "Текстовая метка";
	ElementId[4].ClsId = CurClsId;

	ElementId[5].Type = ET_ARCH | ET_CONSTR;
	ElementId[5].Name = "Семисегм. индикатор";
	ElementId[5].ClsId = CurClsId;

	ElementId[6].Type = ET_ARCH | ET_CONSTR;
	ElementId[6].Name = "Семисегм. дин. индикатор";
	ElementId[6].ClsId = CurClsId;

	ElementId[7].Type = ET_ARCH | ET_CONSTR;
	ElementId[7].Name = "Клавиатура";
	ElementId[7].ClsId = CurClsId;

	ElementId[8].Type = ET_ARCH | ET_CONSTR;
	ElementId[8].Name = "АЦП";
	ElementId[8].ClsId = CurClsId;

	ElementId[9].Type = ET_ARCH | ET_CONSTR;
	ElementId[9].Name = "Генератор звука";
	ElementId[9].ClsId = CurClsId;

	ElementId[10].Type = ET_ARCH | ET_CONSTR;
	ElementId[10].Name = "Матричный индикатор";
	ElementId[10].ClsId = CurClsId;

	ElementId[11].Type = ET_ARCH | ET_INPUTPORT | ET_OUTPUTPORT;
	ElementId[11].Name = "Таймер";
	ElementId[11].ClsId = CurClsId;

	ElementId[12].Type = ET_ARCH;
	ElementId[12].Name = "Запрос прерывания";
	ElementId[12].ClsId = CurClsId;
}


CElemLib* PASCAL CreateLibInstance(HostInterface* pHostInterface) {
	theApp.pHostInterface = pHostInterface;
	return reinterpret_cast<CElemLib*>(new CStdElemLib());
}

DWORD PASCAL AssembleFile() {
	return 0;
}

std::shared_ptr<CElement> CStdElemLib::CreateElement(const CString& name, bool isArchMode, int id) {
	for (int n = 0; n < theApp.m_ElementsCount; n++) {
		if (theApp.ElementId[n].Name != name) continue;

		switch (n) {
		case 0: return std::make_shared<CInputPort>(isArchMode, id);
		case 1: return std::make_shared < COutputPort>(isArchMode, id);
		case 2: return std::make_shared < CLedElement>(isArchMode, id);
		case 3: return std::make_shared < CButtonElement>(isArchMode, id);
		case 4: return std::make_shared < CLabel>(isArchMode, id);
		case 5: return std::make_shared < CIndicator>(isArchMode, id);
		case 6: return std::make_shared < CIndicatorDyn>(isArchMode, id);
		case 7: return std::make_shared < CKbdElement>(isArchMode, id);
		case 8: return std::make_shared < CADCElement>(isArchMode, id);
		case 9: return std::make_shared < CBeepElement>(isArchMode, id);
		case 10: return std::make_shared < CMatrixElement>(isArchMode, id);
		case 11: return std::make_shared < CVi54Element>(isArchMode, id);
		case 12: return std::make_shared < IrqElement>(isArchMode, id);
		}
	}
	return nullptr;
}

CString CStdElemLib::getLibraryName() {
	return "Стандартные элементы";
}

DWORD CStdElemLib::getElementsCount() {
	return theApp.m_ElementsCount;
}

CString CStdElemLib::GetElementName(DWORD Index) {
	return theApp.ElementId[Index].Name;
}

DWORD CStdElemLib::GetElementType(DWORD Index) {
	return theApp.ElementId[Index].Type;
}

HBITMAP CStdElemLib::GetElementIcon(DWORD Index) {
	return theApp.ElementId[Index].Icon;
}
