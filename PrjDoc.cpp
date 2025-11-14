// PrjDoc.cpp : implementation file
//

#include "stdafx.h"
#include "demis2000.h"
#include "PrjDoc.h"

#include <filesystem>
#include <fstream>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CPrjDoc

IMPLEMENT_DYNCREATE(CPrjDoc, CDocument)

CPrjDoc::CPrjDoc()
{
	if (theApp.pPrjDoc) {
		theApp.pPrjDoc->SaveModified();
		theApp.pPrjDoc->OnCloseDocument();
	}
	theApp.pPrjDoc = this;
	RomSize = 4;
	FreePinLevel = 0;
	TaktFreq = 1000000;
}

BOOL CPrjDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	CFileDialog PrjDlg(FALSE, "*.prj", NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
		"Проект (*.prj)|*.prj|Все файлы (*.*)|*.*||");
	PrjDlg.m_ofn.lpstrTitle = "Новый проект";
	if (PrjDlg.DoModal() != IDOK) return FALSE;

	CString PrjName = PrjDlg.GetFileTitle();
	PrjPath = PrjDlg.GetPathName();
	PrjPath = PrjPath.Left(PrjPath.ReverseFind('\\'));


	CDocument* pDoc;
	pDoc = theApp.pArchTemplate->OpenDocumentFile(NULL, FALSE);
	pDoc->SetPathName(PrjPath + "\\" + PrjName + ".arh", FALSE);
	pDoc->SetModifiedFlag();
	pDoc->OnSaveDocument(pDoc->GetPathName());
	pDoc->OnCloseDocument();

	CFile AsmFile(PrjPath + "\\" + PrjName + ".asm", CFile::modeWrite | CFile::typeBinary | CFile::modeCreate);

	CString Template;
	Template += ".386\r\n";
	Template += ";Задайте объём ПЗУ в байтах\r\n";
	Template += "RomSize    EQU   4096\r\n";
	Template += "\r\n";
	Template += "IntTable   SEGMENT use16 AT 0\r\n";
	Template += ";Здесь размещаются адреса обработчиков прерываний\r\n";
	Template += "IntTable   ENDS\r\n";
	Template += "\r\n";
	Template += "Data       SEGMENT use16 AT 40h\r\n";
	Template += ";Здесь размещаются описания переменных\r\n";
	Template += "Data       ENDS\r\n";
	Template += "\r\n";
	Template += ";Задайте необходимый адрес стека\r\n";
	Template += "Stk        SEGMENT use16 AT XXXXh\r\n";
	Template += ";Задайте необходимый размер стека\r\n";
	Template += "           dw    XXXX dup (?)\r\n";
	Template += "StkTop     Label Word\r\n";
	Template += "Stk        ENDS\r\n";
	Template += "\r\n";
	Template += "InitData   SEGMENT use16\r\n";
	Template += "InitDataStart:\r\n";
	Template += ";Здесь размещается описание неизменяемых данных, которые будут храниться в ПЗУ\r\n";
	Template += "\r\n";
	Template += "\r\n";
	Template += "\r\n";
	Template += "InitDataEnd:\r\n";
	Template += "InitData   ENDS\r\n";
	Template += "\r\n";
	Template += "Code       SEGMENT use16\r\n";
	Template += ";Здесь размещается описание неизменяемых данных\r\n";
	Template += "\r\n";
	Template += "           ASSUME cs:Code, ds:Data, es:Data, ss: Stk\r\n";
	Template += "Start:\r\n";
	Template += "           mov   ax, Data\r\n";
	Template += "           mov   ds, ax\r\n";
	Template += "           mov   es, ax\r\n";
	Template += "           mov   ax, Stk\r\n";
	Template += "           mov   ss, ax\r\n";
	Template += "           lea   sp, StkTop\r\n";
	Template += ";Здесь размещается код программы\r\n";
	Template += "\r\n";
	Template += "\r\n";
	Template += ";В следующей строке необходимо указать смещение стартовой точки\r\n";
	Template += "           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)\r\n";
	Template += "           ASSUME cs:NOTHING\r\n";
	Template += "           jmp   Far Ptr Start\r\n";
	Template += "Code       ENDS\r\n";
	Template += "END		Start\r\n";

	Template.AnsiToOem();

	AsmFile.Write((LPCTSTR)Template, Template.GetLength());
	AsmFile.Close();


	PrjFile File;
	File.Flag = 1; File.Folder = 1; File.Path = PrjName + ".asm";
	FileList.AddHead(File);
	File.Flag = 0; File.Folder = 3; File.Path = PrjName + ".arh";
	FileList.AddHead(File);
	TaktFreq = 1000000;
	OnSaveDocument(PrjDlg.GetPathName());
	theApp.pPrjMRUList->Add(PrjDlg.GetPathName());

	SetPathName(PrjDlg.GetPathName(), FALSE);

	UpdateAllViews(NULL);


	return TRUE;
}

