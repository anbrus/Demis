// ElemLib.h : Declaration of the CElemLib

#ifndef __ELEMLIB_H_
#define __ELEMLIB_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CElemLib
class ATL_NO_VTABLE CElemLib : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CElemLib, &CLSID_ElemLib>,
	public IDispatchImpl<IElemLib, &IID_IElemLib, &LIBID_STDELEMLib>
{
public:
	CElemLib()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_ELEMLIB)
DECLARE_NOT_AGGREGATABLE(CElemLib)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CElemLib)
	COM_INTERFACE_ENTRY(IElemLib)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IElemLib
public:
	STDMETHOD(GetElementIcon)(long Index, /*[out,retval]*/ long *pRetVal);
	STDMETHOD(GetElementType)(long Index, /*[out,retval]*/ long *pRetVal);
	STDMETHOD(GetElementName)(long Index,/*[out, retval]*/ BSTR *pRetVal);
	STDMETHOD(get_nElementsCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_sLibraryName)(/*[out, retval]*/ BSTR *pVal);
};

#endif //__ELEMLIB_H_
