// InputPort.h: interface for the CInputPort class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

#include <mutex>

class CInputPort;

class CInPortArchWnd : public CElementWnd
{
public:
	CInPortArchWnd(CElementBase* pElement);
	virtual ~CInPortArchWnd();

	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;
	void DrawDynamic(CDC* pDC);
	void DrawStatic(CDC* pDC);
	int Width, Height;

protected:
	CDC MemoryDC;
	std::mutex mutexDraw;

	afx_msg void OnAddress();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()
};

class CInputPort : public CElementBase
{
public:
	CInputPort(BOOL ArchMode, int id);
	virtual ~CInputPort();

	virtual DWORD GetPinState() override;
	virtual DWORD GetPortData(DWORD Addresses) override;
	virtual void SetPinState(DWORD NewState) override;
	DWORD Value;
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;
	void UpdateTipText();
};

