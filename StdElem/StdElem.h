

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 7.00.0555 */
/* at Fri Mar 10 06:54:40 2017
 */
/* Compiler settings for StdElem.idl:
    Oicf, W1, Zp8, env=Win32 (32b run), target_arch=X86 7.00.0555 
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */

#pragma warning( disable: 4049 )  /* more than 64k source lines */


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __StdElem_h__
#define __StdElem_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IElemLib_FWD_DEFINED__
#define __IElemLib_FWD_DEFINED__
typedef interface IElemLib IElemLib;
#endif 	/* __IElemLib_FWD_DEFINED__ */


#ifndef __IElement_FWD_DEFINED__
#define __IElement_FWD_DEFINED__
typedef interface IElement IElement;
#endif 	/* __IElement_FWD_DEFINED__ */


#ifndef __ElemLib_FWD_DEFINED__
#define __ElemLib_FWD_DEFINED__

#ifdef __cplusplus
typedef class ElemLib ElemLib;
#else
typedef struct ElemLib ElemLib;
#endif /* __cplusplus */

#endif 	/* __ElemLib_FWD_DEFINED__ */


#ifndef __Element_FWD_DEFINED__
#define __Element_FWD_DEFINED__

#ifdef __cplusplus
typedef class Element Element;
#else
typedef struct Element Element;
#endif /* __cplusplus */

#endif 	/* __Element_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IElemLib_INTERFACE_DEFINED__
#define __IElemLib_INTERFACE_DEFINED__

