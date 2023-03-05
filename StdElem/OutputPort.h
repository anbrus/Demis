// OutputPort.h: interface for the COutputPort class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

#include <mutex>

class COutputPort;

class COutPortArchWnd : public CElementWnd
{
public:
	COutPortArchWnd(CElementBase* pElement);
	virtual ~COutPortArchWnd();

	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;
	void InitializePoints();

protected:
	CDC MemoryDC;
	std::mutex mutexDraw;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);

	afx_msg void OnAddress();
	afx_msg void OnRotate();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()
};

class COutputPort : public CElementBase
{
public:
	COutputPort(BOOL ArchMode, int id);
	virtual ~COutputPort();

	virtual DWORD GetPinState();
	virtual void SetPinState(DWORD NewState);
	virtual void SetPortData(DWORD Data);
	DWORD Value;
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
protected:
};
