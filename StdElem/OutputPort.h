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

	virtual void Draw(CDC* pDC) override;
	virtual void Redraw(int64_t ticks) override;
	void InitializePoints();
	void updateMenu(CMenu& PopupMenu);

protected:
	CDC MemoryDC;
	std::mutex mutexDraw;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);

	afx_msg void OnAddress();
	afx_msg void OnRotate(UINT nId);
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()
};

class COutputPort : public CElementBase
{
public:
	COutputPort(BOOL ArchMode, int id);
	virtual ~COutputPort();

	virtual DWORD GetPinState() override;
	virtual void SetPinState(DWORD NewState) override;
	virtual void SetPortData(DWORD Addresses, DWORD Data) override;
	DWORD Value;
	void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;

};
