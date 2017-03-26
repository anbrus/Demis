// Button.cpp: implementation of the CADCElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "ADCElement.h"
#include "ElemInterf.h"
#include "..\definitions.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CADCElement::CADCElement(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
{
  IdIndex=8;
  SliderState=0; Delay=10; StartState=0; ReadyState=0;
  LoLimit="0.00"; HiLimit="10.24";
  HiPrecision=FALSE;

  pArchElemWnd=new CADCArchWnd(this);
  pConstrElemWnd=new CADCConstrWnd(this);

  ChangePinConfiguration();

  HINSTANCE hInstOld=AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_ADC_MENU);
	PopupMenu.CheckMenuItem(ID_HI_PRECISION,MF_BYCOMMAND|MF_UNCHECKED);
	AfxSetResourceHandle(hInstOld);
}

CADCElement::~CADCElement()
{
}

BOOL CADCElement::Load(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"АЦП: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }
  File.Read(&Delay,sizeof(Delay));
  
  int StrLen;
  char s[16];
  
  File.Read(&StrLen,4);
  if(StrLen>15) return FALSE;
  File.Read(&s,StrLen);
  s[StrLen]=0;
  LoLimit=s;

  File.Read(&StrLen,4);
  if(StrLen>15) return FALSE;
  File.Read(&s,StrLen);
  s[StrLen]=0;
  HiLimit=s;

  File.Read(&HiPrecision,4);

  if(HiPrecision)
    PopupMenu.CheckMenuItem(ID_HI_PRECISION,MF_BYCOMMAND|MF_CHECKED);
  else
    PopupMenu.CheckMenuItem(ID_HI_PRECISION,MF_BYCOMMAND|MF_UNCHECKED);

  return CElement::Load(hFile);
}

BOOL CADCElement::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&Delay,sizeof(Delay));

  int StrLen;

  StrLen=LoLimit.GetLength();
  if(StrLen>15) StrLen=15;
  File.Write(&StrLen,4);
  File.Write((LPCTSTR)LoLimit,StrLen);

  StrLen=HiLimit.GetLength();
  if(StrLen>15) StrLen=15;
  File.Write(&StrLen,4);
  File.Write((LPCTSTR)HiLimit,StrLen);

  File.Write(&HiPrecision,4);

  return CElement::Save(hFile);
}

BOOL CADCElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"АЦП",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),pArchParentWnd,0);
  pConstrElemWnd->Create(ClassName,"АЦП",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pConstrElemWnd->Size.cx,pConstrElemWnd->Size.cy),pConstrParentWnd,0);

  ChangePinConfiguration();
  ((CADCArchWnd*)pArchElemWnd)->SetRange(HiPrecision);
  ((CADCConstrWnd*)pConstrElemWnd)->SetRange(HiPrecision);

  UpdateTipText();

  return TRUE;
}

BOOL CADCElement::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  SliderState=0; StartState=0; ReadyState=0;
  DelayTakts=Delay*(TaktFreq/1000)/6;
  StartState=0;

  return CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CADCArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CADCArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CADCArchWnd)
	ON_WM_CREATE()
	ON_WM_VSCROLL()
	ON_COMMAND(ID_DELAY, OnDelay)
	ON_COMMAND(ID_LIMITS, OnLimits)
	ON_COMMAND(ID_HI_PRECISION, OnHiPrecision)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CADCArchWnd::CADCArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=60+6+16;
  Size.cy=8*15+2*10;
}

CADCArchWnd::~CADCArchWnd()
{
}

//////////////////////////////////////////////////////////////////////
// CADCConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CADCConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CADCConstrWnd)
	ON_WM_CREATE()
	ON_WM_VSCROLL()
	ON_COMMAND(ID_DELAY, OnDelay)
	ON_COMMAND(ID_LIMITS, OnLimits)
	ON_COMMAND(ID_HI_PRECISION, OnHiPrecision)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CADCConstrWnd::CADCConstrWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=29+31;
  Size.cy=92;
}

