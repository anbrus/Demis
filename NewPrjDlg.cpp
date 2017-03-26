// NewPrjDlg.cpp : implementation file
//

#include "stdafx.h"
#include "demis2000.h"
#include "NewPrjDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CNewPrjDlg dialog


CNewPrjDlg::CNewPrjDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CNewPrjDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CNewPrjDlg)
	m_PrjPath = _T("");
	m_PrjName = _T("");
	//}}AFX_DATA_INIT
}


void CNewPrjDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CNewPrjDlg)
	DDX_Text(pDX, IDC_NEWPRJPATH, m_PrjPath);
	DDX_Text(pDX, IDC_NEWPRJNAME, m_PrjName);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CNewPrjDlg, CDialog)
	//{{AFX_MSG_MAP(CNewPrjDlg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CNewPrjDlg message handlers

void CNewPrjDlg::OnOK() 
{
  //CString FullName;
  UpdateData();
  if(m_PrjPath[m_PrjPath.GetLength()-1]!='\\') {
    m_PrjPath+='\\';
  }
  UpdateData(FALSE);
  int Start=-1;
  while((Start=m_PrjPath.Find('\\',Start+1))!=-1) {
    CreateDirectory(m_PrjPath.Left(Start),NULL);
  }
  //FullName=m_PrjPath+m_PrjName+".prj";
  //CFile PrjFile(FullName,CFile::modeCreate);
	CDialog::OnOK();
}
