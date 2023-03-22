#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

class Vi54Counter;

class CVi54ArchWnd : public CElementWnd {
public:
	CVi54ArchWnd(CElementBase* pElement);
	virtual ~CVi54ArchWnd();

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

class CVi54Element:	public CElementBase
{
public:
	int indexTimer;
	uint32_t freq=1000000;

	CVi54Element(BOOL ArchMode, int id);
	virtual ~CVi54Element();

	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual void SetPortData(DWORD Addresses, DWORD Data) override;
	virtual DWORD GetPortData(DWORD Addresses) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;
	virtual std::vector<DWORD> GetAddresses() override;
	virtual void SetPinState(DWORD NewState) override;
	virtual DWORD GetPinState() override;

	void OnSettings();

private:
	DWORD PinState = 0;
	int64_t timeStart = 0;
	int64_t nanosStart = 0;
	int64_t nanosPrevClk = 0;
	int64_t perfFreq = 0;
	int idInstructionListener = -1;
	int64_t nanosFreq;
	Vi54Counter* counter;

	void UpdateTipText();
	void updatePoints();
	void OnInstructionListener(int64_t ticks);
	void updateClk();
};

