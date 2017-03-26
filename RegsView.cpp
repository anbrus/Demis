// RegsView.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "RegsView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRegsView

IMPLEMENT_DYNCREATE(CRegsView, CView)

CRegsView::CRegsView()
{
  pEmData=((CDemis2000App*)AfxGetApp())->pEmData;
  pHData=&((CDemis2000App*)AfxGetApp())->Data;
}

CRegsView::~CRegsView()
{
}


BEGIN_MESSAGE_MAP(CRegsView, CView)
	//{{AFX_MSG_MAP(CRegsView)
	ON_WM_ERASEBKGND()
	ON_WM_HELPINFO()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRegsView drawing

void CRegsView::OnDraw(CDC* pDC)
{
	CDocument* pDoc = GetDocument();
  CGdiObject* pOldFont=pDC->SelectObject(&m_Font);

  for(int y=0; y<13; y++) {
    if(RegEdit[y].Changed) pDC->SetTextColor(RGB(255,0,0));
    else pDC->SetTextColor(RGB(0,0,0));
    pDC->TextOut(0,y*16,RegEdit[y].RegName+'=');
  }

  for(int y=0; y<9; y++) {
    if(Flag[y].Changed) pDC->SetTextColor(RGB(255,0,0));
    else pDC->SetTextColor(RGB(0,0,0));
    pDC->TextOut(64,y*16,Flag[y].FlagName);
  }

  pDC->SelectObject(pOldFont);
}

/////////////////////////////////////////////////////////////////////////////
// CRegsView diagnostics

#ifdef _DEBUG
void CRegsView::AssertValid() const
{
	CView::AssertValid();
}

void CRegsView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CRegsView message handlers

void CRegsView::OnInitialUpdate() 
{
  SetWindowContextHelpId(0x666);

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

  RegEdit[0].Create(CRect(24,0,56,16),this,&pEmData->Reg.AX);
  RegEdit[1].Create(CRect(24,16,56,32),this,&pEmData->Reg.BX);
  RegEdit[2].Create(CRect(24,32,56,48),this,&pEmData->Reg.CX);
  RegEdit[3].Create(CRect(24,48,56,64),this,&pEmData->Reg.DX);
  RegEdit[4].Create(CRect(24,64,56,80),this,&pEmData->Reg.SI);
  RegEdit[5].Create(CRect(24,80,56,96),this,&pEmData->Reg.DI);
  RegEdit[6].Create(CRect(24,96,56,112),this,&pEmData->Reg.BP);
  RegEdit[7].Create(CRect(24,112,56,128),this,&pEmData->Reg.SP);
  RegEdit[8].Create(CRect(24,128,56,144),this,&pEmData->Reg.IP);
  RegEdit[9].Create(CRect(24,144,56,160),this,&pEmData->Reg.DS);
  RegEdit[10].Create(CRect(24,160,56,176),this,&pEmData->Reg.ES);
  RegEdit[11].Create(CRect(24,176,56,192),this,&pEmData->Reg.SS);
  RegEdit[12].Create(CRect(24,192,56,208),this,&pEmData->Reg.CS);

  Flag[0].Create(CRect(81,2,94,14),this,0x0001,(WORD*)&pEmData->Reg.Flag);
  Flag[1].Create(CRect(81,18,94,30),this,0x0004,(WORD*)&pEmData->Reg.Flag);
  Flag[2].Create(CRect(81,34,94,46),this,0x0010,(WORD*)&pEmData->Reg.Flag);
  Flag[3].Create(CRect(81,50,94,62),this,0x0040,(WORD*)&pEmData->Reg.Flag);
  Flag[4].Create(CRect(81,66,94,78),this,0x0080,(WORD*)&pEmData->Reg.Flag);
  Flag[5].Create(CRect(81,82,94,94),this,0x0100,(WORD*)&pEmData->Reg.Flag);
  Flag[6].Create(CRect(81,98,94,110),this,0x0200,(WORD*)&pEmData->Reg.Flag);
  Flag[7].Create(CRect(81,114,94,126),this,0x0400,(WORD*)&pEmData->Reg.Flag);
  Flag[8].Create(CRect(81,130,94,142),this,0x0800,(WORD*)&pEmData->Reg.Flag);


  RegEdit[0].RegName="AX"; RegEdit[1].RegName="BX";
  RegEdit[2].RegName="CX"; RegEdit[3].RegName="DX";
  RegEdit[4].RegName="SI"; RegEdit[5].RegName="DI";
  RegEdit[6].RegName="BP"; RegEdit[7].RegName="SP";
  RegEdit[8].RegName="IP"; RegEdit[9].RegName="DS";
  RegEdit[10].RegName="ES"; RegEdit[11].RegName="SS";
  RegEdit[12].RegName="CS";

  Flag[0].FlagName="CF"; Flag[1].FlagName="PF"; Flag[2].FlagName="AF";
  Flag[3].FlagName="ZF"; Flag[4].FlagName="SF"; Flag[5].FlagName="TF";
  Flag[6].FlagName="IF"; Flag[7].FlagName="DF"; Flag[8].FlagName="OF";

  Update();
	CView::OnInitialUpdate();
}

void CRegsView::OnStep()
{
  Update();
}

void CRegsView::OnStopProgram(DWORD StopCode)
{
  OnStep();
}

BOOL CRegsView::OnEraseBkgnd(CDC* pDC) 
{
	CBrush BkBrush(RGB(255,255,255));
  CGdiObject *pOldBrush;
  pOldBrush=pDC->SelectObject(&BkBrush);
  CRect ClRect;
  GetClientRect(&ClRect);
  pDC->PatBlt(ClRect.left,ClRect.top,ClRect.Width(),ClRect.Height(),PATCOPY);
  pDC->SelectObject(pOldBrush);
	
	return CView::OnEraseBkgnd(pDC);
}

void CRegsView::Update()
{
  BOOL Changed=FALSE;
  for(int n=0; n<13; n++) { 
    RegEdit[n].Update();
    if(RegEdit[n].Changed) Changed=TRUE;
  }
  for(int n=0; n<9; n++) { 
    Flag[n].Update();
    if(Flag[n].Changed) Changed=TRUE;
  }
  if(Changed) {
    CClientDC dc(this);
    OnDraw(&dc);
  }
}

BOOL CRegsView::OnHelpInfo(HELPINFO* pHelpInfo) 
{
	theApp.WinHelp(0x20000+IDR_REGSVIEW);
  return TRUE;
}
