// ArchView.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "ArchView.h"
#include "ArchFrame.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CArchView

IMPLEMENT_DYNCREATE(CArchView, CScrollView)

#define VIEW_WIDTH 4096
#define VIEW_HEIGHT 4096

CArchView::CArchView()
{
  pDoc=NULL;
  ConfigMode=TRUE;
  SelectedCount=0; MoveMode=FALSE; CopyMode=FALSE;
}

CArchView::~CArchView()
{
}

BEGIN_MESSAGE_MAP(CArchView, CScrollView)
	//{{AFX_MSG_MAP(CArchView)
	ON_WM_MOUSEMOVE()
	ON_COMMAND(ID_ARCHELEM_DEL, OnArchElemDel)
	ON_WM_LBUTTONDOWN()
	ON_COMMAND(ID_ARCHMODE, OnArchMode)
	ON_COMMAND(ID_CONSTRMODE, OnConstrMode)
	ON_UPDATE_COMMAND_UI(ID_ARCHELEM_DEL, OnUpdateArchElemDel)
	ON_WM_LBUTTONUP()
	ON_MESSAGE(WMU_ADD_ELEMENT_BY_NAME, OnAddElementByName)
	ON_MESSAGE(WMU_ELEMENT_LBUTTONDOWN,OnElementLButtonDown)
	ON_MESSAGE(WMU_ELEMENT_LBUTTONUP,OnElementLButtonUp)
	ON_MESSAGE(WMU_ELEMENT_MOUSEMOVE,OnElementMouseMove)
	ON_MESSAGE(WMU_PINSTATECHANGED,OnPinStateChanged)
	ON_MESSAGE(WMU_SET_INSTRCOUNTER,OnSetInstrCounter)
	ON_MESSAGE(WMU_KILL_INSTRCOUNTER,OnKillInstrCounter)
	ON_MESSAGE(WMU_GETPINSTATE,OnGetPinState)
	ON_WM_KEYDOWN()
	ON_WM_KEYUP()
	ON_WM_ERASEBKGND()
	ON_COMMAND(ID_FILE_PRINT, OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, OnFilePrintPreview)
	ON_WM_TIMER()
	//}}AFX_MSG_MAP
	ON_UPDATE_COMMAND_UI_RANGE(ID_ADD_ELEMENT0,ID_ADD_ELEMENT255,OnUpdateAddElement)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CArchView drawing

void CArchView::OnInitialUpdate()
{
	CScrollView::OnInitialUpdate();

  CSize sizeTotal;
  pDoc=(CArchDoc*)GetDocument();
  pDoc->pView=this;
	sizeTotal.cx=VIEW_WIDTH;
  sizeTotal.cy=VIEW_HEIGHT;
	SetScrollSizes(MM_TEXT, sizeTotal);

  SetClassLong(m_hWnd,GCL_HBRBACKGROUND,NULL);

}

/////////////////////////////////////////////////////////////////////////////
// CArchView diagnostics

#ifdef _DEBUG
void CArchView::AssertValid() const
{
	CScrollView::AssertValid();
}

void CArchView::Dump(CDumpContext& dc) const
{
	CScrollView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CArchView message handlers

BOOL CArchView::OnEraseBkgnd(CDC* pDC) 
{
  CRect ClRect;
  GetClientRect(ClRect);
  pDC->PatBlt(ClRect.left,ClRect.top,ClRect.Width(),ClRect.Height(),WHITENESS);
	
	return CScrollView::OnEraseBkgnd(pDC);
}

BOOL CArchView::PreCreateWindow(CREATESTRUCT& cs) 
{
	//cs.style&=~WS_CLIPSIBLINGS;
	cs.style|=WS_CLIPCHILDREN;

  return CScrollView::PreCreateWindow(cs);
}

void CArchView::OnMouseMove(UINT nFlags, CPoint point) 
{
	CScrollView::OnMouseMove(nFlags, point);

  if(!MoveMode) return;

  if(nFlags==MK_LBUTTON) {
    CPen Pen(PS_DOT,1,RGB(0,0,0));
    CClientDC DC(this);
    DC.SetROP2(R2_XORPEN);
    CPen *pOldPen=DC.SelectObject(&Pen);

    DC.MoveTo(StartMousePoint);
    DC.LineTo(point.x,StartMousePoint.y);
    DC.LineTo(point.x,point.y);
    DC.LineTo(StartMousePoint.x,point.y);
    DC.LineTo(StartMousePoint.x,StartMousePoint.y);

    DC.MoveTo(StartMousePoint);
    DC.LineTo(LastMousePoint.x,StartMousePoint.y);
    DC.LineTo(LastMousePoint.x,LastMousePoint.y);
    DC.LineTo(StartMousePoint.x,LastMousePoint.y);
    DC.LineTo(StartMousePoint.x,StartMousePoint.y);

    DC.SelectObject(pOldPen);
    LastMousePoint=point;
  }
}

/*
По нажатию левой кнопки мыши:
1. Ни один не выделен:
      выделяем текущий
2. Выделен один текущий
      ничего не делаем
3. Выделен один не текущий
      снять выделение с другого, выделить текущий
4. Выделено несколько, в том числе текущий
      ничего не делаем
5. Выделено несколько, текущий не выделен
      снять выделение с других, выделить текущий
*/

LPARAM CArchView::OnElementLButtonDown(WPARAM nFlags,LPARAM hElement)
{
  CPoint point;
  GetCursorPos(&point);
  CElement *pElement=pDoc->Element[(DWORD)hElement];

  MoveMode=TRUE; CopyMode=FALSE;
  HWND hCaptureWnd=(HWND)(ArchMode ? pElement->get_hArchWnd() : pElement->get_hConstrWnd());
  if(hCaptureWnd) ::SetCapture(hCaptureWnd);
  StartMousePoint=point;

  if(nFlags==MK_LBUTTON) { //На клавиатуре ничего не нажато
    //Если щелчок на выделенном элементе, то ничего не делаем
    if(!(ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected())) {
      //Иначе выделяем текущий и снимаем выделение с остальных
      for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
        if(pDoc->Element[n]==NULL) continue;
        if(ArchMode ? pDoc->Element[n]->get_bArchSelected() : pDoc->Element[n]->get_bConstrSelected()) {
          SelectedCount--;
          if(ArchMode) pDoc->Element[n]->put_bArchSelected(FALSE);
          else pDoc->Element[n]->put_bConstrSelected(FALSE);
          HWND hWnd=(HWND)(ArchMode ? pDoc->Element[n]->get_hArchWnd() :
            pDoc->Element[n]->get_hConstrWnd());
          if(hWnd) ::InvalidateRect(hWnd,NULL,FALSE);
        }
      }
      if(ArchMode) pElement->put_bArchSelected(TRUE);
      else pElement->put_bConstrSelected(TRUE);
      HWND hWnd=(HWND)(ArchMode ? pElement->get_hArchWnd() : pElement->get_hConstrWnd());
      if(hWnd) ::InvalidateRect(hWnd,NULL,FALSE);
      SelectedCount++;
    }
  }
  if((nFlags&MK_CONTROL)&&(nFlags&MK_LBUTTON)) {
    pDoc->CopySelected();
    CopyMode=TRUE;
  }

  if(ArchMode) DeconnectSelected();

  return 0;
}

