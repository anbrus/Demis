// KbdElement.cpp: implementation of the CKbdElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "KbdElement.h"
#include "ElemInterf.h"
#include "..\definitions.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

BEGIN_MESSAGE_MAP(CKbdArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CKbdArchWnd)
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_COMMAND(ID_DREBEZG, OnDrebezg)
	ON_COMMAND(ID_KBD_CAPTIONS, OnKbdCaptions)
	ON_COMMAND(ID_KBD_SIZE, OnKbdSize)
	ON_COMMAND(ID_FIXABLE, OnFixable)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

BEGIN_MESSAGE_MAP(CKbdConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CKbdConstrWnd)
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_COMMAND(ID_DREBEZG, OnDrebezg)
	ON_COMMAND(ID_KBD_CAPTIONS, OnKbdCaptions)
	ON_COMMAND(ID_KBD_SIZE, OnKbdSize)
	ON_COMMAND(ID_FIXABLE, OnFixable)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CKbdElement::CKbdElement(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
{
  IdIndex=7;
  KbdSize.cx=4; KbdSize.cy=4;
  //PointCount=KbdSize.cx+KbdSize.cy;
  memset(Pressed,FALSE,sizeof(Pressed));
  InputState=0; OutputState=0;
  Drebezg=FALSE; Fixable=FALSE;
  VibrCounter=0;

  pArchElemWnd=new CKbdArchWnd(this);
  pConstrElemWnd=new CKbdConstrWnd(this);

  for(int x=0; x<KbdSize.cx; x++) {
    for(int y=0; y<KbdSize.cy; y++) {
      Caption[x][y].Format("%d%d",y,KbdSize.cx-x-1);
    }
  }

	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_KBD_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);

  srand(GetTickCount());
}

CKbdElement::~CKbdElement()
{
}

CKbdArchWnd::CKbdArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  BtnSize.cx=15; BtnSize.cy=15;
  KeyOffset.x=12; KeyOffset.y=24;
  Size.cx=((CKbdElement*)pElement)->KbdSize.cx*BtnSize.cx+KeyOffset.x+14;
  Size.cy=(((CKbdElement*)pElement)->KbdSize.cx+
    ((CKbdElement*)pElement)->KbdSize.cy)*BtnSize.cy+KeyOffset.y;
}

CKbdArchWnd::~CKbdArchWnd()
{
}

CKbdConstrWnd::CKbdConstrWnd(CElement* pElement) : CElementWnd(pElement)
{
  BtnSize.cx=30; BtnSize.cy=30;
  Size.cx=((CKbdElement*)pElement)->KbdSize.cx*BtnSize.cx;
  Size.cy=((CKbdElement*)pElement)->KbdSize.cy*BtnSize.cy;
}

CKbdConstrWnd::~CKbdConstrWnd()
{
}

BOOL CKbdElement::Load(HANDLE hFile)
{
  CFile File(hFile);
  
  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Клавиатура: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }

  File.Read(&KbdSize.cx,sizeof(KbdSize.cx));
  File.Read(&KbdSize.cy,sizeof(KbdSize.cy));

  File.Read(&Drebezg,sizeof(Drebezg));
  PopupMenu.CheckMenuItem(ID_DREBEZG,MF_BYCOMMAND|
    (Drebezg ? MF_CHECKED : MF_UNCHECKED));

  File.Read(&Fixable,sizeof(Fixable));
  PopupMenu.CheckMenuItem(ID_FIXABLE,MF_BYCOMMAND|
    (Fixable ? MF_CHECKED : MF_UNCHECKED));

  BYTE Len;
  char Cap[6];
  for(int x=0; x<8; x++) {
    for(int y=0; y<8; y++) {
      File.Read(&Len,sizeof(Len));
      if(Len>sizeof(Cap)-1) return FALSE;
      File.Read(&Cap,Len);
      Cap[Len]=0;
      Caption[x][y]=Cap;
    }
  }

  return CElement::Load(hFile);
}

