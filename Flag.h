#if !defined(AFX_FLAG_H__661B1084_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_)
#define AFX_FLAG_H__661B1084_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Flag.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CFlag window

class CFlag : public CButton
{
// Construction
public:
	CFlag();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CFlag)
	public:
	virtual BOOL Create(CRect& Rect,CWnd* pParent,WORD FlagMask,WORD* pFl);
	//}}AFX_VIRTUAL

// Implementation
public:
	CString FlagName;
	BOOL Changed;
	BOOL OldVal;
	BOOL IsInternalUpdate;
	void Update();
	WORD Mask,*pFlag;
	virtual ~CFlag();

	// Generated message map functions
protected:
	//{{AFX_MSG(CFlag)
	afx_msg void OnClicked();
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_FLAG_H__661B1084_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_)
