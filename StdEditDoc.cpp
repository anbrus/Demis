// StdEditDoc.cpp : implementation of the CStdEditDoc class
//

#include "stdafx.h"
#include "Demis2000.h"

#include "StdEditDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc

IMPLEMENT_DYNCREATE(CStdEditDoc, CDocument)

BEGIN_MESSAGE_MAP(CStdEditDoc, CDocument)
	//{{AFX_MSG_MAP(CStdEditDoc)
	ON_UPDATE_COMMAND_UI(ID_FILE_SAVE, OnUpdateFileSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc construction/destruction

CStdEditDoc::CStdEditDoc()
{
}

CStdEditDoc::~CStdEditDoc()
{
}

BOOL CStdEditDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc serialization

void CStdEditDoc::Serialize(CArchive& ar)
{
	// CEditView contains an edit control which handles all serialization
  if(ar.IsStoring()) {
    char Buf[65536];
    CEdit &EditCtrl=((CEditView*)m_viewList.GetHead())->GetEditCtrl();

    DWORD Length=EditCtrl.GetWindowText(Buf,sizeof(Buf)-1);
    CharToOem(Buf,Buf);
    ar.Write(Buf,Length);
  }
  if(ar.IsLoading()) {
    char Buf[65536];
    CEdit &EditCtrl=((CEditView*)m_viewList.GetHead())->GetEditCtrl();

    DWORD Length=ar.Read(Buf,sizeof(Buf)-1);
    Buf[Length]='\0';
    OemToChar(Buf,Buf);
    EditCtrl.SetWindowText(Buf);
  }
	//((CEditView*)m_viewList.GetHead())->SerializeRaw(ar);
}

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc diagnostics

#ifdef _DEBUG
void CStdEditDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CStdEditDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc commands

void CStdEditDoc::OnUpdateFileSave(CCmdUI* pCmdUI) 
{
	if(IsModified()) pCmdUI->Enable(TRUE);
  else pCmdUI->Enable(FALSE);
}
