// ChildFrm.cpp : implementation of the CChildFrame class
//

#include "stdafx.h"
#include "Demis2000.h"

#include "ChildFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CChildFrame

IMPLEMENT_DYNCREATE(CChildFrame, CMDIChildWnd)

BEGIN_MESSAGE_MAP(CChildFrame, CMDIChildWnd)
	//{{AFX_MSG_MAP(CChildFrame)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CChildFrame construction/destruction

CChildFrame::CChildFrame()
{
  ChildWndInfo.Menu.LoadMenu(IDR_ASSMTYPE_ADD);
  ChildWndInfo.MenuIndex=1;
  ChildWndInfo.pChildWnd=this;
  ChildWndInfo.DocType=".asm";

  ChildWndInfo.BtnCount=4;
  //Добавляем сепаратор
  ChildWndInfo.Btn[0].iBitmap=0;
  ChildWndInfo.Btn[0].idCommand=0;
  ChildWndInfo.Btn[0].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[0].fsStyle=TBSTYLE_SEP;
  ChildWndInfo.Btn[0].dwData=1;
  ChildWndInfo.Btn[0].iString=NULL;

  //Добавляем кнопку Cut
  ChildWndInfo.Btn[1].iBitmap=3;
  ChildWndInfo.Btn[1].idCommand=ID_EDIT_CUT;
  ChildWndInfo.Btn[1].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[1].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[1].dwData=1;
  ChildWndInfo.Btn[1].iString=NULL;

  //Добавляем кнопку Copy
  ChildWndInfo.Btn[2].iBitmap=4;
  ChildWndInfo.Btn[2].idCommand=ID_EDIT_COPY;
  ChildWndInfo.Btn[2].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[2].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[2].dwData=1;
  ChildWndInfo.Btn[2].iString=NULL;

  //Добавляем кнопку Paste
  ChildWndInfo.Btn[3].iBitmap=5;
  ChildWndInfo.Btn[3].idCommand=ID_EDIT_PASTE;
  ChildWndInfo.Btn[3].fsState=TBSTATE_ENABLED;
  ChildWndInfo.Btn[3].fsStyle=TBSTYLE_BUTTON;
  ChildWndInfo.Btn[3].dwData=1;
  ChildWndInfo.Btn[3].iString=NULL;

  ((CMainFrame*)theApp.m_pMainWnd)->AddChildWindow(&ChildWndInfo);
}

CChildFrame::~CChildFrame()
{
  ((CMainFrame*)theApp.m_pMainWnd)->DeleteChildWindow(&ChildWndInfo);
}

/////////////////////////////////////////////////////////////////////////////
// CChildFrame diagnostics

#ifdef _DEBUG
void CChildFrame::AssertValid() const
{
	CMDIChildWnd::AssertValid();
}

void CChildFrame::Dump(CDumpContext& dc) const
{
	CMDIChildWnd::Dump(dc);
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CChildFrame message handlers


BOOL CChildFrame::Create(LPCTSTR lpszClassName,LPCTSTR lpszWindowName,
  DWORD dwStyle,const RECT& rect,CMDIFrameWnd* pParentWnd,
  CCreateContext* pContext)
{
  if(CMDIChildWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, pContext)) {
    if(pContext) {
      ChildWndInfo.pDocument=pContext->m_pCurrentDoc;
    }else ChildWndInfo.pDocument=NULL;
    return TRUE;
  }
  return FALSE;
}
