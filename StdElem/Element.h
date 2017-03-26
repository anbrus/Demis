// Element.h: interface for the CElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ELEMENT_H__CB53E02D_1110_4BD3_BA3C_63F748405197__INCLUDED_)
#define AFX_ELEMENT_H__CB53E02D_1110_4BD3_BA3C_63F748405197__INCLUDED_

#include "..\ElemInterface.h"
#include "StdElemApp.h"

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CElementWnd;
class CElemInterface;

class CElement  
{
public:
	virtual void OnInstrCounterEvent();
	DWORD FreePinLevel;
	DWORD TaktFreq;
	virtual void SetPinState(DWORD NewState);
	virtual DWORD GetPinState();
	virtual void SetPortData(DWORD Data);
	virtual DWORD GetPortData();
	CPoint ConPoint[MAX_CONNECT_POINT];
	int PointCount;
	BOOL ConnectPin(int PinIndex,BOOL Connect);
	DWORD GetPinType(int PinIndex);
	BOOL ConPin[MAX_CONNECT_POINT];
	CElemInterface *pInterface;
	BOOL ConstrSelected;
	BOOL ArchSelected;
	CWnd* pArchParentWnd,*pConstrParentWnd;
	CURRENCY* pTickCounter;
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
  virtual BOOL Load(HANDLE hFile);
  virtual BOOL Save(HANDLE hFile);
	int IdIndex;
	CElementWnd* pArchElemWnd,*pConstrElemWnd;
	CString TipText;
	BOOL ModifiedFlag;
	DWORD Address;
	CMenu PopupMenu;
	BOOL EditMode;
	CElement(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CElement();
	DWORD PinType[MAX_CONNECT_POINT];
protected:
};

#endif // !defined(AFX_ELEMENT_H__CB53E02D_1110_4BD3_BA3C_63F748405197__INCLUDED_)
