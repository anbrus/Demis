// ArchDoc.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "ArchDoc.h"
#include "StdElem\StdElem.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CArchDoc

IMPLEMENT_DYNCREATE(CArchDoc, CDocument)

CArchDoc::CArchDoc()
{
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) Element[n]=NULL;
}

BOOL CArchDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;
	return TRUE;
}

CArchDoc::~CArchDoc()
{
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++)
    if(Element[n]!=NULL) delete Element[n];
}


BEGIN_MESSAGE_MAP(CArchDoc, CDocument)
	//{{AFX_MSG_MAP(CArchDoc)
	ON_UPDATE_COMMAND_UI(ID_FILE_SAVE, OnUpdateFileSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CArchDoc diagnostics

#ifdef _DEBUG
void CArchDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CArchDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CArchDoc serialization

void CArchDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
    ArchSave(ar);
	}
	else
	{
    ArchOpen(ar);
	}
}

/////////////////////////////////////////////////////////////////////////////
// CArchDoc commands

void CArchDoc::ArchOpen(CArchive &ar)
{
  DWORD Version;
  char Id[13];
  CString ClsId,Name;

  Id[12]=0;
  ar.Read(Id,12);
  if(strcmp(Id,"DEMISArchFmt")!=0) {
    MessageBox(NULL,"Неизвестный формат файла","Ошибка",MB_OK|MB_ICONSTOP);
    return;
  }

  ar>>Version;
  if((Version==0x00000201)||(Version==0x00000200)) {
    ConvertVersion0200To0202(ar,Version);
    Version=0x00000202;
  }
  if(Version>0x00000202) {
    MessageBox(NULL,"Неизвестная версия формата файла","Ошибка",MB_OK|MB_ICONSTOP);
    return;
  }

  POSITION p=GetFirstViewPosition();
  CView* pV=GetNextView(p);
  CDocTemplate* pDocTemplate=GetDocTemplate();
  pDocTemplate->InitialUpdateFrame((CFrameWnd*)pV->GetParent(),this);

  int Count;
  ar>>Count;
  CPoint ArchPos,ConstrPos;
  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  int ArchAngle,ConstrAngle;
  for(int n=0; n<Count; n++) {
    ar>>Name>>ClsId;
    ar>>ArchPos.x>>ArchPos.y>>ConstrPos.x>>ConstrPos.y;
    if(Version>=0x00000201) {
      ar>>ArchAngle;
      ar>>ConstrAngle;
    }else {
      ArchAngle=0;
      ConstrAngle=0;
    }
    ar.Flush();
    if(!AddElement(ClsId,Name,FALSE)) break;

    if(!Element[n]->Load((OLE_HANDLE)ar.GetFile()->m_hFile)) {
      MessageBox(NULL,"Ошибка загрузки архитектуры","Ошибка",MB_OK|MB_ICONSTOP);
      return;
    }
    Element[n]->put_nArchAngle(ArchAngle);
    Element[n]->put_nConstrAngle(ConstrAngle);
    Element[n]->Show(pView->m_hWnd,pView->m_hWnd);

    HWND hWnd=(HWND)Element[n]->get_hArchWnd();
    if(hWnd) {
      ::GetWindowPlacement(hWnd,&Pls);
      CRect Rect1(Pls.rcNormalPosition);
      Rect1.OffsetRect(ArchPos);
      ::MoveWindow((HWND)Element[n]->get_hArchWnd(),Rect1.left,Rect1.top,
        Rect1.Width(),Rect1.Height(),TRUE);
    }

    hWnd=(HWND)Element[n]->get_hConstrWnd();
    if(hWnd) {
      ::GetWindowPlacement(hWnd,&Pls);
      CRect Rect2(Pls.rcNormalPosition);
      Rect2.OffsetRect(ConstrPos);
      ::MoveWindow((HWND)Element[n]->get_hConstrWnd(),Rect2.left,Rect2.top,
        Rect2.Width(),Rect2.Height(),TRUE);
    }
  }
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(Element[n]!=NULL) pView->FindIntersections(Element[n]);
  }
}

