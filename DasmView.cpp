// DasmView.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "DasmView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDasmView

IMPLEMENT_DYNCREATE(CDasmView, CScrollView)

CDasmView::CDasmView()
{
  CurInstr.Address=(theApp.pEmData->Reg.CS<<16)|theApp.pEmData->Reg.IP;
  CurInstr.LineNumber=0;

  FirstLine=CurInstr;
  CursorLine=CurInstr;
}

CDasmView::~CDasmView()
{
}


BEGIN_MESSAGE_MAP(CDasmView, CScrollView)
	//{{AFX_MSG_MAP(CDasmView)
	ON_WM_ERASEBKGND()
	ON_WM_KEYDOWN()
	ON_WM_SETFOCUS()
	ON_WM_KILLFOCUS()
	ON_WM_LBUTTONDOWN()
	ON_WM_SIZE()
	ON_WM_RBUTTONDOWN()
	ON_COMMAND(ID_NEW_ADDRESS, OnNewAddress)
	ON_WM_HELPINFO()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDasmView drawing

void CDasmView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();

  CSize sizeTotal;
	sizeTotal.cx = sizeTotal.cy = 100;
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
}

void CDasmView::OnDraw(CDC* pDC)
{
	CDocument* pDoc = GetDocument();
  CGdiObject* pOldFont;
  pOldFont=pDC->SelectObject(&m_Font);
  
  for(int y=0; y<LinesHeight; y++) {
    pDC->TextOut(0,y*16,DasmList[y].LineText);
  }
  DrawCursor(*pDC);
  pDC->SelectObject(pOldFont);
}

/////////////////////////////////////////////////////////////////////////////
// CDasmView diagnostics

#ifdef _DEBUG
void CDasmView::AssertValid() const
{
	CScrollView::AssertValid();
}

void CDasmView::Dump(CDumpContext& dc) const
{
	CScrollView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CDasmView message handlers

BOOL CDasmView::OnEraseBkgnd(CDC* pDC) 
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


void CDasmView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  //SHORT Ctrl=::GetKeyState(VK_CONTROL);
  switch(nChar) {
    case VK_DOWN :
      MoveCursorDown();
      break;
    case VK_UP   : 
      MoveCursorUp();
      break;
  }

	CScrollView::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CDasmView::OnSetFocus(CWnd* pOldWnd) 
{
	CScrollView::OnSetFocus(pOldWnd);
	
  CClientDC dc(this);
  DrawCursor(dc);
}

void CDasmView::OnKillFocus(CWnd* pNewWnd) 
{
	CScrollView::OnKillFocus(pNewWnd);
	
  CClientDC dc(this);
  RemoveCursor(dc);
}

void CDasmView::OnLButtonDown(UINT nFlags, CPoint point) 
{
  CRect ClRect;
  CClientDC dc(this);
  GetClientRect(&ClRect);
  RemoveCursor(dc);
  CursorLine.LineNumber=(point.y-ClRect.top)/16;
  CursorLine=DasmList[(point.y-ClRect.top)/16];
  DrawCursor(dc);

	CScrollView::OnLButtonDown(nFlags, point);
}

void CDasmView::ScrollUp(DWORD Count)
{
  FirstLine.Address=DasmList[1].Address;
  FirstLine.LineText=DasmList[1].LineText;
  MakeDasmList();
  CClientDC dc(this);
  OnDraw(&dc);
}

void CDasmView::OnStep()
{
  Update();
}

void CDasmView::ScrollDown(DWORD Count)
{
  FirstLine.Address--;
  CursorLine=FirstLine;
  MakeDasmList();
  CClientDC dc(this);
  OnDraw(&dc);
}

void CDasmView::OnStopProgram(DWORD StopCode)
{
  OnStep();
  CString ErrorText;
  switch(StopCode) {
  case STOP_BP_EXEC :
    {
      DWORD Addr=theApp.pEmData->Reg.CS; 
      Addr<<=4; Addr+=theApp.pEmData->Reg.IP;
      ::ToggleBreakpoint(BP_EXEC,Addr,1);
      SetFocus();
      break;
    }
  case STOP_BP_INPUT :
  case STOP_BP_OUTPUT :
  case STOP_BP_MEM_READ :
  case STOP_BP_MEM_WRITE : SetFocus(); break;
  case NO_ERRORS : break;
  default :
    theApp.GetErrorText(StopCode,ErrorText);
    MessageBox(ErrorText,"Ошибка",MB_OK|MB_ICONSTOP);
  }
}

void CDasmView::OnRunTo() 
{
  //CDebugFrame* pDF;
  DWORD Addr;
  Addr=HIWORD(CursorLine.Address)<<4;
  Addr+=LOWORD(CursorLine.Address);
  ::ToggleBreakpoint(BP_EXEC,Addr,1);
  //pDF=(CDebugFrame*)GetParent()->GetParent()->
  //  GetParent()->GetParent();
  theApp.RunProg();
}

void CDasmView::DrawCursor(CDC& dc)
{
  if(GetFocus()!=this) { RemoveCursor(dc); return; }

  CBrush CursorBrush(RGB(0,0,255));
  CRect CursorRect;

  GetClientRect(CursorRect);
  CursorRect.top=CursorLine.LineNumber*16;
  CursorRect.bottom=CursorRect.top+16;
  dc.FillRect(CursorRect,&CursorBrush);

  CGdiObject* pOldFont=dc.SelectObject(&m_Font);
  dc.SetTextColor(RGB(255,255,255));
  dc.SetBkColor(RGB(0,0,255));
  dc.TextOut(0,CursorRect.top,DasmList[CursorLine.LineNumber].LineText);
  dc.SelectObject(pOldFont);
}

void CDasmView::RemoveCursor(CDC& dc)
{
  CBrush BkBrush(RGB(255,255,255));
  CRect CursorRect;

  GetClientRect(CursorRect);
  CursorRect.top=CursorLine.LineNumber*16;
  CursorRect.bottom=CursorRect.top+16;
  dc.FillRect(CursorRect,&BkBrush);

  CGdiObject* pOldFont=dc.SelectObject(&m_Font);
  dc.SetTextColor(RGB(0,0,0));
  dc.SetBkColor(RGB(255,255,255));
  dc.TextOut(0,CursorRect.top,DasmList[CursorLine.LineNumber].LineText);
  dc.SelectObject(pOldFont);
}

int CDasmView::MakeDasmLine(struct _LineInfo& Line)
{
  char InstrText[128]="BugBugBug";
  CString NewLine;

  DWORD Seg=(WORD)(Line.Address>>16),
        Offs=(WORD)(Line.Address&0x0000FFFF);
  int InstrLen=::DasmInstr(Seg,Offs,theApp.pEmData,InstrText);
  NewLine.Format("%04X:%04X ",Seg,Offs);

  CString Dump;
  Seg=(WORD)(Line.Address>>16);
  Offs=(WORD)(Line.Address&0x0000FFFF);
  for(int i=0; i<InstrLen; i++) {
    BYTE* pInstr=(BYTE*)VirtToReal((WORD)Seg,(WORD)Offs);
    Dump.Format("%02X",*pInstr);
    NewLine+=Dump;
    Offs++;
    if(Offs>0xFFFF) { Offs&=0xFFFF; Seg+=0x1000; }
  }

  Dump.Format("%*c",2*(7-InstrLen),' ');
  NewLine+=Dump;
  NewLine+=InstrText;
  NewLine+="                                                ";
  if(Line.LineText.GetLength()>9) Line.LineText.SetAt(9,' ');
  if(Line.LineText!=NewLine) ListChanged=TRUE;
  Line.LineText=NewLine;

  if(Line.Address==((((DWORD)theApp.pEmData->Reg.CS)<<16)|theApp.pEmData->Reg.IP)) {
    Line.LineText.SetAt(9,'>');
    CurInstr=Line;
  }

  return InstrLen;
}

void CDasmView::MakeDasmList()
{
  DWORD Seg=FirstLine.Address>>16;
  DWORD Offs=FirstLine.Address&0xFFFF;
  
  CurInstr.LineNumber=-1;
  ListChanged=FALSE;
  for(int n=0; n<LinesHeight; n++) {
    DasmList[n].Address=(Seg<<16)|Offs;
    DasmList[n].LineNumber=n;
    Offs+=MakeDasmLine(DasmList[n]);
    if(Offs>0xFFFF) { Offs&=0xFFFF; Seg+=0x1000; }
  }
}

void CDasmView::OnSize(UINT nType, int cx, int cy) 
{
	CScrollView::OnSize(nType, cx, cy);

  LinesHeight=1+cy/16;
  MakeDasmList();
}

void CDasmView::OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint) 
{
  Update();
}

