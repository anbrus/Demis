// Demis2000.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "Demis2000.h"

#include "MainFrm.h"
#include "ChildFrm.h"
#include "ArchFrame.h"
#include "StdEditDoc.h"
#include "StdEditView.h"
#include "PrjListView.h"
#include "ElemInterface.h"
#include <process.h>
#include "htmlhelp.h"

#include <sstream>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDemis2000App

BEGIN_MESSAGE_MAP(CDemis2000App, CWinApp)
	//{{AFX_MSG_MAP(CDemis2000App)
	ON_COMMAND(ID_APP_ABOUT, OnAppAbout)
	ON_COMMAND(ID_DEBUG, OnDebug)
	ON_COMMAND(ID_RUN, OnRun)
	ON_COMMAND(ID_BREAK, OnBreak)
	ON_UPDATE_COMMAND_UI(ID_BREAK, OnUpdateBreak)
	ON_COMMAND(ID_EMULATORCFG, OnEmulatorCfg)
	ON_UPDATE_COMMAND_UI(ID_RUN, OnUpdateRun)
	ON_COMMAND(ID_BUILD, OnBuild)
	ON_COMMAND(ID_ASSEMBLE, OnAssemble)
	ON_COMMAND(ID_LINK, OnLink)
	ON_UPDATE_COMMAND_UI(ID_DEBUG, OnUpdateDebug)
	ON_UPDATE_COMMAND_UI(ID_EMULATORCFG, OnUpdateEmulatorCfg)
	ON_COMMAND(ID_PRJ_NEW, OnNewPrj)
	ON_COMMAND(ID_PRJ_OPEN, OnOpenPrj)
	//}}AFX_MSG_MAP
	// Standard file based document commands
	//ON_COMMAND(ID_FILE_NEW, CWinApp::OnFileNew)
	//ON_COMMAND(ID_FILE_OPEN, CWinApp::OnFileOpen)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDemis2000App construction

void LoadShell32Dll() {
	ShellExecute(nullptr, "", "", "", "", 0);
}

CDemis2000App::CDemis2000App()
{
	hRunThread = NULL;
	pDebugFrame = NULL;
	FrozenTimer = 0;
	SetAppID(_T("Demis.AppID.NoVersion"));
	EnableHtmlHelp();
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CDemis2000App object

CDemis2000App theApp;

/////////////////////////////////////////////////////////////////////////////
// CDemis2000App initialization

BOOL CDemis2000App::InitInstance()
{
	if (!AfxOleInit()) {
		AfxMessageBox(IDP_OLE_INIT_FAILED);
		return FALSE;
	}

#ifdef _AFXDLL
	//Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

	RunDir = __argv[0];
	RunDir = RunDir.Left(RunDir.ReverseFind('\\'));

	SetRegistryKey(_T("RGATA"));

	LoadStdProfileSettings();  // Load standard INI file options (including MRU)
	LoadLibraryInformation();

	CString strHelpFile = m_pszHelpFilePath;
	strHelpFile.Replace(".HLP", ".chm");
	free((void*)m_pszHelpFilePath);
	m_pszHelpFilePath = _tcsdup(strHelpFile);

	pPrjMRUList = new CRecentFileList(ID_FILE_MRU_PRJ1, "RecentPrjList", "Prj%d", 4);
	pPrjMRUList->ReadList();

	pPrjTemplate = new CMultiDocTemplate(
		IDR_PRJTYPE,
		RUNTIME_CLASS(CPrjDoc),
		RUNTIME_CLASS(CPrjFrame), // custom MDI child frame
		RUNTIME_CLASS(CPrjListView));
	AddDocTemplate(pPrjTemplate);
	pPrjDoc = NULL;

	pAsmTemplate = new CMultiDocTemplate(
		IDR_ASSMTYPE,
		RUNTIME_CLASS(CStdEditDoc),
		RUNTIME_CLASS(CChildFrame), // custom MDI child frame
		RUNTIME_CLASS(CStdEditView));
	AddDocTemplate(pAsmTemplate);

	//CMultiDocTemplate* pArchTemplate;
	pArchTemplate = new CMultiDocTemplate(
		IDR_ARCHTYPE,
		RUNTIME_CLASS(CArchDoc),
		RUNTIME_CLASS(CArchFrame), // custom MDI child frame
		RUNTIME_CLASS(CArchView));
	AddDocTemplate(pArchTemplate);

	// create main MDI Frame window
	CMainFrame* pMainFrame = new CMainFrame;
	if (!pMainFrame->LoadFrame(IDR_MAINFRAME))
		return FALSE;
	m_pMainWnd = pMainFrame;

	m_pMainWnd->DragAcceptFiles();

	// Enable DDE Execute open
	//EnableShellOpen();
	//RegisterShellFileTypes(TRUE);

	// Parse command line for standard shell commands, DDE, file open
	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);

	if (cmdInfo.m_nShellCommand == CCommandLineInfo::FileNew)
		cmdInfo.m_nShellCommand = CCommandLineInfo::FileNothing;
	if (!ProcessShellCommand(cmdInfo)) return FALSE;

	pMainFrame->ShowWindow(SW_SHOWMAXIMIZED);
	pMainFrame->UpdateWindow();

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

	// Dialog Data
		//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

// App command to run the dialog
void CDemis2000App::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}