CPrjDoc::~CPrjDoc()
{
	TRACE("Prj Doc Destroyed\n");
}


BEGIN_MESSAGE_MAP(CPrjDoc, CDocument)
	//{{AFX_MSG_MAP(CPrjDoc)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPrjDoc diagnostics

#ifdef _DEBUG
void CPrjDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CPrjDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CPrjDoc serialization

void CPrjDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
		SaveDoc(ar);
	}
	else {
		LoadDoc(ar);
	}
}

/////////////////////////////////////////////////////////////////////////////
// CPrjDoc commands

void CPrjDoc::SetTitle(LPCTSTR lpszTitle)
{
	CDocument::SetTitle(lpszTitle);
	UpdateAllViews(NULL);
}

CDocument* CPrjDoc::OpenDocument(POSITION Pos)
{
	CDocument* pResDoc = NULL;
	PrjFile File = FileList.GetAt(Pos);
	CDemis2000App* pApp = (CDemis2000App*)AfxGetApp();
	POSITION p = pApp->GetFirstDocTemplatePosition();
	CDocTemplate* pDocTemplate = NULL;
	CString FindExt;
	if (File.Folder == 1) FindExt = ".asm";
	if (File.Folder == 2) FindExt = ".asm";
	if (File.Folder == 3) FindExt = ".arh";

	CString FullPath = PrjPath + '\\' + File.Path;
	pResDoc = theApp.OpenDemisDocument(FullPath, FindExt);
	if (pResDoc) {
		POSITION Pos = pResDoc->GetFirstViewPosition();
		CWnd* pNewFocusWnd = pResDoc->GetNextView(Pos)->GetParent();
		pNewFocusWnd->BringWindowToTop();
	}

	return pResDoc;
}

BOOL CPrjDoc::OnOpenDocument(LPCTSTR lpszPathName)
{
	if (!CDocument::OnOpenDocument(lpszPathName))
		return FALSE;

	PrjPath = lpszPathName;
	PrjPath = PrjPath.Left(PrjPath.ReverseFind('\\'));
	theApp.pPrjMRUList->Add(lpszPathName);

	return TRUE;
}

void CPrjDoc::OnEmulatorCfg()
{
	CPrjCfgDlg CfgDlg;
	CfgDlg.m_RomSize = RomSize;
	CfgDlg.m_TaktFreq = static_cast<float>(TaktFreq)/1000000;
	CfgDlg.m_FreePinLevel = FreePinLevel;
	if (CfgDlg.DoModal() == IDOK) {
		RomSize = CfgDlg.m_RomSize;
		TaktFreq = static_cast<DWORD>(std::round(CfgDlg.m_TaktFreq*1000000));
		FreePinLevel = CfgDlg.m_FreePinLevel;
		RedrawArch();
		//SetModifiedFlag();
	}
}

