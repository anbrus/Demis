// Indicator.h: interface for the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

#include <mutex>

class CIndicator;

class CIndArchWnd : public CElementWnd
{
public:
	CIndArchWnd(CElementBase* pElement);
	virtual ~CIndArchWnd();

	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;

protected:
	//{{AFX_MSG(CIndArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};


class CIndConstrWnd : public CElementWnd
{
public:
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;
	CIndConstrWnd(CElementBase* pElement);
	virtual ~CIndConstrWnd();

protected:
	//{{AFX_MSG(CIndConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};

class CIndicator : public CElementBase
{
public:
	CIndicator(BOOL ArchMode, int id);
	virtual ~CIndicator();

	std::mutex mutexDraw;
	BOOL ActiveHigh;
	DWORD HighLight;

	virtual DWORD GetPinState();
	virtual void SetPinState(DWORD NewState);
	void DrawSegments(CDC* pDC, bool isSelected, bool isArchMode, CPoint Pos);
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	void OnActiveHigh();
	void OnActiveLow();

protected:
	POINT IndImage[8][6];
};