/////////////////////////////////////////////////////////////////////////////
// CDemis2000App commands

void CDemis2000App::OnDebug()
{
	if (!UpdateExecutable()) {
		TRACE("CDemis2000App::OnDebug: UpdateExecutable failed");
		ASSERT(FALSE);
		return;
	}

	if (!InitProgram()) {
		TRACE("CDemis2000App::OnDebug: InitProgram failed");
		ASSERT(FALSE);
		return;
	}
	if (!PrepareArchForEmulation()) {
		TRACE("CDemis2000App::OnDebug: PrepareArchForEmulation failed");
		ASSERT(FALSE);
		return;
	}
	pDebugFrame = new CDebugFrame;
	if (!pDebugFrame->LoadFrame(IDR_DEBUGTYPE, WS_OVERLAPPEDWINDOW | WS_VISIBLE, NULL)) {
		TRACE("CDemis2000App::OnDebug: pDebugFrame->LoadFrame failed");
		ASSERT(FALSE);
	}
}

CDemis2000App::~CDemis2000App()
{
}

int CDemis2000App::ExitInstance()
{
	ASSERT(AfxIsValidAddress(pPrjMRUList, sizeof(CRecentFileList)));

	pPrjMRUList->WriteList();
	delete pPrjMRUList;

	return CWinApp::ExitInstance();
}

CDocument* CDemis2000App::OpenDemisDocument(const CString &PathName, CString& Type)
{
	CString DocString;
	CDocument* pDoc = NULL;
	POSITION Pos = GetFirstDocTemplatePosition();
	do {
		CDocTemplate* pCurDocTemplate = GetNextDocTemplate(Pos);
		pCurDocTemplate->GetDocString(DocString, CDocTemplate::filterExt);
		if (DocString == Type) {
			if (pCurDocTemplate->MatchDocType(PathName, pDoc) !=
				CDocTemplate::yesAlreadyOpen)
				pDoc = pCurDocTemplate->OpenDocumentFile(PathName);
			return pDoc;
		}
	} while (Pos);
	return NULL;
}

BOOL CDemis2000App::PrepareArchForEmulation()
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));

	POSITION Pos = pPrjDoc->FileList.GetHeadPosition();
	CString Path = "";
	while (Pos) {
		PrjFile& File = pPrjDoc->FileList.GetAt(Pos);
		if (File.Folder == 3) { Path = File.Path; break; }
		pPrjDoc->FileList.GetNext(Pos);
	}

	if (Path.IsEmpty()) {
		m_pMainWnd->MessageBox("Проект не содержит архитектуру",
			"Ошибка", MB_OK | MB_ICONSTOP);
		return FALSE;
	}

	pDebugArchDoc = (CArchDoc*)(pPrjDoc->OpenDocument(Pos));
	if (!pDebugArchDoc) {
		m_pMainWnd->MessageBox("Не могу открыть архитектуру",
			"Ошибка", MB_OK | MB_ICONSTOP);
		return FALSE;
	}

	pDebugArchDoc->ChangeMode(FALSE);

	return TRUE;
}

