#include "Assm.h"
#include "..\Definitions.h"

#include <vector>

DWORD MesCounter;

BOOL GetLinkErrorText(char* PrjPath, std::vector<struct _ErrorData>& Errors)
{
	ASSERT(AfxIsValidString(PrjPath, -1));

	BOOL ErrorPresent = FALSE;
	try {
		CString ErrorFileName(PrjPath);
		ErrorFileName += "\\Errors.txt";
		CStdioFile ErrFile;
		if (!ErrFile.Open(ErrorFileName, CFile::modeRead | CFile::typeBinary)) throw(0);

		CString CurStr;
		while (ErrFile.ReadString(CurStr)) {
			CurStr.TrimRight();

			int pos = 0;
			CString partLink = CurStr.Tokenize(":", pos);
			if (pos < 0) continue;
			CString partErrorCode = CurStr.Tokenize(":", pos);
			if (pos < 0) continue;
			CString partMessage = CurStr.Mid(pos);

			partErrorCode = partErrorCode.MakeLower();

			bool hasError = partErrorCode.Find("error") >= 0 || partErrorCode.Find("fatal") >= 0;
			bool hasWarning = partErrorCode.Find("warning") >= 0;
			if (!hasError && !hasWarning) continue;

			ErrorPresent = TRUE;

			struct _ErrorData error;
			error.Type = hasError ? 0 : 1;
			error.Line = -1;
			error.File = "";
			error.Text = partMessage.TrimLeft();

			Errors.push_back(error);
		}
	}
	catch (...) {
		struct _ErrorData error;

		error.Type = 0;
		error.Text = "Ошибка при обработке файла сообщений";
		error.Line = -1;
		Errors.push_back(error);

		MessageBox(NULL, "Ошибка при обработке файла сообщений", "Ошибка", MB_OK | MB_ICONSTOP);
		return FALSE;
	}

	return ErrorPresent;
}

BOOL GetAsmErrorText(char* PrjPath, std::vector<struct _ErrorData>& Errors)
{
  ASSERT(AfxIsValidString(PrjPath,-1));

  BOOL ErrorPresent=FALSE;
  try {
    CString ErrorFileName(PrjPath);
    ErrorFileName+="\\Errors.txt";
    CStdioFile ErrFile;
    if(!ErrFile.Open(ErrorFileName,CFile::modeRead|CFile::typeBinary)) throw(0);
    
    CString CurStr;
    while(ErrFile.ReadString(CurStr)) {
      CurStr.TrimRight();

	  int pos = 0;
	  CString partFileLine = CurStr.Tokenize(":", pos);
	  if (pos < 0) continue;
	  CString partErrorCode = CurStr.Tokenize(":", pos);
	  if (pos < 0) continue;
	  CString partMessage = CurStr.Mid(pos);
	  
	  partErrorCode = partErrorCode.MakeLower();
	  
	  bool hasError = partErrorCode.Find("error")>=0 || partErrorCode.Find("fatal") >= 0;
	  bool hasWarning = partErrorCode.Find("warning") >= 0;
	  if (!hasError && !hasWarning) continue;

	  pos = 0;
	  CString partFile=partFileLine.Tokenize("(", pos);
	  if (pos == -1) continue;
	  CString partLine = partFileLine.Tokenize("(", pos);
	  if (pos == -1) continue;
	  pos = 0;
	  partLine = partLine.Tokenize(")", pos);
	  if (pos == -1) continue;

	  int line = 0;
	  try {
		  line=std::stoi(partLine.GetString());
	  }
	  catch (...) {
		  continue;
	  }
	  
      ErrorPresent=TRUE;
		
		struct _ErrorData error;
		error.Type = hasError ? 0 : 1;
		error.Line=line;
		error.File=partFile;
		error.Text=partMessage.TrimLeft();
        
		Errors.push_back(error);
      }
  }catch(...) {
	struct _ErrorData error;

	error.Type=0;
    error.Text="Ошибка при обработке файла сообщений";
	error.Line=-1;
	Errors.push_back(error);

    MessageBox(NULL,"Ошибка при обработке файла сообщений","Ошибка",MB_OK|MB_ICONSTOP);
    return FALSE;
  }
  
  return ErrorPresent;
}

