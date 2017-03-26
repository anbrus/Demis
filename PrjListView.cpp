// PrjListView.cpp : implementation file
//

#include "stdafx.h"
#include "demis2000.h"
#include "PrjListView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPrjListView

IMPLEMENT_DYNCREATE(CPrjListView, CTreeView)

CPrjListView::CPrjListView()
{
  pDoc=NULL; //pNewFocusWnd=NULL;
}

CPrjListView::~CPrjListView()
{
}


BEGIN_MESSAGE_MAP(CPrjListView, CTreeView)
	//{{AFX_MSG_MAP(CPrjListView)
	ON_COMMAND(ID_FILE_ADD, OnFileAdd)
	ON_COMMAND(ID_SOURCE_ADD, OnSourceAdd)
	ON_COMMAND(ID_INC_ADD, OnIncAdd)
	ON_COMMAND(ID_ARCH_ADD, OnArchAdd)
	ON_COMMAND(ID_SOURCE_OPEN, OnSourceOpen)
	ON_COMMAND(ID_INC_OPEN, OnIncOpen)
	ON_COMMAND(ID_SOURCE_DEL, OnSourceDel)
	ON_COMMAND(ID_INC_DEL, OnIncDel)
	ON_COMMAND(ID_ARCH_OPEN, OnArchOpen)
	ON_COMMAND(ID_ARCH_DEL, OnArchDel)
	ON_WM_LBUTTONDBLCLK()
	ON_NOTIFY_REFLECT(NM_DBLCLK, OnDblclk)
	ON_NOTIFY_REFLECT(NM_RETURN, OnReturn)
	ON_NOTIFY_REFLECT(NM_RCLICK, OnRclick)
	ON_NOTIFY_REFLECT(TVN_ITEMEXPANDED, OnItemExpanded)
	ON_NOTIFY_REFLECT(TVN_KEYDOWN, OnKeydown)
	ON_COMMAND(ID_CONTAINS_ENTRYPOINT, OnContainsEntrypoint)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPrjListView drawing

/////////////////////////////////////////////////////////////////////////////
// CPrjListView diagnostics

#ifdef _DEBUG
void CPrjListView::AssertValid() const
{
	CTreeView::AssertValid();
}

void CPrjListView::Dump(CDumpContext& dc) const
{
	CTreeView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CPrjListView message handlers

void CPrjListView::OnInitialUpdate() 
{
  CTreeView::OnInitialUpdate();
  pDoc=(CPrjDoc*)GetDocument();
  pDoc->pView=this;
  ModifyStyle(0,TVS_HASLINES|TVS_HASBUTTONS|TVS_LINESATROOT);
  ImageList.Create(16,16,TRUE,4,4);
  ImageList.Add(theApp.LoadIcon(IDI_CLOSEDFOLDER));
  ImageList.Add(theApp.LoadIcon(IDI_OPENEDFOLDER));
  ImageList.Add(theApp.LoadIcon(IDR_ASSMTYPE));
  ImageList.Add(theApp.LoadIcon(IDR_INCTYPE));
  ImageList.Add(theApp.LoadIcon(IDR_ARCHTYPE));
  CTreeCtrl& Tree=GetTreeCtrl();
  Tree.SetImageList(&ImageList,TVSIL_NORMAL);
  CString GlFold="Проект ";
  GlFold+=pDoc->GetTitle();
  hGlobalFolder=Tree.InsertItem(GlFold,0,0);
  hSourceFolder=Tree.InsertItem("Ассемблируемые",0,0,hGlobalFolder);
  hIncFolder=Tree.InsertItem("Включаемые",0,0,hGlobalFolder);
  hArchFolder=Tree.InsertItem("Архитектура",0,0,hGlobalFolder);

  POSITION Pos=pDoc->FileList.GetHeadPosition();
  while(Pos) {
    PrjFile File=pDoc->FileList.GetAt(Pos);
    HTREEITEM hFolder=NULL;
    int Icon=0;
    switch(File.Folder) {
    case 1 : hFolder=hSourceFolder; Icon=2; break;
    case 2 : hFolder=hIncFolder;    Icon=3; break;
    case 3 : hFolder=hArchFolder;   Icon=4; break;
    }
    if(hFolder) {
      HTREEITEM hItem=Tree.InsertItem(File.Path,Icon,Icon,hFolder);
      Tree.SetItemData(hItem,(DWORD)Pos);
    }
    pDoc->FileList.GetNext(Pos);
  }
}

void CPrjListView::OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint) 
{
  if(pDoc) {
    CTreeCtrl& Tree=GetTreeCtrl();
    CString GlFold="Проект ";
    GlFold+=pDoc->GetTitle();
    Tree.SetItemText(hGlobalFolder,GlFold);
  }
}

