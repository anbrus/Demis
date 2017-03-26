// Indicator.cpp: implementation of the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "IndicatorDyn.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndicatorDyn::CIndicatorDyn(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
  , PinState(0)
{
  int IndWidth=34;
  int IndHeight=44;

  POINT TempImg[8][6]={
    {//0
      { 2,          2 },
      { 4,          4 },
      { 4,          IndHeight/2-2 },
      { 2,          IndHeight/2 },
      { 0,          IndHeight/2-2 },
      { 0,          4 }
    },
    {//1
      { 2,          2 },
      { 4,          0 },
      { IndWidth-14,0 },
      { IndWidth-12,2 },
      { IndWidth-14,4 },
      { 4,          4 }
    },
    {//2
      { IndWidth-12,2 },
      { IndWidth-10,4 },
      { IndWidth-10,IndHeight/2-2 },
      { IndWidth-12,IndHeight/2 },
      { IndWidth-14,IndHeight/2-2 },
      { IndWidth-14,4 }
    },
    {//3
      { IndWidth-12,IndHeight/2 },
      { IndWidth-10,IndHeight/2+2 },
      { IndWidth-10,IndHeight-4 },
      { IndWidth-12,IndHeight-2 },
      { IndWidth-14,IndHeight-4 },
      { IndWidth-14,IndHeight/2+2 }
    },
    {//4
      { 2,          IndHeight-2 },
      { 4,          IndHeight-4 },
      { IndWidth-14,IndHeight-4 },
      { IndWidth-12,IndHeight-2 },
      { IndWidth-14,IndHeight-0 },
      { 4,          IndHeight-0 }
    },
    {//5
      { 2,          IndHeight/2 },
      { 4,          IndHeight/2+2 },
      { 4,          IndHeight-4 },
      { 2,          IndHeight-2 },
      { 0,          IndHeight-4 },
      { 0,          IndHeight/2+2 }
    },
    {//6
      { 2,          IndHeight/2 },
      { 4,          IndHeight/2-2 },
      { IndWidth-14,IndHeight/2-2 },
      { IndWidth-12,IndHeight/2 },
      { IndWidth-14,IndHeight/2+2 },
      { 4,          IndHeight/2+2 }
    },
    {//7
      { IndWidth-5, IndHeight-5 },
      { IndWidth-0, IndHeight-5 },
      { IndWidth-0, IndHeight-0 },
      { IndWidth-5, IndHeight-0 },
      { IndWidth-5, IndHeight-0 },
      { IndWidth-5, IndHeight-0 },
    }
  };

  memcpy(IndImage,TempImg,sizeof(TempImg));

  TipText="Семисегм. дин. индикатор";
  IdIndex=6;
  ActiveHigh=TRUE; HighLight=0; AfterLightTime=3;

  pArchElemWnd=new CIndDArchWnd(this);
  pConstrElemWnd=new CIndDConstrWnd(this);

  PointCount=9;
  for(int n=0; n<8; n++) {
    ConPoint[n].x=2;
    ConPoint[n].y=10+n*15;
    ConPin[n]=FALSE;
    PinType[n]=PT_INPUT;
  }

  ConPoint[8].x=30;
  ConPoint[8].y=128;
  ConPin[8]=FALSE;
  PinType[8]=PT_INPUT;

  PinState=0;
  for(int n=0; n<8; n++) {
    TimeToOff[n]=0;
  }


	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_IND_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
}

CIndicatorDyn::~CIndicatorDyn()
{
}

BOOL CIndicatorDyn::Load(HANDLE hFile)
{
  CFile File(hFile);
  
  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Индикатор динамический: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }

  File.Read(&ActiveHigh,4);
  if(ActiveHigh) {
  	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	  PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
  }else {
  	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_UNCHECKED);
	  PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_CHECKED);
  }

  return CElement::Load(hFile);
}

BOOL CIndicatorDyn::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&ActiveHigh,4);

  return CElement::Save(hFile);
}

BOOL CIndicatorDyn::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"Дин. индикатор",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),pArchParentWnd,0);
  pConstrElemWnd->Create(ClassName,"Дин. индикатор",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pConstrElemWnd->Size.cx,pConstrElemWnd->Size.cy),pConstrParentWnd,0);

  return TRUE;
}

BOOL CIndicatorDyn::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);

  HighLight=0;
  //if(ActiveHigh) HighLight=0;
  //else HighLight=0xFFFFFFFF;
  if(bEditMode) HighLight=0;

  for(int n=0; n<8; n++) TimeToOff[n]=0;
  if(pArchElemWnd->m_hWnd) {
    if(bEditMode) pArchElemWnd->KillTimer(1);
    else pArchElemWnd->SetTimer(1,40,NULL);
  }

  return TRUE;
}

//////////////////////////////////////////////////////////////////////
// CIndArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndDArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndDArchWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_WM_TIMER()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndDArchWnd::CIndDArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=60;
  Size.cy=131;
}

