// LedElement.cpp: implementation of the CMatrixElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "StdElem.h"
#include "MatrixElem.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMatrixElement::CMatrixElement(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
{
  IdIndex=10;
  MatrixSize.cx=8; MatrixSize.cy=8;
  memset(HighLighted,0,sizeof(HighLighted));
  ActiveHigh=TRUE; AfterLightTime=3;
  
  CreateConPoints();

  pArchElemWnd=new CMatrixArchWnd(this);
  pConstrElemWnd=new CMatrixConstrWnd(this);

	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_MATRIX_MENU);
	AfxSetResourceHandle(hInstOld);
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
}

CMatrixElement::~CMatrixElement()
{
}

BOOL CMatrixElement::Load(HANDLE hFile)
{
  CFile File(hFile);
  
  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Матричный индикатор: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }

  File.Read(&MatrixSize,sizeof(MatrixSize));
  File.Read(&ActiveHigh,4);

  if(ActiveHigh) {
    PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	  PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
  }else {
    PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_UNCHECKED);
	  PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_CHECKED);
  }

  CreateConPoints();

  return CElement::Load(hFile);
}

BOOL CMatrixElement::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&MatrixSize,sizeof(MatrixSize));
  File.Write(&ActiveHigh,4);

  return CElement::Save(hFile);
}

BOOL CMatrixElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"Матричный индикатор",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),pArchParentWnd,0);
  pConstrElemWnd->Create(ClassName,"Матричный индикатор",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pConstrElemWnd->Size.cx,pConstrElemWnd->Size.cy),pConstrParentWnd,0);

  UpdateTipText();

  return TRUE;
}

BOOL CMatrixElement::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  memset(HighLighted,0,sizeof(HighLighted));
  memset(TimeToOff,0,sizeof(TimeToOff));
  OldState=0;
  if(pArchElemWnd->m_hWnd) {
    if(bEditMode) pArchElemWnd->KillTimer(1);
    else pArchElemWnd->SetTimer(1,40,NULL);
  }

  return CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CMatrixArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CMatrixArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CMatrixArchWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_COMMAND(ID_MATRIX_SIZE, OnMatrixSize)
	ON_WM_TIMER()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMatrixArchWnd::CMatrixArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=((CMatrixElement*)pElement)->MatrixSize.cx*15+26;
  Size.cy=((CMatrixElement*)pElement)->MatrixSize.cy*15+44;
}

CMatrixArchWnd::~CMatrixArchWnd()
{

}

//////////////////////////////////////////////////////////////////////
// CMatrixConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CMatrixConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CMatrixConstrWnd)
	ON_COMMAND(ID_ACTIVE_HIGH, OnActiveHigh)
	ON_COMMAND(ID_ACTIVE_LOW, OnActiveLow)
	ON_COMMAND(ID_MATRIX_SIZE, OnMatrixSize)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMatrixConstrWnd::CMatrixConstrWnd(CElement* pElement) : CElementWnd(pElement)
{
  SqrSize=7;
  Size.cx=((CMatrixElement*)pElement)->MatrixSize.cx*SqrSize+1;
  Size.cy=((CMatrixElement*)pElement)->MatrixSize.cy*SqrSize+1;
}

CMatrixConstrWnd::~CMatrixConstrWnd()
{

}

void CMatrixElement::OnActiveHigh() 
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_CHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_UNCHECKED);
  ActiveHigh=TRUE;
  ModifiedFlag=TRUE;
}

void CMatrixElement::OnActiveLow() 
{
	PopupMenu.CheckMenuItem(ID_ACTIVE_HIGH,MF_BYCOMMAND|MF_UNCHECKED);
	PopupMenu.CheckMenuItem(ID_ACTIVE_LOW,MF_BYCOMMAND|MF_CHECKED);
  ActiveHigh=FALSE;
  ModifiedFlag=TRUE;
}

void CMatrixArchWnd::OnActiveHigh() 
{
	((CMatrixElement*)pElement)->OnActiveHigh();
}

void CMatrixArchWnd::OnActiveLow() 
{
	((CMatrixElement*)pElement)->OnActiveLow();
}

void CMatrixConstrWnd::OnActiveHigh() 
{
	((CMatrixElement*)pElement)->OnActiveHigh();
}

void CMatrixConstrWnd::OnActiveLow() 
{
	((CMatrixElement*)pElement)->OnActiveLow();
}

void CMatrixArchWnd::OnMatrixSize() 
{
	((CMatrixElement*)pElement)->OnMatrixSize();
}

void CMatrixConstrWnd::OnMatrixSize() 
{
	((CMatrixElement*)pElement)->OnMatrixSize();
}