/* interface IElemLib */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IElemLib;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("5A99AE06-2098-4ED2-9965-605037B3F4E1")
    IElemLib : public IDispatch
    {
    public:
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_sLibraryName( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nElementsCount( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetElementName( 
            long Index,
            /* [retval][out] */ BSTR *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetElementType( 
            long Index,
            /* [retval][out] */ long *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetElementIcon( 
            long Index,
            /* [retval][out] */ long *pRetVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IElemLibVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IElemLib * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            __RPC__deref_out  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IElemLib * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IElemLib * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IElemLib * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IElemLib * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IElemLib * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IElemLib * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_sLibraryName )( 
            IElemLib * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nElementsCount )( 
            IElemLib * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetElementName )( 
            IElemLib * This,
            long Index,
            /* [retval][out] */ BSTR *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetElementType )( 
            IElemLib * This,
            long Index,
            /* [retval][out] */ long *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetElementIcon )( 
            IElemLib * This,
            long Index,
            /* [retval][out] */ long *pRetVal);
        
        END_INTERFACE
    } IElemLibVtbl;

    interface IElemLib
    {
        CONST_VTBL struct IElemLibVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IElemLib_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IElemLib_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IElemLib_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IElemLib_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IElemLib_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IElemLib_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IElemLib_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IElemLib_get_sLibraryName(This,pVal)	\
    ( (This)->lpVtbl -> get_sLibraryName(This,pVal) ) 

#define IElemLib_get_nElementsCount(This,pVal)	\
    ( (This)->lpVtbl -> get_nElementsCount(This,pVal) ) 

#define IElemLib_GetElementName(This,Index,pRetVal)	\
    ( (This)->lpVtbl -> GetElementName(This,Index,pRetVal) ) 

#define IElemLib_GetElementType(This,Index,pRetVal)	\
    ( (This)->lpVtbl -> GetElementType(This,Index,pRetVal) ) 

#define IElemLib_GetElementIcon(This,Index,pRetVal)	\
    ( (This)->lpVtbl -> GetElementIcon(This,Index,pRetVal) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IElemLib_INTERFACE_DEFINED__ */


#ifndef __IElement_INTERFACE_DEFINED__
#define __IElement_INTERFACE_DEFINED__

/* interface IElement */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IElement;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("C4347DF5-8BE7-48E4-A870-572D6A0458D6")
    IElement : public IDispatch
    {
    public:
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_hElement( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_hElement( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nType( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_sName( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_sClsId( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_hArchWnd( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_hConstrWnd( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nAddress( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_bModifiedFlag( 
            /* [retval][out] */ BOOL *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_sTipText( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_bArchSelected( 
            /* [retval][out] */ BOOL *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_bArchSelected( 
            /* [in] */ BOOL newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_bConstrSelected( 
            /* [retval][out] */ BOOL *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_bConstrSelected( 
            /* [in] */ BOOL newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nPointCount( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nPortData( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_nPortData( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nPinState( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_nPinState( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nArchAngle( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_nArchAngle( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_nConstrAngle( 
            /* [retval][out] */ long *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_nConstrAngle( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Show( 
            long hArchParentWnd,
            long hConstrParentWnd,
            /* [retval][out] */ BOOL *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Create( 
            BSTR sElemName,
            BOOL bArchMode,
            /* [retval][out] */ BOOL *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Reset( 
            BOOL bEditMode,
            CURRENCY *pTickCounter,
            long TaktFreq,
            long FreePinLevel,
            /* [retval][out] */ BOOL *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ConnectPin( 
            long nPinIndex,
            BOOL bConnect,
            /* [retval][out] */ BOOL *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetPinType( 
            long nPinIndex,
            /* [retval][out] */ long *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetPointPos( 
            long nPointIndex,
            /* [retval][out] */ long *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Save( 
            long hFile,
            /* [retval][out] */ BOOL *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Load( 
            long hFile,
            /* [retval][out] */ BOOL *pRetVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE OnInstrCounterEvent( void) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IElementVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IElement * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            __RPC__deref_out  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IElement * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IElement * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IElement * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IElement * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IElement * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IElement * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_hElement )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_hElement )( 
            IElement * This,
            /* [in] */ long newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nType )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_sName )( 
            IElement * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_sClsId )( 
            IElement * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_hArchWnd )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_hConstrWnd )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nAddress )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_bModifiedFlag )( 
            IElement * This,
            /* [retval][out] */ BOOL *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_sTipText )( 
            IElement * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_bArchSelected )( 
            IElement * This,
            /* [retval][out] */ BOOL *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_bArchSelected )( 
            IElement * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_bConstrSelected )( 
            IElement * This,
            /* [retval][out] */ BOOL *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_bConstrSelected )( 
            IElement * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nPointCount )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nPortData )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_nPortData )( 
            IElement * This,
            /* [in] */ long newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nPinState )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_nPinState )( 
            IElement * This,
            /* [in] */ long newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nArchAngle )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_nArchAngle )( 
            IElement * This,
            /* [in] */ long newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_nConstrAngle )( 
            IElement * This,
            /* [retval][out] */ long *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_nConstrAngle )( 
            IElement * This,
            /* [in] */ long newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Show )( 
            IElement * This,
            long hArchParentWnd,
            long hConstrParentWnd,
            /* [retval][out] */ BOOL *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Create )( 
            IElement * This,
            BSTR sElemName,
            BOOL bArchMode,
            /* [retval][out] */ BOOL *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Reset )( 
            IElement * This,
            BOOL bEditMode,
            CURRENCY *pTickCounter,
            long TaktFreq,
            long FreePinLevel,
            /* [retval][out] */ BOOL *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *ConnectPin )( 
            IElement * This,
            long nPinIndex,
            BOOL bConnect,
            /* [retval][out] */ BOOL *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetPinType )( 
            IElement * This,
            long nPinIndex,
            /* [retval][out] */ long *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetPointPos )( 
            IElement * This,
            long nPointIndex,
            /* [retval][out] */ long *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Save )( 
            IElement * This,
            long hFile,
            /* [retval][out] */ BOOL *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Load )( 
            IElement * This,
            long hFile,
            /* [retval][out] */ BOOL *pRetVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *OnInstrCounterEvent )( 
            IElement * This);
        
        END_INTERFACE
    } IElementVtbl;

    interface IElement
    {
        CONST_VTBL struct IElementVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IElement_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IElement_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IElement_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IElement_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IElement_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IElement_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IElement_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IElement_get_hElement(This,pVal)	\
    ( (This)->lpVtbl -> get_hElement(This,pVal) ) 

#define IElement_put_hElement(This,newVal)	\
    ( (This)->lpVtbl -> put_hElement(This,newVal) ) 

#define IElement_get_nType(This,pVal)	\
    ( (This)->lpVtbl -> get_nType(This,pVal) ) 

#define IElement_get_sName(This,pVal)	\
    ( (This)->lpVtbl -> get_sName(This,pVal) ) 

#define IElement_get_sClsId(This,pVal)	\
    ( (This)->lpVtbl -> get_sClsId(This,pVal) ) 

#define IElement_get_hArchWnd(This,pVal)	\
    ( (This)->lpVtbl -> get_hArchWnd(This,pVal) ) 

#define IElement_get_hConstrWnd(This,pVal)	\
    ( (This)->lpVtbl -> get_hConstrWnd(This,pVal) ) 

#define IElement_get_nAddress(This,pVal)	\
    ( (This)->lpVtbl -> get_nAddress(This,pVal) ) 

#define IElement_get_bModifiedFlag(This,pVal)	\
    ( (This)->lpVtbl -> get_bModifiedFlag(This,pVal) ) 

#define IElement_get_sTipText(This,pVal)	\
    ( (This)->lpVtbl -> get_sTipText(This,pVal) ) 

#define IElement_get_bArchSelected(This,pVal)	\
    ( (This)->lpVtbl -> get_bArchSelected(This,pVal) ) 

#define IElement_put_bArchSelected(This,newVal)	\
    ( (This)->lpVtbl -> put_bArchSelected(This,newVal) ) 

#define IElement_get_bConstrSelected(This,pVal)	\
    ( (This)->lpVtbl -> get_bConstrSelected(This,pVal) ) 

#define IElement_put_bConstrSelected(This,newVal)	\
    ( (This)->lpVtbl -> put_bConstrSelected(This,newVal) ) 

#define IElement_get_nPointCount(This,pVal)	\
    ( (This)->lpVtbl -> get_nPointCount(This,pVal) ) 

#define IElement_get_nPortData(This,pVal)	\
    ( (This)->lpVtbl -> get_nPortData(This,pVal) ) 

#define IElement_put_nPortData(This,newVal)	\
    ( (This)->lpVtbl -> put_nPortData(This,newVal) ) 

#define IElement_get_nPinState(This,pVal)	\
    ( (This)->lpVtbl -> get_nPinState(This,pVal) ) 

#define IElement_put_nPinState(This,newVal)	\
    ( (This)->lpVtbl -> put_nPinState(This,newVal) ) 

#define IElement_get_nArchAngle(This,pVal)	\
    ( (This)->lpVtbl -> get_nArchAngle(This,pVal) ) 

#define IElement_put_nArchAngle(This,newVal)	\
    ( (This)->lpVtbl -> put_nArchAngle(This,newVal) ) 

#define IElement_get_nConstrAngle(This,pVal)	\
    ( (This)->lpVtbl -> get_nConstrAngle(This,pVal) ) 

#define IElement_put_nConstrAngle(This,newVal)	\
    ( (This)->lpVtbl -> put_nConstrAngle(This,newVal) ) 

#define IElement_Show(This,hArchParentWnd,hConstrParentWnd,pRetVal)	\
    ( (This)->lpVtbl -> Show(This,hArchParentWnd,hConstrParentWnd,pRetVal) ) 

#define IElement_Create(This,sElemName,bArchMode,pRetVal)	\
    ( (This)->lpVtbl -> Create(This,sElemName,bArchMode,pRetVal) ) 

#define IElement_Reset(This,bEditMode,pTickCounter,TaktFreq,FreePinLevel,pRetVal)	\
    ( (This)->lpVtbl -> Reset(This,bEditMode,pTickCounter,TaktFreq,FreePinLevel,pRetVal) ) 

#define IElement_ConnectPin(This,nPinIndex,bConnect,pRetVal)	\
    ( (This)->lpVtbl -> ConnectPin(This,nPinIndex,bConnect,pRetVal) ) 

#define IElement_GetPinType(This,nPinIndex,pRetVal)	\
    ( (This)->lpVtbl -> GetPinType(This,nPinIndex,pRetVal) ) 

#define IElement_GetPointPos(This,nPointIndex,pRetVal)	\
    ( (This)->lpVtbl -> GetPointPos(This,nPointIndex,pRetVal) ) 

#define IElement_Save(This,hFile,pRetVal)	\
    ( (This)->lpVtbl -> Save(This,hFile,pRetVal) ) 

#define IElement_Load(This,hFile,pRetVal)	\
    ( (This)->lpVtbl -> Load(This,hFile,pRetVal) ) 

#define IElement_OnInstrCounterEvent(This)	\
    ( (This)->lpVtbl -> OnInstrCounterEvent(This) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IElement_INTERFACE_DEFINED__ */



#ifndef __STDELEMLib_LIBRARY_DEFINED__
#define __STDELEMLib_LIBRARY_DEFINED__

/* library STDELEMLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_STDELEMLib;

EXTERN_C const CLSID CLSID_ElemLib;

#ifdef __cplusplus

class DECLSPEC_UUID("6B4C02AF-DC58-4935-B438-552DEBB72761")
ElemLib;
#endif

EXTERN_C const CLSID CLSID_Element;

#ifdef __cplusplus

class DECLSPEC_UUID("508879A8-2F6F-421E-A852-385411F84874")
Element;
#endif
#endif /* __STDELEMLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long *, unsigned long            , BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserMarshal(  unsigned long *, unsigned char *, BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserUnmarshal(unsigned long *, unsigned char *, BSTR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long *, BSTR * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