void CArchDoc::ArchSave(CArchive &ar)
{
  int ElementsCount=0;
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++)
    if(Element[n]!=NULL) ElementsCount++;

  DWORD Version=0x00000202;
  char Id[]="DEMISArchFmt";
  ar.Write(Id,12);
  ar<<Version<<ElementsCount;
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(Element[n]==NULL) continue;
    CString ElemName,ElemClsId;
    Element[n]->get_sName(ElemName);
    Element[n]->get_sClsId(ElemClsId);
    ar<<ElemName;
    ar<<ElemClsId;
    WINDOWPLACEMENT Pls;
    Pls.length=sizeof(Pls);
    ::GetWindowPlacement((HWND)Element[n]->get_hArchWnd(),&Pls);
    Pls.rcNormalPosition.left+=pView->GetScrollPos(SB_HORZ);
    Pls.rcNormalPosition.top+=pView->GetScrollPos(SB_VERT);
    ar<<Pls.rcNormalPosition.left<<Pls.rcNormalPosition.top;
    ::GetWindowPlacement((HWND)Element[n]->get_hConstrWnd(),&Pls);
    Pls.rcNormalPosition.left+=pView->GetScrollPos(SB_HORZ);
    Pls.rcNormalPosition.top+=pView->GetScrollPos(SB_VERT);
    ar<<Pls.rcNormalPosition.left<<Pls.rcNormalPosition.top;
    ar<<Element[n]->get_nArchAngle();
    ar<<Element[n]->get_nConstrAngle();
    ar.Flush();
    Element[n]->Save((OLE_HANDLE)ar.GetFile()->m_hFile);
  }
}

BOOL CArchDoc::DeleteElement(int ElementIndex)
{
  //::ShowWindow((HWND)Element[ElementIndex]->get_hArchWnd(),SW_HIDE);
  //::ShowWindow((HWND)Element[ElementIndex]->get_hConstrWnd(),SW_HIDE);
  delete Element[ElementIndex];
  Element[ElementIndex]=NULL;
  SetModifiedFlag();

  return TRUE;
}

BOOL CArchDoc::OnOpenDocument(LPCTSTR lpszPathName) 
{
	if (!CDocument::OnOpenDocument(lpszPathName))
		return FALSE;
	
	return TRUE;
}

void CArchDoc::OnUpdateFileSave(CCmdUI* pCmdUI) 
{
  UpdateModifyStatus();
	pCmdUI->Enable(IsModified());
}

BOOL CArchDoc::AddElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show)
{
  BOOL FreeFounded=FALSE;
  int n = 0;
  for(n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(Element[n]==NULL) { FreeFounded=TRUE; break; }
  }
  if(!FreeFounded) {
    MessageBox(NULL,"Слишком много элементов","Ошибка",MB_OK|MB_ICONSTOP);
    return FALSE;
  }

  CElement* pElement=theApp.CreateExtElement(GUID,Name,pView->ArchMode);
  if(!(void*)pElement) {
    CString Msg;
    Msg.Format("Невозможно создать элемент \"%s\".",Name);
    MessageBox(NULL,Msg,"Ошибка",MB_OK|MB_ICONSTOP);
    return FALSE;
  }

  Element[n]=pElement;
  Element[n]->put_hElement((HANDLE)n);
  Element[n]->put_bArchSelected(FALSE);
  Element[n]->put_bConstrSelected(FALSE);
  Element[n]->Reset(TRUE,&theApp.pEmData->Takts,
    theApp.pPrjDoc->TaktFreq,theApp.pPrjDoc->FreePinLevel);
  if(Show) {
    pElement->Show(pView->m_hWnd,pView->m_hWnd);
  }
  SetModifiedFlag();
  UpdateAllViews(NULL);

  return TRUE;
}

void CArchDoc::UpdateModifyStatus()
{
  if(IsModified()) return;
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(Element[n]==NULL) continue;
    if(Element[n]->get_bModifiedFlag()) { SetModifiedFlag(); return; }
  }
}

DWORD CArchDoc::ReadPort(DWORD PortAddress)
{
  POSITION Pos=InputPortList.GetHeadPosition();
  PortData PD;

  DWORD Data;
  if(theApp.pPrjDoc->FreePinLevel==0) Data=0;
  else Data=0xFFFFFFFF;

  while(Pos) {
    PD=InputPortList.GetNext(Pos);
    if(PD.Address==PortAddress) {
      if(theApp.pPrjDoc->FreePinLevel==0) Data|=PD.pElement->get_nPortData();
      else Data&=PD.pElement->get_nPortData();
    }
  }
  //if(Data)
  //  MessageBeep(-1);
  return Data;
}

