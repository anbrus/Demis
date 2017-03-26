// Element.cpp: implementation of the CElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "ElementWnd.h"
#include "Element.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CElement::CElement(BOOL ArchMode,CElemInterface* pInterface)
{
  this->pInterface=pInterface;
  ArchSelected=FALSE; ConstrSelected=FALSE;
  pTickCounter=NULL;
  EditMode=TRUE; Address=0; ModifiedFlag=FALSE;
  pArchElemWnd=NULL; pConstrElemWnd=NULL;
  pArchParentWnd=NULL;
  TipText="";
}

CElement::~CElement()
{
  if(pArchElemWnd) delete pArchElemWnd;
  if(pConstrElemWnd) delete pConstrElemWnd;
}

BOOL CElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  pArchParentWnd=CWnd::FromHandle(hArchParentWnd);
  pConstrParentWnd=CWnd::FromHandle(hConstrParentWnd);

  return TRUE;
}

BOOL CElement::Reset(BOOL bEditMode, CURRENCY *pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  this->pTickCounter=pTickCounter;
  this->TaktFreq=TaktFreq;
  this->FreePinLevel=FreePinLevel;
  EditMode=bEditMode;

  return TRUE;
}

DWORD CElement::GetPinType(int PinIndex)
{
  return PinType[PinIndex];
}

BOOL CElement::ConnectPin(int PinIndex, BOOL Connect)
{
  ConPin[PinIndex]=Connect;
  return TRUE;
}

DWORD CElement::GetPortData()
{
  return 0;
}

void CElement::SetPortData(DWORD Data)
{
}

DWORD CElement::GetPinState()
{
  return 0;
}

void CElement::SetPinState(DWORD NewState)
{
}

BOOL CElement::Load(HANDLE hFile)
{
  ModifiedFlag=FALSE;
  return TRUE;
}

BOOL CElement::Save(HANDLE hFile)
{
  ModifiedFlag=FALSE;
  return TRUE;
}

void CElement::OnInstrCounterEvent()
{
}

