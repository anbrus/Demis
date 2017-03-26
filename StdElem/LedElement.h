// LedElement.h: interface for the CLedElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LEDELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_)
#define AFX_LEDELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CLedArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC);
	CLedArchWnd(CElement* pElement);
	virtual ~CLedArchWnd();

protected:
  //{{AFX_MSG(CLedArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnSelectColor();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CLedConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC);
	CLedConstrWnd(CElement* pElement);
	virtual ~CLedConstrWnd();

protected:
  //{{AFX_MSG(CLedConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnSelectColor();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CLedElement : public CElement  
{
public:
	void OnSelectColor();
	COLORREF Color;
	virtual void SetPinState(DWORD NewState);
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	BOOL ActiveHigh;
	BOOL HighLighted;
  CLedElement(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CLedElement();
	void OnActiveHigh();
	void OnActiveLow();
};


#endif // !defined(AFX_LEDELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_)
