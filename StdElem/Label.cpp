// Label.cpp: implementation of the CLabel class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "Label.h"
#include "TextDlg.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CLabel::CLabel(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
{
  pArchElemWnd=NULL;
  pConstrElemWnd=NULL;
  
  TipText="Текстовая метка";
  IdIndex=4;
  OnArch=ArchMode;
  Text="Метка";
  Font.CreatePointFont(90,"Arial Cyr");

  PointCount=0;

	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_LABEL_MENU);
	AfxSetResourceHandle(hInstOld);
}

CLabel::~CLabel()
{
}

BOOL CLabel::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  pLabelWnd=new CLabelWnd(this);
  if(OnArch) pArchElemWnd=pLabelWnd;
  else pConstrElemWnd=pLabelWnd;

  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));

  pLabelWnd->Create(ClassName,"Метка",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,15,15),pArchParentWnd,0);
  
  pLabelWnd->UpdateSize();

  return TRUE;
}

BOOL CLabel::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&OnArch,4);
  int TextLen=Text.GetLength();
  File.Write(&TextLen,4);
  File.Write((LPCTSTR)Text,TextLen);

  return CElement::Save(hFile);
}

BOOL CLabel::Load(HANDLE hFile)
{
  CFile File(hFile);
  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Метка: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }

  File.Read(&OnArch,4);
  int TextLen;
  File.Read(&TextLen,4);
  char* NewText=(char*)malloc(TextLen+1);
  File.Read(NewText,TextLen);
  NewText[TextLen]=0;
  Text=NewText;
  free(NewText);

  return CElement::Load(hFile);
}

BOOL CLabel::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);

  return TRUE;
}

BEGIN_MESSAGE_MAP(CLabelWnd, CElementWnd)
	//{{AFX_MSG_MAP(CLabelWnd)
	ON_COMMAND(ID_LABEL_TEXT, OnLabelText)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


void CLabelWnd::UpdateSize()
{
  if(((CLabel*)pElement)->Text.IsEmpty()) {
    Size.cx=15; Size.cy=15;
  }else {
    CClientDC DC(this);

    CGdiObject* pOldFont=DC.SelectObject(&((CLabel*)pElement)->Font);

    CRect DrawRect(0,0,1000,1000);
    DC.DrawText(((CLabel*)pElement)->Text,DrawRect,DT_CENTER|DT_CALCRECT);
    DrawRect.right=5*(DrawRect.right/5)+5;
    DrawRect.bottom=5*(DrawRect.bottom/5)+5;

    Size.cx=DrawRect.Width()+10;
    Size.cy=DrawRect.Height()+10;

    DC.SelectObject(pOldFont);
  }

  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  ::GetWindowPlacement(m_hWnd,&Pls);
  CRect Rect(Pls.rcNormalPosition);
  Rect.right=Rect.left+Size.cx;
  Rect.bottom=Rect.top+Size.cy;
  MoveWindow(Rect);
  RedrawWindow();
}

void CLabelWnd::OnLabelText() 
{
	HINSTANCE hInstOld=AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(AfxGetAppName());
	AfxSetResourceHandle(hDll);

	CTextDlg Dlg(this);
  Dlg.SetText((char*)(LPCTSTR)((CLabel*)pElement)->Text);
  if(Dlg.DoModal()==IDOK) {
    ((CLabel*)pElement)->Text=Dlg.GetText();
    UpdateSize();
    pElement->ModifiedFlag=TRUE;
  }
	
  AfxSetResourceHandle(hInstOld);
}

void CLabelWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldFont;
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);

  BOOL Sel=((CLabel*)pElement)->OnArch ? pElement->ArchSelected :
    pElement->ConstrSelected;

  if(Sel) pDC->FrameRect(CRect(0,0,Size.cx,Size.cy),&SelectBrush);
  else pDC->FrameRect(CRect(0,0,Size.cx,Size.cy),&NormalBrush);

  pOldFont=pDC->SelectObject(&((CLabel*)pElement)->Font);
  pDC->SetBkColor(theApp.BkColor);
  if(Sel) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  pDC->DrawText(((CLabel*)pElement)->Text,CRect(5,5,Size.cx-5,Size.cy-5),
    DT_CENTER);

  pDC->SelectObject(pOldFont);
}