void CArchDoc::WritePort(DWORD PortAddress, DWORD Data)
{
  POSITION Pos=OutputPortList.GetHeadPosition();
  PortData PD;
  while(Pos) {
    PD=OutputPortList.GetNext(Pos);
    if(PD.Address==PortAddress) PD.pElement->put_nPortData(Data);
  }
}

void CArchDoc::ChangeMode(BOOL ConfigMode)
{
  if(ConfigMode) {
    for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
      if(Element[n]==NULL) continue;
      Element[n]->Reset(ConfigMode,&theApp.pEmData->Takts,
        theApp.pPrjDoc->TaktFreq,theApp.pPrjDoc->FreePinLevel);
      if(Element[n]->get_hArchWnd()) InvalidateRect((HWND)Element[n]->get_hArchWnd(),NULL,TRUE);
      if(Element[n]->get_hConstrWnd()) InvalidateRect((HWND)Element[n]->get_hConstrWnd(),NULL,TRUE);
    }
  }else {
    OutputPortList.RemoveAll();
    InputPortList.RemoveAll();
    PortData PD;
    for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
      if(Element[n]==NULL) continue;
      if(Element[n]->get_nType()&ET_INPUTPORT) {
        PD.Address=Element[n]->get_nAddress();
        PD.pElement=Element[n];
        InputPortList.AddTail(PD);
      }
      if(Element[n]->get_nType()&ET_OUTPUTPORT) {
        PD.Address=Element[n]->get_nAddress();
        PD.pElement=Element[n];
        OutputPortList.AddTail(PD);
      }
      Element[n]->put_bArchSelected(FALSE);
      Element[n]->put_bConstrSelected(FALSE);
      Element[n]->Reset(ConfigMode,&theApp.pEmData->Takts,
        theApp.pPrjDoc->TaktFreq,theApp.pPrjDoc->FreePinLevel);
      if(Element[n]->get_hArchWnd()) InvalidateRect((HWND)Element[n]->get_hArchWnd(),NULL,TRUE);
      if(Element[n]->get_hConstrWnd()) InvalidateRect((HWND)Element[n]->get_hConstrWnd(),NULL,TRUE);

      POSITION Pos=OutputPortList.GetHeadPosition();
      while(Pos) {
        OutputPortList.GetNext(Pos).pElement->put_nPortData(0);
      }
    }
  }
  pView->ChangeMode(ConfigMode);
}