CADCConstrWnd::~CADCConstrWnd()
{
}

void CADCConstrWnd::Draw(CDC *pDC)
{
  DWORD Value=((CADCElement*)pElement)->SliderState;
  if(((CADCElement*)pElement)->HiPrecision) Slider.SetPos(65535-Value);
  else Slider.SetPos(255-Value);

  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);

  CRect MainRect(0,0,Size.cx,Size.cy);
  if(pElement->ConstrSelected)
    pDC->FrameRect(MainRect,&SelectBrush);
  else pDC->FrameRect(MainRect,&NormalBrush);

  CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
  CGdiObject* pOldBrush=pDC->SelectObject(&GrayBrush);
  pDC->PatBlt(29,1,Size.cx-29-1,Size.cy-2,PATCOPY);
  pDC->SelectObject(pOldBrush);

  CFont DrawFont;
  DrawFont.CreatePointFont(80,"Arial Cyr");
  CGdiObject* pOldFont=pDC->SelectObject(&DrawFont);

  if(pElement->ConstrSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);

  pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
  //Подписи к слайдеру
  pDC->DrawText(((CADCElement*)pElement)->LoLimit, CRect(30,Size.cy-18,Size.cx-1,Size.cy-7),
    DT_LEFT|DT_SINGLELINE|DT_BOTTOM);
  pDC->DrawText(((CADCElement*)pElement)->HiLimit, CRect(30,1,Size.cx-1,21),
    DT_LEFT|DT_SINGLELINE|DT_BOTTOM);

  pDC->SelectObject(pOldFont);
}

void CADCArchWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldPen,*pOldFont;
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);
  CPen* pTempPen;
  if(pElement->ArchSelected)
    pTempPen=&theApp.SelectPen;
  else pTempPen=&theApp.DrawPen;
  pOldPen=pDC->SelectObject(pTempPen);
  pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));

  CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
  CGdiObject* pOldBrush=pDC->SelectObject(&GrayBrush);
  pDC->PatBlt(7,1,Size.cx-24,Size.cy-15,PATCOPY);
  pDC->SelectObject(pOldBrush);

  if(pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  
  CString Temp;

  CRect MainRect(6,0,Size.cx-6,Size.cy);
  if(pElement->ArchSelected)
    pDC->FrameRect(MainRect,&SelectBrush);
  else pDC->FrameRect(MainRect,&NormalBrush);
  pDC->MoveTo(Size.cx-17,0); pDC->LineTo(Size.cx-17,Size.cy-15);
  pDC->MoveTo(6,Size.cy-15); pDC->LineTo(Size.cx-6,Size.cy-15);
  pDC->MoveTo(Size.cx/2,Size.cy-15); pDC->LineTo(Size.cx/2,Size.cy);
  
  //Рисуем проводки
  CFont DrawFont;
  DrawFont.CreatePointFont(80,"Arial Cyr");
  pOldFont=pDC->SelectObject(&DrawFont);
  for(int n=0; n<pElement->PointCount; n++) {
    pDC->SelectObject(pTempPen);
    if(n==0) {
      pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
      pDC->LineTo(pElement->ConPoint[n].x+4,pElement->ConPoint[n].y);
    }else {
      pDC->MoveTo(pElement->ConPoint[n].x-4,pElement->ConPoint[n].y);
      pDC->LineTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
    }

    //Рисуем крестик, если надо
    if(!pElement->ConPin[n]) {
      pDC->SelectObject(&BluePen);
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y-2);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y+3);
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y+2);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y-3);
    }else { //или палочку
      pDC->SelectObject(pTempPen);
      if(n==0) {
        pDC->MoveTo(0,pElement->ConPoint[n].y);
        pDC->LineTo(pElement->ConPoint[n].x+1,pElement->ConPoint[n].y);
      }else {
        pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y);
        pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y);
      }
    }
  }
  //Текст внутри порта
  pDC->DrawText("ADC",CRect(7,5,Size.cx-16,18),
    DT_CENTER|DT_SINGLELINE|DT_VCENTER);

  //Подписи к слайдеру
  pDC->DrawText(((CADCElement*)pElement)->LoLimit,
    CRect(37,Size.cy-37,Size.cx-16,Size.cy-22),
    DT_LEFT|DT_SINGLELINE|DT_BOTTOM);
  pDC->DrawText(((CADCElement*)pElement)->HiLimit,
    CRect(37,40,Size.cx-16,52),
    DT_LEFT|DT_SINGLELINE|DT_TOP);

  pDC->SetBkColor(theApp.BkColor);
  pDC->DrawText("Start",CRect(8,Size.cy-12,30,Size.cy-1),
    DT_LEFT|DT_SINGLELINE|DT_BOTTOM);
  pDC->DrawText("Rdy",CRect(Size.cx-36,Size.cy-12,Size.cx-9,Size.cy-1),
    DT_RIGHT|DT_SINGLELINE|DT_BOTTOM);

  DrawValue(pDC);

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
  pDC->SelectObject(pOldFont);
}

