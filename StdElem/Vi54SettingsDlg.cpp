#include "stdafx.h"
#include "Vi54SettingsDlg.h"

Vi54SettingsDlg::Vi54SettingsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(Vi54SettingsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCDelayDlg)
	//}}AFX_DATA_INIT
}


void Vi54SettingsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_ADDRESS, strAddressBaseTimer);
	DDV_MaxChars(pDX, strAddressBaseTimer, 4);
	DDX_CBIndex(pDX, IDC_TIMER_INDEX, indexTimer);
	DDX_Text(pDX, IDC_FREQ, freq);
	DDV_MinMaxInt(pDX, freq, 0, 10000000);

	if (pDX->m_bSaveAndValidate) {
		char c;
		if (sscanf(strAddressBaseTimer, "%X%c", &intBaseAddress, &c) != 1) {
			pDX->PrepareCtrl(IDC_ADDRESS);
			pDX->Fail();
		}
	}
}


BEGIN_MESSAGE_MAP(Vi54SettingsDlg, CDialog)
	//{{AFX_MSG_MAP(CADCDelayDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

void Vi54SettingsDlg::SetBaseAddress(uint16_t value) {
	intBaseAddress = value;
	strAddressBaseTimer.Format("%04X", value);
}

uint16_t Vi54SettingsDlg::GetBaseAddress() {
	return intBaseAddress;
}

void Vi54SettingsDlg::SetFreq(int value) {
	freq = value;
}

int Vi54SettingsDlg::GetFreq() {
	return freq;
}