void CArchDoc::CopySelected()
{
  char TempPath[MAX_PATH+1];
  char TempName[MAX_PATH+1];
  GetTempPath(MAX_PATH,TempPath);
  GetTempFileName(TempPath,"DMS",0,TempName);
  HANDLE hTempFile=::CreateFile(TempName,GENERIC_READ|GENERIC_WRITE,0,NULL,
    CREATE_ALWAYS,FILE_ATTRIBUTE_TEMPORARY|FILE_FLAG_DELETE_ON_CLOSE,NULL);
  
  CFile TempFile(hTempFile);
  CArchive SaveAr(&TempFile,CArchive::store);

  int ElementsCount=0;
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(Element[n]==NULL) continue;
    BOOL Selected=pView->ArchMode ? Element[n]->get_bArchSelected() : Element[n]->get_bConstrSelected();
    if(!Selected) continue;

    ElementsCount++;
  }

  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(Element[n]==NULL) continue;

    BOOL Selected=pView->ArchMode ? Element[n]->get_bArchSelected() : Element[n]->get_bConstrSelected();
    if(!Selected) continue;

    CString ElemName,ElemClsId;
    Element[n]->get_sName(ElemName);
    Element[n]->get_sClsId(ElemClsId);
    SaveAr<<ElemName;
    SaveAr<<ElemClsId;
    WINDOWPLACEMENT Pls;
    Pls.length=sizeof(Pls);
    ::GetWindowPlacement((HWND)Element[n]->get_hArchWnd(),&Pls);
    SaveAr<<Pls.rcNormalPosition.left<<Pls.rcNormalPosition.top;
    ::GetWindowPlacement((HWND)Element[n]->get_hConstrWnd(),&Pls);
    SaveAr<<Pls.rcNormalPosition.left<<Pls.rcNormalPosition.top;
    SaveAr<<Element[n]->get_nArchAngle();
    SaveAr<<Element[n]->get_nConstrAngle();
    SaveAr.Flush();
    Element[n]->Save((OLE_HANDLE)SaveAr.GetFile()->m_hFile);
  }
  SaveAr.Close();

  TempFile.SeekToBegin();
  CArchive LoadAr(&TempFile,CArchive::load);

  CString ClsId,Name;
  CPoint ArchPos,ConstrPos;
  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  for(int n=0; n<sizeof(Element)/sizeof(CElement*); n++) {
    if(!ElementsCount) break;
    if(Element[n]) continue;

    LoadAr>>Name>>ClsId;
    LoadAr>>ArchPos.x>>ArchPos.y>>ConstrPos.x>>ConstrPos.y;
    int ArchAngle,ConstrAngle;
    LoadAr>>ArchAngle;
    LoadAr>>ConstrAngle;
    if(!AddElement(ClsId,Name,FALSE)) break;

    LoadAr.Flush();
    Element[n]->put_nArchAngle(ArchAngle);
    Element[n]->put_nConstrAngle(ConstrAngle);
    Element[n]->Load((OLE_HANDLE)LoadAr.GetFile()->m_hFile);
    Element[n]->Show(pView->m_hWnd,pView->m_hWnd);

    ::GetWindowPlacement((HWND)Element[n]->get_hArchWnd(),&Pls);
    CRect Rect1(Pls.rcNormalPosition);
    if(pView->ArchMode) Rect1.OffsetRect(ArchPos);
    ::MoveWindow((HWND)Element[n]->get_hArchWnd(),Rect1.left,Rect1.top,
      Rect1.Width(),Rect1.Height(),TRUE);

    ::GetWindowPlacement((HWND)Element[n]->get_hConstrWnd(),&Pls);
    CRect Rect2(Pls.rcNormalPosition);
    if(!pView->ArchMode) Rect2.OffsetRect(ConstrPos);
    ::MoveWindow((HWND)Element[n]->get_hConstrWnd(),Rect2.left,Rect2.top,
      Rect2.Width(),Rect2.Height(),TRUE);

    HWND hArchWnd=(HWND)Element[n]->get_hArchWnd();
    HWND hConstrWnd=(HWND)Element[n]->get_hConstrWnd();
    if(pView->ArchMode) {
      if(hArchWnd) ::ShowWindow(hArchWnd,SW_SHOW);
      if(hConstrWnd) ::ShowWindow(hConstrWnd,SW_HIDE);
    }else {
      if(hArchWnd) ::ShowWindow(hArchWnd,SW_HIDE);
      if(hConstrWnd) ::ShowWindow(hConstrWnd,SW_SHOW);
    }

    ElementsCount--;
  }

  if(ElementsCount)
    MessageBox(NULL,"Слишком много элементов","Ошибка",MB_OK|MB_ICONSTOP);

  LoadAr.Close();
  TempFile.Close();
}

LPARAM CArchDoc::OnInstrCounterEvent(HANDLE hElement)
{
  CElement *pElement=Element[(DWORD)hElement];
  pElement->OnInstrCounterEvent();

  return 0;
}