/*
Отпустили клавишу с Ctrl:
      если CopyMode!=TRUE тогда инвертировать текущий
Отпустили клавишу без Ctrl:
1. Ни один не выделен:
      ничего не делаем
2. Выделен один текущий
      ничего не делаем
3. Выделен один не текущий
      ничего не делаем
4. Выделено несколько, в том числе текущий
      снимаем выделение со всех кроме текущего
5. Выделено несколько, текущий не выделен
      ничего не делаем
Если после перемещения, ничего не делаем
*/

LPARAM CArchView::OnElementLButtonUp(WPARAM nFlags,LPARAM hElement)
{
  CPoint point;
  GetCursorPos(&point);
  CElement *pElement=pDoc->Element[(DWORD)hElement];

  switch(nFlags) {
  case 0:
    if((SelectedCount>1)&&
        (ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected())&&
        !MoveMode) {
      for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
        if(pDoc->Element[n]==NULL) continue;
        if(pDoc->Element[n]==pElement) continue;

        if(ArchMode&&pDoc->Element[n]->get_bArchSelected()) {
          pDoc->Element[n]->put_bArchSelected(FALSE);
          HWND hWnd=(HWND)pDoc->Element[n]->get_hArchWnd();
          if(hWnd) ::InvalidateRect(hWnd,NULL,FALSE);
        }
        if(!ArchMode&&pDoc->Element[n]->get_bConstrSelected()) {
          pDoc->Element[n]->put_bConstrSelected(FALSE);
          HWND hWnd=(HWND)pDoc->Element[n]->get_hConstrWnd();
          if(hWnd) ::InvalidateRect(hWnd,NULL,FALSE);
        }
      }
      SelectedCount=1;
    }
    break;
  case MK_SHIFT : //Shift key pressed
    if(ArchMode) {
      if(pElement->get_bArchSelected()) SelectedCount--;
      else SelectedCount++;
      pElement->put_bArchSelected(!pElement->get_bArchSelected());
    }else {
      if(pElement->get_bConstrSelected()) SelectedCount--;
      else SelectedCount++;
      pElement->put_bConstrSelected(!pElement->get_bConstrSelected());
    }

    HWND hElemWnd=(HWND)(ArchMode ? pElement->get_hArchWnd() : pElement->get_hConstrWnd());
    if(hElemWnd) ::InvalidateRect(hElemWnd,NULL,TRUE);
    break;
  }

  if(ArchMode) ConnectSelected();

  ::ReleaseCapture();
  MoveMode=FALSE; CopyMode=FALSE;
  return 0;
}

LPARAM CArchView::OnElementMouseMove(WPARAM nFlags,LPARAM hElement)
{
  if(!(nFlags&MK_LBUTTON)) return 0;
  if(!MoveMode) return 0;

  CPoint point;
  GetCursorPos(&point);

  BOOL Moved=FALSE;
  int ShiftX=point.x-StartMousePoint.x,
      ShiftY=point.y-StartMousePoint.y;
  StartMousePoint=point;
  if(MoveSelected(ShiftX,ShiftY)) {
    MoveMode=TRUE;
    pDoc->SetModifiedFlag();
  }

  return 0;
}

void CArchView::OnArchElemDel() 
{
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if((ArchMode&&pDoc->Element[n]->get_bArchSelected())||(!ArchMode&&pDoc->Element[n]->get_bConstrSelected())) {
      DeconnectElement(n);
    }
  }
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if((ArchMode&&pDoc->Element[n]->get_bArchSelected())||(!ArchMode&&pDoc->Element[n]->get_bConstrSelected())) {
      pDoc->DeleteElement(n);
    }
  }
  RedrawWindow();
}

