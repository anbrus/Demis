// ElementWnd.cpp : implementation file
//

#include "stdafx.h"
#include "stdelem.h"
#include "ElementWnd.h"
#include "Element.h"
#include "..\ElemInterface.h"
#include "ElemInterf.h"
#include "..\definitions.h"
#include "math.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CElementWnd

CElementWnd::CElementWnd(CElement* pElement)
{
  this->pElement=pElement;
  Angle=0;
}

CElementWnd::~CElementWnd()
{
  if(m_hWnd) DestroyWindow();
}


BEGIN_MESSAGE_MAP(CElementWnd, CWnd)
	//{{AFX_MSG_MAP(CElementWnd)
	ON_WM_PAINT()
	ON_WM_CONTEXTMENU()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_MOUSEMOVE()
  ON_MESSAGE(WM_PRINT, OnPrint)
	ON_WM_ERASEBKGND()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CElementWnd message handlers

void CElementWnd::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	Draw(&dc);
}

void CElementWnd::OnContextMenu(CWnd* pWnd, CPoint point) 
{
  if(!pElement->EditMode) return;
  CRect WndRect;
	CMenu DebugMenu;
  pElement->PopupMenu.GetSubMenu(0)->TrackPopupMenu(TPM_LEFTALIGN,point.x,
    point.y,this);
}

void CElementWnd::OnLButtonDown(UINT nFlags, CPoint point) 
{
  BringWindowToTop();
  if(!pElement->EditMode) return;
  GetParent()->SendMessage(WMU_ELEMENT_LBUTTONDOWN,nFlags,
    (LPARAM)pElement->pInterface->hElement);

	CWnd::OnLButtonDown(nFlags, point);
}

void CElementWnd::OnLButtonUp(UINT nFlags, CPoint point) 
{
	if(!pElement->EditMode) return;
  GetParent()->SendMessage(WMU_ELEMENT_LBUTTONUP,nFlags,
    (LPARAM)pElement->pInterface->hElement);
	
	CWnd::OnLButtonUp(nFlags, point);
}

void CElementWnd::OnMouseMove(UINT nFlags, CPoint point) 
{
	if(!pElement->EditMode) return;
  GetParent()->SendMessage(WMU_ELEMENT_MOUSEMOVE,nFlags,
    (LPARAM)pElement->pInterface->hElement);
	
	CWnd::OnMouseMove(nFlags, point);
}

LRESULT CElementWnd::OnPrint(WPARAM hDC,LPARAM nFlags)
{
  CDC* pDC=CDC::FromHandle((HDC)hDC);
  OnEraseBkgnd(pDC);
  Draw(pDC);
  return 0;
}

BOOL CElementWnd::OnEraseBkgnd(CDC* pDC) 
{
	CGdiObject* pOldBrush=pDC->SelectObject(&theApp.BkBrush);
  pDC->PatBlt(0,0,Size.cx,Size.cy,PATCOPY);
  pDC->SelectObject(pOldBrush);

	return CWnd::OnEraseBkgnd(pDC);
}

void CElementWnd::SetAngle(int nNewAngle)
{
  Angle=nNewAngle;
  double RadAngle=Angle*3.1415926/180;

  WorkPntArray.SetSize(OrgPntArray.GetSize());
  for(int n=0; n<OrgPntArray.GetSize(); n++) {
    double PntRad=sqrt(OrgPntArray[n].y*OrgPntArray[n].y+OrgPntArray[n].x*OrgPntArray[n].x);
    if(PntRad==0) {
      WorkPntArray[n].x=0;
      WorkPntArray[n].y=0;
      continue;
    }

    double cos1=OrgPntArray[n].x/PntRad;
    double sin1=OrgPntArray[n].y/PntRad;
    WorkPntArray[n].y=(int)floor(PntRad*(sin1*cos(RadAngle)+cos1*sin(RadAngle))+0.5);
    WorkPntArray[n].x=(int)floor(PntRad*(cos1*cos(RadAngle)-sin1*sin(RadAngle))+0.5);
  }
}
