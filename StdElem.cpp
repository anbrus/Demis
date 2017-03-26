// StdElem.cpp: implementation of the CElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "demis2000.h"
#include "StdElem.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CElement::CElement()
{
}

CElement::~CElement()
{
  pInterface->Release();
}

BOOL CElement::CreateInstance(CString &ElemId)
{
  CLSID clsidClsId;
  wchar_t wClsId[128];
  mbstowcs(wClsId,(LPCTSTR)ElemId,128);
  CLSIDFromString(wClsId,&clsidClsId);
  DWORD Res=CoCreateInstance(clsidClsId,NULL,CLSCTX_INPROC_SERVER,__uuidof(IElement),(void**)&pInterface);
  if(Res!=S_OK) return FALSE;

  return TRUE;
}

HANDLE CElement::get_hElement()
{
  HANDLE hElement;
  pInterface->get_hElement((long*)&hElement);
  return hElement;
}

void CElement::put_hElement(HANDLE hElement)
{
  pInterface->put_hElement((long)hElement);
}

DWORD CElement::get_nType()
{
  long retVal;
  pInterface->get_nType(&retVal);
  return (DWORD)retVal;
}

void CElement::get_sName(CString &Str)
{
  BSTR retVal;
  pInterface->get_sName(&retVal);
  Str=retVal;
  ::SysFreeString(retVal);
}

void CElement::get_sClsId(CString &Str)
{
  BSTR retVal;
  pInterface->get_sClsId(&retVal);
  Str=retVal;
  ::SysFreeString(retVal);
}

HWND CElement::get_hArchWnd()
{
  long retVal;
  pInterface->get_hArchWnd(&retVal);
  return (HWND)retVal;
}

HWND CElement::get_hConstrWnd()
{
  long retVal;
  pInterface->get_hConstrWnd(&retVal);
  return (HWND)retVal;
}

DWORD CElement::get_nAddress()
{
  long retVal;
  pInterface->get_nAddress(&retVal);
  return (DWORD)retVal;
}

BOOL CElement::get_bModifiedFlag()
{
  BOOL retVal;
  pInterface->get_bModifiedFlag(&retVal);
  return retVal;
}

void CElement::get_sTipText(CString &Str)
{
  BSTR retVal;
  pInterface->get_sTipText(&retVal);
  Str=retVal;
  ::SysFreeString(retVal);
}

BOOL CElement::get_bArchSelected()
{
  BOOL retVal;
  pInterface->get_bArchSelected(&retVal);
  return retVal;
}

void CElement::put_bArchSelected(BOOL newVal)
{
  pInterface->put_bArchSelected(newVal);
}

BOOL CElement::get_bConstrSelected()
{
  BOOL retVal;
  pInterface->get_bConstrSelected(&retVal);
  return retVal;
}

void CElement::put_bConstrSelected(BOOL newVal)
{
  pInterface->put_bConstrSelected(newVal);
}

DWORD CElement::get_nPointCount()
{
  long retVal;
  pInterface->get_nPointCount(&retVal);
  return (DWORD)retVal;
}

DWORD CElement::get_nPortData()
{
  long retVal;
  pInterface->get_nPortData(&retVal);
  return (DWORD)retVal;
}

void CElement::put_nPortData(DWORD newVal)
{
  pInterface->put_nPortData(newVal);
}

DWORD CElement::get_nPinState()
{
  long retVal;
  pInterface->get_nPinState(&retVal);
  return (DWORD)retVal;
}

void CElement::put_nPinState(DWORD newVal)
{
  pInterface->put_nPinState(newVal);
}

long CElement::get_nArchAngle()
{
  long retVal;
  pInterface->get_nArchAngle(&retVal);
  return retVal;
}

void CElement::put_nArchAngle(long newVal)
{
  pInterface->put_nArchAngle(newVal);
}

long CElement::get_nConstrAngle()
{
  long retVal;
  pInterface->get_nConstrAngle(&retVal);
  return retVal;
}

void CElement::put_nConstrAngle(long newVal)
{
  pInterface->put_nConstrAngle(newVal);
}

BOOL CElement::Show(HWND hArchParentWnd,HWND hConstrParentWnd)
{
  BOOL RetVal;
  pInterface->Show((long)hArchParentWnd,(long)hConstrParentWnd,&RetVal);
  return RetVal;
}

BOOL CElement::Create(CString &sElemName,BOOL bArchMode)
{
  BOOL RetVal;
  BSTR pStr=sElemName.AllocSysString();
  pInterface->Create(pStr,bArchMode,&RetVal);
  ::SysFreeString(pStr);

  return RetVal;
}

BOOL CElement::Reset(BOOL bEditMode,__int64 *pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  BOOL RetVal;
  pInterface->Reset(bEditMode,(CURRENCY*)pTickCounter,(long)TaktFreq,(long)FreePinLevel,&RetVal);
  return RetVal;
}

BOOL CElement::ConnectPin(DWORD nPinIndex,BOOL bConnect)
{
  BOOL RetVal;
  pInterface->ConnectPin((long)nPinIndex,bConnect,&RetVal);
  return RetVal;
}

DWORD CElement::GetPinType(DWORD nPinIndex)
{
  long RetVal;
  pInterface->GetPinType((long)nPinIndex,&RetVal);
  return (DWORD)RetVal;
}

DWORD CElement::GetPointPos(DWORD nPointIndex)
{
  long RetVal;
  pInterface->GetPointPos((long)nPointIndex,&RetVal);
  return (DWORD)RetVal;
}

BOOL CElement::Save(OLE_HANDLE hFile)
{
  BOOL RetVal;
  pInterface->Save((long)hFile,&RetVal);
  return RetVal;
}

BOOL CElement::Load(OLE_HANDLE hFile)
{
  BOOL RetVal;
  pInterface->Load((long)hFile,&RetVal);
  return RetVal;
}

void CElement::OnInstrCounterEvent()
{
  pInterface->OnInstrCounterEvent();
}

CElemLib::CElemLib()
{
}

CElemLib::~CElemLib()
{
  pInterface->Release();
}

BOOL CElemLib::CreateInstance(CString &ClsId)
{
  CLSID clsidClsId;
  wchar_t wClsId[128];
  mbstowcs(wClsId,(LPCTSTR)ClsId,128);
  CLSIDFromString(wClsId,&clsidClsId);
  if(CoCreateInstance(clsidClsId,NULL,CLSCTX_INPROC_SERVER,__uuidof(IElemLib),(void**)&pInterface)!=S_OK)
    return FALSE;

  return TRUE;
}

void CElemLib::get_sLibraryName(CString &Str)
{
  BSTR RetVal;
  pInterface->get_sLibraryName(&RetVal);
  Str=RetVal;
  ::SysFreeString(RetVal);
}

DWORD CElemLib::get_nElementsCount()
{
  long RetVal;
  pInterface->get_nElementsCount(&RetVal);
  return (DWORD)RetVal;
}

void CElemLib::GetElementName(DWORD Index,CString &Str)
{
  BSTR retVal;
  pInterface->GetElementName((long)Index,&retVal);
  Str=retVal;
  ::SysFreeString(retVal);
}

DWORD CElemLib::GetElementType(DWORD Index)
{
  long RetVal;
  pInterface->GetElementType((long)Index,&RetVal);
  return (DWORD)RetVal;
}

HBITMAP CElemLib::GetElementIcon(DWORD Index)
{
  long RetVal;
  pInterface->GetElementIcon((long)Index,&RetVal);

  return (HBITMAP)RetVal;
}