void CArchView::OnLButtonDown(UINT nFlags, CPoint point) 
{
	CScrollView::OnLButtonDown(nFlags, point);

  MoveMode=TRUE; CopyMode=FALSE;
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if(ArchMode) {
      if(pDoc->Element[n]->get_bArchSelected()) {
        pDoc->Element[n]->put_bArchSelected(FALSE);
        HWND hWnd=(HWND)pDoc->Element[n]->get_hArchWnd();
        if(hWnd) ::InvalidateRect(hWnd,NULL,FALSE);
      }
    }else {
      if(pDoc->Element[n]->get_bConstrSelected()) {
        pDoc->Element[n]->put_bConstrSelected(FALSE);
        HWND hWnd=(HWND)pDoc->Element[n]->get_hConstrWnd();
        if(hWnd) ::InvalidateRect(hWnd,NULL,FALSE);
      }
    }
  }
  SelectedCount=0;
  m_StatusBar.SetPaneText(0,"");
  StartMousePoint=point; LastMousePoint=point;
  SetCapture();
}


void CArchView::OnArchMode() 
{
	ToolBar.GetToolBarCtrl().CheckButton(ID_ARCHMODE,TRUE);
	ToolBar.GetToolBarCtrl().CheckButton(ID_CONSTRMODE,FALSE);
  ArchMode=TRUE;

  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    HWND hArchWnd=(HWND)pDoc->Element[n]->get_hArchWnd();
    HWND hConstrWnd=(HWND)pDoc->Element[n]->get_hConstrWnd();
    if(hConstrWnd) ::ShowWindow(hConstrWnd,SW_HIDE);
    if(hArchWnd) ::ShowWindow(hArchWnd,SW_SHOW);
    if(hConstrWnd) ::EnableWindow(hConstrWnd,FALSE);
    if(hArchWnd) ::EnableWindow(hArchWnd,TRUE);
  }
}

void CArchView::OnConstrMode() 
{
	ToolBar.GetToolBarCtrl().CheckButton(ID_CONSTRMODE,TRUE);
	ToolBar.GetToolBarCtrl().CheckButton(ID_ARCHMODE,FALSE);
  ArchMode=FALSE;

  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    HWND hArchWnd=(HWND)pDoc->Element[n]->get_hArchWnd();
    HWND hConstrWnd=(HWND)pDoc->Element[n]->get_hConstrWnd();
    if(hArchWnd) ::ShowWindow(hArchWnd,SW_HIDE);
    if(hConstrWnd) ::ShowWindow(hConstrWnd,SW_SHOW);
    if(hArchWnd) ::EnableWindow(hArchWnd,FALSE);
    if(hConstrWnd) ::EnableWindow(hConstrWnd,TRUE);
  }
}

BOOL CArchView::Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID, CCreateContext* pContext) 
{
  if(CWnd::Create(lpszClassName,lpszWindowName,dwStyle,rect,pParentWnd,nID,pContext)) {
    m_StatusBar.Create(GetParent());

    Ind[0]=ID_ARCH_STATUS;
    Ind[1]=ID_INSTR_COUNTER;
    m_StatusBar.SetIndicators(Ind,2);
    
    m_StatusBar.SetPaneStyle(0,SBPS_STRETCH|SBPS_NORMAL);

    ToolBar.CreateEx(GetParent(),TBSTYLE_FLAT|TBSTYLE_TRANSPARENT);
	  ToolBar.LoadToolBar(IDR_ARCHTYPE);

	  ToolBar.GetToolBarCtrl().CheckButton(ID_ARCHMODE,TRUE);
	  ToolBar.GetToolBarCtrl().CheckButton(ID_CONSTRMODE,FALSE);
    ReBar.Create(GetParent());
    ReBar.AddBar(&ToolBar);

	  ToolBar.SetBarStyle(ToolBar.GetBarStyle()|CBRS_TOOLTIPS|CBRS_FLYBY);
    CreateElementButtons();

    ArchMode=TRUE;

    ((CFrameWnd*)GetParent())->ShowControlBar(&ToolBar,TRUE,FALSE);

    return TRUE;
  }
	return FALSE;
}

void CArchView::OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint) 
{
  if(!pDoc) return;
	if(ArchMode) OnArchMode();
  else OnConstrMode();
}

void CArchView::ChangeMode(BOOL bConfigMode)
{
  ConfigMode=bConfigMode;
  ((CArchFrame*)GetParent())->ChangeMode(bConfigMode);
  if(ConfigMode) KillTimer(1);
  else SetTimer(1,500,NULL);
}

BOOL CArchView::OnPreparePrinting(CPrintInfo* pInfo) 
{
  if(DoPreparePrinting(pInfo)) {
	  return TRUE;
  }
  return FALSE;
}

