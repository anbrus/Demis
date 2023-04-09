#pragma once

#include "resource.h"

#include <unordered_set>

class Vi54SettingsDlg : public CDialog
{
public:
	Vi54SettingsDlg(CWnd* pParent = NULL);

	enum { IDD = IDD_VI54_SETTINGS_DLG };

	int address=0x40;
	int indexTimer=0;
	bool isFixedFreq = true;
	int freq = 0;
	std::unordered_set<int> validCounterNumbers;

protected:
	virtual void DoDataExchange(CDataExchange* pDX) override;    // DDX/DDV support
	DECLARE_MESSAGE_MAP()
};