void CDemis2000App::OnRun()
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));

	if (!pPrjDoc) return;  //Сначала нужно открыть проект

	//Проверим: а не изменился ли исходный текст?
	//Для этого сравним времена изменения файлов

	if (!UpdateExecutable()) {
		TRACE("CDemis2000App::OnRun: UpdateExecutable failed");
		//ASSERT(FALSE);
		return;
	}

	RunProg();
}

void CDemis2000App::OnBreak()
{
	ASSERT(hRunThread);

	//Останавливаем цепочку
	if (!hRunThread) return;
	TerminateEmulator();
}

void CDemis2000App::OnUpdateBreak(CCmdUI* pCmdUI)
{
	if (hRunThread) pCmdUI->Enable(TRUE);
	else pCmdUI->Enable(FALSE);
}

void CDemis2000App::OnEmulatorCfg()
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));

	pPrjDoc->OnEmulatorCfg();
}

std::shared_ptr<CElement> CDemis2000App::CreateExtElement(const CString& LibGUID, const CString& ElementName, BOOL ArchMode, int id)
{
	const auto iterLib = ElementLibraries.find(std::string(LibGUID));
	if (iterLib == ElementLibraries.cend()) {
		return nullptr;
	}
	CElemLib* pLib = iterLib->second;
	std::shared_ptr<CElement> pElement = pLib->CreateElement(ElementName, ArchMode, id);
	if (pElement == nullptr) {
		TRACE("CDemis2000App::CreateExtElement: CreateElement failed");
		ASSERT(FALSE);
		return nullptr;
	}
	return pElement;
}

void CDemis2000App::OnUpdateRun(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(!hRunThread);
}

DWORD pascal CDemis2000App::HostCall(DWORD Message, WPARAM wParam, LPARAM lParam)
{
	ASSERT(FALSE);

	return 0;
}

void CDemis2000App::OnBuild()
{
	ASSERT(m_pMainWnd);

	((CMainFrame*)m_pMainWnd)->ClearMessages();
	BuildMsgCount = 0;

	int Errors = 0, Warnings = 0;
	if (!Assemble(&Errors, &Warnings)) return;
	Link(&Errors, &Warnings);
	CString Total;
	Total.Format("Итого:\r\nОшибок: %d\r\nПредупреждений: %d\r\n", Errors, Warnings);
	((CMainFrame*)m_pMainWnd)->AddMessage(Total, TRUE);
}

void CDemis2000App::OnAssemble()
{
	ASSERT(m_pMainWnd);

	((CMainFrame*)m_pMainWnd)->ClearMessages();
	BuildMsgCount = 0;

	int Errors = 0, Warnings = 0;
	Assemble(&Errors, &Warnings);
	CString Total;
	Total.Format("Итого:\r\nОшибок: %d\r\nПредупреждений: %d\r\n", Errors, Warnings);
	((CMainFrame*)m_pMainWnd)->AddMessage(Total, TRUE);
}

void CDemis2000App::OnLink()
{
	ASSERT(m_pMainWnd);

	((CMainFrame*)m_pMainWnd)->ClearMessages();
	BuildMsgCount = 0;

	int Errors = 0, Warnings = 0;
	Link(&Errors, &Warnings);
	CString Total;
	Total.Format("Итого:\r\nОшибок: %d\r\nПредупреждений: %d\r\n", Errors, Warnings);
	((CMainFrame*)m_pMainWnd)->AddMessage(Total, TRUE);
}