BOOL CKbdElement::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&KbdSize.cx,sizeof(KbdSize.cx));
  File.Write(&KbdSize.cy,sizeof(KbdSize.cy));

  File.Write(&Drebezg,sizeof(Drebezg));
  File.Write(&Fixable,sizeof(Fixable));

  BYTE Len;
  for(int x=0; x<8; x++) {
    for(int y=0; y<8; y++) {
      Len=Caption[x][y].GetLength();
      File.Write(&Len,sizeof(Len));
      File.Write((LPCTSTR)Caption[x][y],Len);
    }
  }

  return CElement::Save(hFile);
}

BOOL CKbdElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"Клавиатура",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),pArchParentWnd,0);
  pConstrElemWnd->Create(ClassName,"Клавиатура",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pConstrElemWnd->Size.cx,pConstrElemWnd->Size.cy),pConstrParentWnd,0);

  UpdateSize();
  UpdateTipText();

  return TRUE;
}

BOOL CKbdElement::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  memset(Pressed,FALSE,sizeof(Pressed));
  InputState=0; OutputState=0;
  VibrCounter=0;

  return CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);
}

void CKbdElement::UpdateTipText()
{
  TipText="Клавиатура";
}

void CKbdConstrWnd::Draw(CDC *pDC)
{
  CBrush FaceBrush(GetSysColor(COLOR_BTNFACE));
  CGdiObject* pOldBrush=pDC->SelectObject(&FaceBrush);
	pDC->PatBlt(0,0,Size.cx,Size.cy,PATCOPY);
  pDC->SelectObject(pOldBrush);

  if(pElement->ConstrSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  DWORD BkColor=GetSysColor(COLOR_BTNFACE);
  CGdiObject* pOldFont=pDC->SelectStockObject(ANSI_VAR_FONT);
  for(int x=0; x<((CKbdElement*)pElement)->KbdSize.cx; x++) {
    for(int y=0; y<((CKbdElement*)pElement)->KbdSize.cy; y++) {
      CRect BtnRect(x*BtnSize.cx,y*BtnSize.cy,
        (x+1)*BtnSize.cx,(y+1)*BtnSize.cy);
      if(((CKbdElement*)pElement)->Pressed[x][y]) {
        pDC->Draw3dRect(BtnRect,RGB(0,0,0),RGB(255,255,255));
        BtnRect.DeflateRect(4,4); BtnRect.OffsetRect(1,1);
        pDC->SetBkColor(BkColor);
        pDC->DrawText(((CKbdElement*)pElement)->Caption[x][y],
          BtnRect,DT_CENTER|DT_SINGLELINE|DT_VCENTER);
      }else {
        pDC->Draw3dRect(BtnRect,RGB(255,255,255),RGB(0,0,0));
        BtnRect.DeflateRect(4,4);
        pDC->SetBkColor(BkColor);
        pDC->DrawText(((CKbdElement*)pElement)->Caption[x][y],
          BtnRect,DT_CENTER|DT_SINGLELINE|DT_VCENTER);
      }
    }
  }
  pDC->SelectObject(pOldFont);
}

void CKbdArchWnd::Draw(CDC *pDC)
{
  CGdiObject* pOldPen;

  if(pElement->ArchSelected) {
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
    pDC->SetTextColor(theApp.SelectColor);
  }else {
    pOldPen=pDC->SelectObject(&theApp.DrawPen);
    pDC->SetTextColor(theApp.DrawColor);
  }

  CSize KbdSize(((CKbdElement*)pElement)->KbdSize);

  int x,y;
  
  CFont UFont;
  UFont.CreatePointFont(60,"Arial Cyr");
  CGdiObject* pOldFont=pDC->SelectObject(&UFont);
  if(pElement->FreePinLevel)
    pDC->DrawText("+5В",CRect(Size.cx-20,0,Size.cx,9),DT_RIGHT|DT_TOP|DT_SINGLELINE);
  else
    pDC->DrawText("GND",CRect(Size.cx-20,0,Size.cx,9),DT_RIGHT|DT_TOP|DT_SINGLELINE);
  pDC->SelectObject(pOldFont);

  pDC->MoveTo(KeyOffset.x+BtnSize.cx,9); pDC->LineTo(Size.cx,9);

  //Рисуем резисторы
  for(x=0; x<KbdSize.cx; x++) {
    int XCenter=KeyOffset.x+BtnSize.cx*(x+1);
    pDC->MoveTo(XCenter,9); pDC->LineTo(XCenter,13);
    pDC->Rectangle(XCenter-2,13,XCenter+3,KeyOffset.y-2);
    pDC->MoveTo(XCenter,KeyOffset.y-2); pDC->LineTo(XCenter,KeyOffset.y);
  }

  //Рисуем горизонтальные проводники
  for(y=0; y<KbdSize.cy; y++) {
    pDC->MoveTo(3,KeyOffset.y+12+y*BtnSize.cy);
    pDC->LineTo(KeyOffset.x+KbdSize.cx*BtnSize.cx,KeyOffset.y+12+y*BtnSize.cy);
  }

  //Рисуем вертикальные проводники
  for(x=0; x<KbdSize.cx; x++) {
    pDC->MoveTo(KeyOffset.x+BtnSize.cx*(x+1),KeyOffset.y);
    pDC->LineTo(KeyOffset.x+BtnSize.cx*(x+1),KeyOffset.y+(KbdSize.cx+KbdSize.cy-x)*BtnSize.cy-3);
    pDC->LineTo(Size.cx-3,KeyOffset.y+(KbdSize.cx+KbdSize.cy-x)*BtnSize.cy-3);
  }

  //Рисуем кнопки
  for(y=0; y<KbdSize.cy; y++) {
    for(x=0; x<KbdSize.cx; x++) {
      pDC->MoveTo(KeyOffset.x+x*BtnSize.cx+3,KeyOffset.y+(y+1)*BtnSize.cy-3);
      pDC->LineTo(KeyOffset.x+x*BtnSize.cx+3+4,KeyOffset.y+(y+1)*BtnSize.cy-4-3);

      if(((CKbdElement*)pElement)->Pressed[x][y]) {
        pDC->LineTo(KeyOffset.x+(x+1)*BtnSize.cx-3,KeyOffset.y+y*BtnSize.cy+3);
      }else {
        pDC->LineTo(KeyOffset.x+x*BtnSize.cx+3+4,KeyOffset.y+y*BtnSize.cy+2-1);
      }

      pDC->MoveTo(KeyOffset.x+(x+1)*BtnSize.cx-3,KeyOffset.y+y*BtnSize.cy+3);
      pDC->LineTo(KeyOffset.x+(x+1)*BtnSize.cx,KeyOffset.y+y*BtnSize.cy);
    }
  }

  //Рисуем крестики или палочки
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  for(int n=0; n<KbdSize.cx+KbdSize.cy; n++) {
    if(!pElement->ConPin[n]) {
      pDC->SelectObject(&BluePen);
      pDC->MoveTo(pElement->ConPoint[n].x-2,
        pElement->ConPoint[n].y-2);
      pDC->LineTo(pElement->ConPoint[n].x+3,
        pElement->ConPoint[n].y+3);
      pDC->MoveTo(pElement->ConPoint[n].x+2,
        pElement->ConPoint[n].y-2);
      pDC->LineTo(pElement->ConPoint[n].x-3,
        pElement->ConPoint[n].y+3);
    }else {
      pDC->SelectObject(&theApp.DrawPen);
      pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
      if(pElement->PinType[n]==PT_INPUT)
        pDC->LineTo(-1,pElement->ConPoint[n].y);
      else
        pDC->LineTo(Size.cx,pElement->ConPoint[n].y);
    }
  }

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

DWORD CKbdElement::GetPinState()
{
  return OutputState;
}

void CKbdElement::SetPinState(DWORD NewState)
{
  InputState=NewState&((1<<KbdSize.cy)-1);
  DWORD CurState=OutputState;
  RecalcOutputs();
  if(CurState!=OutputState) pArchParentWnd->SendMessage(WMU_PINSTATECHANGED,OutputState,
    (LPARAM)pInterface->hElement);
}

void CKbdElement::OnKeyPressed(CPoint Key,BOOL Pressed)
{
  if(Fixable) {
    if(Pressed) {
      this->Pressed[Key.x][Key.y]=!this->Pressed[Key.x][Key.y];
      LastChangedKey=Key;
    }
  }else {
    this->Pressed[Key.x][Key.y]=Pressed;
    LastChangedKey=Key;
  }

  if(Drebezg) {
    VibrCounter=((DWORD)rand()*500)/RAND_MAX+500; //500..1000 нс
    VibrCounter=VibrCounter*TaktFreq/6/1000000;
    pArchParentWnd->SendMessage(WMU_SET_INSTRCOUNTER,2,(LPARAM)pInterface->hElement);
  }

  RecalcOutputs();
  pArchParentWnd->SendMessage(WMU_PINSTATECHANGED,OutputState,(LPARAM)pInterface->hElement);
}

void CKbdArchWnd::OnLButtonDown(UINT nFlags, CPoint point) 
{
  if(!pElement->EditMode) {
    SetCapture();
    PressKey(point,TRUE);
    OldPoint=point;
  }else	CElementWnd::OnLButtonDown(nFlags, point);
}

void CKbdArchWnd::OnLButtonUp(UINT nFlags, CPoint point) 
{
  if(!pElement->EditMode) {
    if(GetCapture()!=this) return;
    ReleaseCapture();
    PressKey(OldPoint,FALSE);
  }else	CElementWnd::OnLButtonUp(nFlags, point);
}

void CKbdConstrWnd::OnLButtonDown(UINT nFlags, CPoint point) 
{
  if(!pElement->EditMode) {
    SetCapture();
    PressKey(point,TRUE);
    OldPoint=point;
  }else	CElementWnd::OnLButtonDown(nFlags, point);
}

void CKbdConstrWnd::OnLButtonUp(UINT nFlags, CPoint point) 
{
  if(!pElement->EditMode) {
    if(GetCapture()!=this) return;
    ReleaseCapture();
    PressKey(OldPoint,FALSE);
  }else	CElementWnd::OnLButtonUp(nFlags, point);
}

void CKbdConstrWnd::PressKey(CPoint point, BOOL Press)
{
  CPoint KeyPoint;
  KeyPoint.x=(point.x)/BtnSize.cx;
  KeyPoint.y=(point.y)/BtnSize.cy;
  if((KeyPoint.x<((CKbdElement*)pElement)->KbdSize.cx)&&
    (KeyPoint.y<((CKbdElement*)pElement)->KbdSize.cy)) {
    ((CKbdElement*)pElement)->OnKeyPressed(KeyPoint,Press);
    RedrawWindow(CRect(
      KeyPoint.x*BtnSize.cx,
      KeyPoint.y*BtnSize.cy,
      (KeyPoint.x+1)*BtnSize.cx,
      (KeyPoint.y+1)*BtnSize.cy));
    pElement->pArchElemWnd->RedrawWindow();
  }
}

void CKbdArchWnd::PressKey(CPoint point, BOOL Press)
{
  CPoint KeyPoint;
  KeyPoint.x=(point.x-KeyOffset.x)/BtnSize.cx;
  KeyPoint.y=(point.y-KeyOffset.y)/BtnSize.cy;
  if((KeyPoint.x<((CKbdElement*)pElement)->KbdSize.cx)&&
    (KeyPoint.y<((CKbdElement*)pElement)->KbdSize.cy)) {
    ((CKbdElement*)pElement)->OnKeyPressed(KeyPoint,Press);
    RedrawWindow(
      CRect(KeyPoint.x*BtnSize.cx+KeyOffset.x,
      KeyPoint.y*BtnSize.cy+KeyOffset.y,
      (KeyPoint.x+1)*BtnSize.cx+KeyOffset.x,
      (KeyPoint.y+1)*BtnSize.cy+KeyOffset.y));
    pElement->pConstrElemWnd->RedrawWindow();
  }
}

void CKbdArchWnd::OnDrebezg() 
{
  ((CKbdElement*)pElement)->OnDrebezg();
}

void CKbdArchWnd::OnKbdCaptions() 
{
  ((CKbdElement*)pElement)->OnKbdCaptions();
}

void CKbdConstrWnd::OnDrebezg() 
{
  ((CKbdElement*)pElement)->OnDrebezg();
}

void CKbdConstrWnd::OnKbdCaptions() 
{
  ((CKbdElement*)pElement)->OnKbdCaptions();
}

void CKbdElement::OnDrebezg()
{
  Drebezg=!Drebezg;
  PopupMenu.CheckMenuItem(ID_DREBEZG,MF_BYCOMMAND|
    (Drebezg ? MF_CHECKED : MF_UNCHECKED));
  ModifiedFlag=TRUE;
}

void CKbdElement::OnKbdCaptions()
{
  CKbdCaptionsDlg Dlg;
  Dlg.KbdSize=KbdSize;
  for(int x=0; x<8; x++) {
    for(int y=0; y<8; y++) {
      Dlg.Caption[x][y]=Caption[x][y];
    }
  }
  if(Dlg.DoModal()==IDOK) {
    for(int x=0; x<8; x++) {
      for(int y=0; y<8; y++) {
        Caption[x][y]=Dlg.Caption[x][y];
      }
    }
    pArchElemWnd->RedrawWindow();
    pConstrElemWnd->RedrawWindow();
    ModifiedFlag=TRUE;
  }
}
/////////////////////////////////////////////////////////////////////////////
// CKbdCaptionsDlg dialog


CKbdCaptionsDlg::CKbdCaptionsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CKbdCaptionsDlg::IDD, pParent)
{
  KbdSize.cx=0; KbdSize.cy=0;
  for(int x=0; x<8; x++) {
    for(int y=0; y<8; y++) {
      Caption[x][y]="";
    }
  }

  //{{AFX_DATA_INIT(CKbdCaptionsDlg)
	//}}AFX_DATA_INIT
}


void CKbdCaptionsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CKbdCaptionsDlg)
	//}}AFX_DATA_MAP

  if(pDX->m_bSaveAndValidate) {
  }else {
    CString Val;
    for(int x=0; x<KbdSize.cx; x++) {
      Val.Format("%d",x);
      SendDlgItemMessage(IDC_X,CB_ADDSTRING,0,(LPARAM)(LPCTSTR)Val);
    }
    for(int y=0; y<KbdSize.cy; y++) {
      Val.Format("%d",y);
      SendDlgItemMessage(IDC_Y,CB_ADDSTRING,0,(LPARAM)(LPCTSTR)Val);
    }
    SendDlgItemMessage(IDC_X,CB_SETCURSEL,0);
    SendDlgItemMessage(IDC_Y,CB_SETCURSEL,0);
    SendDlgItemMessage(IDC_CAPTION,EM_LIMITTEXT,5);
    SetDlgItemText(IDC_CAPTION,Caption[0][0]);
  }
}


