// LedElement.h: interface for the CLedElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LEDELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_)
#define AFX_LEDELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "ElementBase.h"
#include "ElementWnd.h"

class CLedArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	CLedArchWnd(CElementBase* pElement);
	virtual ~CLedArchWnd();
	virtual void Redraw(int64_t ticks) override;

protected:
  //{{AFX_MSG(CLedArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnSelectColor();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
private:
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};


class CLedConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	CLedConstrWnd(CElementBase* pElement);
	virtual ~CLedConstrWnd();
	virtual void Redraw(int64_t ticks) override;

protected:
  //{{AFX_MSG(CLedConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnSelectColor();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
private:
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};

class CLedElement : public CElementBase  
{
public:
	CLedElement(BOOL ArchMode, int id);
	virtual ~CLedElement();

	void OnSelectColor();
	COLORREF Color;
	virtual void SetPinState(DWORD NewState);
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,int64_t* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	BOOL ActiveHigh;
	BOOL HighLighted;
	void OnActiveHigh();
	void OnActiveLow();

private:
	std::mutex mutexDraw;

	friend class CLedArchWnd;
	friend class CLedConstrWnd;
};


#endif // !defined(AFX_LEDELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_)