BOOL CDemis2000App::InitProgram()
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));

	Data.TaktFreq = pPrjDoc->TaktFreq;
	Data.hHostWnd = m_pMainWnd->m_hWnd;
	Data.RomSize = pPrjDoc->RomSize * 1024;
	pEmData = InitEmulator(&Data);
	ASSERT(pEmData);

	CString ProgTitle = pPrjDoc->GetTitle();
	int PtPos = ProgTitle.ReverseFind('.');
	if (PtPos != -1) ProgTitle = ProgTitle.Left(PtPos);
	CString ProgName = pPrjDoc->GetPathName();
	int SlashPos = ProgName.ReverseFind('\\');
	if (SlashPos != -1) ProgName = ProgName.Left(SlashPos + 1);
	else ProgName = "";
	ProgName += ProgTitle;
	std::string pathLst = (LPCTSTR)ProgName;
	pathLst += ".lst";
	ProgName += ".dms";
	ASSERT(pPrjDoc->RomSize < 1024);
	int ProgStart = (1024 * (1024 - pPrjDoc->RomSize) >> 4);
	DWORD Code = LoadProgram((char*)(LPCTSTR)ProgName, ProgStart, 0x0000);
	if (Code) {
		CString ErrorText;
		GetErrorText(Code, ErrorText);
		ErrorText += "\r\n";
		((CMainFrame*)m_pMainWnd)->AddMessage("Ошибка загрузки программы\r\n", FALSE);
		((CMainFrame*)m_pMainWnd)->AddMessage(ErrorText, FALSE);
		return FALSE;
	}
	CString Mes;
	Mes.Format("Загружен исполняемый файл %s\r\n", ProgTitle);
	((CMainFrame*)m_pMainWnd)->AddMessage(Mes, FALSE);

	::ClearListing();
	::ParseListing(pathLst);

	return TRUE;
}

DWORD CDemis2000App::AddBuildMessages(std::vector<struct _ErrorData>& Errors)
{
	ASSERT(m_pMainWnd);

	DWORD ErrorCount = 0, WarningCount = 0, TotalCount;
	for (const struct _ErrorData& error : Errors) {
		if (error.Line != 0) {
			CString Mes, Type;
			if (error.Type == 0) { Type = "Ошибка"; ErrorCount++; }
			else { Type = "Предупреждение"; WarningCount++; }
			if (error.Line != -1)
				Mes.Format("%s в %s, строка %d : %s\r\n", Type, error.File.c_str(),
					error.Line, error.Text.c_str());
			else Mes.Format("%s: %s\r\n", Type, error.Text.c_str());
			((CMainFrame*)m_pMainWnd)->AddMessage(Mes, FALSE);
		}
		else break;
	}
	BuildMsgCount += ErrorCount + WarningCount;
	TotalCount = (ErrorCount << 16) + WarningCount;
	return TotalCount;
}

void CDemis2000App::GetErrorText(DWORD Code, CString &ErrorText)
{
	switch (Code) {
	case UNKNOWN_SEGMENT:
		ErrorText = "Обнаружен неизвестный сегмент"; break;
	case MODULE_TOO_LARGE:
		ErrorText = "Модуль слишком большой"; break;
	case TOO_MUCH_SEGMENTS:
		ErrorText = "Слишком много сегментов"; break;
	case FILE_DAMAGED:
		ErrorText = "Файл повреждён"; break;
	case ASSEMBLER_ERROR:
		ErrorText = "Ошибка ассемблирования"; break;
	case LINKER_ERROR:
		ErrorText = "Ошибка связывания"; break;
	case STOP_UNKNOWN_INSTRUCTION:
		ErrorText = "Неизвестная инструкция"; break;
	case STOP_BP_EXEC:
		ErrorText = "Точка останова по исполнению"; break;
	case STOP_BP_INPUT:
		ErrorText = "Точка останова по вводу"; break;
	case STOP_BP_OUTPUT:
		ErrorText = "Точка останова по выводу"; break;
	case STOP_BP_MEM_READ:
		ErrorText = "Точка останова по чтению памяти"; break;
	case STOP_BP_MEM_WRITE:
		ErrorText = "Точка останова по записи в память"; break;
	case INVALID_ADDRESS:
		ErrorText = "Неверный адрес"; break;
	case FILE_NOT_FOUND:
		ErrorText = "Файл не найден"; break;
	case NO_MEMORY:
		ErrorText = "Нехватает памяти"; break;
	}
}

