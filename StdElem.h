
#include "StdElem\StdElem.h"

#pragma once

class CElement  
{
public:
	BOOL CreateInstance(CString &ElemI);
	CElement();
	virtual ~CElement();

  HANDLE get_hElement();
  void put_hElement(HANDLE hElement);
  DWORD get_nType();
  void get_sName(CString &Str);
  void get_sClsId(CString &Str);
  HWND get_hArchWnd();
  HWND get_hConstrWnd();
  DWORD get_nAddress();
  BOOL get_bModifiedFlag();
  void get_sTipText(CString &Str);
  BOOL get_bArchSelected();
  void put_bArchSelected(BOOL newVal);
  BOOL get_bConstrSelected();
  void put_bConstrSelected(BOOL newVal);
  DWORD get_nPointCount();
  DWORD get_nPortData();
  void put_nPortData(DWORD newVal);
  DWORD get_nPinState();
  void put_nPinState(DWORD newVal);
  long get_nArchAngle();
  void put_nArchAngle(long newVal);
  long get_nConstrAngle();
  void put_nConstrAngle(long newVal);
  BOOL Show(HWND hArchParentWnd,HWND hConstrParentWnd);
  BOOL Create(CString &sElemName,BOOL bArchMode);
  BOOL Reset(BOOL bEditMode,__int64 *pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
  BOOL ConnectPin(DWORD nPinIndex,BOOL bConnect);
  DWORD GetPinType(DWORD nPinIndex);
  DWORD GetPointPos(DWORD nPointIndex);
  BOOL Save(OLE_HANDLE hFile);
  BOOL Load(OLE_HANDLE hFile);
  void OnInstrCounterEvent();

protected:
	IElement *pInterface;
};

class CElemLib
{
public:
	BOOL CreateInstance(CString &ElemID);
	CElemLib();
	virtual ~CElemLib();

  void get_sLibraryName(CString &Str);
  DWORD get_nElementsCount();
  void GetElementName(DWORD Index,CString &Str);
  DWORD GetElementType(DWORD Index);
  HBITMAP GetElementIcon(DWORD Index);
protected:
	IElemLib *pInterface;
};