void CPrjListView::OnFileAdd() 
{
  CString S;
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  do {
    if(hActiveItem==hGlobalFolder) {
      S="Архитектура (*.arh)|*.arh|Все файлы (*.*)|*.*||"; 
      break;
    }
    if(hActiveItem==hSourceFolder) {
      S="Текст программы (*.asm)|*.asm|Все файлы (*.*)|*.*||"; 
      break;
    }
  }while(FALSE);
	CFileDialog TextFindDlg(TRUE,NULL,NULL,OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT,
    S,this);
  if(TextFindDlg.DoModal()==IDOK) {
  }
}

void CPrjListView::ShowPopupMenu()
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  CMenu Menu,*pPopupMenu=NULL;
  CPoint CursorPos;
  GetCursorPos(&CursorPos);
  Menu.LoadMenu(IDM_PRJPOPUP);
  HTREEITEM hParentItem=Tree.GetParentItem(hActiveItem);
  do {
    if(hActiveItem==hGlobalFolder) {
      pPopupMenu=Menu.GetSubMenu(0);
      pPopupMenu->TrackPopupMenu(TPM_LEFTALIGN|TPM_TOPALIGN|
      TPM_LEFTBUTTON|TPM_HORIZONTAL|TPM_RIGHTBUTTON,
      CursorPos.x,CursorPos.y,theApp.m_pMainWnd);
      return;
    }
    if(hParentItem==hGlobalFolder) {
      if(hActiveItem==hSourceFolder) {
        pPopupMenu=Menu.GetSubMenu(1);
        break;
      }
      if(hActiveItem==hIncFolder) {
        pPopupMenu=Menu.GetSubMenu(2);
        break;
      }
      if(hActiveItem==hArchFolder) {
        pPopupMenu=Menu.GetSubMenu(3);
        break;
      }
    }else {  //Click on filename
      if(hParentItem==hSourceFolder) {
        pPopupMenu=Menu.GetSubMenu(4);
        pPopupMenu->CheckMenuItem(ID_CONTAINS_ENTRYPOINT,
          pDoc->FileList.GetAt((POSITION)Tree.GetItemData(hActiveItem)).Flag&1
          ? MF_CHECKED : MF_UNCHECKED);
        break;
      }
      if(hParentItem==hIncFolder) {
        pPopupMenu=Menu.GetSubMenu(5);
        break;
      }
      if(hParentItem==hArchFolder) {
        pPopupMenu=Menu.GetSubMenu(6);
        break;
      }
    }
  }while(FALSE);
  if(pPopupMenu) pPopupMenu->TrackPopupMenu(TPM_LEFTALIGN|TPM_TOPALIGN|
    TPM_LEFTBUTTON|TPM_HORIZONTAL|TPM_RIGHTBUTTON,CursorPos.x,CursorPos.y,this);
}

