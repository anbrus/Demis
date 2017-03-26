// StdElem.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f StdElemps.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include <initguid.h>
#include "StdElem.h"
#include "StdElemApp.h"

#include "StdElem_i.c"
#include "ElemLib.h"
#include "ElemInterf.h"

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_ElemLib, CElemLib)
OBJECT_ENTRY(CLSID_Element, CElemInterface)
END_OBJECT_MAP()

BEGIN_MESSAGE_MAP(CStdElemApp, CWinApp)
	//{{AFX_MSG_MAP(CStdElemApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

CStdElemApp theApp;

BOOL CStdElemApp::InitInstance()
{
  _Module.Init(ObjectMap, m_hInstance, &LIBID_STDELEMLib);

  BkColor=RGB(255,255,255);
  DrawColor=RGB(0,0,0);
  SelectColor=RGB(255,0,0);
  BkBrush.CreateSolidBrush(BkColor);
  DrawPen.CreatePen(PS_SOLID,0,DrawColor);
  SelectPen.CreatePen(PS_SOLID,0,SelectColor);

  CBitmap NumbBmp,CharBmp;
  CDC OrigDC;
  
  OrigDC.CreateCompatibleDC(NULL);
  DWORD Planes=OrigDC.GetDeviceCaps(PLANES);
  DWORD BitsPixel=OrigDC.GetDeviceCaps(BITSPIXEL);
	
  HINSTANCE hInstOld=AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
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
  
  AfxSetResourceHandle(hInstOld);

  //Numbers
  CGdiObject *pOldBitmap=OrigDC.SelectObject(&NumbBmp);

  DrawOnWhiteNumb.CreateCompatibleDC(NULL);
  DrawOnWhiteNumbBmp.CreateBitmap(128,8,Planes,BitsPixel,NULL);
  DrawOnWhiteNumb.SelectObject(&DrawOnWhiteNumbBmp);
  DrawOnWhiteNumb.SetBkColor(RGB(255,255,255));
  DrawOnWhiteNumb.BitBlt(0,0,128,8,&OrigDC,0,0,SRCCOPY);

  DrawOnGrayNumb.CreateCompatibleDC(NULL);
  DrawOnGrayNumbBmp.CreateBitmap(128,8,Planes,BitsPixel,NULL);
  DrawOnGrayNumb.SelectObject(&DrawOnGrayNumbBmp);
  DrawOnGrayNumb.SetBkColor(GetSysColor(COLOR_BTNFACE));
  DrawOnGrayNumb.BitBlt(0,0,128,8,&OrigDC,0,0,SRCCOPY);

  SelOnWhiteNumb.CreateCompatibleDC(NULL);
  SelOnWhiteNumbBmp.CreateBitmap(128,8,Planes,BitsPixel,NULL);
  SelOnWhiteNumb.SelectObject(&SelOnWhiteNumbBmp);
  SelOnWhiteNumb.SetBkColor(RGB(255,255,255));
  SelOnWhiteNumb.BitBlt(0,0,128,8,&OrigDC,0,0,SRCCOPY);

  int x,y;
  for(y=0; y<8; y++) {
    for(x=0; x<128; x++) {
      DWORD OldCol=SelOnWhiteNumb.GetPixel(x,y);
      if(!OldCol) {
        SelOnWhiteNumb.SetPixelV(x,y,SelectColor);
        OldCol=SelOnWhiteNumb.GetPixel(x,y);
      }
    }
  }

  SelOnGrayNumb.CreateCompatibleDC(NULL);
  SelOnGrayNumbBmp.CreateBitmap(128,8,Planes,BitsPixel,NULL);
  SelOnGrayNumb.SelectObject(&SelOnGrayNumbBmp);
  SelOnGrayNumb.SetBkColor(GetSysColor(COLOR_BTNFACE));
  SelOnGrayNumb.BitBlt(0,0,128,8,&OrigDC,0,0,SRCCOPY);

  for(y=0; y<8; y++) {
    for(x=0; x<128; x++) {
      DWORD OldCol=SelOnGrayNumb.GetPixel(x,y);
      if(!OldCol)
        SelOnGrayNumb.SetPixelV(x,y,SelectColor);
    }
  }

  //Chars
  OrigDC.SelectObject(&CharBmp);

  DrawOnWhiteChar.CreateCompatibleDC(NULL);
  DrawOnWhiteCharBmp.CreateBitmap(128,8,Planes,BitsPixel,NULL);
  DrawOnWhiteChar.SelectObject(&DrawOnWhiteCharBmp);
  DrawOnWhiteChar.SetBkColor(RGB(255,255,255));
  DrawOnWhiteChar.BitBlt(0,0,128,8,&OrigDC,0,0,SRCCOPY);
  
  SelOnWhiteChar.CreateCompatibleDC(NULL);
  SelOnWhiteCharBmp.CreateBitmap(128,8,Planes,BitsPixel,NULL);
  SelOnWhiteChar.SelectObject(&SelOnWhiteCharBmp);
  SelOnWhiteChar.SetBkColor(RGB(255,255,255));
  SelOnWhiteChar.BitBlt(0,0,128,8,&OrigDC,0,0,SRCCOPY);

  for(y=0; y<8; y++) {
    for(x=0; x<128; x++) {
      DWORD OldCol=SelOnWhiteChar.GetPixel(x,y);
      if(!OldCol)
        SelOnWhiteChar.SetPixelV(x,y,SelectColor);
    }
  }

  OrigDC.SelectObject(pOldBitmap);

  return CWinApp::InitInstance();
}

