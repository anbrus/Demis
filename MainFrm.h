// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_MAINFRM_H__6A0AA609_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
#define AFX_MAINFRM_H__6A0AA609_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "definitions.h"

struct _ChildWndInfo
{
public:
	int BtnCount;
	TBBUTTON Btn[16];
	CDocument* pDocument;
	int MenuIndex;
	CString DocType;
	CMDIChildWnd* pChildWnd;
	CMenu Menu;
};

#include "DebugFrame.h"

class CDebugFrame;

class CInfoBar : public CMDIChildWnd
{
	DECLARE_DYNCREATE(CInfoBar);
public:
	CInfoBar();
	~CInfoBar();
	CEdit InfoEdit;
	CMDIFrameWnd* pParentFrame;
	virtual BOOL Create(CMDIFrameWnd* pParent);
	CFont m_Font;
	void ClearInfo();
	void AddText(CString Add);
	//CString InfoText;
	void SetSize(CSize NewSize) {};
	//virtual CSize CalcDynamicLayout(int nLength,DWORD dwMode);
  //{{AFX_VIRTUAL(CInfoBar)
public:
	virtual BOOL DestroyWindow();
protected:
	//}}AFX_VIRTUAL

protected:
	//CSize Size;
	//{{AFX_MSG(CInfoBar)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

class CMainFrame : public CMDIFrameWnd
{
	DECLARE_DYNAMIC(CMainFrame)
public:
	CMainFrame();

	// Attributes
public:

	// Operations
public:

	virtual BOOL DestroyWindow();

// Implementation
public:
	void ClearMessages();
	void AddMessage(const char* MesText, BOOL SetFocus);
	int MenuCounter[7];
	BOOL DeleteChildWindow(struct _ChildWndInfo* pChildWndInfo);
	CPtrList ChildWndList;
	BOOL AddChildWindow(struct _ChildWndInfo* pChildWndInfo);
	BOOL InfoBarPresent;
	void RestoreInfoBar();
	void CloseAllWindows();
	//BOOL CreateBar(CWnd* pParentWnd, UINT nIDTemplate, UINT nStyle, UINT nID);
	//struct _Port InpPort[64],OutPort[64];
	virtual ~CMainFrame();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:  // control bar embedded members
	CStatusBar  m_wndStatusBar;
	CToolBar    m_wndToolBar;
	CReBar      m_wndReBar;

	// Generated message map functions
protected:
	CDialogBar m_wndProjectBar;
	CInfoBar* pInfoBar;
	//{{AFX_MSG(CMainFrame)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnFileMruPrj(UINT nID);
	afx_msg void OnUpdateFileMruPrj1(CCmdUI* pCmdUI);
	afx_msg void OnClose();
	afx_msg LRESULT OnEmulatorMessage(WPARAM, LPARAM);
	afx_msg LPARAM OnReadPort(WPARAM wParam, LPARAM lParam);
	afx_msg LPARAM OnIntRequest(WPARAM wParam, LPARAM lParam);
	afx_msg LPARAM OnEmulStop(WPARAM wParam, LPARAM lParam);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAINFRM_H__6A0AA609_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