void CPrjListView::OnSourceAdd() 
{
  //GetParent()->SetWindowPos(NULL,0,0,100,50,SWP_NOZORDER|SWP_NOACTIVATE|SWP_SHOWWINDOW);
  CTreeCtrl& Tree=GetTreeCtrl();
	CFileDialog FileDlg(TRUE,".asm",pDoc->PrjPath+"\\*.asm",OFN_HIDEREADONLY
    |OFN_OVERWRITEPROMPT|OFN_CREATEPROMPT,
    "Текст программы (*.asm)|*.asm|Все файлы (*.*)|*.*||",this);
  if(FileDlg.DoModal()==IDOK) {
    CFile NewFile;
    if(!NewFile.Open(FileDlg.GetPathName(),CFile::modeRead|CFile::typeBinary))
    {
      NewFile.Open(FileDlg.GetPathName(),
        CFile::modeWrite|CFile::typeBinary|CFile::modeCreate);
    }
    NewFile.Close();
    //pDoc->SetModifiedFlag();
    HTREEITEM hNewItem=Tree.InsertItem(FileDlg.GetFileName(),
      2,2,hSourceFolder);
    PrjFile File;
    File.Path=FileDlg.GetFileName();
    File.Folder=1; File.Flag=0;
    POSITION PathPos=pDoc->FileList.AddHead(File);
    Tree.SetItemData(hNewItem,(DWORD)PathPos);
  }
  Tree.Invalidate();
}

void CPrjListView::OnIncAdd() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
	CFileDialog FileDlg(TRUE,".asm",pDoc->PrjPath+"\\*.asm",OFN_HIDEREADONLY
    |OFN_OVERWRITEPROMPT|OFN_CREATEPROMPT,
    "Текст программы (*.asm)|*.asm|Все файлы (*.*)|*.*||",this);
  if(FileDlg.DoModal()==IDOK) {
    CFile NewFile;
    if(!NewFile.Open(FileDlg.GetPathName(),CFile::modeRead|CFile::typeBinary))
    {
      NewFile.Open(FileDlg.GetPathName(),
        CFile::modeWrite|CFile::typeBinary|CFile::modeCreate);
    }
    NewFile.Close();
    //pDoc->SetModifiedFlag();
    HTREEITEM hNewItem=Tree.InsertItem(FileDlg.GetFileName(),
      3,3,hIncFolder);
    PrjFile File;
    File.Path=FileDlg.GetFileName();
    File.Folder=2; File.Flag=0;
    POSITION PathPos=pDoc->FileList.AddHead(File);
    Tree.SetItemData(hNewItem,(DWORD)PathPos);
  }
  Tree.Invalidate();
}

void CPrjListView::OnArchAdd() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
	CFileDialog FileDlg(TRUE,".arh",NULL,OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT|OFN_CREATEPROMPT,
    "Архитектура (*.arh)|*.arh|Все файлы (*.*)|*.*||",this);
  if(FileDlg.DoModal()==IDOK) {
    CFile NewFile;
    if(!NewFile.Open(FileDlg.GetPathName(),CFile::modeRead|CFile::typeBinary))
    {
      NewFile.Open(FileDlg.GetPathName(),
        CFile::modeWrite|CFile::typeBinary|CFile::modeCreate);
    }
    NewFile.Close();
    //pDoc->SetModifiedFlag();
    HTREEITEM hArch=Tree.GetChildItem(hArchFolder);
    if(!hArch) hArch=Tree.InsertItem("",4,4,hArchFolder);
    else pDoc->FileList.RemoveAt((POSITION)Tree.GetItemData(hArch));
    Tree.SetItemText(hArch,FileDlg.GetFileName());
    PrjFile File;
    File.Path=FileDlg.GetFileName();
    File.Folder=3; File.Flag=0;
    POSITION PathPos=pDoc->FileList.AddHead(File);
    Tree.SetItemData(hArch,(DWORD)PathPos);
  }
  Tree.Invalidate();
}

void CPrjListView::OnSourceOpen()
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  pDoc->OpenDocument((POSITION)Tree.GetItemData(hActiveItem));
}

void CPrjListView::OnIncOpen()
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  pDoc->OpenDocument((POSITION)Tree.GetItemData(hActiveItem));
}

void CPrjListView::OnSourceDel() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  pDoc->FileList.RemoveAt((POSITION)Tree.GetItemData(hActiveItem));
  Tree.DeleteItem(hActiveItem);
  Tree.Invalidate();
  if(Tree.GetChildItem(hSourceFolder)==NULL) Tree.SetItemImage(hSourceFolder,0,0);
  //pDoc->SetModifiedFlag();
}