void CADCElement::UpdateTipText()
{
  TipText="АЦП";
}

DWORD CADCElement::GetPinState()
{
  DWORD Res=0;
  if(ReadyState) Res=(SliderState<<2)|(ReadyState<<1)|StartState;
  else Res=StartState;

  return Res;
}

int CADCArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CElementWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
  SetWindowRgn(ADCRgn,FALSE);

  Slider.Create(TBS_VERT|TBS_RIGHT|TBS_AUTOTICKS|WS_VISIBLE|WS_CHILD,
    CRect(7,33,36,Size.cy-15),this,1);
  Slider.SetRange(0,255);
  Slider.SetPageSize(64);
  Slider.SetTicFreq(64);
  Slider.SetPos(255);
	
	return 0;
}

int CADCConstrWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CElementWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
  Slider.Create(TBS_VERT|TBS_RIGHT|TBS_AUTOTICKS|WS_VISIBLE|WS_CHILD,
    CRect(1,1,29,Size.cy-1),this,1);
  Slider.SetRange(0,255);
  Slider.SetPageSize(64);
  Slider.SetTicFreq(64);
  Slider.SetPos(255);
	
	return 0;
}

void CADCArchWnd::DrawValue(CDC *pDC)
{
  DWORD Value=((CADCElement*)pElement)->SliderState;
  if(((CADCElement*)pElement)->HiPrecision) Slider.SetPos(65535-Value);
  else Slider.SetPos(255-Value);

  CGdiObject *pOldFont;
  CFont DrawFont;
  DrawFont.CreatePointFont(80,"Arial Cyr");
  pOldFont=pDC->SelectObject(&DrawFont);
  pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
  if(pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  CString Temp;
  Temp.Format("(%04Xh)",Value);
  pDC->DrawText(Temp,CRect(7,18,Size.cx-16,31),
    DT_CENTER|DT_SINGLELINE|DT_VCENTER);

  pDC->SetBkColor(theApp.BkColor);
  if(pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);

  DWORD CurVal=pElement->GetPinState()>>2;
  for(int n=0; n<pElement->PointCount-2; n++) {
    if(n<10) Temp.Format("%x",n);
    //else Temp='a'+(n-10);
    if(!pElement->EditMode) {
      if(CurVal&(1<<n)) pDC->SetTextColor(theApp.SelectColor);
      else pDC->SetTextColor(theApp.DrawColor);
    }
    pDC->DrawText(Temp,CRect(Size.cx-14,4+n*15,Size.cx-7,18+n*15),DT_SINGLELINE);
  }
  //Восстанавливаем контекст
  pDC->SelectObject(pOldFont);

  Slider.RedrawWindow();
}

void CADCArchWnd::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
  if(((CADCElement*)pElement)->HiPrecision) ((CADCElement*)pElement)->SliderState=65535-Slider.GetPos();
  else ((CADCElement*)pElement)->SliderState=255-Slider.GetPos();
  CClientDC DC(this);
  DrawValue(&DC);
	
	//CElementWnd::OnVScroll(nSBCode, nPos, pScrollBar);
}

