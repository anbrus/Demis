#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

#include <random>

class CBtnArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override {};
	CBtnArchWnd(CElementBase* pElement);
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
	virtual void Redraw(int64_t ticks) {};
	void UpdateSize();
	CBtnConstrWnd(CElementBase* pElement);
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

class CButtonElement : public CElementBase  
{
public:
	CButtonElement(BOOL ArchMode, int id);
	virtual ~CButtonElement();

	void OnTickTimer();
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
	virtual BOOL Reset(BOOL bEditMode,int64_t* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	BOOL NormalOpened;
	BOOL Pressed;

private:
	DWORD CurState;
	int64_t* pTickCounter=nullptr;
	int64_t ticksDrebezgEnd;
	std::default_random_engine rndEngine;
	std::uniform_int_distribution<int> distributionDrebezg = std::uniform_int_distribution<int>(2000, 5000);
	std::uniform_int_distribution<int> distributionBinary = std::uniform_int_distribution<int>(0, 1);

	void ChangePinState();
};
