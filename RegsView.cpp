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
	pEmData = ((CDemis2000App*)AfxGetApp())->pEmData;
	pHData = &((CDemis2000App*)AfxGetApp())->Data;
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
	CGdiObject* pOldFont = pDC->SelectObject(&m_Font);

	for (int y = 0; y < 13; y++) {
		if (RegEdit[y].Changed) pDC->SetTextColor(RGB(255, 0, 0));
		else pDC->SetTextColor(RGB(0, 0, 0));
		pDC->TextOut(2, y * 16, RegEdit[y].RegName + '=');
	}

	for (int y = 0; y < 9; y++) {
		if (Flag[y].Changed) pDC->SetTextColor(RGB(255, 0, 0));
		else pDC->SetTextColor(RGB(0, 0, 0));
		pDC->TextOut(68, y * 16, Flag[y].FlagName);
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

	LOGFONT lf = {
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

	CRect rect;
	rect = CRect(26, 0, 62, 16);
	RegEdit[0].Create(rect, this, &pEmData->Reg.AX);
	rect = CRect(26, 16, 62, 32);
	RegEdit[1].Create(rect, this, &pEmData->Reg.BX);
	rect = CRect(26, 32, 62, 48);
	RegEdit[2].Create(rect, this, &pEmData->Reg.CX);
	rect = CRect(26, 48, 62, 64);
	RegEdit[3].Create(rect, this, &pEmData->Reg.DX);
	rect = CRect(26, 64, 62, 80);
	RegEdit[4].Create(rect, this, &pEmData->Reg.SI);
	rect = CRect(26, 80, 62, 96);
	RegEdit[5].Create(rect, this, &pEmData->Reg.DI);
	rect = CRect(26, 96, 62, 112);
	RegEdit[6].Create(rect, this, &pEmData->Reg.BP);
	rect = CRect(26, 112, 62, 128);
	RegEdit[7].Create(rect, this, &pEmData->Reg.SP);
	rect = CRect(26, 128, 62, 144);
	RegEdit[8].Create(rect, this, &pEmData->Reg.IP);
	rect = CRect(26, 144, 62, 160);
	RegEdit[9].Create(rect, this, &pEmData->Reg.DS);
	rect = CRect(26, 160, 62, 176);
	RegEdit[10].Create(rect, this, &pEmData->Reg.ES);
	rect = CRect(26, 176, 62, 192);
	RegEdit[11].Create(rect, this, &pEmData->Reg.SS);
	rect = CRect(26, 192, 62, 208);
	RegEdit[12].Create(rect, this, &pEmData->Reg.CS);

	rect = CRect(87, 2, 100, 14);
	Flag[0].Create(rect, this, 0x0001, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 18, 100, 30);
	Flag[1].Create(rect, this, 0x0004, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 34, 100, 46);
	Flag[2].Create(rect, this, 0x0010, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 50, 100, 62);
	Flag[3].Create(rect, this, 0x0040, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 66, 100, 78);
	Flag[4].Create(rect, this, 0x0080, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 82, 100, 94);
	Flag[5].Create(rect, this, 0x0100, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 98, 100, 110);
	Flag[6].Create(rect, this, 0x0200, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 114, 100, 126);
	Flag[7].Create(rect, this, 0x0400, (WORD*)&pEmData->Reg.Flag);
	rect = CRect(87, 130, 100, 142);
	Flag[8].Create(rect, this, 0x0800, (WORD*)&pEmData->Reg.Flag);


	RegEdit[0].RegName = "AX"; RegEdit[1].RegName = "BX";
	RegEdit[2].RegName = "CX"; RegEdit[3].RegName = "DX";
	RegEdit[4].RegName = "SI"; RegEdit[5].RegName = "DI";
	RegEdit[6].RegName = "BP"; RegEdit[7].RegName = "SP";
	RegEdit[8].RegName = "IP"; RegEdit[9].RegName = "DS";
	RegEdit[10].RegName = "ES"; RegEdit[11].RegName = "SS";
	RegEdit[12].RegName = "CS";

	Flag[0].FlagName = "CF"; Flag[1].FlagName = "PF"; Flag[2].FlagName = "AF";
	Flag[3].FlagName = "ZF"; Flag[4].FlagName = "SF"; Flag[5].FlagName = "TF";
	Flag[6].FlagName = "IF"; Flag[7].FlagName = "DF"; Flag[8].FlagName = "OF";

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
	CBrush BkBrush(RGB(255, 255, 255));
	CGdiObject* pOldBrush;
	pOldBrush = pDC->SelectObject(&BkBrush);
	CRect ClRect;
	GetClientRect(&ClRect);
	pDC->PatBlt(ClRect.left, ClRect.top, ClRect.Width(), ClRect.Height(), PATCOPY);
	pDC->SelectObject(pOldBrush);

	return CView::OnEraseBkgnd(pDC);
}

void CRegsView::Update()
{
	BOOL Changed = FALSE;
	for (int n = 0; n < 13; n++) {
		RegEdit[n].Update();
		if (RegEdit[n].Changed) Changed = TRUE;
	}
	for (int n = 0; n < 9; n++) {
		Flag[n].Update();
		if (Flag[n].Changed) Changed = TRUE;
	}
	if (Changed) {
		CClientDC dc(this);
		OnDraw(&dc);
	}
}

BOOL CRegsView::OnHelpInfo(HELPINFO* pHelpInfo)
{
	theApp.WinHelp(0x20000 + IDR_REGSVIEW);
	return TRUE;
}
