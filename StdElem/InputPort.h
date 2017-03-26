// InputPort.h: interface for the CInputPort class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INPUTPORT_H__AC326D83_78BA_11D4_8288_E863E1351E47__INCLUDED_)
#define AFX_INPUTPORT_H__AC326D83_78BA_11D4_8288_E863E1351E47__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CInputPort;

class CInPortArchWnd : public CElementWnd
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC);
	int Width,Height;
	CInPortArchWnd(CElement* pElement);
	virtual ~CInPortArchWnd();

protected:
  //{{AFX_MSG(CInPortArchWnd)
	afx_msg void OnAddress();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CInputPort : public CElement  
{
public:
	virtual DWORD GetPinState();
	virtual DWORD GetPortData();
	virtual void SetPinState(DWORD NewState);
	DWORD Value;
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	CInputPort(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CInputPort();
	void UpdateTipText();
};

#endif // !defined(AFX_INPUTPORT_H__AC326D83_78BA_11D4_8288_E863E1351E47__INCLUDED_)