void CDemis2000App::TerminateEmulator()
{
	if (!hRunThread) return;

	ASSERT(AfxIsValidAddress(pEmData, sizeof(_EmulatorData)));
	pEmData->RunProg = FALSE;

	if (FrozenTimer) { KillTimer(NULL, FrozenTimer); FrozenTimer = 0; }
	FrozenTimer = ::SetTimer(NULL, 0, 2000, (TIMERPROC)OnEmulatorFrozen);
}

BOOL CDemis2000App::Assemble(int *pErrorsCount, int *pWarningsCount)
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));
	ASSERT(m_pMainWnd);

	if (pPrjDoc == NULL) return FALSE;

	SaveAllModified();

	std::vector<struct _ErrorData> Errors;

	CString Head;
	Head.Format("---------- Проект %s ----------\r\n", pPrjDoc->GetTitle());
	((CMainFrame*)m_pMainWnd)->AddMessage(Head, TRUE);
	((CMainFrame*)m_pMainWnd)->AddMessage("Ассемблирование...\r\n", TRUE);

	DWORD ErrorPresent = 0;

	CList<PrjFile, PrjFile>* pList = &pPrjDoc->FileList;
	PrjFile File;
	BOOL Assembled = FALSE;
	POSITION Pos = pList->GetHeadPosition();
	CString PrjPath = pPrjDoc->GetPathName();
	int SlashPos = PrjPath.ReverseFind('\\');
	if (SlashPos != -1) PrjPath = PrjPath.Left(SlashPos);
	else PrjPath = "";

	do {
		if (pList->GetAt(Pos).Folder == 1) {
			Assembled = TRUE;
			AssembleFile((char*)(LPCTSTR)PrjPath, (char*)(LPCTSTR)pList->GetAt(Pos).Path, Errors);

			DWORD Res = AddBuildMessages(Errors);
			*pErrorsCount += HIWORD(Res); *pWarningsCount += LOWORD(Res);
			ErrorPresent += HIWORD(Res);
		}
		pList->GetNext(Pos);
	} while (Pos);

	CString Total;
	//Total.Format("Итого:\r\nОшибок: %d\r\nПредупреждений: %d\r\n",
	//  Errors,Warnings);
	//((CMainFrame*)m_pMainWnd)->AddMessage(Total,TRUE);

	return ErrorPresent == 0;
}

BOOL CDemis2000App::Link(int *pErrorsCount, int *pWarningsCount)
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));
	ASSERT(m_pMainWnd);

	if (pPrjDoc == NULL) return FALSE;

	theApp.SaveAllModified();

	std::vector<struct _ErrorData> Errors;

	CString Head, OBJNames;
	Head.Format("---------- Проект %s ----------\r\n", pPrjDoc->GetTitle());
	((CMainFrame*)m_pMainWnd)->AddMessage(Head, FALSE);
	((CMainFrame*)m_pMainWnd)->AddMessage("Компоновка...\r\n", FALSE);

	CList<PrjFile, PrjFile>* pList = &pPrjDoc->FileList;
	PrjFile File;
	CString PrjPath = pPrjDoc->GetPathName();
	int SlashPos = PrjPath.ReverseFind('\\');
	if (SlashPos != -1) PrjPath = PrjPath.Left(SlashPos);
	else PrjPath = "";

	//Добавляем обычные файлы
	POSITION Pos = pList->GetHeadPosition();
	while (Pos) {
		PrjFile& File = pList->GetNext(Pos);
		if ((File.Folder == 1) && (!(File.Flag & 1))) {
			CString Temp = (char*)(LPCTSTR)File.Path;
			OBJNames += Temp.Left(Temp.ReverseFind('.'));
			OBJNames += ".obj ";
		}
	}

	//Добавляем файлы со стартовой точкой
	Pos = pList->GetHeadPosition();
	while (Pos) {
		PrjFile& File = pList->GetNext(Pos);
		if ((File.Folder == 1) && (File.Flag & 1)) {
			CString Temp = (char*)(LPCTSTR)File.Path;
			OBJNames += Temp.Left(Temp.ReverseFind('.'));
			OBJNames += ".obj ";
		}
	}

	CString OutName = pPrjDoc->GetTitle();
	int PtPos = OutName.ReverseFind('.');
	if (PtPos != -1) OutName = OutName.Left(PtPos);
	OutName += ".dms";
	LinkFiles((char*)(LPCTSTR)PrjPath, (char*)(LPCTSTR)OBJNames, (char*)(LPCTSTR)OutName, Errors);

	DWORD Res = AddBuildMessages(Errors);
	*pErrorsCount += HIWORD(Res); *pWarningsCount += LOWORD(Res);

	return HIWORD(Res) == 0;
}