void CArchView::OnUpdateArchElemDel(CCmdUI* pCmdUI) 
{
  int SelCount=0,ElementIndex;
  CElement* pElement;
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if((ArchMode&&pDoc->Element[n]->get_bArchSelected())||
      (!ArchMode&&pDoc->Element[n]->get_bConstrSelected())) {
      SelCount++;
      pElement=pDoc->Element[n];
      ElementIndex=n;
    }
  }
  pCmdUI->Enable(SelCount>0);
  if(SelCount==1) {
    struct _ConListElem {
      CElement* pElement;
      CString PinNumber;
    }ConList[8];

    int ConnectedCount=0,MaxConCount=8;
    for(int n=0; n<MaxConCount; n++) ConList[n].pElement=NULL;
    int ElPointCount=pElement->get_nPointCount();
    for(int n=0; n<ElPointCount; n++) {
      PointList *pPnt=&ConData[ElementIndex][n];
      POSITION Pos=pPnt->GetHeadPosition();
      while(Pos) {
        ConPoint &CP=pPnt->GetNext(Pos);
        if(CP.pElement) {
          CString *pStr=NULL;
          for(int i=0; i<ConnectedCount; i++) {
            if(CP.pElement==ConList[i].pElement) {
              pStr=&ConList[i].PinNumber;
              break;
            }
          }
          if(!pStr&&(ConnectedCount<MaxConCount)) {
            pStr=&ConList[ConnectedCount].PinNumber;
            ConList[ConnectedCount].pElement=CP.pElement;
            ConnectedCount++;
          }
          if(pStr) {
            CString s;
            s.Format("%d",CP.PinNumber);
            if(pStr->GetLength()>0) *pStr+=",";
            *pStr+=s;
          }
        }
      }
    }

    CString Tip;
    if(ConnectedCount) {
      Tip=" подключён к ";
      for(int i=0; i<ConnectedCount; i++) {
        CString TipText;
        ConList[i].pElement->get_sTipText(TipText);
        Tip+="\""+TipText+"\"";
        Tip+=" ("+ConList[i].PinNumber+"), ";
      }
    }
    if(Tip.GetLength()) Tip=Tip.Left(Tip.GetLength()-2);

    CString TipText;
    pElement->get_sTipText(TipText);
    m_StatusBar.SetPaneText(0,TipText+Tip);
  }else m_StatusBar.SetPaneText(0,"");
}

void CArchView::OnUpdateAddElement(CCmdUI* pCmdUI)
{
  pCmdUI->Enable(ConfigMode);
}

void CArchView::OnLButtonUp(UINT nFlags, CPoint point) 
{
	CScrollView::OnLButtonUp(nFlags, point);

  CopyMode=FALSE;
  if(!MoveMode) return;

  CPen Pen(PS_DOT,1,RGB(0,0,0));
  CClientDC DC(this);
  DC.SetROP2(R2_XORPEN);
  CPen *pOldPen=DC.SelectObject(&Pen);

  DC.MoveTo(StartMousePoint);
  DC.LineTo(LastMousePoint.x,StartMousePoint.y);
  DC.LineTo(LastMousePoint.x,LastMousePoint.y);
  DC.LineTo(StartMousePoint.x,LastMousePoint.y);
  DC.LineTo(StartMousePoint.x,StartMousePoint.y);

  DC.SelectObject(pOldPen);
  ReleaseCapture();

  CRect SelRect(StartMousePoint,LastMousePoint);
  SelRect.NormalizeRect();
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    WINDOWPLACEMENT ElemPlace;
    ElemPlace.length=sizeof(ElemPlace);
    HWND hWnd=(HWND)(ArchMode ? pDoc->Element[n]->get_hArchWnd() :
      pDoc->Element[n]->get_hConstrWnd());
    if(!hWnd) continue;

    ::GetWindowPlacement(hWnd,&ElemPlace);
    if(SelRect.PtInRect(CPoint(ElemPlace.rcNormalPosition.left,ElemPlace.rcNormalPosition.top))&&
      SelRect.PtInRect(CPoint(ElemPlace.rcNormalPosition.right,ElemPlace.rcNormalPosition.bottom))) {
      if(ArchMode) {
        if(!pDoc->Element[n]->get_bArchSelected()) {
          pDoc->Element[n]->put_bArchSelected(TRUE);
          ::InvalidateRect(hWnd,NULL,FALSE);
        }
      }else {
        if(!pDoc->Element[n]->get_bConstrSelected()) {
          pDoc->Element[n]->put_bConstrSelected(TRUE);
          ::InvalidateRect(hWnd,NULL,FALSE);
        }
      }
      SelectedCount++;
    }else {
      if(ArchMode) {
        if(pDoc->Element[n]->get_bArchSelected()) {
          pDoc->Element[n]->put_bArchSelected(FALSE);
          ::InvalidateRect(hWnd,NULL,FALSE);
        }
      }else {
        if(pDoc->Element[n]->get_bConstrSelected()) {
          pDoc->Element[n]->put_bConstrSelected(FALSE);
          ::InvalidateRect(hWnd,NULL,FALSE);
        }
      }
    }
  }
	MoveMode=FALSE;
}

LPARAM CArchView::OnAddElementByName(WPARAM wParam,LPARAM lParam)
{
  pDoc->AddElement((LPCTSTR)wParam,(LPCTSTR)lParam,TRUE);
  return 0;
}

