// DebugFrame.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "DebugFrame.h"
#include "definitions.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDebugFrame

IMPLEMENT_DYNCREATE(CDebugFrame, CMDIChildWnd)

constexpr int WIDTH_REGS_VIEW = 108;

CDebugFrame::CDebugFrame()
{
	ChildWndInfo.Menu.LoadMenu(IDR_DEBUGTYPE_ADD);
	ChildWndInfo.MenuIndex = 3;
	ChildWndInfo.pChildWnd = this;
	ChildWndInfo.pDocument = NULL;
	ChildWndInfo.BtnCount = 0;
	((CMainFrame*)theApp.m_pMainWnd)->AddChildWindow(&ChildWndInfo);
	pRegsView = new CRegsView;
}

CDebugFrame::~CDebugFrame()
{
	TRACE("Debug Frame Class Destroyed\n");
}


BEGIN_MESSAGE_MAP(CDebugFrame, CMDIChildWnd)
	//{{AFX_MSG_MAP(CDebugFrame)
	ON_WM_CREATE()
	ON_COMMAND(ID_STEPINTO, OnStepInto)
	ON_WM_SIZE()
	ON_COMMAND(ID_DASMALL, OnDasmAll)
	ON_COMMAND(ID_RUNTO, OnRunTo)
	ON_COMMAND(ID_STEPOVER, OnStepOver)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDebugFrame message handlers

BOOL CDebugFrame::OnCreateClient(LPCREATESTRUCT lpcs, CCreateContext* pContext)
{
	pLeftDebug = new CFrameWnd;
	pLeftDebug->Create(NULL, "LeftDebug", WS_VISIBLE | WS_CHILD
		| WS_OVERLAPPED, CRect(0, 0, 1, 1), this);
	CRuntimeClass* pDasm = RUNTIME_CLASS(CDasmView);
	CRuntimeClass* pDump = RUNTIME_CLASS(CDumpView);

	LeftSplitter.CreateStatic(pLeftDebug, 2, 1);
	LeftSplitter.CreateView(0, 0, pDasm, CSize(100, 200), NULL);
	LeftSplitter.CreateView(1, 0, pDump, CSize(100, 100), NULL);

	CRect ParentRect;
	GetClientRect(&ParentRect);
	LeftSplitter.SetRowInfo(0, ParentRect.bottom - 50, 0);
	LeftSplitter.RecalcLayout();

	pDasmView = (CDasmView*)LeftSplitter.GetPane(0, 0);
	pDasmView->pDebugFrame = this;
	pDumpView = (CDumpView*)LeftSplitter.GetPane(1, 0);
	pDumpView->pDebugFrame = this;

	pRightDebug = new CFrameWnd;
	pRightDebug->Create(NULL, "RightDebug", WS_VISIBLE | WS_CHILD
		| WS_OVERLAPPED, CRect(0, 0, WIDTH_REGS_VIEW, 100), this);

	pRegsView->Create(NULL, "RegsView", WS_CHILD | WS_VISIBLE | WS_OVERLAPPED,
		CRect(0, 0, 1, 1), pRightDebug, 0);
	pRegsView->pDebugFrame = this;
	pRegsView->OnInitialUpdate();

	return CMDIChildWnd::OnCreateClient(lpcs, pContext);
}

int CDebugFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CMDIChildWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

	HACCEL hAccel = ::LoadAccelerators(AfxGetInstanceHandle(), MAKEINTRESOURCE(IDR_DEBUGTYPE_ADD));
	SetHandles(NULL, hAccel);
	SetIcon(AfxGetApp()->LoadIcon(IDR_DEBUGTYPE), FALSE);

	return 0;
}

void CDebugFrame::OnStepInto()
{
	DWORD Result;
	if ((Result = ::StepInstruction(TRUE)) != 0) {
		CString ErrorText;
		theApp.GetErrorText(Result, ErrorText);
		MessageBox(ErrorText, "Îøèáêà", MB_ICONSTOP | MB_OK);
	}

	pDasmView->OnStep();
	pDumpView->OnStep();
	pRegsView->OnStep();
}

void CDebugFrame::OnSize(UINT nType, int cx, int cy)
{
	if (cx - WIDTH_REGS_VIEW > 300) {
		pLeftDebug->MoveWindow(0, 0, cx - WIDTH_REGS_VIEW, cy);
		pRightDebug->MoveWindow(cx - WIDTH_REGS_VIEW, 0, cx, cy);
	}
	else {
		pLeftDebug->MoveWindow(0, 0, 300, cy);
		pRightDebug->MoveWindow(300, 0, 400, cy);
	}
	pRegsView->MoveWindow(0, 0, WIDTH_REGS_VIEW, cy);

	CMDIChildWnd::OnSize(nType, cx, cy);
}

BOOL CDebugFrame::DestroyWindow()
{
	theApp.TerminateEmulator();
	if (theApp.pDebugArchDoc) theApp.pDebugArchDoc->ChangeMode(TRUE);

	((CMainFrame*)theApp.m_pMainWnd)->DeleteChildWindow(&ChildWndInfo);
	theApp.pDebugFrame = NULL;

	TRACE("Debug Frame Destroyed\n");

	return CMDIChildWnd::DestroyWindow();
}

void CDebugFrame::OnDasmAll()
{
	CStdioFile OutFile("DasmList.asm", CFile::modeCreate | CFile::modeWrite);
	char Instr[128];
	CString Line;
	WORD IPOffs, CurIP = 0, CurCS = theApp.pEmData->Reg.CS;
	while (CurIP <= 0x1000) {
		IPOffs = (WORD)::DasmInstr(CurCS, CurIP, theApp.pEmData, Instr);
		Line.Format("%04X:%04X ", CurCS, CurIP);
		CString Dump;
		BYTE* pInstr = (BYTE*)VirtToReal(CurCS, CurIP);
		for (int i = 0; i < IPOffs; i++) {
			Dump.Format("%02X", *(pInstr + i));
			Line += Dump;
		}
		Dump.Format("%*c", 2 * (7 - IPOffs), ' ');
		Line += Dump; Line += Instr; Line += "\n";
		OutFile.WriteString((LPCTSTR)Line);
		CurIP += IPOffs;
	}
	OutFile.Close();
}

BOOL CDebugFrame::Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CMDIFrameWnd* pParentWnd, CCreateContext* pContext)
{

	return CMDIChildWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, pContext);
}

void CDebugFrame::OnRunProgram()
{
	SetFocus();
	pDasmView->EnableWindow(FALSE);
	pDumpView->EnableWindow(FALSE);
	pRegsView->EnableWindow(FALSE);
}

void CDebugFrame::OnStopProgram(DWORD StopCode)
{
	pDasmView->EnableWindow();
	pDasmView->OnStopProgram(StopCode);

	pDumpView->EnableWindow();
	pDumpView->OnStopProgram(StopCode);

	pRegsView->EnableWindow();
	pRegsView->OnStopProgram(StopCode);

	SetFocus();
	pDasmView->SetFocus();
}

void CDebugFrame::OnRunTo()
{
	if (GetFocus() == pDasmView) {
		SetFocus();
		pDasmView->EnableWindow(FALSE);
		pDumpView->EnableWindow(FALSE);
		pRegsView->EnableWindow(FALSE);

		pDasmView->OnRunTo();
	}
}

void CDebugFrame::UpdateAllViews()
{
	pDasmView->Update();
	pRegsView->Update();
	pDumpView->Update();
}

void CDebugFrame::OnStepOver()
{
	if (GetFocus() == pDasmView) {
		pDasmView->OnStepOver();
	}
}
