#pragma once

#include "ElementBase.h"
//#include "ElementWnd.h"

#include "vi54.h"

class Vi54IoPort : public CElementBase {
public:
	Vi54IoPort(BOOL ArchMode, int id);
	virtual ~Vi54IoPort();

	VI54 Vi54;

	virtual void SetPortData(DWORD Addresses, DWORD Data) override;
	virtual DWORD GetPortData(DWORD Addresses) override;
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;
};