void CArchView::FindIntersections(CElement* pElement)
{
  CRect IntRect;
  if(!(pElement->get_nType()&ET_ARCH)) return;

  //Находим один ближайший элемент
  CPoint MinDist(10,10);
  CElement* pNearestEl=NULL;
  WINDOWPLACEMENT Pls1,Pls2;
  Pls1.length=sizeof(Pls1);
  Pls2.length=sizeof(Pls2);
  ::GetWindowPlacement((HWND)pElement->get_hArchWnd(),&Pls1);
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if(!(pDoc->Element[n]->get_nType()&ET_ARCH)) continue;
    if(pDoc->Element[n]==pElement) continue;

    ::GetWindowPlacement((HWND)pDoc->Element[n]->get_hArchWnd(),&Pls2);
    if(IntRect.IntersectRect(&Pls1.rcNormalPosition,&Pls2.rcNormalPosition)) {
      CPoint TempDist=GetMinDist(pDoc->Element[n],pElement);
      if((abs(MinDist.x)>=abs(TempDist.x))&&(abs(MinDist.y)>=abs(TempDist.y))) {
        MinDist=TempDist;
        pNearestEl=pDoc->Element[n];
      }
    }
  }

  if((abs(MinDist.x)>3)||(abs(MinDist.y)>3)) return;

  //Пододвигаем элемент так, чтобы соединить его с ближайшим элементом
  if((abs(MinDist.x)<3)&&(abs(MinDist.y)<3)) {
    WINDOWPLACEMENT Pls;
    Pls.length=sizeof(Pls);
    ::GetWindowPlacement((HWND)pElement->get_hArchWnd(),&Pls);
    CRect MovedRect(Pls.rcNormalPosition);
    MovedRect.OffsetRect(-MinDist.x,-MinDist.y);
    ::MoveWindow((HWND)pElement->get_hArchWnd(),
      MovedRect.left,MovedRect.top,
      MovedRect.Width(),MovedRect.Height(),TRUE);
  }

  //Подсоединяем все совпавшие выводы
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if(pDoc->Element[n]==pElement) continue;

    ::GetWindowPlacement((HWND)pDoc->Element[n]->get_hArchWnd(),&Pls2);
    if(IntRect.IntersectRect(&Pls1.rcNormalPosition,&Pls2.rcNormalPosition)) {
      ConnectElements(pElement,pDoc->Element[n]);
    }
  }
}

CPoint CArchView::GetMinDist(CElement* pFixedElement, CElement* pMovedElement)
{
  CPoint Res(10,10);

  if(pMovedElement->get_nPointCount()<=0) return Res;
  if(pFixedElement->get_nPointCount()<=0) return Res;

  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  ::GetWindowPlacement((HWND)pMovedElement->get_hArchWnd(),&Pls);
  CRect MovedRect(Pls.rcNormalPosition);
  ::GetWindowPlacement((HWND)pFixedElement->get_hArchWnd(),&Pls);
  CRect FixedRect(Pls.rcNormalPosition);
  //Перебираем точки фиксированного
  DWORD FixPntCnt=pFixedElement->get_nPointCount();
  for(DWORD n=0; n<FixPntCnt; n++) {
    DWORD Pnt=pFixedElement->GetPointPos(n);
    CPoint FixPnt(LOWORD(Pnt),HIWORD(Pnt));
    //Перебор точек двигаемого
    int MovPntCnt=pMovedElement->get_nPointCount();
    for(int m=0; m<MovPntCnt; m++) {
      //Проверим типы точек
      if((pMovedElement->GetPinType(m)==pFixedElement->GetPinType(n))&&
        (pMovedElement->GetPinType(m)!=(PT_INPUT|PT_OUTPUT))) continue;

      Pnt=pMovedElement->GetPointPos(m);
      CPoint MovPnt(LOWORD(Pnt),HIWORD(Pnt));
      CPoint TempPnt;
      TempPnt.x=MovedRect.left+MovPnt.x-FixedRect.left-FixPnt.x;
      TempPnt.y=MovedRect.top+MovPnt.y-FixedRect.top-FixPnt.y;
      if((abs(Res.x)>=abs(TempPnt.x))&&(abs(Res.y)>=abs(TempPnt.y))) Res=TempPnt;
    }
  }

  return Res;
}

BOOL CArchView::ConnectElements(CElement* pMovedElement, CElement* pFixedElement)
{
  if(pMovedElement->get_nPointCount()<=0) return FALSE;
  if(pFixedElement->get_nPointCount()<=0) return FALSE;

  //Подсоединяем элемент
  int DistX,DistY;
  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  ::GetWindowPlacement((HWND)pMovedElement->get_hArchWnd(),&Pls);
  CRect MovedRect(Pls.rcNormalPosition);
  ::GetWindowPlacement((HWND)pFixedElement->get_hArchWnd(),&Pls);
  CRect FixedRect(Pls.rcNormalPosition);
  int FixPntCnt=pFixedElement->get_nPointCount();
  for(int n=0; n<FixPntCnt; n++) { //Перебор точек фиксированного
    DWORD Pnt=pFixedElement->GetPointPos(n);
    CPoint FixPnt(LOWORD(Pnt),HIWORD(Pnt));
    //Перебор точек двигаемого
    int MovPntCnt=pMovedElement->get_nPointCount();
    for(int m=0; m<MovPntCnt; m++) {
      //Проверим типы точек
      if((pMovedElement->GetPinType(m)==pFixedElement->GetPinType(n))&&
        (pMovedElement->GetPinType(m)!=(PT_INPUT|PT_OUTPUT))) continue;

      DWORD Pnt=pMovedElement->GetPointPos(m);
      CPoint MovPnt(LOWORD(Pnt),HIWORD(Pnt));
      DistX=MovedRect.left+MovPnt.x-FixedRect.left-FixPnt.x;
      DistY=MovedRect.top+MovPnt.y-FixedRect.top-FixPnt.y;
      if((DistX==0)&&(DistY==0)) {
        //Находим индексы обоих элементов в массиве
        int FixedIndex=-1,MovedIndex=-1;
        for(int i=0; i<sizeof(pDoc->Element)/sizeof(CElement*); i++) {
          if(pDoc->Element[i]==NULL) continue;
          if(pDoc->Element[i]==pFixedElement) FixedIndex=i;
          if(pDoc->Element[i]==pMovedElement) MovedIndex=i;
        }
        //Проверим не соединены ли они уже и соединим при необходимости
        ConPoint CP;
        BOOL Found;
        POSITION Pos;
        
        CP.pElement=pFixedElement;
        CP.PinNumber=n;
        Found=FALSE;
        Pos=ConData[MovedIndex][m].GetHeadPosition();
        while(Pos) {
          ConPoint CPLst=ConData[MovedIndex][m].GetNext(Pos);
          if(memcmp(&CPLst,&CP,sizeof(ConPoint))==0) { Found=TRUE; break; }
        }
        if(!Found) ConData[MovedIndex][m].AddTail(CP);
        pMovedElement->ConnectPin(m,TRUE);

        CP.pElement=pMovedElement;
        CP.PinNumber=m;
        Found=FALSE;
        Pos=ConData[FixedIndex][n].GetHeadPosition();
        while(Pos) {
          ConPoint CPLst=ConData[FixedIndex][n].GetNext(Pos);
          if(memcmp(&CPLst,&CP,sizeof(ConPoint))==0) { Found=TRUE; break; }
        }
        if(!Found) ConData[FixedIndex][n].AddTail(CP);
        pFixedElement->ConnectPin(n,TRUE);
        break;
      }
    }
  }
  ::InvalidateRect((HWND)pFixedElement->get_hArchWnd(),NULL,TRUE);
  ::InvalidateRect((HWND)pMovedElement->get_hArchWnd(),NULL,TRUE);

  return TRUE;
}