void CADCConstrWnd::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
  if(((CADCElement*)pElement)->HiPrecision) ((CADCElement*)pElement)->SliderState=65535-Slider.GetPos();
  else ((CADCElement*)pElement)->SliderState=255-Slider.GetPos();
}

void CADCArchWnd::OnDelay() 
{
	((CADCElement*)pElement)->OnDelay();
}

void CADCConstrWnd::OnDelay() 
{
	((CADCElement*)pElement)->OnDelay();
}

void CADCElement::OnDelay()
{
  CADCDelayDlg Dlg;
  Dlg.Delay=Delay;
  if(Dlg.DoModal()==IDOK) {
    Delay=Dlg.Delay;
    ModifiedFlag=TRUE;
  }
}
/////////////////////////////////////////////////////////////////////////////
// CADCDelayDlg dialog


CADCDelayDlg::CADCDelayDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CADCDelayDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCDelayDlg)
	Delay = 0;
	//}}AFX_DATA_INIT
}


void CADCDelayDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CADCDelayDlg)
	DDX_Text(pDX, IDC_DELAY, Delay);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CADCDelayDlg, CDialog)
	//{{AFX_MSG_MAP(CADCDelayDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CADCDelayDlg message handlers

void CADCElement::SetPinState(DWORD NewState)
{
  DWORD OldStartState=StartState;
  StartState=NewState&1;

  //Если фронт
  if((OldStartState!=StartState)&(OldStartState==0)) {
    if(DelayTakts) {
      ReadyState=0;
      pArchParentWnd->SendMessage(WMU_SET_INSTRCOUNTER,DelayTakts,(LPARAM)pInterface->hElement);
    }else {
      ReadyState=1;
    }
  }

  pArchParentWnd->SendMessage(WMU_PINSTATECHANGED,GetPinState(),
    (LPARAM)pInterface->hElement);

  if(pArchElemWnd->IsWindowEnabled()) {
    CClientDC ArchDC(pArchElemWnd);
    ((CADCArchWnd*)pArchElemWnd)->DrawValue(&ArchDC);
  }
}

void CADCConstrWnd::OnLimits() 
{
	((CADCElement*)pElement)->OnLimits();
}

void CADCArchWnd::OnLimits() 
{
	((CADCElement*)pElement)->OnLimits();
}

void CADCElement::OnLimits()
{
  CADCLimitsDlg Dlg;
  Dlg.m_LoLimit=LoLimit;
  Dlg.m_HiLimit=HiLimit;
  if(Dlg.DoModal()==IDOK) {
    LoLimit=Dlg.m_LoLimit;
    HiLimit=Dlg.m_HiLimit;
    pArchElemWnd->RedrawWindow();
    pConstrElemWnd->RedrawWindow();
    ModifiedFlag=TRUE;
  }
}
/////////////////////////////////////////////////////////////////////////////
// CADCLimitsDlg dialog


CADCLimitsDlg::CADCLimitsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CADCLimitsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CADCLimitsDlg)
	m_HiLimit = _T("");
	m_LoLimit = _T("");
	//}}AFX_DATA_INIT
}


void CADCLimitsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CADCLimitsDlg)
	DDX_Text(pDX, IDC_HILIMIT, m_HiLimit);
	DDV_MaxChars(pDX, m_HiLimit, 5);
	DDX_Text(pDX, IDC_LOLIMIT, m_LoLimit);
	DDV_MaxChars(pDX, m_LoLimit, 5);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CADCLimitsDlg, CDialog)
	//{{AFX_MSG_MAP(CADCLimitsDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CADCLimitsDlg message handlers

