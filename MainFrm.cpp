// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "Demis2000.h"

#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMainFrame

IMPLEMENT_DYNAMIC(CMainFrame, CMDIFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CMDIFrameWnd)
	ON_COMMAND_EX(CG_ID_VIEW_INFOBAR, OnBarCheck)
	ON_UPDATE_COMMAND_UI(CG_ID_VIEW_INFOBAR, OnUpdateControlBarMenu)
	//{{AFX_MSG_MAP(CMainFrame)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_COMMAND_RANGE(ID_FILE_MRU_PRJ1,ID_FILE_MRU_PRJ4, OnFileMruPrj)
	ON_UPDATE_COMMAND_UI(ID_FILE_MRU_PRJ1, OnUpdateFileMruPrj1)
	ON_WM_CLOSE()
  ON_MESSAGE(WMU_EMULATOR_MESSAGE,OnEmulatorMessage)
	ON_MESSAGE(WMU_WRITEPORT,OnWritePort)
	ON_MESSAGE(WMU_READPORT,OnReadPort)
	ON_MESSAGE(WMU_INTREQUEST,OnIntRequest)
	ON_MESSAGE(WMU_EMULSTOP,OnEmulStop)
	ON_MESSAGE(WMU_INSTRCOUNTER_EVENT,OnInstrCounterEvent)
	//}}AFX_MSG_MAP
	// Global help commands
	ON_COMMAND(ID_HELP_FINDER, CMDIFrameWnd::OnHelpFinder)
	ON_COMMAND(ID_HELP, CMDIFrameWnd::OnHelp)
	//ON_COMMAND(ID_CONTEXT_HELP, CMDIFrameWnd::OnContextHelp)
	ON_COMMAND(ID_DEFAULT_HELP, CMDIFrameWnd::OnHelpFinder)
END_MESSAGE_MAP()

static UINT indicators[] =
{
	ID_SEPARATOR,           // status line indicator
  //ID_ROWCOL,
	//ID_INDICATOR_CAPS,
	//ID_INDICATOR_NUM,
	//ID_INDICATOR_SCRL,
};

/////////////////////////////////////////////////////////////////////////////
// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
  InfoBarPresent=FALSE;
  MenuCounter[0]=1;   //Файл
  MenuCounter[1]=0;   //Правка
  MenuCounter[2]=0;   //Архитектура
  MenuCounter[3]=0;   //Отладка
  MenuCounter[4]=0;   //Проект
  MenuCounter[5]=1;   //Вид
  MenuCounter[6]=1;   //Справка
}

CMainFrame::~CMainFrame()
{
	TRACE("Main Frame Class Destroyed\n");
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if(CMDIFrameWnd::OnCreate(lpCreateStruct)==-1)
		return -1;
	
  m_wndToolBar.CreateEx(this,TBSTYLE_FLAT|TBSTYLE_TRANSPARENT);
	m_wndToolBar.LoadBitmap(IDR_MAINFRAME);

  CToolBarCtrl &TBCtrl=m_wndToolBar.GetToolBarCtrl();
  TBBUTTON Btn[3]={
    { 0,ID_PRJ_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,NULL },
    { 1,ID_PRJ_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,NULL },
    { 2,ID_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,NULL },
  };
  TBCtrl.AddButtons(3,Btn);

	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(indicators,
		  sizeof(indicators)/sizeof(UINT)))
	{
		TRACE0("Failed to create status bar\n");
		return -1;      // fail to create
	}

  m_wndReBar.Create(this);
  m_wndReBar.AddBar(&m_wndToolBar);

	m_wndToolBar.SetBarStyle(m_wndToolBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY);

	return 0;
}

/////////////////////////////////////////////////////////////////////////////
// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CMDIFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CMDIFrameWnd::Dump(dc);
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CMainFrame message handlers

void CMainFrame::OnSize(UINT nType, int cx, int cy) 
{
  //m_wndInfoBar.SetSize(CSize(cx,128));
	CMDIFrameWnd::OnSize(nType, cx, cy);
}