BOOL CALLBACK EnumChildProc(HWND hwnd,LPARAM lParam)
{
  if(!IsWindowEnabled(hwnd)) return TRUE;

  CDC* pDC=(CDC*)lParam;

  CDC DC;
  CBitmap Bmp;
  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  ::GetWindowPlacement(hwnd,&Pls);
  CRect ElemRect(Pls.rcNormalPosition);

  DC.CreateCompatibleDC(pDC);
  Bmp.CreateCompatibleBitmap(pDC,ElemRect.Width(),ElemRect.Height());
  DC.SelectObject(&Bmp);
  ::SendMessage(hwnd,WM_PRINT,(WPARAM)DC.m_hDC,0);
  ::BitBlt(pDC->m_hDC,ElemRect.left,ElemRect.top,ElemRect.Width(),ElemRect.Height(),
    DC.m_hDC,0,0,SRCCOPY);

  return TRUE;
}

void CArchView::OnPrint(CDC* pDC, CPrintInfo* pInfo) 
{
  pDC->SetMapMode(MM_ISOTROPIC);
  pDC->SetWindowExt(72,72);
  pDC->SetViewportExt(pDC->GetDeviceCaps(LOGPIXELSX),
    pDC->GetDeviceCaps(LOGPIXELSY));
  EnumChildWindows(m_hWnd,EnumChildProc,(LPARAM)pDC);
  pDC->SetWindowOrg(0,0);
  pDC->SetWindowExt(1,1);
  pDC->SetViewportExt(1,1);

  CScrollView::OnPrint(pDC, pInfo);
}

void CArchView::OnDraw(CDC* pDC) 
{
}

LPARAM CArchView::OnPinStateChanged(WPARAM PinState,LPARAM hElement)
{
  //1. Перебираем все выводы элемента
  //2. Перебираем все входы элементов, подключенных к текущему выводу
  //3. Ищем элемент в кэше, и если его там нет, заносим его туда
  //4. Рассчитываем новое состояние элемента в кэше
  //5. Перебираем все элементы кэша и устанавливаем состояние реальных элементов

  if(theApp.pDebugArchDoc==NULL) return 0;

  CElement* pElement=pDoc->Element[(DWORD)hElement];
  PointList* pConData=ConData[(DWORD)hElement];

  int PointCount=pElement->get_nPointCount();

  struct _ElData{
    CElement* pElement;
    DWORD PinState;
  }ElData[MAX_CONNECT_POINT*4];
  int CachedCount=0;

  for(int n=0; n<PointCount; n++) {
    POSITION Pos=pConData[n].GetHeadPosition();
    while(Pos) {
      //Получим данные о выводе подключённого элемента
      ConPoint Point=pConData[n].GetNext(Pos);
      //Нас интересуют только входы
      if(!(Point.pElement->GetPinType(Point.PinNumber)&PT_INPUT)) continue;

      BOOL Found=FALSE;
	  int i = 0;
      for(i=0; i<CachedCount; i++) {
        if(ElData[i].pElement==Point.pElement) {
          Found=TRUE;
          break;
        }
      }
      if(!Found) {
        i=CachedCount;
        ElData[i].pElement=Point.pElement;
        ElData[i].PinState=Point.pElement->get_nPinState();
        CachedCount++;
      }

      DWORD NewState=ElData[i].PinState;

      NewState&=~(1<<Point.PinNumber);
      NewState|=PinState&(1<<n) ? (1<<Point.PinNumber) : 0;
      ElData[i].PinState=NewState;
    }
  }

  for(int i=0; i<CachedCount; i++) {
    ElData[i].pElement->put_nPinState(ElData[i].PinState);
  }

  return 0;
}