void CMatrixArchWnd::DrawValue(CDC *pDC,BOOL Redraw)
{
  CBrush HighLightBrush(theApp.SelectColor);
  CBrush NoLightBrush(theApp.BkColor);

  int cx=((CMatrixElement*)pElement)->MatrixSize.cx;
  int cy=((CMatrixElement*)pElement)->MatrixSize.cy;
  int x,y;
  //Подписываем контакты
  BYTE VertInput=(BYTE)(((CMatrixElement*)pElement)->OldState>>1);
  BYTE HorInput=(BYTE)(((CMatrixElement*)pElement)->OldState>>(((CMatrixElement*)pElement)->MatrixSize.cy+1));
  //Вертикальные
  CDC *pNumbDC;
  for(y=0; y<((CMatrixElement*)pElement)->MatrixSize.cy; y++) {
    if((pElement->ArchSelected)||((VertInput>>y)&1)) pNumbDC=&theApp.SelOnWhiteNumb;
    else pNumbDC=&theApp.DrawOnWhiteNumb;
    pDC->BitBlt(12,y*15+25,8,8,pNumbDC,y*8,0,SRCCOPY);
  }
  //Горизонтальные
  CDC *pCharDC;
  for(x=0; x<((CMatrixElement*)pElement)->MatrixSize.cx; x++) {
    if((pElement->ArchSelected)||((HorInput>>x)&1)) pCharDC=&theApp.SelOnWhiteChar;
    else pCharDC=&theApp.DrawOnWhiteChar;
    pDC->BitBlt(27+x*15,cy*15+25,8,8,pCharDC,x*8,0,SRCCOPY);
  }

  //Раскрашиваем матрицу
  pDC->SelectObject(&HighLightBrush);
  for(x=0; x<((CMatrixElement*)pElement)->MatrixSize.cx; x++) {
    for(y=0; y<((CMatrixElement*)pElement)->MatrixSize.cy; y++) {
      if(!Redraw&&(HighLighted[x][y]==((CMatrixElement*)pElement)->HighLighted[x][y])) continue;

      if(((CMatrixElement*)pElement)->HighLighted[x][y])
        pDC->FillRect(CRect(24+x*15,22+y*15,38+x*15,36+y*15),&HighLightBrush);
      else
        pDC->FillRect(CRect(24+x*15,22+y*15,38+x*15,36+y*15),&NoLightBrush);
    }
  }

  memcpy(HighLighted,((CMatrixElement*)pElement)->HighLighted,sizeof(HighLighted));
}

void CMatrixConstrWnd::DrawValue(CDC *pDC,BOOL Redraw)
{
  int x,y,GrX,GrY;
  for(x=0, GrX=0; x<((CMatrixElement*)pElement)->MatrixSize.cx; x++, GrX+=SqrSize) {
    for(y=0, GrY=0; y<((CMatrixElement*)pElement)->MatrixSize.cy; y++, GrY+=SqrSize) {
      if(!Redraw&&(HighLighted[x][y]==((CMatrixElement*)pElement)->HighLighted[x][y])) continue;

      if(((CMatrixElement*)pElement)->HighLighted[x][y])
        pDC->FillSolidRect(CRect(GrX+1,GrY+1,GrX+SqrSize,GrY+SqrSize),RGB(255,0,0));
      else
        pDC->FillSolidRect(CRect(GrX+1,GrY+1,GrX+SqrSize,GrY+SqrSize),theApp.BkColor);
    }
  }

  memcpy(HighLighted,((CMatrixElement*)pElement)->HighLighted,sizeof(HighLighted));
}

