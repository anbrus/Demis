// StdEditView.cpp : implementation of the CStdEditView class
//

#include "stdafx.h"
#include "Demis2000.h"

#include "StdEditDoc.h"
#include "StdEditView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CStdEditView

IMPLEMENT_DYNCREATE(CStdEditView, CEditView)

BEGIN_MESSAGE_MAP(CStdEditView, CEditView)
	//{{AFX_MSG_MAP(CStdEditView)
	ON_WM_CHAR()
	ON_WM_KEYDOWN()
	ON_WM_LBUTTONDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CStdEditView construction/destruction

CStdEditView::CStdEditView()
{
  Row=1; Col=1;

  //CMDIFrameWnd* pFrame=(CMDIFrameWnd*)(AfxGetApp()->m_pMainWnd);
  //CMenu* pFrameMenu=pFrame->GetMenu();
  //EditMenu.LoadMenu(IDR_ASSMTYPE_ADD);
  //CString MenuName;
  //EditMenu.GetMenuString(0,MenuName,MF_BYPOSITION);
  //pFrameMenu->InsertMenu(1,MF_BYPOSITION|MF_POPUP,(UINT)EditMenu.
  //  GetSubMenu(0)->m_hMenu,MenuName);
  //pFrame->DrawMenuBar();
}

CStdEditView::~CStdEditView()
{
  CMDIFrameWnd* pFrame=(CMDIFrameWnd*)(AfxGetApp()->m_pMainWnd);
  CMenu* pFrameMenu=pFrame->GetMenu();
  pFrameMenu->RemoveMenu(1,MF_BYPOSITION);
  pFrame->DrawMenuBar();
  UpdateRowColInd(0,0);
}

BOOL CStdEditView::PreCreateWindow(CREATESTRUCT& cs)
{
	BOOL bPreCreated = CEditView::PreCreateWindow(cs);

	return bPreCreated;
}

/////////////////////////////////////////////////////////////////////////////
// CStdEditView drawing

void CStdEditView::OnDraw(CDC* pDC)
{
}

/////////////////////////////////////////////////////////////////////////////
// CStdEditView diagnostics

#ifdef _DEBUG
void CStdEditView::AssertValid() const
{
	CEditView::AssertValid();
}

void CStdEditView::Dump(CDumpContext& dc) const
{
	CEditView::Dump(dc);
}

CStdEditDoc* CStdEditView::GetDocument() // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CStdEditDoc)));
	return (CStdEditDoc*)m_pDocument;
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CStdEditView message handlers

void CStdEditView::OnInitialUpdate() 
{
	CEditView::OnInitialUpdate();

  pDoc=GetDocument();
  pDoc->pView=this;
  LOGFONT LogFont;
  HDC hDC=::GetDC(NULL);
  LogFont.lfHeight=-MulDiv(10,GetDeviceCaps(hDC,LOGPIXELSY),72);
  ::ReleaseDC(NULL,hDC);
  LogFont.lfWidth=0;
  LogFont.lfEscapement=0;
  LogFont.lfOrientation=0;
  LogFont.lfWeight=FW_NORMAL;
  LogFont.lfItalic=FALSE;
  LogFont.lfUnderline=FALSE;
  LogFont.lfStrikeOut=FALSE;
  LogFont.lfCharSet=RUSSIAN_CHARSET;
  LogFont.lfOutPrecision=OUT_DEFAULT_PRECIS;
  LogFont.lfClipPrecision=CLIP_DEFAULT_PRECIS;
  LogFont.lfQuality=DEFAULT_QUALITY;
  LogFont.lfPitchAndFamily=FIXED_PITCH;
  strcpy(LogFont.lfFaceName,"Courier New Cyr");
  Font.CreateFontIndirect(&LogFont);
  Font.GetLogFont(&LogFont);
  SetFont(&Font);
  SetFocus();
  UpdateRowColInd(1,1);
}

void CStdEditView::OnChar(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  CString Char=(char)nChar;
  if(nChar==9) {
    CEdit &Edit=GetEditCtrl();
    int Start,End,Add=0;
    Edit.GetSel(Start,End);
    Row=Edit.LineFromChar()+1;
    Col=End-Edit.LineIndex()+1;

    do{
      if(Col<12) { Add=12-Col; break; }
      if((Col>=12)&&(Col<18)) { Add=18-Col; break; }
      if((Col>=18)&&(Col<30)) { Add=30-Col; break; }
      Add=4;
    }while(FALSE);

    for(int n=0; n<Add; n++)
      CEditView::DefWindowProc(WM_CHAR,' ',nRepCnt|(nFlags<<16));
    Col+=Add;
    UpdateRowColInd(Row,Col);
    return;
  }
  if(nChar==13) {
    CEditView::DefWindowProc(WM_CHAR,(BYTE)Char[0],nRepCnt|(nFlags<<16));
    CEdit &Edit=GetEditCtrl();
    int CurChar=Edit.LineIndex();
    if(CurChar>0) {
      char PrevLine[128];
      Edit.GetLine(Edit.LineFromChar(CurChar-1),PrevLine,sizeof(PrevLine)-3);
      for(int n=0; n<(int)strlen(PrevLine); n++) {
        if(PrevLine[n]!=' ') { PrevLine[n]=0; break; }
      }
      Edit.SetSel(CurChar,CurChar);
      Edit.ReplaceSel(PrevLine,TRUE);
    }
    UpdateRowColInd(-1,-1);
    return;
  }
  CEditView::DefWindowProc(WM_CHAR,(BYTE)Char[0],nRepCnt|(nFlags<<16));

  UpdateRowColInd(-1,-1);
}

void CStdEditView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
	CEditView::OnKeyDown(nChar, nRepCnt, nFlags);

  UpdateRowColInd(-1,-1);
}

void CStdEditView::OnLButtonDown(UINT nFlags, CPoint point) 
{
	CEditView::OnLButtonDown(nFlags, point);
  CEdit &Edit=GetEditCtrl();
  int Start,End;
  Edit.GetSel(Start,End);
  Row=Edit.LineFromChar()+1;
  Col=End-Edit.LineIndex()+1;
	UpdateRowColInd(Row,Col);
}

BOOL CStdEditView::Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID, CCreateContext* pContext) 
{
	BOOL Status=CWnd::Create(lpszClassName, lpszWindowName, dwStyle, rect, pParentWnd, nID, pContext);
  if(Status) {
    m_StatusBar.Create(GetParent());
    UINT Ind[] =
    {
	    ID_SEPARATOR,           // status line indicator
      ID_ROWCOL,
	    ID_INDICATOR_CAPS,
	    ID_INDICATOR_NUM,
	    ID_INDICATOR_SCRL,
    };
    m_StatusBar.SetIndicators(Ind,5);
    m_StatusBar.SetPaneInfo(1,Ind[1],SBPS_NORMAL,64);
    m_StatusBar.SetPaneStyle(0,SBPS_STRETCH|SBPS_NORMAL);
	GetEditCtrl().SetLimitText(1024 * 1024);
  }
  return Status;
}

void CStdEditView::UpdateRowColInd(int Row, int Col)
{
  if(!m_StatusBar.m_hWnd) return;
  if(!Row||!Col) { m_StatusBar.SetPaneText(1,""); return; }

  if((Row<0)||(Col<0)) {
    CEdit &Edit=GetEditCtrl();
    int Start,End;
    Edit.GetSel(Start,End);
    Row=Edit.LineFromChar()+1;
    Col=End-Edit.LineIndex()+1;
  }

  CString Text;
  Text.Format("%d:%d",Row,Col);
  m_StatusBar.SetPaneText(1,Text);
}