CIndDArchWnd::~CIndDArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CIndConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndDConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndDConstrWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndDConstrWnd::CIndDConstrWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=35;
  Size.cy=45;
}

CIndDConstrWnd::~CIndDConstrWnd()
{
}

void CIndicatorDyn::OnActiveHigh() 
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
  ActiveHigh=TRUE;
  ModifiedFlag=TRUE;
}

void CIndicatorDyn::OnActiveLow() 
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_CHECKED);
  ActiveHigh=FALSE;
  ModifiedFlag=TRUE;
}

void CIndDArchWnd::OnActiveHigh() 
{
	((CIndicatorDyn*)pElement)->OnActiveHigh();
}

void CIndDArchWnd::OnActiveLow() 
{
	((CIndicatorDyn*)pElement)->OnActiveLow();
}

void CIndDConstrWnd::OnActiveHigh() 
{
	((CIndicatorDyn*)pElement)->OnActiveHigh();
}

void CIndDConstrWnd::OnActiveLow() 
{
	((CIndicatorDyn*)pElement)->OnActiveLow();
}

void CIndicatorDyn::DrawSegments(CDC *pDC,CBrush* pBkBrush,CPoint Pos,DWORD OldHighLight)
{
  CBrush LightBrush(RGB(255,0,0));
  CGdiObject *pOldPen,*pOldBrush=pDC->SelectObject(pBkBrush);
  CPen Pen(PS_SOLID,0,GetSysColor(COLOR_3DSHADOW));
  if(!EditMode) pOldPen=pDC->SelectObject(&Pen);
  for(int n=0; n<8; n++) {
    BOOL NewBit=(HighLight>>n)&1;
    BOOL OldBit=(OldHighLight>>n)&1;
    if(NewBit==OldBit) continue;

    if(NewBit) pDC->SelectObject(&LightBrush);
    else pDC->SelectObject(pBkBrush);
    CPoint SegImage[6];
    memcpy(SegImage,IndImage[n],sizeof(SegImage));
    for(int i=0; i<6; i++) SegImage[i]+=Pos;
    pDC->Polygon(SegImage,6);
  }
  pDC->SelectObject(pOldBrush);
  if(!EditMode) pDC->SelectObject(pOldPen);
}

void CIndDArchWnd::DrawValue(CDC *pDC,DWORD OldPinState,DWORD OldHighLight)
{
  CGdiObject* pOldPen,*pOldFont;
  CBrush BkBrush(GetSysColor(COLOR_BTNFACE));
  CFont Font;
  Font.CreatePointFont(80,"Arial Cyr");
  pOldFont=pDC->SelectObject(&Font);
  pDC->SetBkColor(theApp.BkColor);
  if(pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  CString Temp;
  DWORD PinState=((CIndicatorDyn*)pElement)->GetPinState();
  for(int n=0; n<8; n++) {
    BOOL NewBit=PinState&1;
    BOOL OldBit=(OldPinState>>n)&1;
    if(NewBit==OldBit) continue;

    Temp.Format("%c",'a'+n);

    if(!pElement->EditMode) {
      if(NewBit) pDC->SetTextColor(theApp.SelectColor);
      else pDC->SetTextColor(theApp.DrawColor);
    }
    pDC->DrawText(Temp,CRect(8,3+n*15,16,15+n*15),DT_SINGLELINE);
    PinState>>=1;
  }
  if(pElement->ArchSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  ((CIndicatorDyn*)pElement)->DrawSegments(pDC,&BkBrush,CPoint(21,40),OldHighLight);

  pDC->SelectObject(pOldPen);
  pDC->SelectObject(pOldFont);
}

void CIndDConstrWnd::DrawValue(CDC *pDC,DWORD OldPinState,DWORD OldHighLight)
{
  CGdiObject *pOldPen;
  if(pElement->ConstrSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  ((CIndicatorDyn*)pElement)->DrawSegments(pDC,&theApp.BkBrush,CPoint(0,0),OldHighLight);

  pDC->SelectObject(pOldPen);
}

void CIndDConstrWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldPen;
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);

  if(pElement->ConstrSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  DrawValue(pDC,~((CIndicatorDyn*)pElement)->GetPinState(),~((CIndicatorDyn*)pElement)->HighLight);

  /*if(pElement->ElementInfo.ConstrElem.bSelected)
    pDC->FrameRect(&MainRect,&SelectBrush);
  else pDC->FrameRect(&MainRect,&NormalBrush);*/

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

void CIndDArchWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldPen;
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);

  if(pElement->ArchSelected)
    pDC->FrameRect(CRect(6,0,Size.cx,Size.cy-6),&SelectBrush);
  else pDC->FrameRect(CRect(6,0,Size.cx,Size.cy-6),&NormalBrush);

  CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
  CGdiObject* pOldBrush=pDC->SelectObject(&GrayBrush);
  pDC->PatBlt(17,1,Size.cx-18,Size.cy-8,PATCOPY);
  pDC->SelectObject(pOldBrush);

  CPen* pTempPen;
  if(pElement->ArchSelected) pTempPen=&theApp.SelectPen;
	else pTempPen=&theApp.DrawPen;
  pOldPen=pDC->SelectObject(pTempPen);

  pDC->MoveTo(16,0);
  pDC->LineTo(16,Size.cy-6);
  
  DrawValue(pDC,~((CIndicatorDyn*)pElement)->GetPinState(),~((CIndicatorDyn*)pElement)->HighLight);

  //Рисуем проводки
  for(int n=0; n<8; n++) {
    pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
    pDC->LineTo(pElement->ConPoint[n].x+4,pElement->ConPoint[n].y);
  }
  pDC->MoveTo(pElement->ConPoint[8].x,pElement->ConPoint[8].y);
  pDC->LineTo(pElement->ConPoint[8].x,pElement->ConPoint[8].y-4);

  for(int n=0; n<8; n++) {
    //Рисуем палочку или крестик
    if(pElement->ConPin[n]) {
      pDC->SelectObject(pTempPen);
      pDC->MoveTo(0,pElement->ConPoint[n].y);
      pDC->LineTo(6,pElement->ConPoint[n].y);
    }else {
      pDC->SelectObject(&BluePen);
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y-2);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y+3);
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y+2);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y-3);
    }
  }
  if(pElement->ConPin[8]) {
    pDC->SelectObject(pTempPen);
    pDC->MoveTo(pElement->ConPoint[8].x,pElement->ConPoint[8].y+2);
    pDC->LineTo(pElement->ConPoint[8].x,pElement->ConPoint[8].y-3);
  }else {
    pDC->SelectObject(&BluePen);
    pDC->MoveTo(pElement->ConPoint[8].x-2,pElement->ConPoint[8].y-2);
    pDC->LineTo(pElement->ConPoint[8].x+3,pElement->ConPoint[8].y+3);
    pDC->MoveTo(pElement->ConPoint[8].x-2,pElement->ConPoint[8].y+2);
    pDC->LineTo(pElement->ConPoint[8].x+3,pElement->ConPoint[8].y-3);
  }

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