BEGIN_MESSAGE_MAP(CKbdCaptionsDlg, CDialog)
	//{{AFX_MSG_MAP(CKbdCaptionsDlg)
	ON_BN_CLICKED(ID_NEXT, OnNext)
	ON_CBN_SELCHANGE(IDC_X, OnChangeX)
	ON_CBN_SELCHANGE(IDC_Y, OnChangeY)
	ON_EN_CHANGE(IDC_CAPTION, OnChangeCaption)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CKbdCaptionsDlg message handlers

void CKbdCaptionsDlg::OnNext() 
{
  int x=SendDlgItemMessage(IDC_X,CB_GETCURSEL);
  int y=SendDlgItemMessage(IDC_Y,CB_GETCURSEL);
  x++;
  if(x==KbdSize.cx) { x=0; y++; }
  if(y==KbdSize.cy) { x=0; y=0; }
  SendDlgItemMessage(IDC_X,CB_SETCURSEL,x);
  SendDlgItemMessage(IDC_Y,CB_SETCURSEL,y);
  SetDlgItemText(IDC_CAPTION,Caption[x][y]);
  SendDlgItemMessage(IDC_CAPTION,EM_SETSEL,0,-1);
}

void CKbdCaptionsDlg::OnChangeX() 
{
  int x=SendDlgItemMessage(IDC_X,CB_GETCURSEL);
  int y=SendDlgItemMessage(IDC_Y,CB_GETCURSEL);
  SetDlgItemText(IDC_CAPTION,Caption[x][y]);
}

