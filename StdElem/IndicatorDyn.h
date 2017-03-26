// Indicator.h: interface for the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "Element.h"
#include "ElementWnd.h"

class CIndicatorDyn;

class CIndDArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC *pDC,DWORD OldPinState,DWORD OldHighLight);
	CIndDArchWnd(CElement* pElement);
	virtual ~CIndDArchWnd();

protected:
  //{{AFX_MSG(CIndDArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnTimer(UINT nIDEvent);
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CIndDConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC *pDC,DWORD OldPinState,DWORD OldHighLight);
	CIndDConstrWnd(CElement* pElement);
	virtual ~CIndDConstrWnd();

protected:
  //{{AFX_MSG(CIndConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CIndicatorDyn : public CElement  
{
public:
  void OnTimer(UINT idEvent);
	virtual DWORD GetPinState();
	virtual void SetPinState(DWORD NewState);
	void DrawSegments(CDC *pDC,CBrush* pBkBrush,CPoint Pos,DWORD OldHighLight);
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	BOOL ActiveHigh;
	DWORD HighLight,AfterLightTime;
	virtual BOOL Load(HANDLE hFile);
	CIndicatorDyn(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CIndicatorDyn();
	void OnActiveHigh();
	void OnActiveLow();

  DWORD TimeToOff[8];
protected:
  POINT IndImage[8][6];

  DWORD PinState;
};
