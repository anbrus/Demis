#include "stdafx.h"
#include "IrqSettingsDlg.h"

IrqSettingsDlg::IrqSettingsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(IrqSettingsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCDelayDlg)
	//}}AFX_DATA_INIT
}


void IrqSettingsDlg::DoDataExchange(CDataExchange* pDX)
{
	int idx_address = 0;
	if (!pDX->m_bSaveAndValidate) {
		switch (irqNumber) {
		case 0x02: idx_address = 0; break;
		case 0x20: idx_address = 1; break;
		case 0x21: idx_address = 2; break;
		case 0x22: idx_address = 3; break;
		case 0x23: idx_address = 4; break;
		case 0x24: idx_address = 5; break;
		case 0x25: idx_address = 6; break;
		case 0x26: idx_address = 7; break;
		case 0x27: idx_address = 8; break;
		case 0xff: idx_address = 9; break;
		}
	}
	
	CDialog::DoDataExchange(pDX);
	DDX_CBIndex(pDX, IDC_ADDRESS, idx_address);
	DDV_MaxChars(pDX, strIrqNumber, 2);
	DDX_CBIndex(pDX, IDC_LEVEL, activeHigh);

	if (pDX->m_bSaveAndValidate) {
		switch (idx_address) {
		case 0: irqNumber = 0x02; break;
		case 1: irqNumber = 0x20; break;
		case 2: irqNumber = 0x21; break;
		case 3: irqNumber = 0x22; break;
		case 4: irqNumber = 0x23; break;
		case 5: irqNumber = 0x24; break;
		case 6: irqNumber = 0x25; break;
		case 7: irqNumber = 0x26; break;
		case 8: irqNumber = 0x27; break;
		case 9: irqNumber = 0xff; break;
		}
	}
}


BEGIN_MESSAGE_MAP(IrqSettingsDlg, CDialog)
	//{{AFX_MSG_MAP(CADCDelayDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()