void CIndicatorDyn::OnTimer(UINT idEvent)
{
  DWORD OldHighLight=HighLight;

  if(ActiveHigh) {
    HighLight=PinState&0x000000FF;
    if(PinState&0x00000100) HighLight=0x00000000;
  }else {
    HighLight=~(PinState&0x000000FF);
    if((PinState&0x00000100)==0) HighLight=0x00000000;
  }

  for(int n=0; n<8; n++) {
    if(HighLight&(1<<n)) { TimeToOff[n]=AfterLightTime; continue; }
    if(TimeToOff[n]==0) continue;

    TimeToOff[n]--;
    HighLight|=(1<<n);
  }

  if(HighLight!=OldHighLight) {
    if(pArchElemWnd->IsWindowEnabled()) {
      CClientDC ArchDC(pArchElemWnd);
      ((CIndDArchWnd*)pArchElemWnd)->DrawValue(&ArchDC,PinState,OldHighLight);
    }
    if(pConstrElemWnd->IsWindowEnabled()) {
      CClientDC ConstrDC(pConstrElemWnd);
      ((CIndDConstrWnd*)pConstrElemWnd)->DrawValue(&ConstrDC,PinState,OldHighLight);
    }
  }
}

void CIndicatorDyn::SetPinState(DWORD NewState)
{
  PinState=NewState;
  DWORD OldHighLight=HighLight;

  if(ActiveHigh) {
    HighLight=NewState&0x000000FF;
    if(NewState&0x00000100) HighLight=0x00000000;
  }else {
    HighLight=~(NewState&0x000000FF);
    if((NewState&0x00000100)==0) HighLight=0x00000000;
  }

  HighLight=HighLight;

  for(int n=0; n<8; n++) {
    if(HighLight&(1<<n)) { TimeToOff[n]=AfterLightTime; continue; }
    if(TimeToOff[n]==0) continue;

    HighLight|=(1<<n);
  }

  if(OldHighLight==HighLight) return;

  if(pArchElemWnd->IsWindowEnabled()) {
    CClientDC ArchDC(pArchElemWnd);
    ((CIndDArchWnd*)pArchElemWnd)->DrawValue(&ArchDC,NewState,OldHighLight);
  }
  if(pConstrElemWnd->IsWindowEnabled()) {
    CClientDC ConstrDC(pConstrElemWnd);
    ((CIndDConstrWnd*)pConstrElemWnd)->DrawValue(&ConstrDC,NewState,OldHighLight);
  }
}

DWORD CIndicatorDyn::GetPinState()
{
  return PinState;
}

void CIndDArchWnd::OnTimer(UINT nIDEvent) 
{
	((CIndicatorDyn*)pElement)->OnTimer(nIDEvent);
}
