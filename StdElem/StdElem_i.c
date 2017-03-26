

/* this ALWAYS GENERATED file contains the IIDs and CLSIDs */

/* link this file in with the server and any clients */


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


#ifdef __cplusplus
extern "C"{
#endif 


#include <rpc.h>
#include <rpcndr.h>

#ifdef _MIDL_USE_GUIDDEF_

#ifndef INITGUID
#define INITGUID
#include <guiddef.h>
#undef INITGUID
#else
#include <guiddef.h>
#endif

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        DEFINE_GUID(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#else // !_MIDL_USE_GUIDDEF_

#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        const type name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#endif !_MIDL_USE_GUIDDEF_

MIDL_DEFINE_GUID(IID, IID_IElemLib,0x5A99AE06,0x2098,0x4ED2,0x99,0x65,0x60,0x50,0x37,0xB3,0xF4,0xE1);


MIDL_DEFINE_GUID(IID, IID_IElement,0xC4347DF5,0x8BE7,0x48E4,0xA8,0x70,0x57,0x2D,0x6A,0x04,0x58,0xD6);


MIDL_DEFINE_GUID(IID, LIBID_STDELEMLib,0xD30F470C,0xC4B7,0x4014,0x8F,0x92,0xF4,0xBE,0xCE,0xF0,0x7E,0x06);


MIDL_DEFINE_GUID(CLSID, CLSID_ElemLib,0x6B4C02AF,0xDC58,0x4935,0xB4,0x38,0x55,0x2D,0xEB,0xB7,0x27,0x61);


MIDL_DEFINE_GUID(CLSID, CLSID_Element,0x508879A8,0x2F6F,0x421E,0xA8,0x52,0x38,0x54,0x11,0xF8,0x48,0x74);

#undef MIDL_DEFINE_GUID

#ifdef __cplusplus
}
#endif



