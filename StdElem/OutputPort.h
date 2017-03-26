// OutputPort.h: interface for the COutputPort class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_OUTPUTPORT_H__FC894DD1_71C6_11D4_8267_CDB158FEE847__INCLUDED_)
#define AFX_OUTPUTPORT_H__FC894DD1_71C6_11D4_8267_CDB158FEE847__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class COutputPort;

class COutPortArchWnd : public CElementWnd
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC,DWORD OldValue);
	COutPortArchWnd(CElement* pElement);
	virtual ~COutPortArchWnd();
	void InitializePoints();

protected:
  //{{AFX_MSG(COutPortArchWnd)
	afx_msg void OnAddress();
	afx_msg void OnRotate();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class COutputPort : public CElement  
{
public:
	virtual DWORD GetPinState();
	virtual void SetPinState(DWORD NewState);
	virtual void SetPortData(DWORD Data);
	DWORD Value;
	virtual void UpdateTipText();
  virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	COutputPort(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~COutputPort();
protected:
};

#endif // !defined(AFX_OUTPUTPORT_H__FC894DD1_71C6_11D4_8267_CDB158FEE847__INCLUDED_)
