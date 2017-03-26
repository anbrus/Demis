#if !defined(AFX_NEWPRJDLG_H__F11FCA66_2E0E_11D4_AC2F_AA882562FC66__INCLUDED_)
#define AFX_NEWPRJDLG_H__F11FCA66_2E0E_11D4_AC2F_AA882562FC66__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// NewPrjDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CNewPrjDlg dialog

class CNewPrjDlg : public CDialog
{
// Construction
public:
	CNewPrjDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CNewPrjDlg)
	enum { IDD = IDD_NEWPRJDLG };
	CString	m_PrjPath;
	CString	m_PrjName;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CNewPrjDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CNewPrjDlg)
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_NEWPRJDLG_H__F11FCA66_2E0E_11D4_AC2F_AA882562FC66__INCLUDED_)
