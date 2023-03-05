#if !defined(AFX_PRJCFGDLG_H__E8472B07_2F8C_11D4_AC36_AC8D8287E066__INCLUDED_)
#define AFX_PRJCFGDLG_H__E8472B07_2F8C_11D4_AC36_AC8D8287E066__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// PrjCfgDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CPrjCfgDlg dialog

class CPrjCfgDlg : public CDialog
{
// Construction
public:
	int m_RomSize;
	CPrjCfgDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CPrjCfgDlg)
	enum { IDD = IDD_EMULATORCFG };
	CString	m_RamSize;
	CString	m_RamStart;
	CString	m_RomStart;
	CString	m_sRomSize;
	float	m_TaktFreq;
	int		m_FreePinLevel;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPrjCfgDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
  virtual void OnOK( );
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CPrjCfgDlg)
	afx_msg void OnChangeRomSize();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PRJCFGDLG_H__E8472B07_2F8C_11D4_AC36_AC8D8287E066__INCLUDED_)
