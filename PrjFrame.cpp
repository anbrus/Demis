// PrjFrame.cpp : implementation file
//

#include "stdafx.h"
#include "demis2000.h"
#include "PrjFrame.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPrjFrame

IMPLEMENT_DYNCREATE(CPrjFrame, CMDIChildWnd)

CPrjFrame::CPrjFrame()
{
  ChildWndInfo.Menu.LoadMenu(IDR_PRJTYPE_ADD);
  ChildWndInfo.MenuIndex=4;
  ChildWndInfo.pChildWnd=this;
  ChildWndInfo.DocType=".prj";

  ChildWndInfo.BtnCount=6;
  //Добавляем сепаратор
  ChildWndInfo.Btn[0].iBitmap=0;
  ChildWndInfo.Btn[0].idCommand=0;
  ChildWndInfo.Btn[0].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[0].fsStyle=TBSTYLE_SEP;
  ChildWndInfo.Btn[0].dwData=4;
  ChildWndInfo.Btn[0].iString=NULL;

  //Добавляем кнопку Assemble
  ChildWndInfo.Btn[1].iBitmap=7;
  ChildWndInfo.Btn[1].idCommand=ID_ASSEMBLE;
  ChildWndInfo.Btn[1].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[1].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[1].dwData=4;
  ChildWndInfo.Btn[1].iString=NULL;

  //Добавляем кнопку Build
  ChildWndInfo.Btn[2].iBitmap=8;
  ChildWndInfo.Btn[2].idCommand=ID_BUILD;
  ChildWndInfo.Btn[2].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[2].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[2].dwData=4;
  ChildWndInfo.Btn[2].iString=NULL;

  //Добавляем кнопку Run
  ChildWndInfo.Btn[3].iBitmap=9;
  ChildWndInfo.Btn[3].idCommand=ID_RUN;
  ChildWndInfo.Btn[3].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[3].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[3].dwData=4;
  ChildWndInfo.Btn[3].iString=NULL;

  //Добавляем кнопку Debug
  ChildWndInfo.Btn[4].iBitmap=10;
  ChildWndInfo.Btn[4].idCommand=ID_DEBUG;
  ChildWndInfo.Btn[4].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[4].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[4].dwData=4;
  ChildWndInfo.Btn[4].iString=NULL;

  //Добавляем кнопку Break
  ChildWndInfo.Btn[5].iBitmap=11;
  ChildWndInfo.Btn[5].idCommand=ID_BREAK;
  ChildWndInfo.Btn[5].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[5].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[5].dwData=4;
  ChildWndInfo.Btn[5].iString=NULL;

  ((CMainFrame*)theApp.m_pMainWnd)->AddChildWindow(&ChildWndInfo);
}

CPrjFrame::~CPrjFrame()
{
}


BEGIN_MESSAGE_MAP(CPrjFrame, CMDIChildWnd)
	//{{AFX_MSG_MAP(CPrjFrame)
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPrjFrame message handlers

void CPrjFrame::ActivateFrame(int nCmdShow) 
{
  CRect ParentRect;
  GetParent()->GetClientRect(&ParentRect);
  ParentRect.bottom-=128;
  ParentRect.right=200;
	MoveWindow(ParentRect);

	CMDIChildWnd::ActivateFrame(nCmdShow);
}

BOOL CPrjFrame::Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CMDIFrameWnd* pParentWnd, CCreateContext* pContext) 
{
  if(CMDIChildWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, pContext)) {
    if(pContext) {
      ChildWndInfo.pDocument=pContext->m_pCurrentDoc;
    }else ChildWndInfo.pDocument=NULL;
    return TRUE;
  }
  return FALSE;
	
	//return CMDIChildWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, pContext);
}

BOOL CPrjFrame::DestroyWindow() 
{
  ((CMainFrame*)theApp.m_pMainWnd)->DeleteChildWindow(&ChildWndInfo);

  CPrjDoc* pDoc=(CPrjDoc*)ChildWndInfo.pDocument;
  if(!pDoc->GetPathName().IsEmpty()) pDoc->OnSaveDocument(pDoc->GetPathName());
  
  CMainFrame* pMainFrame=(CMainFrame*)theApp.m_pMainWnd;
  while(TRUE) {
    POSITION Pos=pMainFrame->ChildWndList.GetHeadPosition();
    if(!Pos) break;

    struct _ChildWndInfo* pWndInfo;
    pWndInfo=(struct _ChildWndInfo*)pMainFrame->ChildWndList.GetAt(Pos);
    pWndInfo->pChildWnd->DestroyWindow();
  }
  theApp.pPrjDoc=NULL;
	
  return CMDIChildWnd::DestroyWindow();
}

void CPrjFrame::OnClose() 
{
  if(!theApp.SaveAllModified()) return;
	
	CMDIChildWnd::OnClose();
}
