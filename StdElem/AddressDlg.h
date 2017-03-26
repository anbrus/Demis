#if !defined(AFX_ADDRESSDLG_H__24FFE305_771C_11D4_827D_8FEC81240347__INCLUDED_)
#define AFX_ADDRESSDLG_H__24FFE305_771C_11D4_827D_8FEC81240347__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// AddressDlg.h : header file
//

#include "StdElemApp.h"

/////////////////////////////////////////////////////////////////////////////
// CAddressDlg dialog

class CAddressDlg : public CDialog
{
// Construction
protected:
	WORD intAddress;

public:
	WORD GetAddress();
	void SetAddress(WORD Address);
	CAddressDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CAddressDlg)
	enum { IDD = IDD_ADDRESS_DLG };
  CString	strAddress;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAddressDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CAddressDlg)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ADDRESSDLG_H__24FFE305_771C_11D4_827D_8FEC81240347__INCLUDED_)
