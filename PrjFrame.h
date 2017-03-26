#if !defined(AFX_PRJFRAME_H__CE29D6B5_0B71_11D4_AB96_9B6B5A91A566__INCLUDED_)
#define AFX_PRJFRAME_H__CE29D6B5_0B71_11D4_AB96_9B6B5A91A566__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// PrjFrame.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CPrjFrame frame

class CPrjFrame : public CMDIChildWnd
{
	DECLARE_DYNCREATE(CPrjFrame)
protected:
	CPrjFrame();           // protected constructor used by dynamic creation

// Attributes
public:
	struct _ChildWndInfo ChildWndInfo;
// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPrjFrame)
	public:
	virtual void ActivateFrame(int nCmdShow = -1);
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle = WS_CHILD | WS_VISIBLE | WS_OVERLAPPEDWINDOW, const RECT& rect = rectDefault, CMDIFrameWnd* pParentWnd = NULL, CCreateContext* pContext = NULL);
	virtual BOOL DestroyWindow();
	protected:
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CPrjFrame();

	// Generated message map functions
	//{{AFX_MSG(CPrjFrame)
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PRJFRAME_H__CE29D6B5_0B71_11D4_AB96_9B6B5A91A566__INCLUDED_)
