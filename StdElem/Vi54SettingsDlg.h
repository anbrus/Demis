#pragma once

#include "resource.h"

class Vi54SettingsDlg : public CDialog
{
public:
	Vi54SettingsDlg(CWnd* pParent = NULL);

	enum { IDD = IDD_VI54_SETTINGS_DLG };

	int indexTimer=0;

	void SetBaseAddress(uint16_t value);
	uint16_t GetBaseAddress();

	void SetFreq(int value);
	int GetFreq();

protected:
	int freq = 0;
	uint16_t intBaseAddress = 0;
	CString	strAddressBaseTimer = "";

	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	DECLARE_MESSAGE_MAP()

};

