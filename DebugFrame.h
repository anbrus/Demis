#pragma once

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
public:
	CDebugFrame();

	CSplitterWnd LeftSplitter;
	CFrameWnd* pLeftDebug;
	CFrameWnd* pRightDebug;
	CRegsView* pRegsView;
	CDasmView* pDasmView;
	CDumpView* pDumpView;
	struct _ChildWndInfo ChildWndInfo;

	void UpdateAllViews();
	void OnRunProgram();
	void OnStopProgram(DWORD StopCode);
	virtual BOOL DestroyWindow();
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle = WS_CHILD | WS_VISIBLE | WS_OVERLAPPEDWINDOW, const RECT& rect = rectDefault, CMDIFrameWnd* pParentWnd = NULL, CCreateContext* pContext = NULL);

protected:
	virtual ~CDebugFrame();

	virtual BOOL OnCreateClient(LPCREATESTRUCT lpcs, CCreateContext* pContext);

	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnStepInto();
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnDasmAll();
	afx_msg void OnRunTo();
	afx_msg void OnStepOver();

	DECLARE_MESSAGE_MAP()
};
