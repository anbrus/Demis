#pragma once

#include "resource.h"

class IrqSettingsDlg : public CDialog
{
public:
	IrqSettingsDlg(CWnd* pParent = NULL);

	enum { IDD = IDD_IRQ_SETTINGS_DLG };

	int irqNumber = 0;
	int activeHigh = 1;

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	DECLARE_MESSAGE_MAP()

private:
	CString strIrqNumber;
};

