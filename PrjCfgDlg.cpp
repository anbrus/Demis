// PrjCfgDlg.cpp : implementation file
//

#include "stdafx.h"
#include "demis2000.h"
#include "PrjCfgDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPrjCfgDlg dialog


CPrjCfgDlg::CPrjCfgDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CPrjCfgDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CPrjCfgDlg)
	m_RamSize = _T("");
	m_RamStart = _T("");
	m_RomStart = _T("");
	m_sRomSize = _T("");
	m_TaktFreq = 0;
	m_RomSize = 0;
	m_FreePinLevel = -1;
	//}}AFX_DATA_INIT
}


void CPrjCfgDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	if (!pDX->m_bSaveAndValidate) {
		if ((m_RomSize > 0) && (m_RomSize < 1024)) {
			m_RamStart = "00000h";
			m_RomStart.Format("%05Xh", 1024 * 1024 - m_RomSize * 1024);
			m_RamSize.Format("%d", 1024 - m_RomSize);
			m_sRomSize.Format("%d", m_RomSize);
		}
	}

	//{{AFX_DATA_MAP(CPrjCfgDlg)
	DDX_Text(pDX, IDC_RAMSIZE, m_RamSize);
	DDX_Text(pDX, IDC_RAMSTART, m_RamStart);
	DDX_Text(pDX, IDC_ROMSTART, m_RomStart);
	DDX_Text(pDX, IDC_ROMSIZE, m_sRomSize);
	DDX_Text(pDX, IDC_TAKTFREQ, m_TaktFreq);
	DDV_MinMaxFloat(pDX, m_TaktFreq, 0.001f, 1E6f);
	DDX_Radio(pDX, IDC_FREEPIN_0, m_FreePinLevel);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CPrjCfgDlg, CDialog)
	//{{AFX_MSG_MAP(CPrjCfgDlg)
	ON_EN_CHANGE(IDC_ROMSIZE, OnChangeRomSize)
	ON_COMMAND(ID_HELP, OnHelp)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPrjCfgDlg message handlers

void CPrjCfgDlg::OnChangeRomSize()
{
	UpdateData();
	int NewSize;
	if (sscanf(m_sRomSize, "%d", &NewSize) != 1) return;
	m_RomSize = NewSize;
	UpdateData(FALSE);
}

void CPrjCfgDlg::OnOK()
{
	if (m_sRomSize.GetLength() != 0) CDialog::OnOK();
	else MessageBeep(-1);
}

void CPrjCfgDlg::OnHelp() {
	AfxGetApp()->HtmlHelp((DWORD_PTR)"HTML/Project.htm", HH_DISPLAY_TOPIC);
}