void CDemis2000App::AddMessage(CString Msg, BOOL SetFocus)
{
	ASSERT(m_pMainWnd);

	if (((CMainFrame*)m_pMainWnd))
		((CMainFrame*)m_pMainWnd)->AddMessage(Msg, SetFocus);
}

void CDemis2000App::OnUpdateDebug(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(!(pDebugFrame || hRunThread));
}

typedef CElemLib* (*CreateInstancePtr)(HostInterface* pHostInterface);

void CDemis2000App::LoadLibraryInformation()
{
	char ValueName[256] = "", Value[MAX_PATH];
	DWORD ValueNameSize = sizeof(ValueName);
	HKEY hKey;
	LONG Result;
	DWORD Index = 0, Type, ValueSize;

	CString KeyName = "Software\\";
	KeyName += m_pszRegistryKey;
	KeyName += "\\";
	KeyName += m_pszAppName;
	KeyName += "\\Settings\\Elements Libraries";
	if (::RegOpenKeyEx(HKEY_LOCAL_MACHINE, KeyName, 0, KEY_READ, &hKey) != ERROR_SUCCESS) {
		TRACE("Error: CDemis2000App::LoadLibraryInformation: RegOpenKeyEx failed\n");
		ASSERT(FALSE);
		return;
	}
	do {
		ValueSize = sizeof(Value);
		Result = ::RegEnumValue(hKey, Index, ValueName, &ValueNameSize, NULL, &Type, (LPBYTE)Value, &ValueSize);
		Index++;
		if (Result == ERROR_SUCCESS) {
			std::string path = Value;
			HMODULE hLib = LoadLibrary(path.c_str());
			if (hLib == nullptr) {
				std::stringstream ss;
				ss << "Error: CDemis2000App::LoadLibraryInformation: failed to load library" << path;
				TRACE(ss.str().c_str());
				continue;
			}
			CreateInstancePtr pCreateInstance = reinterpret_cast<CreateInstancePtr>(GetProcAddress(hLib, "CreateLibInstance"));
			if (pCreateInstance == nullptr) {
				TRACE("Error: CDemis2000App::LoadLibraryInformation: failed to find exported function CreateLibInstance");
				continue;
			}
			CElemLib* pLib = pCreateInstance(&Data);
			if (pLib == nullptr) {
				TRACE("Error: CDemis2000App::LoadLibraryInformation: failed to create library instance");
				continue;
			}
			std::string guid = ValueName;
			ElementLibraries[guid]=pLib;
		}
	} while (Result == ERROR_SUCCESS);
	::RegCloseKey(hKey);

	if (Index == 0) {
		MessageBox(NULL, "Библиотеки элементов не установлены", "Design Microsystems",
			MB_OK | MB_ICONWARNING);
	}
}