void CKbdCaptionsDlg::OnChangeY() 
{
  int x=SendDlgItemMessage(IDC_X,CB_GETCURSEL);
  int y=SendDlgItemMessage(IDC_Y,CB_GETCURSEL);
  SetDlgItemText(IDC_CAPTION,Caption[x][y]);
}

void CKbdCaptionsDlg::OnChangeCaption() 
{
  int x=SendDlgItemMessage(IDC_X,CB_GETCURSEL);
  int y=SendDlgItemMessage(IDC_Y,CB_GETCURSEL);
  GetDlgItemText(IDC_CAPTION,Caption[x][y]);
}

void CKbdArchWnd::UpdateRegionSize()
{
  if(KbdRgn.m_hObject) {
    SetWindowRgn(NULL,FALSE);
    KbdRgn.DeleteObject();
  }
  CPoint Pnts[]={
    CPoint(KeyOffset.x,0),
    CPoint(Size.cx,0),
    CPoint(Size.cx,10),
    CPoint(BtnSize.cx*((CKbdElement*)pElement)->KbdSize.cx+KeyOffset.x+3,10),
    CPoint(BtnSize.cx*((CKbdElement*)pElement)->KbdSize.cx+KeyOffset.x+3,
      KeyOffset.y+BtnSize.cy*((CKbdElement*)pElement)->KbdSize.cy+8),
    CPoint(Size.cx,KeyOffset.y+BtnSize.cy*((CKbdElement*)pElement)->KbdSize.cy+8),
    CPoint(Size.cx,Size.cy),
    CPoint(KeyOffset.x+10,Size.cy),
    CPoint(KeyOffset.x+10,KeyOffset.y+BtnSize.cy*((CKbdElement*)pElement)->KbdSize.cy),
    CPoint(KeyOffset.x,KeyOffset.y+BtnSize.cy*((CKbdElement*)pElement)->KbdSize.cy),
    CPoint(0,KeyOffset.y+BtnSize.cy*((CKbdElement*)pElement)->KbdSize.cy),
    CPoint(0,32),
    CPoint(KeyOffset.x,32),
  };
  KbdRgn.CreatePolygonRgn(Pnts,sizeof(Pnts)/sizeof(CPoint),WINDING);
  SetWindowRgn(KbdRgn,FALSE);
}

