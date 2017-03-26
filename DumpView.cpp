// DumpView.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "DumpView.h"
#include "definitions.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDumpView

IMPLEMENT_DYNCREATE(CDumpView, CScrollView)

CDumpView::CDumpView()
{
}

CDumpView::~CDumpView()
{
}


BEGIN_MESSAGE_MAP(CDumpView, CScrollView)
	//{{AFX_MSG_MAP(CDumpView)
	ON_WM_ERASEBKGND()
	ON_WM_SETFOCUS()
	ON_WM_KILLFOCUS()
	ON_WM_KEYDOWN()
	ON_WM_SIZE()
	ON_WM_RBUTTONDOWN()
	ON_COMMAND(ID_NEW_ADDRESS, OnNewAddress)
	ON_WM_LBUTTONDOWN()
	ON_WM_HELPINFO()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDumpView drawing

void CDumpView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();

	CSize sizeTotal;
	sizeTotal.cx = sizeTotal.cy = 0;
	SetScrollSizes(MM_TEXT, sizeTotal);
  SetClassLong(m_hWnd,GCL_HBRBACKGROUND,NULL);
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
  StartSeg=theApp.pEmData->Reg.DS; StartOffs=0;
  CursorPos.x=10; CursorPos.y=0;
  CharSize.cx=8; CharSize.cy=16;
  MakeDumpList();
  RedrawWindow();
}

void CDumpView::OnDraw(CDC* pDC)
{
	CDocument* pDoc = GetDocument();
  CGdiObject* pOldFont=pDC->SelectObject(&m_Font);

  for(int y=0; y<LinesHeight; y++)
    pDC->TextOut(0,y*16,DumpList[y].LineText);

  pDC->SelectObject(pOldFont);
}

/////////////////////////////////////////////////////////////////////////////
// CDumpView diagnostics

#ifdef _DEBUG
void CDumpView::AssertValid() const
{
	CScrollView::AssertValid();
}

void CDumpView::Dump(CDumpContext& dc) const
{
	CScrollView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CDumpView message handlers

BOOL CDumpView::OnEraseBkgnd(CDC* pDC) 
{
	CBrush BkBrush(RGB(255,255,255));
  CGdiObject* pOldBrush;
  pOldBrush=pDC->SelectObject(&BkBrush);
  CRect ClRect;
  GetClientRect(&ClRect);
  pDC->PatBlt(ClRect.left,ClRect.top,ClRect.Width(),ClRect.Height(),PATCOPY);
  pDC->SelectObject(pOldBrush);
	
	return CScrollView::OnEraseBkgnd(pDC);
}


void CDumpView::OnStep()
{
  Update();
}
/////////////////////////////////////////////////////////////////////////////
// CDumpCfg dialog


CDumpCfg::CDumpCfg(CWnd* pParent /*=NULL*/)
	: CDialog(CDumpCfg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDumpCfg)
	m_sAddress = _T("");
	//}}AFX_DATA_INIT
}


void CDumpCfg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);

  if(!pDX->m_bSaveAndValidate) {
    m_sAddress.Format("%04X:%04X",Seg,Offs);
  }

	//{{AFX_DATA_MAP(CDumpCfg)
	DDX_Text(pDX, IDC_ADDRESS, m_sAddress);
	DDV_MaxChars(pDX, m_sAddress, 9);
	//}}AFX_DATA_MAP

  if(pDX->m_bSaveAndValidate) {
    pDX->PrepareEditCtrl(IDC_ADDRESS);
    char c;
    if(sscanf((LPCTSTR)m_sAddress,"%X%c%X",&Seg,&c,&Offs)!=3) {
      pDX->Fail(); return;
    }
    if(c!=':') pDX->Fail();
  }
}


BEGIN_MESSAGE_MAP(CDumpCfg, CDialog)
	//{{AFX_MSG_MAP(CDumpCfg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDumpCfg message handlers

void CDumpView::OnSetFocus(CWnd* pOldWnd) 
{
	CScrollView::OnSetFocus(pOldWnd);
	
  CreateSolidCaret(2,14);
  CPoint CaretPos;
  CaretPos.x=CursorPos.x*CharSize.cx;
  CaretPos.y=CursorPos.y*CharSize.cy+1;
  SetCaretPos(CaretPos);
  ShowCaret();
}

void CDumpView::OnKillFocus(CWnd* pNewWnd) 
{
	CScrollView::OnKillFocus(pNewWnd);
	
	DestroyCaret();
}

void CDumpView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  char Char;
  Char=(char)MapVirtualKey(nChar,2);
  if((Char>='0')&&(Char<='9')||(Char>='A')&&(Char<='F')) {
    ChangeVal(Char);
    CursorRight();
  }else {
    switch(nChar) {
      case VK_DOWN  : CursorDown(); break;
      case VK_UP    : CursorUp(); break;
      case VK_LEFT  : CursorLeft(); break;
      case VK_RIGHT : CursorRight(); break;
    }
  }
  CPoint CaretPos;
  CaretPos.x=CursorPos.x*CharSize.cx;
  CaretPos.y=CursorPos.y*CharSize.cy+1;
  SetCaretPos(CaretPos);

	CScrollView::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CDumpView::Scroll(int Count)
{
  StartOffs+=16*Count;
  MakeDumpList();
  RedrawWindow();
}