DWORD PASCAL AssembleFile(char *PrjPath,char *AsmName, std::vector<struct _ErrorData>& Errors)
{
  ASSERT(AfxIsValidString(PrjPath,-1));
  ASSERT(AfxIsValidString(AsmName,-1));
  //ASSERT(AfxIsValidAddress(pError,sizeof(_ErrorData)));

  MesCounter=0;
  //char RunDir[MAX_PATH];
  //strncpy(RunDir, __argv[0], MAX_PATH);
  //GetShortPathName(__argv[0],RunDir,MAX_PATH);
  //char *pSlash=strrchr(RunDir,'\\');
  //if(pSlash) *(pSlash+1)=0;

  //struct _ErrorData* pCurError=pError;
  CString CmdLine;

  CString NameWithoutExt=AsmName;
  int PntIndex= NameWithoutExt.ReverseFind('.');
  if(PntIndex!=-1) NameWithoutExt = NameWithoutExt.Left(PntIndex);
  //ObjName+=".obj";

  CmdLine += "C:\\MASM32\\ml.exe /c /Fl";
  CmdLine += NameWithoutExt;
  CmdLine += ".lst ";
  CmdLine+=AsmName;
  //CmdLine+=", ";
  //CmdLine+=ObjName;
  
  CString ErrorFileName=PrjPath;
  ErrorFileName+="\\Errors.txt";
  CFile ErrFile(ErrorFileName,CFile::modeCreate|CFile::modeReadWrite|CFile::typeBinary);

  STARTUPINFO si;
  memset(&si,0,sizeof(si));
  si.cb=sizeof(si);
  si.dwFlags=STARTF_USESHOWWINDOW|STARTF_USESTDHANDLES;
  si.wShowWindow=SW_SHOWMINIMIZED|SW_HIDE;
  //si.hStdInput=(HANDLE)ErrFile.m_hFile;
  si.hStdOutput=(HANDLE)ErrFile.m_hFile;
  si.hStdError=(HANDLE)ErrFile.m_hFile;

  PROCESS_INFORMATION pi;
  memset(&pi,0,sizeof(pi));

  //Запуск TASM
  if (!CreateProcess(NULL, (char*)(LPCTSTR)CmdLine, NULL, NULL, TRUE, CREATE_DEFAULT_ERROR_MODE, NULL, PrjPath, &si, &pi)) {
	  struct _ErrorData e;
	  e.File[0] = 0;
	  e.Line = -1;
	  e.Text="Не удалось запустить ассемблер ml.exe";
	  e.Type = 0;
	  Errors.push_back(e);
	  return ASSEMBLER_ERROR;
  }
  //Ждём завершения работы процесса
  if(pi.hProcess) WaitForSingleObject(pi.hProcess,INFINITE);
  CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
  ErrFile.Close();
  if(GetAsmErrorText(PrjPath,Errors)) return ASSEMBLER_ERROR;

  return 0;
}

DWORD PASCAL LinkFiles(char* PrjPath,char* OBJNames,char* DMSName, std::vector<struct _ErrorData>& Errors)
{
  ASSERT(AfxIsValidString(PrjPath,-1));

  MesCounter=0;
  //char RunDir[MAX_PATH];
  //strncpy(RunDir, __argv[0], MAX_PATH);
  //char *pSlash=strrchr(RunDir,'\\');
  //if(pSlash) *(pSlash+1)=0;

  CString NameWithoutExt = DMSName;
  int PntIndex = NameWithoutExt.ReverseFind('.');
  if (PntIndex != -1) NameWithoutExt = NameWithoutExt.Left(PntIndex);

  CString CmdLine("C:\\MASM32\\link16.exe ");
  CmdLine+=OBJNames;
  CmdLine+=",";
  CmdLine += DMSName;
  CmdLine += ",";
  CmdLine += NameWithoutExt;
  CmdLine += ".map,,,";

  CString ErrorFileName = PrjPath;
  ErrorFileName += "\\Errors.txt";
  CFile ErrFile(ErrorFileName, CFile::modeCreate | CFile::modeReadWrite | CFile::typeBinary);

  STARTUPINFO si;
  memset(&si,0,sizeof(si));
  si.cb=sizeof(si);
  si.dwFlags=STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
  si.wShowWindow=SW_SHOWMINIMIZED;
  si.hStdOutput = (HANDLE)ErrFile.m_hFile;
  si.hStdError = (HANDLE)ErrFile.m_hFile;

  PROCESS_INFORMATION pi;
  memset(&pi,0,sizeof(pi));
  //Запуск RUNTLINK
  if (!CreateProcess(NULL, (char*)(LPCTSTR)CmdLine, NULL, NULL, TRUE, CREATE_DEFAULT_ERROR_MODE, NULL, PrjPath, &si, &pi)) {
	  struct _ErrorData e;
	  e.File[0] = 0;
	  e.Line = -1;
	  e.Text="Не удалось запустить компоновщик link16.exe";
	  e.Type = 0;
	  Errors.push_back(e);

	  return ASSEMBLER_ERROR;
  }
  //Ждём завершения работы процесса
  if(pi.hProcess) WaitForSingleObject(pi.hProcess,INFINITE);
  CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
  ErrFile.Close();
  if(GetLinkErrorText(PrjPath,Errors)) return LINKER_ERROR;

  return 0;
}

BOOL WINAPI DllEntryPoint(HINSTANCE,DWORD fdwReason,LPVOID)
{
  switch(fdwReason) {
    case DLL_PROCESS_ATTACH : break;
    case DLL_PROCESS_DETACH : break;
  }
  return TRUE;
}
