// ElemLib.cpp : Implementation of CElemLib
#include "stdafx.h"
#include "StdElem.h"
#include "StdElemApp.h"
#include "ElemLib.h"

/////////////////////////////////////////////////////////////////////////////
// CElemLib


STDMETHODIMP CElemLib::get_sLibraryName(BSTR *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

  *pVal=SysAllocString(L"Стандартные элементы");
  
  return S_OK;
}

STDMETHODIMP CElemLib::get_nElementsCount(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=theApp.m_ElementsCount;

	return S_OK;
}

STDMETHODIMP CElemLib::GetElementName(long Index, BSTR *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

  *pRetVal=theApp.ElementId[Index].Name.AllocSysString();

	return S_OK;
}

STDMETHODIMP CElemLib::GetElementType(long Index, long *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

  *pRetVal=theApp.ElementId[Index].Type;

	return S_OK;
}

STDMETHODIMP CElemLib::GetElementIcon(long Index, long *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

  *pRetVal=(long)(HBITMAP)theApp.ElementId[Index].Icon;

	return S_OK;
}
