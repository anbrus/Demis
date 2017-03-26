#if !defined(AFX_DEBUGFRAME_H__0A312C11_EC49_11D3_AB18_ECCB5B165B62__INCLUDED_)
#define AFX_DEBUGFRAME_H__0A312C11_EC49_11D3_AB18_ECCB5B165B62__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "MainFrm.h"
#include "RegsView.h"
#include "DumpView.h"
#include "DasmView.h"

// DebugFrame.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CDebugFrame frame

class CDebugFrame : public CMDIChildWnd
{
	DECLARE_DYNCREATE(CDebugFrame)
protected:

// Attributes
public:

// Operations
public:
	void UpdateAllViews();
  //CDasmView DasmView;
	void OnRunProgram();
	void OnStopProgram(DWORD StopCode);
  CSplitterWnd LeftSplitter;
	CFrameWnd* pLeftDebug;
	CFrameWnd* pRightDebug;
  CRegsView* pRegsView;
  CDasmView* pDasmView;
  CDumpView* pDumpView;
	struct _ChildWndInfo ChildWndInfo;
	//CArchDoc* pArchDoc;
	CDebugFrame();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDebugFrame)
	public:
	virtual BOOL DestroyWindow();
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle = WS_CHILD | WS_VISIBLE | WS_OVERLAPPEDWINDOW, const RECT& rect = rectDefault, CMDIFrameWnd* pParentWnd = NULL, CCreateContext* pContext = NULL);
	protected:
	virtual BOOL OnCreateClient(LPCREATESTRUCT lpcs, CCreateContext* pContext);
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CDebugFrame();

	// Generated message map functions
	//{{AFX_MSG(CDebugFrame)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnStepInto();
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnDasmAll();
	afx_msg void OnRunTo();
	afx_msg void OnStepOver();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DEBUGFRAME_H__0A312C11_EC49_11D3_AB18_ECCB5B165B62__INCLUDED_)
