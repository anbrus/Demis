// Flag.cpp : implementation file
//
#include "stdafx.h"
#include "Demis2000.h"
#include "Flag.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CFlag

CFlag::CFlag()
{
  Changed=FALSE;
}

CFlag::~CFlag()
{
}


BEGIN_MESSAGE_MAP(CFlag, CButton)
	//{{AFX_MSG_MAP(CFlag)
	ON_CONTROL_REFLECT(BN_CLICKED, OnClicked)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CFlag message handlers

BOOL CFlag::Create(CRect& Rect,CWnd* pParent,WORD FlagMask,WORD* pFl) 
{
	Mask=FlagMask; pFlag=pFl;
	if(!CButton::Create("",BS_CHECKBOX|BS_LEFTTEXT|WS_VISIBLE,Rect,pParent,0)) return FALSE;
  Update();
  return TRUE;
}

void CFlag::Update()
{
  IsInternalUpdate=TRUE;
  BOOL NewVal=*pFlag&Mask;
  SetCheck(NewVal);
  if(NewVal!=OldVal) { Changed=TRUE; OldVal=NewVal; }
  else Changed=FALSE;
  IsInternalUpdate=FALSE;
}

void CFlag::OnClicked() 
{
	*pFlag^=Mask;
  Update();
}
