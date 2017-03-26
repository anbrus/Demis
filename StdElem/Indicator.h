// Indicator.h: interface for the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INDICATOR_H__159F0B11_7C9E_11D4_828D_94691C991847__INCLUDED_)
#define AFX_INDICATOR_H__159F0B11_7C9E_11D4_828D_94691C991847__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CIndicator;

class CIndArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC,DWORD OldValue);
	CIndArchWnd(CElement* pElement);
	virtual ~CIndArchWnd();

protected:
  //{{AFX_MSG(CIndArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CIndConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC,DWORD OldValue);
	CIndConstrWnd(CElement* pElement);
	virtual ~CIndConstrWnd();

protected:
  //{{AFX_MSG(CIndConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CIndicator : public CElement  
{
public:
	virtual DWORD GetPinState();
	virtual void SetPinState(DWORD NewState);
	void DrawSegments(CDC *pDC,CBrush* pBkBrush,CPoint Pos,DWORD OldValue);
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	BOOL ActiveHigh;
	DWORD HighLight;
	virtual BOOL Load(HANDLE hFile);
	CIndicator(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CIndicator();
	void OnActiveHigh();
	void OnActiveLow();
protected:
  POINT IndImage[8][6];

};

#endif // !defined(AFX_INDICATOR_H__159F0B11_7C9E_11D4_828D_94691C991847__INCLUDED_)