IMPLEMENT_DYNCREATE(CInfoBar, CMDIChildWnd);

BEGIN_MESSAGE_MAP(CInfoBar, CMDIChildWnd)
	//{{AFX_MSG_MAP(CInfoBar)
	ON_WM_SIZE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/*int CInfoBar::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if(CDialogBar::OnCreate(lpCreateStruct)==-1)
		return -1;
  Size.cx=lpCreateStruct->cx; Size.cy=lpCreateStruct->cy;
  LOGFONT lf={
    100,
    0,
    0,
    0,
    0,
    FALSE,
    FALSE,
    FALSE,
    ANSI_CHARSET,
    OUT_DEFAULT_PRECIS,
    CLIP_DEFAULT_PRECIS,
    DEFAULT_QUALITY,
    DEFAULT_PITCH,
    "Courier New Cyr"
  };
  m_Font.CreatePointFontIndirect(&lf);
  return 0;
}*/

/*CSize CInfoBar::CalcDynamicLayout(int nLength, DWORD dwMode)
{
  return Size;
}*/

/*void CInfoBar::SetSize(CSize NewSize)
{
  Size=NewSize;
  Invalidate(FALSE);
  CEdit* pEdit=(CEdit*)GetDlgItem(IDC_INFOEDIT);
  CRect Rect(4,4,Size.cx-6,Size.cy-6);
  pEdit->MoveWindow(Rect);
}*/

BOOL CInfoBar::DestroyWindow() 
{
  //InfoEdit.DestroyWindow();
	return CMDIChildWnd::DestroyWindow();
}

void CInfoBar::AddText(CString Add)
{
  int LastCharIndex=InfoEdit.LineIndex(InfoEdit.GetLineCount()-1);
  LastCharIndex+=InfoEdit.LineLength(InfoEdit.GetLineCount()-1);
  InfoEdit.SetSel(LastCharIndex,LastCharIndex);
  InfoEdit.ReplaceSel(Add);
  InfoEdit.UpdateWindow();
}

void CInfoBar::ClearInfo()
{
  InfoEdit.SetSel(0,-1);
  InfoEdit.ReplaceSel("");
  
  //InfoText.Empty();
  //SetDlgItemText(IDC_INFOEDIT,InfoText);
  //GetDlgItem(IDC_INFOEDIT)->RedrawWindow();
}

BOOL CInfoBar::Create(CMDIFrameWnd *pParent)
{
  pParentFrame=pParent;
  LoadFrame(IDR_INFOFRAME,WS_CHILD|WS_OVERLAPPEDWINDOW,pParentFrame);
  CRect FrameRect,EditRect;
  GetParent()->GetClientRect(&FrameRect);
  FrameRect.top=FrameRect.bottom-128;
  MoveWindow(FrameRect);

  GetClientRect(&EditRect);
  InfoEdit.Create(ES_AUTOHSCROLL|ES_AUTOVSCROLL|ES_LEFT|ES_MULTILINE
    |ES_WANTRETURN|WS_CHILD|WS_VISIBLE|WS_HSCROLL|WS_VSCROLL,
    EditRect,this,0);

  LOGFONT lf={
    100,
    0,
    0,
    0,
    0,
    FALSE,
    FALSE,
    FALSE,
    ANSI_CHARSET,
    OUT_DEFAULT_PRECIS,
    CLIP_DEFAULT_PRECIS,
    DEFAULT_QUALITY,
    DEFAULT_PITCH,
    "Courier New Cyr"
  };
  m_Font.CreatePointFontIndirect(&lf);
  InfoEdit.SetFont(&m_Font);

  //InfoEdit.SetReadOnly();
  ShowWindow(SW_NORMAL);
  return TRUE;
}

CInfoBar::~CInfoBar()
{
  ((CMainFrame*)pParentFrame)->InfoBarPresent=FALSE;
}

