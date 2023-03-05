#if !defined(AFX_ARCHFRAME_H__11136566_3531_11D4_AC57_8826044CFF66__INCLUDED_)
#define AFX_ARCHFRAME_H__11136566_3531_11D4_AC57_8826044CFF66__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// ArchFrame.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CArchFrame frame

class CArchFrame : public CMDIChildWnd
{
	DECLARE_DYNCREATE(CArchFrame)
protected:
	CArchFrame();           // protected constructor used by dynamic creation
	CArray<CString, CString> MsgStr;

	// Attributes
public:

	// Operations
public:
	void ChangeMode(BOOL bConfigMode);
	CString MenuItemGUID[256];
	CMenu ArchSubMenu[16];
	CDocument* pDoc;
	struct _ChildWndInfo ChildWndInfo;
	// Overrides
		// ClassWizard generated virtual function overrides
		//{{AFX_VIRTUAL(CArchFrame)
public:
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle = WS_CHILD | WS_VISIBLE | WS_OVERLAPPEDWINDOW, const RECT& rect = rectDefault, CMDIFrameWnd* pParentWnd = NULL, CCreateContext* pContext = NULL);
	virtual BOOL DestroyWindow();
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CArchFrame();

	// Generated message map functions
	//{{AFX_MSG(CArchFrame)
	afx_msg void OnClose();
	afx_msg void OnAddElement(UINT nId);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
public:
	virtual void GetMessageString(UINT nID, CString& rMessage) const;
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ARCHFRAME_H__11136566_3531_11D4_AC57_8826044CFF66__INCLUDED_)