void CKbdArchWnd::OnKbdSize() 
{
  ((CKbdElement*)pElement)->OnKbdSize();
}

void CKbdConstrWnd::OnKbdSize() 
{
  ((CKbdElement*)pElement)->OnKbdSize();
}

void CKbdElement::OnKbdSize()
{
  CKbdSizeDlg Dlg;
  Dlg.Width=KbdSize.cx;
  Dlg.Height=KbdSize.cy;
  if(Dlg.DoModal()==IDOK) {
    KbdSize.cx=Dlg.Width;
    KbdSize.cy=Dlg.Height;
    UpdateSize();
    ModifiedFlag=TRUE;
  }
}
/////////////////////////////////////////////////////////////////////////////
// CKbdSizeDlg dialog


CKbdSizeDlg::CKbdSizeDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CKbdSizeDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CKbdSizeDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CKbdSizeDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CKbdSizeDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP

  if(pDX->m_bSaveAndValidate) {
    Width=1+SendDlgItemMessage(IDC_X,CB_GETCURSEL);
    Height=1+SendDlgItemMessage(IDC_Y,CB_GETCURSEL);
  }else {
    SendDlgItemMessage(IDC_X,CB_SETCURSEL,Width-1);
    SendDlgItemMessage(IDC_Y,CB_SETCURSEL,Height-1);
  }
}


