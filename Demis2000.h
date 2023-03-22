#pragma once

#ifndef __AFXWIN_H__
#error include 'stdafx.h' before including this file for PCH
#endif

#include "afxadv.h"
#include "resource.h"       // main symbols
#include "definitions.h"
#include "DebugFrame.h"
#include "ArchDoc.h"
#include "PrjDoc.h"
#include "PrjFrame.h"
#include "StdElem.h"

#include <vector>
#include <unordered_map>

/////////////////////////////////////////////////////////////////////////////
// CDemis2000App:
// See Demis2000.cpp for the implementation of this class
//

#define WMU_EMULATOR_MESSAGE    WM_USER+1
#define WMU_ADD_ELEMENT_BY_NAME WM_USER+2

class HostData : public HostInterface {
public:
	HostData();
	virtual ~HostData();

	virtual void SetTickTimer(int64_t ticks, int64_t interval, DWORD hElement, std::function<void(DWORD)> handler) override;
	virtual void WritePort(WORD port, BYTE value) override;
	virtual uint8_t ReadPort(WORD port) override;
	virtual void OnPinStateChanged(DWORD PinState, int hElement) override;
	virtual int AddInstructionListener(std::function<void(int64_t)> handler) override;
	virtual void DeleteInstructionListener(int id) override;
	virtual void Interrupt(int irqNumber) override;
};


class CDemis2000App : public CWinApp
{
public:
	CDemis2000App();
	~CDemis2000App();

	std::unordered_map<std::string, CElemLib*> ElementLibraries;

	CDebugFrame* pDebugFrame;
	CArchDoc* pDebugArchDoc;
	CMultiDocTemplate* pAsmTemplate=nullptr;
	CMultiDocTemplate *pArchTemplate = nullptr;
	CMultiDocTemplate *pPrjTemplate = nullptr;
	HANDLE hRunThread;
	CRecentFileList* pPrjMRUList = nullptr;
	CString RunDir;
	struct _EmulatorData* pEmData = nullptr;
	HostData Data;
	CPrjDoc* pPrjDoc = nullptr;
	UINT FrozenTimer;

	void RunProg();
	BOOL UpdateExecutable();
	//BOOL EnumElemLibs(LONG Index, CString* LibName, CString* ClsName);
	DWORD BuildMsgCount=0;
	void TerminateEmulator();
	void GetErrorText(DWORD Code, CString& ErrorText);
	DWORD AddBuildMessages(std::vector<struct _ErrorData>& Errors);
	BOOL InitProgram();
	static DWORD pascal HostCall(DWORD Message, WPARAM wParam, LPARAM lParam);
	std::shared_ptr<CElement> CreateExtElement(const CString& LibName, const CString& ElementName, BOOL ArchMode, int id);
	BOOL PrepareArchForEmulation();
	CDocument* OpenDemisDocument(const CString& PathName, CString& Type);

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
	static void CALLBACK OnEmulatorFrozen(HWND hWnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime);
	//CString LibGUID[16], LibPath[16];
	void LoadLibraryInformation();
	void AddMessage(const CString Msg, BOOL SetFocus);
	BOOL Link(int *pErrorsCount, int *pWarningsCount);
	BOOL Assemble(int *pErrorsCount, int *pWarningsCount);
};

extern CDemis2000App theApp;