void CALLBACK CDemis2000App::OnEmulatorFrozen(HWND hWnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime)
{
	ASSERT(theApp.m_pMainWnd);

	if (!theApp.hRunThread) return;

	if (theApp.pEmData->Stopped) return;

	KillTimer(NULL, idEvent);
	MessageBox(NULL, "Симулятор \"висит\"", "Ошибка", MB_OK);

	TerminateThread(theApp.hRunThread, 0);
	theApp.pEmData->Stopped = TRUE;
	CloseHandle(theApp.hRunThread);
	theApp.m_pMainWnd->SendMessage(WMU_EMULSTOP, UNKNOWN_ERROR, 0);
}

void CDemis2000App::WinHelp(DWORD dwData, UINT nCmd)
{
	switch (nCmd) {
	case HELP_CONTEXT:
		HtmlHelp(dwData, HH_HELP_CONTEXT);
		break;
	case HELP_FINDER:
		HtmlHelp(0, HH_DISPLAY_TOPIC);
		break;
	}
}

void CDemis2000App::OnUpdateEmulatorCfg(CCmdUI* pCmdUI)
{
	if (hRunThread) pCmdUI->Enable(FALSE);
	else pCmdUI->Enable(TRUE);
}

BOOL CDemis2000App::SaveAllModified()
{
	ASSERT(m_pMainWnd);

	POSITION Pos = ((CMainFrame*)m_pMainWnd)->ChildWndList.GetHeadPosition();
	while (Pos) {
		struct _ChildWndInfo *pChildWndInfo =
			(struct _ChildWndInfo*)((CMainFrame*)m_pMainWnd)->ChildWndList.GetNext(Pos);
		CDocument *pDoc = pChildWndInfo->pDocument;

		if (pDoc) {  //Отладчик не имеет документа, не нужно его сохранять
			ASSERT(AfxIsValidAddress(pDoc, sizeof(CDocument)));
			if (pDoc->IsModified()) pDoc->OnSaveDocument(pDoc->GetPathName());
		}
	}

	return CWinApp::SaveAllModified();
}

void CDemis2000App::OnNewPrj()
{
	ASSERT(AfxIsValidAddress(pPrjTemplate, sizeof(CMultiDocTemplate)));
	pPrjTemplate->OpenDocumentFile(NULL);
}

void CDemis2000App::OnOpenPrj()
{
	ASSERT(AfxIsValidAddress(pPrjTemplate, sizeof(CMultiDocTemplate)));

	CString FilterName, FilterExt;
	pPrjTemplate->GetDocString(FilterName, CDocTemplate::filterName);
	pPrjTemplate->GetDocString(FilterExt, CDocTemplate::filterExt);
	CString Filter;
	Filter += FilterName;
	Filter += "|*";
	Filter += FilterExt;
	Filter += "||";

	CFileDialog DlgFile(TRUE, "prj", NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, Filter, m_pMainWnd);

	DlgFile.m_ofn.lpstrTitle = "Выберите проект";

	if (DlgFile.DoModal() == IDOK) {
		pPrjTemplate->OpenDocumentFile(DlgFile.GetPathName());
	}
}