void CDasmView::OnRButtonDown(UINT nFlags, CPoint point) 
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

void CDasmView::OnNewAddress() 
{
  CDumpCfg Dlg;
  Dlg.Seg=FirstLine.Address>>16;
  Dlg.Offs=FirstLine.Address&0x0000FFFF;
  if(Dlg.DoModal()==IDOK) {
    FirstLine.Address=(Dlg.Seg<<16)|Dlg.Offs;
    MakeDasmList();
    CursorLine=FirstLine;
    RedrawWindow();
  }
}

void CDasmView::Update()
{
  MakeDasmList();
  if(CurInstr.LineNumber==-1) {
    FirstLine.Address=((((DWORD)theApp.pEmData->Reg.CS)<<16)
      |theApp.pEmData->Reg.IP);
    MakeDasmList();
    CursorLine=CurInstr;
    RedrawWindow();
  }else {
    if(ListChanged) {
      CursorLine=CurInstr;
      RedrawWindow();
    }else {
      CClientDC dc(this);
      CBrush BkBrush(RGB(255,255,255));
      RemoveCursor(dc);

      dc.FillRect(CRect(8*9,0,8*10,LinesHeight*16),&BkBrush);

      CursorLine=CurInstr;
      DrawCursor(dc);
    }
  }
}

BOOL CDasmView::OnHelpInfo(HELPINFO* pHelpInfo) 
{
	theApp.WinHelp(0x20000+IDR_DASMVIEW);
  return TRUE;
}


void CDasmView::OnStepOver()
{
  //CString COP=CursorLine.LineText.Mid(24,4);
  if(CursorLine.LineText.Mid(24,4)=="CALL") {
    MoveCursorDown();
    pDebugFrame->SendMessage(WM_COMMAND,ID_RUNTO,0);
  }else {
    pDebugFrame->SendMessage(WM_COMMAND,ID_STEPINTO,0);
  }
}

void CDasmView::MoveCursorDown()
{
  if(CursorLine.LineNumber<LinesHeight-2) {
    CClientDC dc(this);
    RemoveCursor(dc);
    CursorLine=DasmList[CursorLine.LineNumber+1];
    DrawCursor(dc);
  }else {
    ScrollUp(1);
  }
}

void CDasmView::MoveCursorUp()
{
  if(CursorLine.LineNumber>0) {
    CClientDC dc(this);
    RemoveCursor(dc);
    CursorLine=DasmList[CursorLine.LineNumber-1];
    DrawCursor(dc);
  }else {
    ScrollDown(1);
  }
}