void CPrjListView::OnIncDel() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  pDoc->FileList.RemoveAt((POSITION)Tree.GetItemData(hActiveItem));
  Tree.DeleteItem(hActiveItem);
  Tree.Invalidate();
  if(Tree.GetChildItem(hIncFolder)==NULL) Tree.SetItemImage(hIncFolder,0,0);
  //pDoc->SetModifiedFlag();
}

void CPrjListView::OnArchOpen() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  pDoc->OpenDocument((POSITION)Tree.GetItemData(hActiveItem));
}

void CPrjListView::OnArchDel() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  pDoc->FileList.RemoveAt((POSITION)Tree.GetItemData(hActiveItem));
  Tree.DeleteItem(hActiveItem);
  Tree.Invalidate();
  Tree.SetItemImage(hArchFolder,0,0);
  //pDoc->SetModifiedFlag();
}

void CPrjListView::OnLButtonDblClk(UINT nFlags, CPoint point) 
{
	CTreeView::OnLButtonDblClk(nFlags, point);
}

void CPrjListView::OnDblclk(NMHDR* pNMHDR, LRESULT* pResult) 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  if((hActiveItem!=hGlobalFolder)&&
    (Tree.GetParentItem(hActiveItem)!=hGlobalFolder)) {
    pDoc->OpenDocument((POSITION)Tree.GetItemData(hActiveItem));
  }
	
	*pResult = 0;
}

void CPrjListView::OnReturn(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnDblclk(pNMHDR,pResult);
}

void CPrjListView::OnRclick(NMHDR* pNMHDR, LRESULT* pResult) 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  TV_ITEM ti;
  ti.mask=TVIF_HANDLE;
  ti.hItem=hSourceFolder;
  Tree.GetItem(&ti);
  hActiveItem=Tree.GetDropHilightItem();
  if(hActiveItem==NULL) hActiveItem=Tree.GetSelectedItem();
  Tree.SelectItem(hActiveItem);
	ShowPopupMenu();
	
	*pResult = 0;
}

void CPrjListView::OnItemExpanded(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_TREEVIEW* pNMTreeView = (NM_TREEVIEW*)pNMHDR;
  CTreeCtrl& Tree=GetTreeCtrl();
  if(pNMTreeView->itemNew.state&TVIS_EXPANDED) 
    Tree.SetItemImage(pNMTreeView->itemNew.hItem,1,1);
  else Tree.SetItemImage(pNMTreeView->itemNew.hItem,0,0);
	
	*pResult = 0;
}

void CPrjListView::OnKeydown(NMHDR* pNMHDR, LRESULT* pResult) 
{
	TV_KEYDOWN* pTVKeyDown = (TV_KEYDOWN*)pNMHDR;
  if(pTVKeyDown->wVKey==VK_DELETE) {
    CTreeCtrl& Tree=GetTreeCtrl();
    HTREEITEM hActiveItem=Tree.GetSelectedItem();
    HTREEITEM hParentItem=Tree.GetParentItem(hActiveItem);
    do {
      if(hParentItem==hSourceFolder) {
        OnSourceDel(); break;
      }
      if(hParentItem==hIncFolder) {
        OnIncDel(); break;
      }
      if(hParentItem==hArchFolder) {
        OnArchDel(); break;
      }
    }while(FALSE);
  }

	*pResult = 0;
}


void CPrjListView::OnContainsEntrypoint() 
{
  CTreeCtrl& Tree=GetTreeCtrl();
  HTREEITEM hActiveItem=Tree.GetSelectedItem();
  PrjFile& File=pDoc->FileList.GetAt((POSITION)Tree.GetItemData(hActiveItem));
  if(!File.Flag&1) {  //Снимем признак с остальных
    POSITION Pos=pDoc->FileList.GetHeadPosition();
    while(Pos) {
      PrjFile& CurFile=pDoc->FileList.GetNext(Pos);
      if((CurFile.Folder==1)&&(CurFile.Flag&1)) CurFile.Flag^=1;
    }
  }
  File.Flag^=1;
}