BOOL CDemis2000App::UpdateExecutable()
{
	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));

	SaveAllModified();

	CString PrjPath = pPrjDoc->GetPathName();
	int SlashPos = PrjPath.ReverseFind('\\');
	if (SlashPos != -1) PrjPath = PrjPath.Left(SlashPos);
	else PrjPath = "";
	PrjPath = PrjPath + '\\';

	CString DmsName = PrjPath + pPrjDoc->GetTitle();
	int PtPos = DmsName.ReverseFind('.');
	if (PtPos != -1) DmsName = DmsName.Left(PtPos);
	DmsName += ".dms";

	CFileStatus DmsStatus;
	if (!CFile::GetStatus(DmsName, DmsStatus)) return TRUE;

	CList<PrjFile, PrjFile>* pList = &pPrjDoc->FileList;
	PrjFile File;
	POSITION Pos = pList->GetHeadPosition();
	BOOL ModFlag = FALSE;
	do {
		if (pList->GetAt(Pos).Folder == 1) {
			CFileStatus SrcStatus;
			if (!CFile::GetStatus(PrjPath + pList->GetAt(Pos).Path, SrcStatus)) {
				TRACE("CDemis2000App::UpdateExecutable: CFile::GetStatus failed");
				ASSERT(FALSE);
				return TRUE;
			}
			if (SrcStatus.m_mtime > DmsStatus.m_mtime) {
				ModFlag = TRUE;
				break;
			}
		}
		pList->GetNext(Pos);
	} while (Pos);

	if (!ModFlag) return TRUE;

	DWORD Res = MessageBox(NULL, "Исходные файлы были изменены.\nВыполнить сборку?", "Design Microsystem",
		MB_ICONQUESTION | MB_YESNOCANCEL);
	if (Res == IDYES) {
		((CMainFrame*)m_pMainWnd)->ClearMessages();
		BuildMsgCount = 0;

		int Errors = 0, Warnings = 0;

		if (!Assemble(&Errors, &Warnings)) return FALSE;
		if (!Link(&Errors, &Warnings)) return FALSE;
		CString Total;
		Total.Format("Итого:\r\nОшибок: %d\r\nПредупреждений: %d\r\n", Errors, Warnings);
		((CMainFrame*)m_pMainWnd)->AddMessage(Total, TRUE);
	}

	return TRUE;
}

void CDemis2000App::RunProg()
{
	if (!pPrjDoc) return;  //Сначала нужно открыть проект

	ASSERT(AfxIsValidAddress(pPrjDoc, sizeof(CPrjDoc)));
	ASSERT(m_pMainWnd);

	BOOL Status = TRUE;
	if (!pDebugFrame) {
		((CMainFrame*)m_pMainWnd)->ClearMessages();
		do {
			if (!InitProgram()) {
				TRACE("CDemis2000App::RunProg: InitProgram failed");
				ASSERT(FALSE);
				return;
			}
			if (!PrepareArchForEmulation()) {
				TRACE("CDemis2000App::RunProg: PrepareArchForEmulation failed");
				ASSERT(FALSE);
				return;
			}
		} while (FALSE);
	}
	else {
		ASSERT(AfxIsValidAddress(pDebugFrame, sizeof(CDebugFrame)));
		pDebugFrame->OnRunProgram();
	}

	//Прогон программы

	ASSERT(AfxIsValidAddress(pEmData, sizeof(_EmulatorData)));

	DWORD ThrID;
	pEmData->RunProg = TRUE;
	hRunThread = (HANDLE)_beginthreadex(NULL, 0,
		(unsigned int(__stdcall*)(void*))::RunToBreakPoint,
		HostCall, 0, (unsigned int*)&ThrID);
	//::SetThreadPriority(hRunThread, THREAD_PRIORITY_ABOVE_NORMAL);
}

HostData::HostData() {

}

HostData::~HostData() {

}

//void HostData::OnTickTimer(DWORD hElement) {
//	theApp.pDebugArchDoc->OnInstrCounterEvent(hElement);
//}

void HostData::WritePort(WORD port, BYTE value) {
	theApp.pDebugArchDoc->WritePort(port, value);
}

uint8_t HostData::ReadPort(WORD port) {
	return static_cast<uint8_t>(theApp.pDebugArchDoc->ReadPort(port));
}

void HostData::OnPinStateChanged(DWORD PinState, int hElement) {
	theApp.pDebugArchDoc->pView->OnPinStateChanged(PinState, hElement);
}

void HostData::SetTickTimer(int64_t ticks, int64_t interval, DWORD hElement, std::function<void(DWORD)> handler) {
	::SetTickTimer(hElement, ticks, interval, handler);
}

int HostData::AddInstructionListener(std::function<void(int64_t)> handler) {
	return ::AddInstructionListener(handler);
}

void HostData::DeleteInstructionListener(int id) {
	::DeleteInstructionListener(id);
}

void HostData::Interrupt(int intNumber) {
	theApp.pEmData->IntRequest |= static_cast<uint64_t>(1) << intNumber;
}