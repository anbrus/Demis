// Element.h : Declaration of the CElement
//#ifndef __ELEMENT_H_
//#define __ELEMENT_H_
//
//#include "resource.h"       // main symbols
//#include "Element.h"
//
///////////////////////////////////////////////////////////////////////////////
//// CElement
//class ATL_NO_VTABLE CElemInterface1 : 
//	public CComObjectRootEx<CComSingleThreadModel>,
//	public CComCoClass<CElemInterface1, &CLSID_Element>,
//	public IDispatchImpl<IElement, &IID_IElement, &LIBID_STDELEMLib>
//{
//public:
//	CElemInterface1()
//	{
//	}
//
//	~CElemInterface1()
//	{
//	}
//
//DECLARE_REGISTRY_RESOURCEID(IDR_ELEMENT)
//DECLARE_NOT_AGGREGATABLE(CElemInterface1)
//
//DECLARE_PROTECT_FINAL_CONSTRUCT()
//
//BEGIN_COM_MAP(CElemInterface1)
//	COM_INTERFACE_ENTRY(IElement)
//	COM_INTERFACE_ENTRY(IDispatch)
//END_COM_MAP()
//
//// IElement
//public:
//	STDMETHOD(IsArchRedrawRequired)(BOOL *pRetVal);
//	STDMETHOD(IsConstrRedrawRequired)(BOOL *pRetVal);
//	STDMETHOD(RedrawArchWnd)();
//	STDMETHOD(RedrawConstrWnd)();
//	STDMETHOD(OnInstrCounterEvent)();
//	STDMETHOD(Load)(long hFile,/*[out,retval]*/ BOOL *pRetVal);
//	STDMETHOD(Save)(long hFile,/*[out,retval]*/ BOOL *pRetVal);
//	STDMETHOD(GetPointPos)(long nPointIndex,/*[out,retval]*/ long *pRetVal);
//	STDMETHOD(GetPinType)(long nPinIndex,/*[out,retval]*/ long *pRetVal);
//	STDMETHOD(ConnectPin)(long nPinIndex, BOOL bConnect,/*[out,retval]*/ BOOL *pRetVal);
//	STDMETHOD(Reset)(BOOL bEditMode, CURRENCY* pTickCounter,long TaktFreq,long FreePinLevel,/*[out,retval]*/ BOOL *pRetVal);
//	STDMETHOD(Create)(BSTR sElemName,BOOL bArchMode,/*[out,retval]*/ BOOL *pRetVal);
//	STDMETHOD(Show)(long hArchParentWnd, long hConstrParentWnd, /*[out,retval]*/ BOOL *pRetVal);
//	STDMETHOD(get_nConstrAngle)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(put_nConstrAngle)(/*[in]*/ long newVal);
//	STDMETHOD(get_nArchAngle)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(put_nArchAngle)(/*[in]*/ long newVal);
//	STDMETHOD(get_nPinState)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(put_nPinState)(/*[in]*/ long newVal);
//	STDMETHOD(get_nPortData)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(put_nPortData)(/*[in]*/ long newVal);
//	STDMETHOD(get_nPointCount)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(get_bConstrSelected)(/*[out, retval]*/ BOOL *pVal);
//	STDMETHOD(put_bConstrSelected)(/*[in]*/ BOOL newVal);
//	STDMETHOD(get_bArchSelected)(/*[out, retval]*/ BOOL *pVal);
//	STDMETHOD(put_bArchSelected)(/*[in]*/ BOOL newVal);
//	STDMETHOD(get_sTipText)(/*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(get_bModifiedFlag)(/*[out, retval]*/ BOOL *pVal);
//	STDMETHOD(get_nAddress)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(get_hConstrWnd)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(get_hArchWnd)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(get_sClsId)(/*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(get_sName)(/*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(get_nType)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(get_hElement)(/*[out, retval]*/ long *pVal);
//	STDMETHOD(put_hElement)(/*[in]*/ long newVal);
//
//  HANDLE hElement;
//
//protected:
//	CElement *pElement;
//public:
//  void FinalRelease();
//};
//
//#endif //__ELEMENT_H_
