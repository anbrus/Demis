#include "stdafx.h"
#include "TextDlg.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

CTextDlg::CTextDlg(CWnd* pParent)
	: CDialog(IDD_TEXT_DLG, pParent)
{
}

void CTextDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_TEXT, Text);
}