LRESULT CArchView::WindowProc(UINT message, WPARAM wParam, LPARAM lParam) 
{
  if(message==WMU_PINSTATECHANGED)
    return OnPinStateChanged(wParam,lParam);
	return CScrollView::WindowProc(message, wParam, lParam);
}

LPARAM CArchView::OnGetPinState(WPARAM wParam,LPARAM hElement)
{
  return GetPinState((int)hElement);
}

DWORD CArchView::GetPinState(int ElementIndex)
{
  if(theApp.pDebugArchDoc==NULL) return 0;

  CElement* pElement=pDoc->Element[ElementIndex];
  PointList* pConData=ConData[ElementIndex];

  int PointCount=pElement->get_nPointCount();

  struct _ElData{
    CElement* pElement;  //Указатель на подключённый элемент
    DWORD PinState;        //Состояние выводов подключённого элемента
  }ElData[MAX_CONNECT_POINT*4];
  int CachedCount=0;

  //Переберём все контакты текущего элемента
  //И запомним подключенные элементы и состояние их выводов
  DWORD NewState=0;
  for(int n=0; n<PointCount; n++) {
    NewState&=~(1<<n);
    POSITION Pos=pConData[n].GetHeadPosition();
    //Переберём все контакты, подключенные к n-му контакту тек. элемента
    while(Pos) {
      //Получим данные о контакте подключённого элемента
      ConPoint Point=pConData[n].GetNext(Pos);

      BOOL Found=FALSE;
	  int i = 0;
      for(i=0; i<CachedCount; i++) {
        if(ElData[i].pElement==Point.pElement) {
          Found=TRUE;
          break;
        }
      }
      if(!Found) {
        i=CachedCount;
        ElData[i].pElement=Point.pElement;
        ElData[i].PinState=Point.pElement->get_nPinState();
        CachedCount++;
      }

      if((ElData[i].PinState>>Point.PinNumber)&1)
        NewState|=(1<<n);
    }
  }

  return NewState;
}

void CArchView::DeconnectElement(int ElemIndex)
{
  PointList* pSelPoint=ConData[ElemIndex];
  //Перебираем все выводы заданного элемента
  int ElPntCnt=pDoc->Element[ElemIndex]->get_nPointCount();
  for(int i=0; i<ElPntCnt; i++) {
    if(pSelPoint[i].IsEmpty()) continue;

    //Теперь переберём все связи i-й точки заданного элемента
    //и отключим подключённые к ней элементы
    POSITION Pos=pSelPoint[i].GetHeadPosition();
    while(Pos) {
      //Отключим и перерисуем
      ConPoint& CP=pSelPoint[i].GetNext(Pos);

      //Находим индекс подсоединённого элемента
      BOOL Found=FALSE;
	  int m = 0;
      for(m=0; m<sizeof(pDoc->Element)/sizeof(CElement*); m++) {
        if(CP.pElement==pDoc->Element[m]) { Found=TRUE; break; }
      }
      if(!Found) MessageBox("Ошибка отсоединения элемента","Ошибка",MB_OK|MB_ICONSTOP);
      //Отключаем от соответствующего вывода m-го элемента текущий элемент
      //for(int j=0; j<pDoc->Element[m]->nPointCount; j++) {
      if(!ConData[m][CP.PinNumber].IsEmpty()) {
        POSITION Pos2=ConData[m][CP.PinNumber].GetHeadPosition();
        while(Pos2) {
          POSITION OldPos=Pos2;
          ConPoint &CP2=ConData[m][CP.PinNumber].GetNext(Pos2);
          if(CP2.pElement==pDoc->Element[ElemIndex]) {
            ConData[m][CP.PinNumber].RemoveAt(OldPos);
            pDoc->Element[m]->ConnectPin(CP.PinNumber,FALSE);
          }
        }
      }
      ::InvalidateRect((HWND)pDoc->Element[m]->get_hArchWnd(),NULL,TRUE);
    }
    pSelPoint[i].RemoveAll();
    //Все подключенные элементы отключены, отключаем заданный
    pDoc->Element[ElemIndex]->ConnectPin(i,FALSE);
  }
  //Теперь перерисуем заданный элемент
  HWND hWnd=(HWND)pDoc->Element[ElemIndex]->get_hArchWnd();
  if(hWnd) ::InvalidateRect((HWND)pDoc->Element[ElemIndex]->get_hArchWnd(),NULL,TRUE);
}