void CDumpView::CursorLeft()
{
  do {
    if(CursorPos.x==10) { 
      CursorPos.x=56;
      CursorUp();
    }else CursorPos.x--;
  }while((CursorPos.x-9)%3==0);
}

void CDumpView::CursorRight()
{
  do{
    if(CursorPos.x==57) { 
      CursorPos.x=10;
      CursorDown();
    }else CursorPos.x++;
  }while((CursorPos.x-9)%3==0);
}

void CDumpView::CursorDown()
{
  if(CursorPos.y>=LinesHeight-2) Scroll(1);
  else CursorPos.y++;
}

void CDumpView::CursorUp()
{
  if(CursorPos.y==0) Scroll(-1);
  else CursorPos.y--;
}

void CDumpView::ChangeVal(char Char)
{
  WORD Offs=(WORD)(StartOffs+CursorPos.y*16+(CursorPos.x-10)/3);
  BYTE* pOldVal=(BYTE*)::VirtToReal(StartSeg,Offs);
  BYTE NewVal;
  NewVal=Char-'0'; if(NewVal>9) NewVal-='A'-'0'-10;
  if((CursorPos.x-10)%3==0) {
    NewVal<<=4;
    *pOldVal&=0x0F;
  }else {
    *pOldVal&=0xF0;
  }
  *pOldVal|=NewVal;
  MakeDumpList();
  Invalidate(FALSE);
  pDebugFrame->UpdateAllViews();
}

void CDumpView::OnStopProgram(DWORD StopCode)
{
  MakeDumpList();
  RedrawWindow();
}

BOOL CDumpView::MakeDumpList()
{
  BOOL Changed=FALSE;
  WORD CurSeg=StartSeg,CurOffs=StartOffs;
  BYTE NewVal;
  CString Temp;

  for(int Line=0; Line<LinesHeight; Line++) {
    DumpList[Line].LineText.Format("%04X:%04X",CurSeg,CurOffs);
    for(int Byte=0; Byte<16; Byte++) {
      NewVal=*(BYTE*)::VirtToReal(CurSeg,CurOffs);
      if(NewVal!=DumpList[Line].Data[Byte]) {
        Changed=TRUE;
        DumpList[Line].Data[Byte]=NewVal;
      }
      Temp.Format(" %02X",NewVal);
      DumpList[Line].LineText+=Temp;
      CurOffs++;
    }
  }

  return Changed;
}

void CDumpView::OnSize(UINT nType, int cx, int cy) 
{
	CScrollView::OnSize(nType, cx, cy);
	
	LinesHeight=cy/16+1;
  MakeDumpList();
}

void CDumpView::OnRButtonDown(UINT nFlags, CPoint point) 
{
  CRect WndRect;
	CMenu DebugMenu;
  GetWindowRect(&WndRect);
  WndRect+=point;
  DebugMenu.LoadMenu(IDR_CONTEXT_DEBUG);
  DebugMenu.GetSubMenu(0)->TrackPopupMenu(TPM_LEFTALIGN,
    WndRect.left,WndRect.top,this);
	
	CScrollView::OnRButtonDown(nFlags, point);
}

void CDumpView::OnNewAddress() 
{
	CDumpCfg CfgDlg(this);
  CfgDlg.Seg=StartSeg;
  CfgDlg.Offs=StartOffs;
  CfgDlg.m_sAddress.Format("%04X:%04X",StartSeg,StartOffs);
  if(CfgDlg.DoModal()==IDOK) {
    StartSeg=(WORD)CfgDlg.Seg; StartOffs=(WORD)CfgDlg.Offs;
  }
  MakeDumpList();
  RedrawWindow();
}

void CDumpView::OnLButtonDown(UINT nFlags, CPoint point) 
{
	CursorPos.x=point.x/CharSize.cx;
  if((CursorPos.x-10)%3==2) CursorPos.x--;
  if(CursorPos.x<10) CursorPos.x=10;
  if(CursorPos.x>56) CursorPos.x=56;

	CursorPos.y=point.y/CharSize.cy;
  if(CursorPos.y>LinesHeight-2) CursorPos.y=LinesHeight-2;

  CPoint CaretPos;
  CaretPos.x=CursorPos.x*CharSize.cx;
  CaretPos.y=CursorPos.y*CharSize.cy+1;
  SetCaretPos(CaretPos);

	CScrollView::OnLButtonDown(nFlags, point);
}

void CDumpView::Update()
{
  if(MakeDumpList()) RedrawWindow();
}

BOOL CDumpView::OnHelpInfo(HELPINFO* pHelpInfo) 
{
  theApp.WinHelp(0x20000+IDR_DUMPVIEW);
  return TRUE;
}