void CMatrixArchWnd::Draw(CDC *pDC)
{
  //Рисуем крестики, если надо
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CGdiObject* pOldPen=pDC->GetCurrentPen();

  int cx=((CMatrixElement*)pElement)->MatrixSize.cx;
  int cy=((CMatrixElement*)pElement)->MatrixSize.cy;

  pDC->SelectObject(&BluePen);
  for(int n=0; n<pElement->PointCount; n++) {
    if(!pElement->ConPin[n]) {
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y-2);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y+3);
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y+2);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y-3);
    }
  }
  
  CPen DoublePen;
  if(pElement->ArchSelected) DoublePen.CreatePen(PS_SOLID,2,theApp.SelectColor);
  else DoublePen.CreatePen(PS_SOLID,2,theApp.DrawColor);

  pOldPen=pDC->SelectObject(&DoublePen);

  //Общий вывод
  pDC->Rectangle(23,7,25+cx*15,22);
  //Вертикальные ячейки
  for(int n=0; n<cy; n++) {
    pDC->Rectangle(8,n*15+21,24,n*15+38);
  }
  //Горизонтальные ячейки
  for(int n=0; n<cx; n++) {
    pDC->Rectangle(23+n*15,cy*15+22,n*15+40,cy*15+38);
  }
  //Делаем жирную обводную линию справа
  pDC->MoveTo(cx*15+24,22);
  pDC->LineTo(cx*15+24,cy*15+23);

  if(pElement->ArchSelected) pDC->SelectObject(&theApp.SelectPen);
	else pDC->SelectObject(&theApp.DrawPen);

  //Рисуем светодиодную матрицу
  CBrush Brush;
  if(pElement->ArchSelected) Brush.CreateSolidBrush(theApp.SelectColor);
	else Brush.CreateSolidBrush(theApp.DrawColor);
  int x,y;
  for(x=0; x<((CMatrixElement*)pElement)->MatrixSize.cx; x++) {
    for(y=0; y<((CMatrixElement*)pElement)->MatrixSize.cy; y++) {
      pDC->FrameRect(CRect(23+x*15,21+y*15,39+x*15,37+y*15),&Brush);
    }
  }
  
  //Рисуем букву E
  int X=23+cx*15/2;
  int Y=9;
  pDC->MoveTo(X-3,Y); pDC->LineTo(X-3,Y+8);
  pDC->MoveTo(X-3,Y); pDC->LineTo(X+4,Y);
  pDC->MoveTo(X-3,Y+4); pDC->LineTo(X+4,Y+4);
  pDC->MoveTo(X-3,Y+8); pDC->LineTo(X+4,Y+8);

  //Рисуем выводы
  if(pElement->ConPin[0]) {
    pDC->MoveTo(pElement->ConPoint[0].x,pElement->ConPoint[0].y-2);
    pDC->LineTo(pElement->ConPoint[0].x,pElement->ConPoint[0].y+3);
  }
  for(int n=1; n<cy+1; n++) {
    if(pElement->ConPin[n]) {
      pDC->MoveTo(pElement->ConPoint[n].x-2,pElement->ConPoint[n].y);
      pDC->LineTo(pElement->ConPoint[n].x+3,pElement->ConPoint[n].y);
    }
  }
  for(int n=1+cy; n<cy+cx+1; n++) {
    if(pElement->ConPin[n]) {
      pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
      pDC->LineTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y+3);
    }
  }

  pDC->MoveTo(pElement->ConPoint[0].x,pElement->ConPoint[0].y);
  pDC->LineTo(pElement->ConPoint[0].x,pElement->ConPoint[0].y+5);
  for(int n=1; n<cy+1; n++) {
    pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
    pDC->LineTo(pElement->ConPoint[n].x+5,pElement->ConPoint[n].y);
  }
  for(int n=1+cy; n<cy+cx+1; n++) {
    pDC->MoveTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y);
    pDC->LineTo(pElement->ConPoint[n].x,pElement->ConPoint[n].y-5);
  }

  DrawValue(pDC,TRUE);
  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

void CMatrixConstrWnd::Draw(CDC *pDC)
{
  CBrush Brush;
  if(pElement->ConstrSelected) Brush.CreateSolidBrush(theApp.SelectColor);
	else Brush.CreateSolidBrush(theApp.DrawColor);

  for(int x=0; x<((CMatrixElement*)pElement)->MatrixSize.cx; x++) {
    for(int y=0; y<((CMatrixElement*)pElement)->MatrixSize.cy; y++) {
      pDC->FrameRect(CRect(x*SqrSize,y*SqrSize,x*SqrSize+SqrSize+1,y*SqrSize+SqrSize+1),&Brush);
    }
  }

  DrawValue(pDC,TRUE);
}

void CMatrixElement::UpdateTipText()
{
  TipText="Матричный индикатор";
}

void CMatrixElement::SetPinState(DWORD NewState)
{
  if(NewState==OldState) return;

  BYTE LightState=ActiveHigh ? 1 : 0;
  BYTE Enabler=(BYTE)(NewState&1);
  OldState=NewState;
  
  if(Enabler!=LightState) {
    for(int VertBit=0; VertBit<MatrixSize.cy; VertBit++) {
      for(int HorBit=0; HorBit<MatrixSize.cx; HorBit++) {
        if(HighLighted[HorBit][VertBit]&&!TimeToOff[HorBit][VertBit])
          TimeToOff[HorBit][VertBit]=AfterLightTime;
      }
    }
  }else {

    BYTE VertMask=(1<<MatrixSize.cy)-1;
    BYTE HorMask=(1<<MatrixSize.cx)-1;
    BYTE VertInput=(BYTE)(NewState>>1)&VertMask;
    BYTE HorInput=(BYTE)(NewState>>(MatrixSize.cy+1))&HorMask;

    for(int VertBit=0; VertBit<MatrixSize.cy; VertBit++) {
      for(int HorBit=0; HorBit<MatrixSize.cx; HorBit++) {
        if(((HorInput>>HorBit)&(VertInput>>VertBit)&1)==LightState) {
          HighLighted[HorBit][VertBit]=TRUE;
          TimeToOff[HorBit][VertBit]=0;
        }else {
          if(HighLighted[HorBit][VertBit]&&!TimeToOff[HorBit][VertBit])
            TimeToOff[HorBit][VertBit]=AfterLightTime;
        }
      }
    }
  }

  if(pArchElemWnd->IsWindowEnabled()) {
    CClientDC ArchDC(pArchElemWnd);
    ((CMatrixArchWnd*)pArchElemWnd)->DrawValue(&ArchDC,FALSE);
  }
  if(pConstrElemWnd->IsWindowEnabled()) {
    CClientDC ConstrDC(pConstrElemWnd);
    ((CMatrixConstrWnd*)pConstrElemWnd)->DrawValue(&ConstrDC,FALSE);
  }
}


