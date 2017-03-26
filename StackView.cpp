// StackView.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "StackView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CStackView

IMPLEMENT_DYNCREATE(CStackView, CScrollView)

CStackView::CStackView()
{
}

CStackView::~CStackView()
{
}


BEGIN_MESSAGE_MAP(CStackView, CScrollView)
	//{{AFX_MSG_MAP(CStackView)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CStackView drawing

void CStackView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();

	CSize sizeTotal;
	sizeTotal.cx = sizeTotal.cy = 0;
	SetScrollSizes(MM_TEXT, sizeTotal);
}

void CStackView::OnDraw(CDC* pDC)
{
	CDocument* pDoc = GetDocument();
  CRect ClRect;
  GetClientRect(&ClRect);
  pDC->PatBlt(0,0,ClRect.right,ClRect.bottom,WHITENESS);
}

/////////////////////////////////////////////////////////////////////////////
// CStackView diagnostics

#ifdef _DEBUG
void CStackView::AssertValid() const
{
	CScrollView::AssertValid();
}

void CStackView::Dump(CDumpContext& dc) const
{
	CScrollView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CStackView message handlers

void CStackView::OnStopProgram(DWORD StopCode)
{
}
