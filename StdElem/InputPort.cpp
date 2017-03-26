// InputPort.cpp: implementation of the CInputPort class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "InputPort.h"
#include "AddressDlg.h"
#include "..\definitions.h"
#include "ElemInterf.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CInputPort::CInputPort(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
{
  IdIndex=0;
  Value=0; Address=0;

  pArchElemWnd=new CInPortArchWnd(this);
  pConstrElemWnd=NULL;

  PointCount=8;
  for(int n=0; n<8; n++) {
    ConPoint[n].x=3;
    ConPoint[n].y=10+n*15;
    ConPin[n]=FALSE;
    PinType[n]=PT_INPUT;
  }

	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_INPUT_PORT_MENU);
	AfxSetResourceHandle(hInstOld);
}

CInputPort::~CInputPort()
{
}

BOOL CInputPort::Load(HANDLE hFile)
{
  CFile File(hFile);
  
  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Порт ввода: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }

  File.Read(&Address,4);

  return CElement::Load(hFile);
}

BOOL CInputPort::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&Address,4);

  return CElement::Save(hFile);
}

BOOL CInputPort::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"Порт ввода",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),
    CWnd::FromHandle(hArchParentWnd),0);

  UpdateTipText();

  return TRUE;
}

BOOL CInputPort::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  if((FreePinLevel==0)||bEditMode) Value=0;
  else Value=0xFF;

  return CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CLedArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CInPortArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CInPortArchWnd)
	ON_COMMAND(ID_ADDRESS, OnAddress)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CInPortArchWnd::CInPortArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=60;
  Size.cy=7*15+2*10;
}

CInPortArchWnd::~CInPortArchWnd()
{
}

void CInPortArchWnd::DrawValue(CDC* pDC)
{
  CGdiObject *pOldFont;
  CFont DrawFont;
  DrawFont.CreatePointFont(80,"Arial Cyr");
  pOldFont=pDC->SelectObject(&DrawFont);
  pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
  if(pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  CString Temp;
  Temp.Format("(%02Xh)",((CInputPort*)pElement)->Value);
  pDC->DrawText(Temp,CRect(17,31,Size.cx-1,44),
    DT_CENTER|DT_SINGLELINE|DT_VCENTER);

  pDC->SetBkColor(theApp.BkColor);
  for(int n=0; n<8; n++) {
    Temp.Format("%d",n);
    if(!pElement->EditMode)
      if(((CInputPort*)pElement)->Value&(1<<n)) pDC->SetTextColor(theApp.SelectColor);
      else pDC->SetTextColor(theApp.DrawColor);
    pDC->DrawText(Temp,CRect(9,4+n*15,16,18+n*15),DT_SINGLELINE);
  }

  //Восстанавливаем контекст
  pDC->SelectObject(pOldFont);
}


void CInPortArchWnd::OnAddress() 
{
	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
	CAddressDlg Dlg(this);
  Dlg.SetAddress((WORD)pElement->Address);
  if(Dlg.DoModal()==IDOK) {
    pElement->Address=(DWORD)Dlg.GetAddress();
    RedrawWindow();
    pElement->ModifiedFlag=TRUE;
    ((CInputPort*)pElement)->UpdateTipText();
  }
	AfxSetResourceHandle(hInstOld);
}

void CInPortArchWnd::Draw(CDC *pDC)
{
  CGdiObject *pOldPen,*pOldFont;
  CPen BluePen(PS_SOLID,0,RGB(0,0,255));
  CBrush SelectBrush(theApp.SelectColor);
  CBrush NormalBrush(theApp.DrawColor);
  pOldPen=pDC->SelectObject(&theApp.DrawPen);

  CRect MainRect(6,0,Size.cx,Size.cy);
  if(pElement->ArchSelected)
    pDC->FrameRect(MainRect,&SelectBrush);
  else pDC->FrameRect(MainRect,&NormalBrush);

  CBrush GrayBrush(GetSysColor(COLOR_BTNFACE));
  CGdiObject* pOldBrush=pDC->SelectObject(&GrayBrush);
  pDC->PatBlt(17,1,Size.cx-18,Size.cy-2,PATCOPY);
  pDC->SelectObject(pOldBrush);

  if(pElement->ArchSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);
  pDC->MoveTo(16,0); pDC->LineTo(16,Size.cy);
  
  //Рисуем проводки
  for(int n=0; n<8; n++) {
    if(pElement->ArchSelected) pDC->SelectObject(&theApp.SelectPen);
	    else pDC->SelectObject(&theApp.DrawPen);
    pDC->MoveTo(3,10+n*15); pDC->LineTo(6,10+n*15);

    //Рисуем крестик, если надо
    if(!pElement->ConPin[n]) {
      pDC->SelectObject(&BluePen);
      pDC->MoveTo(0,8+n*15); pDC->LineTo(5,13+n*15);
      pDC->MoveTo(0,12+n*15); pDC->LineTo(5,7+n*15);
    }else { //или палочку
      pDC->MoveTo(0,10+n*15); pDC->LineTo(6,10+n*15);
    }
  }
  //Текст внутри порта
  CFont DrawFont;
  DrawFont.CreatePointFont(80,"Arial Cyr");
  pOldFont=pDC->SelectObject(&DrawFont);
  pDC->SetBkColor(GetSysColor(COLOR_BTNFACE));
  if(pElement->ArchSelected) pDC->SetTextColor(theApp.SelectColor);
  else pDC->SetTextColor(theApp.DrawColor);
  pDC->DrawText("RGIN",CRect(17,5,Size.cx-1,18),
    DT_CENTER|DT_SINGLELINE|DT_VCENTER);
  CString Temp;
  Temp.Format("[%04Xh]",pElement->Address);
  pDC->DrawText(Temp,CRect(17,18,Size.cx-1,31),
    DT_CENTER|DT_SINGLELINE|DT_VCENTER);
  DrawValue(pDC);

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
  pDC->SelectObject(pOldFont);
}


void CInputPort::UpdateTipText()
{
  TipText.Format("Порт ввода [%04Xh]",Address);
}

void CInputPort::SetPinState(DWORD NewState)
{
  Value=NewState;
  CClientDC DC(pArchElemWnd);
  ((CInPortArchWnd*)pArchElemWnd)->DrawValue(&DC);
}

DWORD CInputPort::GetPortData()
{
  return Value;
}

DWORD CInputPort::GetPinState()
{
  return Value;
}
