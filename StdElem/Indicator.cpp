// Indicator.cpp: implementation of the CIndicator class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "Indicator.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndicator::CIndicator(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
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

  TipText="Семисегментный индикатор";
  IdIndex=5;
  ActiveHigh=TRUE; HighLight=0;

  pArchElemWnd=new CIndArchWnd(this);
  pConstrElemWnd=new CIndConstrWnd(this);

  PointCount=8;
  for(int n=0; n<PointCount; n++) {
    ConPoint[n].x=2;
    ConPoint[n].y=10+n*15;
    ConPin[n]=FALSE;
    PinType[n]=PT_INPUT;
  }

	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_IND_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
}

CIndicator::~CIndicator()
{
}

BOOL CIndicator::Load(HANDLE hFile)
{
  CFile File(hFile);
  
  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Индикатор: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
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

BOOL CIndicator::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&ActiveHigh,4);

  return CElement::Save(hFile);
}

BOOL CIndicator::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"Индикатор",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),pArchParentWnd,0);
  pConstrElemWnd->Create(ClassName,"Индикатор",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pConstrElemWnd->Size.cx,pConstrElemWnd->Size.cy),pConstrParentWnd,0);

  return TRUE;
}

BOOL CIndicator::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);

  if(ActiveHigh) HighLight=0;
  else HighLight=0xFFFFFFFF;
  if(bEditMode) HighLight=0;

  return TRUE;
}

//////////////////////////////////////////////////////////////////////
// CIndArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndArchWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndArchWnd::CIndArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=60;
  Size.cy=125;
}

CIndArchWnd::~CIndArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CIndConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CIndConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CIndConstrWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIndConstrWnd::CIndConstrWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=35;
  Size.cy=45;
}

CIndConstrWnd::~CIndConstrWnd()
{
}

void CIndicator::OnActiveHigh() 
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
  ActiveHigh=TRUE;
  ModifiedFlag=TRUE;
}

void CIndicator::OnActiveLow() 
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_CHECKED);
  ActiveHigh=FALSE;
  ModifiedFlag=TRUE;
}

void CIndArchWnd::OnActiveHigh() 
{
	((CIndicator*)pElement)->OnActiveHigh();
}

void CIndArchWnd::OnActiveLow() 
{
	((CIndicator*)pElement)->OnActiveLow();
}

void CIndConstrWnd::OnActiveHigh() 
{
	((CIndicator*)pElement)->OnActiveHigh();
}

void CIndConstrWnd::OnActiveLow() 
{
	((CIndicator*)pElement)->OnActiveLow();
}

void CIndicator::DrawSegments(CDC *pDC,CBrush* pBkBrush,CPoint Pos,DWORD OldValue)
{
  CBrush LightBrush(RGB(255,0,0));
  CGdiObject *pOldPen,*pOldBrush=pDC->SelectObject(pBkBrush);
  CPen Pen(PS_SOLID,0,GetSysColor(COLOR_3DSHADOW));
  if(!EditMode) pOldPen=pDC->SelectObject(&Pen);
  for(int n=0; n<8; n++) {
    if((HighLight&(1<<n))==(OldValue&(1<<n))) continue;
    if(HighLight&(1<<n)) pDC->SelectObject(&LightBrush);
    else pDC->SelectObject(pBkBrush);
    CPoint SegImage[6];
    memcpy(SegImage,IndImage[n],sizeof(SegImage));
    for(int i=0; i<6; i++) SegImage[i]+=Pos;
    pDC->Polygon(SegImage,6);
  }
  pDC->SelectObject(pOldBrush);
  if(!EditMode) pDC->SelectObject(pOldPen);
}

void CIndArchWnd::DrawValue(CDC *pDC,DWORD OldValue)
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
  for(int n=0; n<8; n++) {
    if((((CIndicator*)pElement)->HighLight&(1<<n))==
      (OldValue&(1<<n))) continue;
    Temp.Format("%c",'a'+n);
    if(!pElement->EditMode) {
      if((((CIndicator*)pElement)->HighLight&(1<<n))^
        ((((CIndicator*)pElement)->ActiveHigh ? 0 : 1)<<n))
        pDC->SetTextColor(theApp.SelectColor);
      else pDC->SetTextColor(theApp.DrawColor);
    }
    pDC->DrawText(Temp,CRect(8,3+n*15,16,15+n*15),DT_SINGLELINE);
  }
  if(pElement->ArchSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  ((CIndicator*)pElement)->DrawSegments(pDC,&BkBrush,CPoint(21,40),OldValue);

  pDC->SelectObject(pOldPen);
  pDC->SelectObject(pOldFont);
}

void CIndConstrWnd::DrawValue(CDC *pDC,DWORD OldValue)
{
  CGdiObject *pOldPen;
  if(pElement->ConstrSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  ((CIndicator*)pElement)->DrawSegments(pDC,&theApp.BkBrush,CPoint(0,0),OldValue);

  pDC->SelectObject(pOldPen);
}

void CIndConstrWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldPen;
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);

  if(pElement->ConstrSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  DrawValue(pDC,~((CIndicator*)pElement)->HighLight);

  /*if(pElement->ElementInfo.ConstrElem.bSelected)
    pDC->FrameRect(&MainRect,&SelectBrush);
  else pDC->FrameRect(&MainRect,&NormalBrush);*/

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

void CIndArchWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldPen;
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);

  if(pElement->ArchSelected)
    pDC->FrameRect(CRect(6,0,Size.cx,Size.cy),&SelectBrush);
  else pDC->FrameRect(CRect(6,0,Size.cx,Size.cy),&NormalBrush);

  CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
  CGdiObject* pOldBrush=pDC->SelectObject(&GrayBrush);
  pDC->PatBlt(17,1,Size.cx-18,Size.cy-2,PATCOPY);
  pDC->SelectObject(pOldBrush);

  CPen* pTempPen;
  if(pElement->ArchSelected) pTempPen=&theApp.SelectPen;
	else pTempPen=&theApp.DrawPen;
  pOldPen=pDC->SelectObject(pTempPen);

  pDC->MoveTo(16,0);
  pDC->LineTo(16,Size.cy);
  
  DrawValue(pDC,~((CIndicator*)pElement)->HighLight);

  //Рисуем проводки
  for(int n=0; n<8; n++) {
    pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
    pDC->LineTo(pElement->ConPoint[n].x+4,pElement->ConPoint[n].y);
  }
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

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

void CIndicator::SetPinState(DWORD NewState)
{
  DWORD OldHighLight=HighLight;
  if(ActiveHigh) HighLight=NewState;
  else HighLight=~NewState;
  if(OldHighLight==HighLight) return;

  if(pArchElemWnd->IsWindowEnabled()) {
    CClientDC ArchDC(pArchElemWnd);
    ((CIndArchWnd*)pArchElemWnd)->DrawValue(&ArchDC,OldHighLight);
  }
  if(pConstrElemWnd->IsWindowEnabled()) {
    CClientDC ConstrDC(pConstrElemWnd);
    ((CIndConstrWnd*)pConstrElemWnd)->DrawValue(&ConstrDC,OldHighLight);
  }
}

DWORD CIndicator::GetPinState()
{
  return ActiveHigh ? HighLight : ~HighLight;
}