void CInfoBar::OnSize(UINT nType, int cx, int cy) 
{
	CMDIChildWnd::OnSize(nType, cx, cy);
	
  if(InfoEdit.m_hWnd) {
    CRect EditRect;
    GetClientRect(&EditRect);
	  InfoEdit.MoveWindow(EditRect);
  }
}

CInfoBar::CInfoBar()
{
}

void CMainFrame::RestoreInfoBar()
{
  if(!InfoBarPresent) {
    pInfoBar=new CInfoBar;
    pInfoBar->Create(this);
    InfoBarPresent=TRUE;
  }
  pInfoBar->SetWindowPos(&wndTop,0,0,0,0,SWP_NOSIZE|SWP_NOMOVE);
}

void CMainFrame::OnUpdateFileMruPrj1(CCmdUI* pCmdUI) 
{
	theApp.pPrjMRUList->UpdateMenu(pCmdUI);
}

void CMainFrame::OnFileMruPrj(UINT nID) 
{
  CString PrjPathName=(*(theApp.pPrjMRUList))[nID-ID_FILE_MRU_PRJ1];
  theApp.OpenDemisDocument(PrjPathName,CString(".prj"));
}

BOOL CMainFrame::AddChildWindow(struct _ChildWndInfo *pChildWndInfo)
{
  ChildWndList.AddTail(pChildWndInfo);
  if(MenuCounter[pChildWndInfo->MenuIndex]==0) {
    //Добавляем меню
    CMenu* pMenu=GetMenu();

    int MenuPos=0;
    for(int n=0; n<pChildWndInfo->MenuIndex; n++) {
      if(MenuCounter[n]) MenuPos++;
    }
    CString AddMenuName;
    pChildWndInfo->Menu.GetMenuString(0,AddMenuName,MF_BYPOSITION);
    pMenu->InsertMenu(MenuPos,MF_BYPOSITION|MF_POPUP,
      (UINT)pChildWndInfo->Menu.GetSubMenu(0)->GetSafeHmenu(),AddMenuName);
    DrawMenuBar();

    //Добавляем панель инструментов
    CToolBarCtrl &TBCtrl=m_wndToolBar.GetToolBarCtrl();
    TBBUTTON Btn;
    int NewBtnIndex=TBCtrl.GetButtonCount();
    for(int n=0; n<TBCtrl.GetButtonCount(); n++) {
      TBCtrl.GetButton(n,&Btn);
      if(Btn.dwData>(UINT)pChildWndInfo->MenuIndex) { NewBtnIndex=n; break; }
    }

    for(int n=0; n<pChildWndInfo->BtnCount; n++) {
      memcpy(&Btn,&pChildWndInfo->Btn[n],sizeof(TBBUTTON));
      TBCtrl.InsertButton(NewBtnIndex,&Btn);
      NewBtnIndex++;
    }
    TBCtrl.AutoSize();
    ShowControlBar(&m_wndToolBar,TRUE,FALSE);
  }
  MenuCounter[pChildWndInfo->MenuIndex]++;

  return TRUE;
}

BOOL CMainFrame::DeleteChildWindow(struct _ChildWndInfo *pChildWndInfo)
{
  POSITION Pos;
  if(Pos=ChildWndList.Find(pChildWndInfo)) {
    ChildWndList.RemoveAt(Pos);

    MenuCounter[pChildWndInfo->MenuIndex]--;
    if(!MenuCounter[pChildWndInfo->MenuIndex]) {
      CString CurMenuName,ChildMenuName;
      pChildWndInfo->Menu.GetMenuString(0,ChildMenuName,MF_BYPOSITION);
      CMenu* pMenu=GetMenu();
      for(int MenuPos=0; MenuPos<7; MenuPos++) {
        pMenu->GetMenuString(MenuPos,CurMenuName,MF_BYPOSITION);
        if(CurMenuName==ChildMenuName) {
          pMenu->RemoveMenu(MenuPos,MF_BYPOSITION);
          DrawMenuBar();
          break;
        }
      }
      //Удаляем панель инструментов
      CToolBarCtrl &TBCtrl=m_wndToolBar.GetToolBarCtrl();
      TBBUTTON Btn;
      for(int n=0; n<TBCtrl.GetButtonCount(); n++) {
        TBCtrl.GetButton(n,&Btn);
        if(Btn.dwData==(UINT)pChildWndInfo->MenuIndex) TBCtrl.DeleteButton(n--);
      }
      TBCtrl.AutoSize();
      ShowControlBar(&m_wndToolBar,TRUE,FALSE);
    }
  }
  
  return TRUE;
}

