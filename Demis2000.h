// Demis2000.h : main header file for the DEMIS2000 application
//

#if !defined(AFX_DEMIS2000_H__6A0AA605_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
#define AFX_DEMIS2000_H__6A0AA605_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "afxadv.h"
#include "resource.h"       // main symbols
#include "DebugFrame.h"
#include "ArchDoc.h"
#include "PrjDoc.h"
#include "PrjFrame.h"
#include "StdElem.h"

#include <vector>

/////////////////////////////////////////////////////////////////////////////
// CDemis2000App:
// See Demis2000.cpp for the implementation of this class
//

#define WMU_EMULATOR_MESSAGE    WM_USER+1
#define WMU_ADD_ELEMENT_BY_NAME WM_USER+2

class CDemis2000App : public CWinApp
{
public:
	void RunProg();
	BOOL UpdateExecutable();
	BOOL EnumElemLibs(LONG Index, CString* LibName, CString* ClsName);
	DWORD BuildMsgCount;
	void TerminateEmulator();
	void GetErrorText(DWORD Code,CString& ErrorText);
	DWORD AddBuildMessages(std::vector<struct _ErrorData>& Errors);
  CDebugFrame* pDebugFrame;
	BOOL InitProgram();
	static DWORD pascal HostCall(DWORD Message,WPARAM wParam,LPARAM lParam);
	CElement *CreateExtElement(CString LibName,CString ElementName,BOOL ArchMode);
	CArchDoc* pDebugArchDoc;
	BOOL PrepareArchForEmulation();
	HANDLE hRunThread;
	CRecentFileList* pPrjMRUList;
	CDocument* OpenDemisDocument(CString& PathName, CString& Type);
	CString RunDir;
	struct _EmulatorData* pEmData;
	struct _HostData Data;
  CPrjDoc* pPrjDoc;
	 ~CDemis2000App();
	CMultiDocTemplate* pAsmTemplate;
	CMultiDocTemplate *pArchTemplate;
	CMultiDocTemplate *pPrjTemplate;
	CDemis2000App();
	UINT FrozenTimer;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDemis2000App)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	virtual void WinHelp(DWORD dwData, UINT nCmd = HELP_CONTEXT);
	virtual BOOL SaveAllModified();
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CDemis2000App)
	afx_msg void OnAppAbout();
	afx_msg void OnDebug();
	afx_msg void OnRun();
	afx_msg void OnBreak();
	afx_msg void OnUpdateBreak(CCmdUI* pCmdUI);
	afx_msg void OnEmulatorCfg();
	afx_msg void OnUpdateRun(CCmdUI* pCmdUI);
	afx_msg void OnBuild();
	afx_msg void OnAssemble();
	afx_msg void OnLink();
	afx_msg void OnUpdateDebug(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEmulatorCfg(CCmdUI* pCmdUI);
	afx_msg void OnNewPrj();
	afx_msg void OnOpenPrj();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
protected:
	static void CALLBACK OnEmulatorFrozen(HWND hWnd,UINT uMsg,UINT_PTR idEvent,DWORD dwTime);
	CString LibGUID[16],ClsGUID[16];
	void LoadLibraryInformation();
	void AddMessage(CString Msg,BOOL SetFocus);
	BOOL Link(int *pErrorsCount,int *pWarningsCount);
	BOOL Assemble(int *pErrorsCount,int *pWarningsCount);
};

extern CDemis2000App theApp;

//extern "C" BOOL __stdcall RegisterElement(struct _ElementInfo* pElement);
//extern "C" void __stdcall UnregisterElement(struct _ElementInfo* pElement);

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DEMIS2000_H__6A0AA605_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