DWORD CMatrixElement::GetPinState()
{
  return OldState;
}


void CMatrixElement::OnTimer(UINT idEvent)
{
  BOOL Updated=FALSE;

  for(int x=0; x<MatrixSize.cx; x++) {
    for(int y=0; y<MatrixSize.cy; y++) {
      if(TimeToOff[x][y]==0) continue;

      TimeToOff[x][y]--;
      if(!TimeToOff[x][y]) {
        HighLighted[x][y]=FALSE;
        Updated=TRUE;
      }
    }
  }

  if(Updated) {
    if(pArchElemWnd->IsWindowEnabled()) {
      CClientDC ArchDC(pArchElemWnd);
      ((CMatrixArchWnd*)pArchElemWnd)->DrawValue(&ArchDC,FALSE);
    }
    if(pConstrElemWnd->IsWindowEnabled()) {
      CClientDC ConstrDC(pConstrElemWnd);
      ((CMatrixConstrWnd*)pConstrElemWnd)->DrawValue(&ConstrDC,FALSE);
    }
  }
}

void CMatrixElement::CreateConPoints()
{
  PointCount=MatrixSize.cx+MatrixSize.cy+1;
  ConPoint[0].x=23+(MatrixSize.cx*15)/2;
  ConPoint[0].y=2;
  //Вертикальные входы
  int n;
  for(n=1; n<MatrixSize.cy+1; n++) {
    ConPoint[n].x=2;
    ConPoint[n].y=n*15+14;
  }
  //Горизонтальные входы
  for(n=MatrixSize.cy+1; n<PointCount; n++) {
    ConPoint[n].x=(n-MatrixSize.cy-1)*15+30;
    ConPoint[n].y=MatrixSize.cy*15+41;
  }

  for(n=0; n<PointCount; n++) { ConPin[n]=FALSE; PinType[n]=PT_INPUT; }
}
/////////////////////////////////////////////////////////////////////////////
// CMatrixSizeDlg dialog


CMatrixElement::CMatrixSizeDlg::CMatrixSizeDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMatrixSizeDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMatrixSizeDlg)
	m_XSize = -1;
	m_YSize = -1;
	//}}AFX_DATA_INIT
}


void CMatrixElement::CMatrixSizeDlg::DoDataExchange(CDataExchange* pDX)
{
  if(!pDX->m_bSaveAndValidate) {
    m_XSize-=5; m_YSize-=7;
  }

	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMatrixSizeDlg)
	DDX_CBIndex(pDX, IDC_X, m_XSize);
	DDX_CBIndex(pDX, IDC_Y, m_YSize);
	//}}AFX_DATA_MAP

  if(pDX->m_bSaveAndValidate) {
    m_XSize+=5; m_YSize+=7;
  }
}


BEGIN_MESSAGE_MAP(CMatrixElement::CMatrixSizeDlg, CDialog)
	//{{AFX_MSG_MAP(CMatrixSizeDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMatrixSizeDlg message handlers

void CMatrixElement::OnMatrixSize()
{
  CMatrixSizeDlg Dlg;
  Dlg.m_XSize=MatrixSize.cx;
  Dlg.m_YSize=MatrixSize.cy;
  if(Dlg.DoModal()==IDOK) {
    MatrixSize.cx=Dlg.m_XSize;
    MatrixSize.cy=Dlg.m_YSize;

    CreateConPoints();

    ((CMatrixArchWnd*)pArchElemWnd)->Invalidate();
    ((CMatrixConstrWnd*)pConstrElemWnd)->Invalidate();

    ModifiedFlag=TRUE;
  }
}

void CMatrixArchWnd::OnTimer(UINT nIDEvent) 
{
	((CMatrixElement*)pElement)->OnTimer(nIDEvent);
}