void CArchDoc::ConvertVersion0200To0202(CArchive &ar,DWORD OldVersion)
{
  CString NewFileName(ar.GetFile()->GetFilePath());
  NewFileName+=".new";
  CFile OutFile(NewFileName,CFile::modeWrite|CFile::typeBinary|CFile::modeCreate);

  CString ClsId,Name;

  char Id[]="DEMISArchFmt";
  OutFile.Write(Id,12);
  DWORD Version=0x00000202;
  OutFile.Write(&Version,4);

  int Count;
  ar>>Count;
  OutFile.Write(&Count,4);

  POINT ArchPos,ConstrPos;
  int ArchAngle,ConstrAngle;
  BOOL Error=FALSE;
  for(int n=0; n<Count; n++) {
    ar>>Name>>ClsId;
    DWORD Len;
    Len=Name.GetLength();
    OutFile.Write(&Len,1);
    OutFile.Write((LPCTSTR)Name,Name.GetLength());
    Len=ClsId.GetLength();
    OutFile.Write(&Len,1);
    OutFile.Write((LPCTSTR)ClsId,ClsId.GetLength());
    
    ar>>ArchPos.x>>ArchPos.y>>ConstrPos.x>>ConstrPos.y;
    OutFile.Write(&ArchPos.x,4);
    OutFile.Write(&ArchPos.y,4);
    OutFile.Write(&ConstrPos.x,4);
    OutFile.Write(&ConstrPos.y,4);

    if(OldVersion>=0x00000201) {
      ar>>ArchAngle;
      ar>>ConstrAngle;
    }else {
      ArchAngle=0;
      ConstrAngle=0;
    }
    OutFile.Write(&ArchAngle,4);
    OutFile.Write(&ConstrAngle,4);

    while(TRUE) {
      BYTE Buf[16384];
      DWORD Version=0x00010000;
      OutFile.Write(&Version,4);
      if(strcmp(Name,"Порт ввода")==0) {
        ar.Read(Buf,4);
        OutFile.Write(Buf,4);
        break;
      }
      if(strcmp(Name,"Порт вывода")==0) {
        ar.Read(Buf,4);
        OutFile.Write(Buf,4);
        break;
      }
      if(strcmp(Name,"Светодиод")==0) {
        ar.Read(Buf,4);
        COLORREF Color=RGB(255,0,0);
        OutFile.Write(&Color,4);
        OutFile.Write(Buf,4);
        break;
      }
      if(strcmp(Name,"Кнопка")==0) {
        DWORD BitAttrib;
        ar>>BitAttrib;
        OutFile.Write(&BitAttrib,4);
        int TextLen;
        ar>>TextLen;
        OutFile.Write(&TextLen,4);
        ar.Read(Buf,TextLen);
        OutFile.Write(Buf,TextLen);
        break;
      }
      if(strcmp(Name,"Текстовая метка")==0) {
        DWORD OnArch;
        ar.Read(&OnArch,4);
        OutFile.Write(&OnArch,4);
        int TextLen;
        ar.Read(&TextLen,4);
        OutFile.Write(&TextLen,4);
        ar.Read(Buf,TextLen);
        OutFile.Write(Buf,TextLen);
        break;
      }
      if(strcmp(Name,"Семисегм. индикатор")==0) {
        ar.Read(Buf,4);
        OutFile.Write(Buf,4);
        break;
      }
      if(strcmp(Name,"Клавиатура")==0) {
        ar.Read(Buf,16);
        OutFile.Write(Buf,16);

        BYTE Len;
        for(int x=0; x<8; x++) {
          for(int y=0; y<8; y++) {
            ar.Read(&Len,sizeof(Len));
            OutFile.Write(&Len,1);
            ar.Read(Buf,Len);
            OutFile.Write(Buf,Len);
          }
        }
        break;
      }
      if(strcmp(Name,"АЦП")==0) {
        ar.Read(&Buf,4);
        OutFile.Write(Buf,4);
  
        int StrLen;
        ar.Read(&StrLen,4);
        OutFile.Write(&StrLen,4);
        ar.Read(Buf,StrLen);
        OutFile.Write(Buf,StrLen);

        ar.Read(&StrLen,4);
        OutFile.Write(&StrLen,4);
        ar.Read(Buf,StrLen);
        OutFile.Write(Buf,StrLen);

        DWORD HiPrecision=FALSE;
        OutFile.Write(&HiPrecision,4);

        break;
      }
      if(strcmp(Name,"Генератор звука")==0) {
        ar.Read(Buf,4);
        OutFile.Write(Buf,4);
        break;
      }
      if(strcmp(Name,"Матричный индикатор")==0) {
        ar.Read(Buf,12);
        OutFile.Write(Buf,12);
        break;
      }

      MessageBox(NULL,"Ошибка преобразования формата с версии 2.00 к 2.02","Ошибка",MB_OK|MB_ICONSTOP);
      Error=TRUE;
      break;
    }
    if(Error) break;
  }
  OutFile.Close();
  
  if(Error) return;

  CFile *pFile=ar.GetFile();
  ar.Flush();
  pFile->Close();
  pFile->Open(NewFileName,CFile::typeBinary|CFile::modeRead);
  pFile->Seek(16,CFile::begin);
}