BOOL CMainFrame::DestroyWindow() 
{
  //::MessageBeep(-1);
  if(theApp.pPrjDoc) {
    delete theApp.pPrjDoc;
  }
	return CMDIFrameWnd::DestroyWindow();
}

void CMainFrame::AddMessage(const char *MesText,BOOL SetFocus)
{
  if(!InfoBarPresent) RestoreInfoBar();
  pInfoBar->AddText(MesText);
  if(SetFocus) pInfoBar->SetFocus();
}

void CMainFrame::ClearMessages()
{
  if(!InfoBarPresent) RestoreInfoBar();
  pInfoBar->ClearInfo();
}

void CMainFrame::OnClose() 
{
  theApp.pDebugFrame=NULL;
  theApp.TerminateEmulator();
	
	CMDIFrameWnd::OnClose();
}

LRESULT CMainFrame::OnEmulatorMessage(WPARAM wParam, LPARAM lParam) 
{
  if(lParam==WMU_EMULSTOP) {
    //Если открыт отладчик, то просто извещаем его
    if(theApp.pDebugFrame) theApp.pDebugFrame->OnStopProgram(wParam);
    //Иначе нужно сообщить об остановке и о её причине
    else {
      if(wParam!=NO_ERRORS) {
        CString ErrorText;
        theApp.GetErrorText(wParam,ErrorText);
        MessageBox(ErrorText,"Ошибка",MB_OK|MB_ICONSTOP);
      }
      //AddMessage("Программа остановлена\r\n",FALSE);
    }
  }
  return 0;
}

LPARAM CMainFrame::OnWritePort(WPARAM wParam, LPARAM lParam)
{
  if(theApp.pDebugArchDoc) theApp.pDebugArchDoc->WritePort(wParam,lParam);
  return 0;
}

LPARAM CMainFrame::OnReadPort(WPARAM wParam, LPARAM lParam)
{
  if(theApp.pDebugArchDoc) return theApp.pDebugArchDoc->ReadPort(wParam);
  return 0;
}

LPARAM CMainFrame::OnIntRequest(WPARAM wParam, LPARAM lParam)
{
  theApp.pEmData->IntRequest|=wParam;
  return 0;
}

LPARAM CMainFrame::OnEmulStop(WPARAM wParam, LPARAM lParam)
{
  if(theApp.FrozenTimer) {
    ::KillTimer(NULL,theApp.FrozenTimer);
    theApp.FrozenTimer=0;
  }
  PostMessage(WMU_EMULATOR_MESSAGE,wParam,WMU_EMULSTOP);
  theApp.hRunThread=NULL;

  if(theApp.pDebugFrame) theApp.pDebugFrame->OnStopProgram(0);
  else if(theApp.pDebugArchDoc) theApp.pDebugArchDoc->ChangeMode(TRUE);

  return 0;
}

LRESULT CMainFrame::WindowProc(UINT message, WPARAM wParam, LPARAM lParam) 
{
  switch(message) {
  case WMU_WRITEPORT  : return OnWritePort(wParam,lParam);
  case WMU_READPORT   : return OnReadPort(wParam,lParam);
  default             : return CMDIFrameWnd::WindowProc(message, wParam, lParam);
  }
  return 0;
}

LPARAM CMainFrame::OnInstrCounterEvent(WPARAM wParam, LPARAM lParam)
{
  if(theApp.pDebugArchDoc) return theApp.pDebugArchDoc->OnInstrCounterEvent((HANDLE)lParam);
  return 0;
}