void CADCElement::OnInstrCounterEvent()
{
  ReadyState=1;

  pArchParentWnd->SendMessage(WMU_PINSTATECHANGED,GetPinState(),
    (LPARAM)pInterface->hElement);

  if(pArchElemWnd->IsWindowEnabled()) {
    CClientDC ArchDC(pArchElemWnd);
    ((CADCArchWnd*)pArchElemWnd)->DrawValue(&ArchDC);
  }
}

void CADCArchWnd::OnHiPrecision()
{
	((CADCElement*)pElement)->OnHiPrecision();
}

void CADCConstrWnd::OnHiPrecision()
{
	((CADCElement*)pElement)->OnHiPrecision();
}

void CADCElement::OnHiPrecision()
{
	HiPrecision=!HiPrecision;
  if(HiPrecision)
    PopupMenu.CheckMenuItem(ID_HI_PRECISION,MF_BYCOMMAND|MF_CHECKED);
  else
    PopupMenu.CheckMenuItem(ID_HI_PRECISION,MF_BYCOMMAND|MF_UNCHECKED);
  
  ChangePinConfiguration();

  ((CADCArchWnd*)pArchElemWnd)->SetRange(HiPrecision);
  ((CADCConstrWnd*)pConstrElemWnd)->SetRange(HiPrecision);
  pArchElemWnd->Invalidate();
  pConstrElemWnd->Invalidate();

  ModifiedFlag=TRUE;
}

void CADCElement::ChangePinConfiguration()
{
  //0-Start, 1-Ready, 2-...-Data
  if(HiPrecision) PointCount=18;
  else PointCount=10;

  ConPoint[0].x=2; ConPoint[0].y=(PointCount-2)*15+2*10-7;
  ConPin[0]=FALSE; PinType[0]=PT_INPUT;

  ConPoint[1].x=pArchElemWnd->Size.cx-3;
  ConPoint[1].y=PointCount*15-5-12;
  ConPin[1]=FALSE; PinType[1]=PT_OUTPUT;

  for(int n=2; n<PointCount; n++) {
    ConPoint[n].x=pArchElemWnd->Size.cx-3;
    ConPoint[n].y=n*15-20;
    ConPin[n]=FALSE; PinType[n]=PT_OUTPUT;
  }
}

void CADCArchWnd::SetRange(BOOL HiPrecision)
{
  if(HiPrecision) {
    Slider.SetRange(0,65535);
    Size.cx=60+6+16;
    Size.cy=16*15+2*10;
  }else {
    Slider.SetRange(0,255);
    Size.cx=60+6+16;
    Size.cy=8*15+2*10;
  }

  if(ADCRgn.m_hObject) {
    SetWindowRgn(NULL,FALSE);
    ADCRgn.DeleteObject();
  }

  CPoint Pnts[]={
    CPoint(6,0),
    CPoint(Size.cx,0),
    CPoint(Size.cx,Size.cy),
    CPoint(0,Size.cy),
    CPoint(0,Size.cy-15),
    CPoint(6,Size.cy-15)
  };
  ADCRgn.CreatePolygonRgn(Pnts,sizeof(Pnts)/sizeof(CPoint),WINDING);
  SetWindowRgn(ADCRgn,FALSE);

  WINDOWPLACEMENT Pls;
  GetWindowPlacement(&Pls);
  MoveWindow(Pls.rcNormalPosition.left,Pls.rcNormalPosition.top,Size.cx,Size.cy);
  Slider.MoveWindow(7,33,29,Size.cy-15-33);

  GetParent()->Invalidate();
}

void CADCConstrWnd::SetRange(BOOL HiPrecision)
{
  if(HiPrecision) Slider.SetRange(0,65535);
  else Slider.SetRange(0,255);
}
