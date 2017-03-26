#if !defined(AFX_REGISTEREDIT_H__661B1083_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_)
#define AFX_REGISTEREDIT_H__661B1083_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// RegisterEdit.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CRegisterEdit window

class CRegisterEdit : public CEdit
{
// Construction
public:
	CRegisterEdit();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRegisterEdit)
	public:
	virtual BOOL Create(CRect& Rect,CWnd* pParent,WORD* pRegister);
	//}}AFX_VIRTUAL

// Implementation
public:
	CString RegName;
	WORD CurValue;
	BOOL Changed;
	BOOL IsInternalChange;
	void Update();
	CFont Font;
	WORD* pReg;
	virtual ~CRegisterEdit();

	// Generated message map functions
protected:
	//{{AFX_MSG(CRegisterEdit)
	afx_msg void OnChar(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnChange();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_REGISTEREDIT_H__661B1083_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_)
