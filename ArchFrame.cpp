// ArchFrame.cpp : implementation file
//

#include "stdafx.h"
#include "demis2000.h"
#include "ArchFrame.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CArchFrame

IMPLEMENT_DYNCREATE(CArchFrame, CMDIChildWnd)

CArchFrame::CArchFrame()
{
  ChildWndInfo.Menu.LoadMenu(IDR_ARCHTYPE_ADD);
  ChildWndInfo.MenuIndex=2;
  ChildWndInfo.pChildWnd=this;
  ChildWndInfo.DocType=".arh";
  ChildWndInfo.BtnCount=0;

  ((CMainFrame*)theApp.m_pMainWnd)->AddChildWindow(&ChildWndInfo);
}

CArchFrame::~CArchFrame()
{
}


BEGIN_MESSAGE_MAP(CArchFrame, CMDIChildWnd)
	//{{AFX_MSG_MAP(CArchFrame)
	ON_WM_CLOSE()
	ON_COMMAND_RANGE(ID_ADD_ELEMENT0,ID_ADD_ELEMENT255,OnAddElement)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CArchFrame message handlers


BOOL CArchFrame::Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CMDIFrameWnd* pParentWnd, CCreateContext* pContext) 
{
  if(CMDIChildWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, pContext)) {
    if(pContext) {
      ChildWndInfo.pDocument=pContext->m_pCurrentDoc;
      pDoc=pContext->m_pCurrentDoc;
    }else ChildWndInfo.pDocument=NULL;

    CString LibGUID,ClsGUID;
    LONG Index=0,ElIndex=0;
    CMenu *pMainSubMenu=ChildWndInfo.Menu.GetSubMenu(0);
    while (theApp.EnumElemLibs(Index,&LibGUID,&ClsGUID)) {
      CElemLib *pElemLib=new CElemLib;
      pElemLib->CreateInstance(LibGUID);

      if(pElemLib->get_nElementsCount()==0) { Index++; continue; }
      ArchSubMenu[Index].CreateMenu();
      for(DWORD n=0; n<pElemLib->get_nElementsCount(); n++) {
        CString ElemName;
        pElemLib->GetElementName(n,ElemName);
        ArchSubMenu[Index].AppendMenu(MF_ENABLED|MF_STRING,
          ID_ADD_ELEMENT0+ElIndex,ElemName);
        MenuItemGUID[ElIndex]=LibGUID;
        MsgStr.Add(CString(ElemName));
        ElIndex++;
      }

      CString SubMenuName;
      pElemLib->get_sLibraryName(SubMenuName);
      pMainSubMenu->InsertMenu(0,MF_BYPOSITION|MF_POPUP,(UINT)ArchSubMenu[Index].m_hMenu,SubMenuName);
      CMenu* pSubMenu=pMainSubMenu->GetSubMenu(0);
    
      delete pElemLib;
      Index++;
    }
  
    if(!Index) MessageBox("Библиотеки элементов не установлены","Ошибка",MB_OK|MB_ICONSTOP);

    return TRUE;
  }
  return FALSE;
}

BOOL CArchFrame::DestroyWindow() 
{
  ((CMainFrame*)theApp.m_pMainWnd)->DeleteChildWindow(&ChildWndInfo);

  if(theApp.pDebugArchDoc==pDoc) theApp.pDebugArchDoc=NULL;

	return CMDIChildWnd::DestroyWindow();
}

void CArchFrame::OnClose() 
{
  if(theApp.pDebugArchDoc==pDoc) {
    if(theApp.pDebugFrame) {
      CString Mes="Закрытие окна архитектуры приведёт к закрытию отладчика\n";
      Mes+="Продолжить?";
      if(MessageBox(Mes,"Предупреждение",MB_YESNO|
        MB_ICONEXCLAMATION)!=IDYES) return;
      theApp.pDebugFrame->DestroyWindow();
    }
    if(theApp.pDebugArchDoc==pDoc) {
      //При закрытии, остановить эмулятор
      theApp.TerminateEmulator();
    }
  }

	CMDIChildWnd::OnClose();
}

void CArchFrame::OnAddElement(UINT nId) 
{
  CString ElemName;
  ChildWndInfo.Menu.GetMenuString(nId,ElemName,MF_BYCOMMAND);
  GetActiveView()->SendMessage(WMU_ADD_ELEMENT_BY_NAME,
    (WPARAM)(LPCTSTR)MenuItemGUID[nId-ID_ADD_ELEMENT0],
    (LPARAM)(LPCTSTR)ElemName);
}

void CArchFrame::ChangeMode(BOOL bConfigMode)
{
  /*CMenu *pMainMenu=ChildWndInfo.Menu.GetSubMenu(0);
  for(DWORD n=0; n<pMenu->GetMenuItemCount(); n++) {
    CMenu *pSubMenu=
    CMenu *pMainMenu=ChildWndInfo.Menu.GetSubMenu(0);
    CString Str;
    pMenu->GetMenuString(n,Str,MF_BYPOSITION);
    pMenu->EnableMenuItem(MF_BYPOSITION|MF_GRAYED,n);
  }*/
}

void CArchFrame::GetMessageString(UINT nID, CString& rMessage) const
{
  if((nID>=ID_ADD_ELEMENT0)&&(nID<=ID_ADD_ELEMENT255)) {
    rMessage=MsgStr[nID-ID_ADD_ELEMENT0];
    return;
  }
  return CMDIChildWnd::GetMessageString(nID, rMessage);
}
