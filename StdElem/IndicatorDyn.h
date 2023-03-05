// Indicator.h: interface for the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

#include <mutex>

class CIndicatorDyn;

class CIndDArchWnd : public CElementWnd
{
public:
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;
	CIndDArchWnd(CElementBase* pElement);
	virtual ~CIndDArchWnd();

protected:
	CDC MemoryDC;

	//{{AFX_MSG(CIndDArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};


class CIndDConstrWnd : public CElementWnd
{
public:
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;
	CIndDConstrWnd(CElementBase* pElement);
	virtual ~CIndDConstrWnd();

protected:
	CDC MemoryDC;

	//{{AFX_MSG(CIndConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};

class CIndicatorDyn : public CElementBase
{
public:
	CIndicatorDyn(BOOL ArchMode, int id);
	virtual ~CIndicatorDyn();

	std::mutex mutexDraw;
	int64_t* pTickCounter = nullptr;
	int64_t ticksAfterLight;
	DWORD PinState;
	BOOL ActiveHigh;
	int64_t HighLighted[8];

	virtual DWORD GetPinState();
	virtual void SetPinState(DWORD NewState);
	void DrawSegments(CDC* pDC, bool isSelected, bool isArchMode, CPoint Pos);
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	void OnActiveHigh();
	void OnActiveLow();
	bool IsRedrawRequired();

protected:
	POINT IndImage[8][6];
};