int CStdElemApp::ExitInstance()
{
  _Module.Term();
  return CWinApp::ExitInstance();
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
    AFX_MANAGE_STATE(AfxGetStaticModuleState());
    return (AfxDllCanUnloadNow()==S_OK && _Module.GetLockCount()==0) ? S_OK : S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// Returns a class factory to create an object of the requested type

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _Module.GetClassObject(rclsid, riid, ppv);
}

/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    return _Module.RegisterServer(TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
    return _Module.UnregisterServer(TRUE);
}


CStdElemApp::CStdElemApp()
{
  m_ElementsCount=11;

  LPOLESTR pIIDStr;
  ::StringFromIID(CElemLib::GetObjectCLSID(),&pIIDStr);
  CString CurClsId(pIIDStr);

  ElementId[0].Type=ET_ARCH|ET_INPUTPORT;
  ElementId[0].Name="Порт ввода";
  ElementId[0].ClsId=CurClsId;

  ElementId[1].Type=ET_ARCH|ET_OUTPUTPORT;
  ElementId[1].Name="Порт вывода";
  ElementId[1].ClsId=CurClsId;

  ElementId[2].Type=ET_ARCH|ET_CONSTR;
  ElementId[2].Name="Светодиод";
  ElementId[2].ClsId=CurClsId;

  ElementId[3].Type=ET_ARCH|ET_CONSTR;
  ElementId[3].Name="Кнопка";
  ElementId[3].ClsId=CurClsId;

  ElementId[4].Type=ET_ARCH|ET_CONSTR;
  ElementId[4].Name="Текстовая метка";
  ElementId[4].ClsId=CurClsId;

  ElementId[5].Type=ET_ARCH|ET_CONSTR;
  ElementId[5].Name="Семисегм. индикатор";
  ElementId[5].ClsId=CurClsId;

  ElementId[6].Type=ET_ARCH|ET_CONSTR;
  ElementId[6].Name="Семисегм. дин. индикатор";
  ElementId[6].ClsId=CurClsId;

  ElementId[7].Type=ET_ARCH|ET_CONSTR;
  ElementId[7].Name="Клавиатура";
  ElementId[7].ClsId=CurClsId;

  ElementId[8].Type=ET_ARCH|ET_CONSTR;
  ElementId[8].Name="АЦП";
  ElementId[8].ClsId=CurClsId;

  ElementId[9].Type=ET_ARCH|ET_CONSTR;
  ElementId[9].Name="Генератор звука";
  ElementId[9].ClsId=CurClsId;

  ElementId[10].Type=ET_ARCH|ET_CONSTR;
  ElementId[10].Name="Матричный индикатор";
  ElementId[10].ClsId=CurClsId;
}