BOOL CPrjDoc::SaveDoc(CArchive &ar)
{
	CString PrjPathNew = ar.GetFile()->GetFilePath();
	PrjPathNew = PrjPathNew.Left(PrjPathNew.ReverseFind('\\'));

	std::filesystem::path pathProjectFrom = std::string(PrjPath);
	std::string nameProjectFrom = pathProjectFrom.stem().string();
	std::filesystem::path pathProjectTo = std::string(PrjPathNew);
	std::string nameProjectTo = pathProjectTo.stem().string();

	POSITION Pos = FileList.GetHeadPosition();
	CString Line;
	//Сохраняем дерево
	while (Pos) {
		PrjFile& File = FileList.GetAt(Pos);

		std::filesystem::path pathFile = std::string(File.Path);
		if (nameProjectFrom != nameProjectTo) {
			if (pathFile.stem() == nameProjectFrom) {
				std::string pathFrom(PrjPath + "\\" + pathFile.c_str());
				pathFile.replace_filename(nameProjectTo + pathFile.extension().string());
				std::string pathTo(PrjPathNew + "\\" + pathFile.c_str());
				CopyFile(pathFrom.c_str(), pathTo.c_str(), FALSE);
				File.Path = pathFile.c_str();
			}
		}

		switch (File.Folder) {
		case 0: Line = "[GLOBAL]="; break;
		case 1: Line = "[SOURCE]="; break;
		case 2: Line = "[INCLUDE]="; break;
		case 3: Line = "[ARCH]="; break;
		}
		CString sFlag;
		sFlag.Format("%08X,", File.Flag);
		Line += sFlag;
		Line += File.Path;
		Line += "\r\n";
		ar.WriteString(Line);
		FileList.GetNext(Pos);
	}
	//Сохраняем параметры проекта
	Line.Format("[ROMSIZE]=%d\r\n", RomSize);
	ar.WriteString(Line);
	Line.Format("[FREQ]=%d\r\n", TaktFreq);
	ar.WriteString(Line);
	Line.Format("[FREEPINLEVEL]=%d\r\n", FreePinLevel);
	ar.WriteString(Line);
	if (theApp.pPrjDoc->encoding == Encoding::Utf8) {
		Line.Format("[ENCODING]=Utf8\r\n");
	}
	ar.WriteString(Line);
	//Сохраняем положения окон
	CMainFrame* pMainFrame = (CMainFrame*)theApp.m_pMainWnd;
	//CWnd* pChildWnd;
	struct _ChildWndInfo* pChildWndInfo;
	WINDOWPLACEMENT ChildWndPlacement;
	ChildWndPlacement.length = sizeof(ChildWndPlacement);

	if (PrjPathNew == PrjPath) {
		Pos = pMainFrame->ChildWndList.GetHeadPosition();
		while (Pos) {
			pChildWndInfo = (struct _ChildWndInfo*)pMainFrame->ChildWndList.GetNext(Pos);
			if (pChildWndInfo->pDocument) {
				pChildWndInfo->pChildWnd->GetWindowPlacement(&ChildWndPlacement);
				Line.Format("[WND%s]=(%d,%d,%d,%d)%s\r\n",
					pChildWndInfo->DocType,
					ChildWndPlacement.rcNormalPosition.left,
					ChildWndPlacement.rcNormalPosition.top,
					ChildWndPlacement.rcNormalPosition.right,
					ChildWndPlacement.rcNormalPosition.bottom,
					pChildWndInfo->pDocument->GetPathName());
				ar.WriteString(Line);
			}
		}
	}

	if (PrjPathNew != PrjPath) {
		//CopyProjectFiles(PrjPath, PrjPathNew);
		PrjPath = PrjPathNew;
		//pMainFrame->CloseAllWindows();
	}

	return TRUE;
}