BOOL CArchView::MoveSelected(int ShiftX, int ShiftY)
{
  BOOL Moved=FALSE;

  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if(ArchMode ? pDoc->Element[n]->get_bArchSelected() : pDoc->Element[n]->get_bConstrSelected()) {
      WINDOWPLACEMENT Pls;
      Pls.length=sizeof(Pls);
      HWND hWnd=(HWND)pDoc->Element[n]->get_hArchWnd();
      ::GetWindowPlacement((HWND)(ArchMode ? pDoc->Element[n]->get_hArchWnd() :
        pDoc->Element[n]->get_hConstrWnd()),&Pls);
      CRect CurRect(Pls.rcNormalPosition);
      CurRect.OffsetRect(GetScrollPos(SB_HORZ),GetScrollPos(SB_VERT));
      if((ShiftX!=0)||(ShiftY!=0)) {
        CurRect.left+=ShiftX; CurRect.right+=ShiftX;
        CurRect.top+=ShiftY; CurRect.bottom+=ShiftY;

        if(CurRect.top<0) {
          CurRect.bottom-=CurRect.top;
          CurRect.top=0;
        }
        if(CurRect.left<0) {
          CurRect.right-=CurRect.left;
          CurRect.left=0;
        }

        if(CurRect.bottom>VIEW_HEIGHT-1) {
          CurRect.top-=CurRect.bottom-VIEW_HEIGHT+1;
          CurRect.bottom=VIEW_HEIGHT-1;
        }
        if(CurRect.right>VIEW_WIDTH-1) {
          CurRect.left-=CurRect.right-VIEW_WIDTH+1;
          CurRect.right=VIEW_WIDTH-1;
        }
        
        int dy=GetScrollPos(SB_VERT);
        int dx=GetScrollPos(SB_HORZ);
        if(ArchMode) {
          HWND hWnd=(HWND)pDoc->Element[n]->get_hArchWnd();
          if(hWnd) ::MoveWindow(hWnd,
            CurRect.left-dx,CurRect.top-dy,CurRect.Width(),CurRect.Height(),
            TRUE);
        }else {
          HWND hWnd=(HWND)pDoc->Element[n]->get_hConstrWnd();
          if(hWnd) ::MoveWindow(hWnd,
            CurRect.left-dx,CurRect.top-dy,CurRect.Width(),CurRect.Height(),
            TRUE);
        }
        Moved=TRUE;
      }
    }
  }
  return Moved;
}

void CArchView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  BOOL Deconnect=((nFlags&0x4000)==0)&&ArchMode;
  
  switch(nChar) {
  case VK_LEFT  :
    if(Deconnect) DeconnectSelected();
    MoveSelected(-1,0);
    break;
  case VK_RIGHT :
    if(Deconnect) DeconnectSelected();
    MoveSelected(1,0);
    break;
  case VK_UP    :
    if(Deconnect) DeconnectSelected();
    MoveSelected(0,-1);
    break;
  case VK_DOWN  :
    if(Deconnect) DeconnectSelected();
    MoveSelected(0,1);
    break;
  }

	CScrollView::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CArchView::OnKeyUp(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  switch(nChar) {
  case VK_LEFT  :
    ConnectSelected();
    break;
  case VK_RIGHT :
    ConnectSelected();
    break;
  case VK_UP    :
    ConnectSelected();
    break;
  case VK_DOWN  :
    ConnectSelected();
    break;
  }
	
	CScrollView::OnKeyUp(nChar, nRepCnt, nFlags);
}

void CArchView::DeconnectSelected() 
{
  pDoc->SetModifiedFlag();
  for(int n=0; n<sizeof(pDoc->Element)/sizeof(CElement*); n++) {
    if(pDoc->Element[n]==NULL) continue;
    if(!pDoc->Element[n]->get_bArchSelected()) continue;
    DeconnectElement(n);
  }
}

void CArchView::ConnectSelected()
{
  if(ArchMode) {
    for(int i=0; i<sizeof(pDoc->Element)/sizeof(CElement*); i++) {
      if(pDoc->Element[i]==NULL) continue;
      if((!CopyMode&&pDoc->Element[i]->get_bArchSelected())||CopyMode)
        FindIntersections(pDoc->Element[i]);
    }
  }
}

LPARAM CArchView::OnSetInstrCounter(WPARAM Value,LPARAM hElement)
{
  return SetInstrCounter((DWORD)hElement,Value);
}

LPARAM CArchView::OnKillInstrCounter(WPARAM Void,LPARAM hElement)
{
  return KillInstrCounter((DWORD)hElement);
}

void CArchView::OnTimer(UINT nIDEvent) 
{
	char sCounter[20];
  int Sec=(int)(theApp.pEmData->Takts*6/theApp.Data.TaktFreq);
  int Min=Sec/60;
  int Hour=Min/60;
  Sec=Sec%60;
  Min=Min%60;
  sprintf(sCounter,"CPU: %02u:%02u:%02u",Hour,Min,Sec);
  //CString sCounter;
  //sCounter.Format("%I64u",theApp.pEmData->Takts);
  m_StatusBar.SetPaneText(1,sCounter);

	//CScrollView::OnTimer(nIDEvent);
}

BOOL CArchView::CreateElementButtons()
{
  CToolBarCtrl &TBCtrl=ToolBar.GetToolBarCtrl();
  //CToolTipCtrl* pTTCtrl=TBCtrl.GetToolTips();

  CString LibGUID,ClsGUID;
  LONG Index=0,ElIndex=0;
  while (theApp.EnumElemLibs(Index,&LibGUID,&ClsGUID)) {
    CElemLib *pElemLib=new CElemLib;
    pElemLib->CreateInstance(LibGUID);

    if(pElemLib->get_nElementsCount()==0) { Index++; continue; }
    for(DWORD n=0; n<pElemLib->get_nElementsCount(); n++) {
      CString ElemName;
      pElemLib->GetElementName(n,ElemName);
      BtnBmp[ElIndex]=CBitmap::FromHandle(pElemLib->GetElementIcon(n));

      TBBUTTON Btn={TBCtrl.AddBitmap(1,BtnBmp[ElIndex]),ID_ADD_ELEMENT0+ElIndex,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0};
      TBCtrl.InsertButton(0,&Btn);
      ElIndex++;
      //pTTCtrl->AddTool(&TBCtrl,"1",NULL,ID_ADD_ELEMENT0+ElIndex);
    }

    CString SubMenuName;
    pElemLib->get_sLibraryName(SubMenuName);
    
    delete pElemLib;
    Index++;
  }

  return TRUE;
}
