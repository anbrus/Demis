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
	if (!pDX->m_bSaveAndValidate) {
		strIrqNumber.Format("%02X", irqNumber);
	}
	
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_ADDRESS, strIrqNumber);
	DDV_MaxChars(pDX, strIrqNumber, 2);
	DDX_CBIndex(pDX, IDC_LEVEL, activeHigh);

	if (pDX->m_bSaveAndValidate) {
		char c;
		if (sscanf(strIrqNumber, "%X%c", &irqNumber, &c) != 1) {
			pDX->PrepareCtrl(IDC_ADDRESS);
			pDX->Fail();
		}
		if (irqNumber < 0x20 || irqNumber>0x28) {
			pDX->PrepareCtrl(IDC_ADDRESS);
			pDX->Fail();
		}
	}
}


BEGIN_MESSAGE_MAP(IrqSettingsDlg, CDialog)
	//{{AFX_MSG_MAP(CADCDelayDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()
