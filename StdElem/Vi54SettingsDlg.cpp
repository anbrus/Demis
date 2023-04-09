#include "stdafx.h"
#include "Vi54SettingsDlg.h"

#include <format>

Vi54SettingsDlg::Vi54SettingsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(Vi54SettingsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCDelayDlg)
	//}}AFX_DATA_INIT
}

void Vi54SettingsDlg::DoDataExchange(CDataExchange* pDX)
{
	CString strBaseAddress = std::format("{:02X}h", address).c_str();
	int cbFreq = isFixedFreq ? 0 : 1;

	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_ADDRESS, strBaseAddress);
	DDV_MaxChars(pDX, strBaseAddress, 4);
	DDX_CBIndex(pDX, IDC_TIMER_INDEX, indexTimer);
	DDX_Text(pDX, IDC_FREQ, freq);
	DDV_MinMaxInt(pDX, freq, 1, 10000000);
	DDX_Radio(pDX, IDC_FIXED_CLK, cbFreq);

	if (pDX->m_bSaveAndValidate) {
		isFixedFreq = cbFreq == 0;

		if (validCounterNumbers.count(indexTimer) == 0) {
			AfxMessageBox("Таймер с этим номером уже используется", MB_ICONSTOP);
			pDX->PrepareCtrl(IDC_TIMER_INDEX);
			pDX->Fail();
			return;
		}

		char c;
		int baseAddress;
		if (sscanf(strBaseAddress, "%X%c", &baseAddress, &c) < 1) {
			pDX->PrepareCtrl(IDC_ADDRESS);
			pDX->Fail();
			return;
		}
		address = static_cast<uint16_t>(baseAddress);
	}
}


BEGIN_MESSAGE_MAP(Vi54SettingsDlg, CDialog)
	//{{AFX_MSG_MAP(CADCDelayDlg)
	// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()
