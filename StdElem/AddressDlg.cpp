// AddressDlg.cpp : implementation file
//

#include "stdafx.h"
#include "AddressDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAddressDlg dialog


CAddressDlg::CAddressDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CAddressDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CAddressDlg)
	strAddress = _T("");
	//}}AFX_DATA_INIT
}


void CAddressDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAddressDlg)
	DDX_Text(pDX, IDC_ADDRESS, strAddress);
	DDV_MaxChars(pDX, strAddress, 4);
	//}}AFX_DATA_MAP

  if(pDX->m_bSaveAndValidate) {
    char c;
    if(sscanf(strAddress,"%X%c",&intAddress,&c)!=1) {
      pDX->PrepareCtrl(IDC_ADDRESS);
      pDX->Fail();
    }
  }
}


BEGIN_MESSAGE_MAP(CAddressDlg, CDialog)
	//{{AFX_MSG_MAP(CAddressDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CAddressDlg message handlers

void CAddressDlg::SetAddress(WORD Addresses)
{
  strAddress.Format("%04X",Addresses);
}

WORD CAddressDlg::GetAddress()
{
  return intAddress;
}
