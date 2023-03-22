#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

class CIrqArchWnd : public CElementWnd {
public:
	CIrqArchWnd(CElementBase* pElement);
	virtual ~CIrqArchWnd();

	virtual void Draw(CDC* pDC) override;
	virtual void Redraw(int64_t ticks) override;
	void updateSize();

protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()
	void OnSettings();

private:
	std::mutex mutexDraw;
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC);
};

class IrqElement : public CElementBase
{
public:
	int irqNumber = 32;

	IrqElement(BOOL ArchMode, int id);
	virtual ~IrqElement();

	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;
	virtual void SetPinState(DWORD NewState) override;
	virtual DWORD GetPinState() override;

	void OnSettings();

private:
	DWORD PinState = 0;
	bool activeHigh=true;

	void UpdateTipText();
	void updatePoints();
};