BOOL CPrjDoc::LoadDoc(CArchive &ar)
{
	CString TempStr, Line;
	do {
		ar.ReadString(Line);
		DWORD Type;
		do {
			if (Line.Find("[SOURCE]=") == 0) { Type = 1; break; }
			if (Line.Find("[INCLUDE]=") == 0) { Type = 2; break; }
			if (Line.Find("[ARCH]=") == 0) { Type = 3; break; }
			if (Line.Find("[ROMSIZE]=") == 0) { Type = 4; break; }
			if (Line.Find("[FREQ") == 0) { Type = 5; break; }
			if (Line.Find("[FREEPINLEVEL") == 0) { Type = 6; break; }
			if (Line.Find("[WND") == 0) { Type = 7; break; }
			if (Line.Find("[ENCODING]=") == 0) { Type = 8; break; }
		} while (FALSE);
		if (Line == "") break;
		switch (Type) {
		case 1: case 2: case 3:
		{
			PrjFile File;
			DWORD StartIndex = Line.Find('=') + 1;
			sscanf(Line.Mid(StartIndex, 8), "%X", &File.Flag);
			StartIndex += 9;
			File.Path = Line.Mid(StartIndex);
			File.Folder = Type;
			FileList.AddHead(File);
			break;
		}
		case 4:
			sscanf(10 + (LPCTSTR)Line, "%d", &RomSize);
			break;
		case 5:
			sscanf(7 + (LPCTSTR)Line, "%d", &TaktFreq);
			break;
		case 6:
			sscanf(15 + (LPCTSTR)Line, "%d", &FreePinLevel);
			FreePinLevel &= 1;
			break;
		case 7:
		{
			CString PathName = Line.Mid(Line.Find(')') + 1);
			CString DocType = Line.Mid(4, 4);
			CDocument* pNewDoc = NULL;
			if (DocType != ".prj") pNewDoc = theApp.OpenDemisDocument(PathName, DocType);
			if (pNewDoc) {
				POSITION Pos;
				CMainFrame* pMainFrame = (CMainFrame*)theApp.m_pMainWnd;
				Pos = pMainFrame->ChildWndList.GetHeadPosition();
				while (Pos) {
					struct _ChildWndInfo* pWndInfo =
						(struct _ChildWndInfo*)pMainFrame->ChildWndList.GetNext(Pos);
					if (pNewDoc == pWndInfo->pDocument) {
						CRect WndRect;
						//char c;
						sscanf(11 + (LPCTSTR)Line, "%d,%d,%d,%d", &WndRect.left,
							&WndRect.top,
							&WndRect.right, &WndRect.bottom);
						pWndInfo->pChildWnd->MoveWindow(WndRect);
					}
				}

			}
			break;
		}
		case 8: {
			CString strEncoding = Line.Mid(11);
			if (strEncoding == "Utf8") {
				encoding = Encoding::Utf8;
			}
		}
		}
	} while (Line != "");

	/*if (encoding != Encoding::Utf8) {
		int answer = MessageBox(theApp.m_pMainWnd->m_hWnd, "Необходимо преобразовать кодировку asm-файлов из 866 в UTF-8. Продолжить?", "Вопрос", MB_YESNO);
		if (answer != IDYES) throw "Ошибка при открытии проекта";

		try {
			ar.Close();
			convertEncoding();
		}
		catch (...) {}
	}*/

	return TRUE;
}

void CPrjDoc::convertEncoding() {
	POSITION Pos = FileList.GetHeadPosition();
	while (Pos) {
		PrjFile& File = FileList.GetAt(Pos);

		std::filesystem::path path((LPCTSTR)File.Path);
		CString ext(path.extension().c_str());
		ext.MakeLower();
		if (ext == ".asm" || ext == ".inc") {
			std::ifstream f(path, std::ios::in | std::ios::binary);
			const auto sz = std::filesystem::file_size(path);
			std::vector<char> buf;
			buf.resize(sz);
			std::vector<wchar_t> wbuf;
			wbuf.resize(sz);
			f.read(buf.data(), sz);
			f.close();

			MultiByteToWideChar(866, 0, buf.data(), sz, wbuf.data(), sz+1);
			WideCharToMultiByte(1251, 0, wbuf.data(), sz, buf.data(), sz + 1, nullptr, nullptr);

			std::ofstream out(path, std::ios::out | std::ios::binary | std::ios::trunc);
			out.write(buf.data(), sz);
			out.close();
		}

		FileList.GetNext(Pos);
	}

	CFile fileDoc(PrjPath, CFile::modeCreate|CFile::modeWrite|CFile::typeBinary);
	CArchive archDoc(&fileDoc, CArchive::store);
	SaveDoc(archDoc);
}

void CPrjDoc::RedrawArch()
{
	CMainFrame* pMainFrame = (CMainFrame*)theApp.m_pMainWnd;
	POSITION Pos = pMainFrame->ChildWndList.GetHeadPosition();
	while (Pos) {
		struct _ChildWndInfo* pWndInfo;
		pWndInfo = (struct _ChildWndInfo*)pMainFrame->ChildWndList.GetNext(Pos);
		if (pWndInfo->DocType == ".arh") {
			((CArchDoc*)pWndInfo->pDocument)->ChangeMode(TRUE);
		}
	}
}