BEGIN_MESSAGE_MAP(CKbdSizeDlg, CDialog)
	//{{AFX_MSG_MAP(CKbdSizeDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CKbdSizeDlg message handlers

void CKbdArchWnd::UpdateSize()
{
  Size.cx=((CKbdElement*)pElement)->KbdSize.cx*BtnSize.cx+KeyOffset.x+12;
  Size.cy=(((CKbdElement*)pElement)->KbdSize.cx+
    ((CKbdElement*)pElement)->KbdSize.cy)*BtnSize.cy+KeyOffset.y;

  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  GetWindowPlacement(&Pls);
  CRect Rect(Pls.rcNormalPosition);
  MoveWindow(Rect.left,Rect.top,Size.cx,Size.cy);
  UpdateRegionSize();

  GetParent()->RedrawWindow();
}

void CKbdConstrWnd::UpdateSize()
{
  Size.cx=((CKbdElement*)pElement)->KbdSize.cx*BtnSize.cx;
  Size.cy=((CKbdElement*)pElement)->KbdSize.cy*BtnSize.cy;

  WINDOWPLACEMENT Pls;
  Pls.length=sizeof(Pls);
  GetWindowPlacement(&Pls);
  CRect Rect(Pls.rcNormalPosition);
  MoveWindow(Rect.left,Rect.top,Size.cx,Size.cy);

  GetParent()->RedrawWindow();
}

