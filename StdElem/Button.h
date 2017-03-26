// Button.h: interface for the CButtonElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BUTTON_H__AC326D84_78BA_11D4_8288_E863E1351E47__INCLUDED_)
#define AFX_BUTTON_H__AC326D84_78BA_11D4_8288_E863E1351E47__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CBtnArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	CBtnArchWnd(CElement* pElement);
	virtual ~CBtnArchWnd();

protected:
  //{{AFX_MSG(CBtnArchWnd)
	afx_msg void OnLabelText();
	afx_msg void OnNormalClosed();
	afx_msg void OnNormalOpened();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnFixable();
	afx_msg void OnDrebezg();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CBtnConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void UpdateSize();
	CBtnConstrWnd(CElement* pElement);
	virtual ~CBtnConstrWnd();

protected:
  //{{AFX_MSG(CBtnConstrWnd)
	afx_msg void OnLabelText();
	afx_msg void OnNormalClosed();
	afx_msg void OnNormalOpened();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnFixable();
	afx_msg void OnDrebezg();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CButtonElement : public CElement  
{
public:
	virtual void OnInstrCounterEvent();
	virtual DWORD GetPinState();
	void OnLButtonDown();
	void OnLButtonUp();
	BOOL Drebezg;
  //INT64 LastEventTakt;
	void OnFixable();
	void OnDrebezg();
	BOOL Fixable;
	void OnNormalClosed();
	void OnNormalOpened();
	void OnLabelText(CElementWnd* pParentWnd);
	CString Text;
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	virtual ~CButtonElement();
	BOOL NormalOpened;
	BOOL Pressed;
	CButtonElement(BOOL ArchMode,CElemInterface* pInterface);

protected:
	DWORD CurState;
	int DrebCounter;
	void ChangePinState();
};

#endif // !defined(AFX_BUTTON_H__AC326D84_78BA_11D4_8288_E863E1351E47__INCLUDED_)
