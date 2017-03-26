// RegisterEdit.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "RegisterEdit.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRegisterEdit

CRegisterEdit::CRegisterEdit()
{
  Changed=FALSE;
}

CRegisterEdit::~CRegisterEdit()
{
}


BEGIN_MESSAGE_MAP(CRegisterEdit, CEdit)
	//{{AFX_MSG_MAP(CRegisterEdit)
	ON_WM_CHAR()
	ON_CONTROL_REFLECT(EN_CHANGE, OnChange)
	ON_WM_LBUTTONDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRegisterEdit message handlers

BOOL CRegisterEdit::Create(CRect& Rect,CWnd* pParent,WORD* pRegister) 
{
  pReg=pRegister;
  if(!CEdit::Create(ES_LEFT|ES_UPPERCASE|WS_VISIBLE,Rect,pParent,0)) 
    return FALSE;
  LOGFONT lf={
    100,
    0,
    0,
    0,
    0,
    FALSE,
    FALSE,
    FALSE,
    ANSI_CHARSET,
    OUT_DEFAULT_PRECIS,
    CLIP_DEFAULT_PRECIS,
    DEFAULT_QUALITY,
    DEFAULT_PITCH,
    "Courier New Cyr"
  };
  Font.CreatePointFontIndirect(&lf);
  SetFont(&Font,FALSE);
  LimitText(4);
  CurValue=0;
  IsInternalChange=TRUE;
  SetWindowText("0000");
  IsInternalChange=FALSE;
  Update();

  return TRUE;
}

void CRegisterEdit::OnChar(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  if(nChar>' ') {
    UINT UpperChar=(UINT)CharUpper((char*)(nChar&0xFF));
	  if(((UpperChar<'0')||(UpperChar>'F'))||
       ((UpperChar>'9')&&(UpperChar<'A'))) return;
  }
	CEdit::OnChar(nChar, nRepCnt, nFlags);
}

void CRegisterEdit::Update()
{
  IsInternalChange=TRUE;
  CString NewVal;

  if(CurValue!=*pReg) {
    Changed=TRUE;
    CurValue=*pReg;
    NewVal.Format("%04X",*pReg);
	  SetWindowText(NewVal);
  }else Changed=FALSE;

  IsInternalChange=FALSE;
}

void CRegisterEdit::OnChange() 
{
  if(IsInternalChange) return;
  CString NewVal;
  GetWindowText(NewVal);
  DWORD NewReg;
  if(sscanf((LPCTSTR)NewVal,"%X",&NewReg)==1) {
    if(*pReg!=(WORD)NewReg) {
      Changed=TRUE;
      GetParent()->Invalidate(FALSE);
    }
    *pReg=(WORD)NewReg;
    CurValue=*pReg;
  }
}

void CRegisterEdit::OnLButtonDown(UINT nFlags, CPoint point) 
{
	CEdit::OnLButtonDown(nFlags, point);
  SetSel(0,-1);	
}