void CKbdElement::UpdateSize()
{
  ((CKbdArchWnd*)pArchElemWnd)->UpdateSize();
  ((CKbdConstrWnd*)pConstrElemWnd)->UpdateSize();

  PointCount=KbdSize.cx+KbdSize.cy;
  int PointIndex=0;
  //Входы
  for(int y=0; y<KbdSize.cy; y++) {
    ConPoint[PointIndex].x=2;
    ConPoint[PointIndex].y=24+12+y*15;
    ConPin[PointIndex]=FALSE; PinType[PointIndex]=PT_INPUT;
    PointIndex++;
  }
  //Выходы
  for(int x=0; x<KbdSize.cx; x++) {
    ConPoint[PointIndex].x=pArchElemWnd->Size.cx-3;
    ConPoint[PointIndex].y=24+(KbdSize.cx+KbdSize.cy-x)*15-3;
    ConPin[PointIndex]=FALSE; PinType[PointIndex]=PT_OUTPUT;
    PointIndex++;
  }

  pArchElemWnd->RedrawWindow();
  pConstrElemWnd->RedrawWindow();
}

void CKbdArchWnd::OnFixable() 
{
  ((CKbdElement*)pElement)->OnFixable();
}

void CKbdConstrWnd::OnFixable() 
{
  ((CKbdElement*)pElement)->OnFixable();
}

void CKbdElement::OnFixable()
{
  Fixable=!Fixable;
  PopupMenu.CheckMenuItem(ID_FIXABLE,MF_BYCOMMAND|
    (Fixable ? MF_CHECKED : MF_UNCHECKED));
  ModifiedFlag=TRUE;
}

void CKbdElement::RecalcOutputs()
{
  if(FreePinLevel==0) OutputState=0;
  else OutputState=0xFFFFFFFF;

  for(int y=0; y<KbdSize.cy; y++) {
    DWORD InpLineState=(InputState>>y)&1;
    for(int x=0; x<KbdSize.cx; x++) {
      DWORD PressState=Pressed[x][y];
      if(VibrCounter&&(LastChangedKey.x==x)&&(LastChangedKey.y==y)) {
        PressState=rand()&1;
      }
      if(PressState) {
        if(FreePinLevel==0) {
          OutputState|=InpLineState<<(KbdSize.cy+x);
        }else if(InpLineState==0) OutputState&=~(1<<(KbdSize.cy+x));
      }
    }
  }
}

int CKbdArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CElementWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
  UpdateRegionSize();

  return 0;
}

void CKbdElement::OnInstrCounterEvent()
{
  VibrCounter-=2;
  if(VibrCounter>0) {
    RecalcOutputs();
    pArchParentWnd->SendMessage(WMU_PINSTATECHANGED,OutputState,(LPARAM)pInterface->hElement);
    pArchParentWnd->SendMessage(WMU_SET_INSTRCOUNTER,2,(LPARAM)pInterface->hElement);
  }else {
    VibrCounter=0;
    RecalcOutputs();
    pArchParentWnd->SendMessage(WMU_PINSTATECHANGED,OutputState,(LPARAM)pInterface->hElement);
  }
}
