
#include "..\ElemInterface.h"
#include "resource.h"

#pragma once

extern "C" class CStdElemApp : public CWinApp
{
public:
	CPen DrawPen,SelectPen;
  COLORREF DrawColor,BkColor,SelectColor;
  CBrush BkBrush;
  CDC DrawOnWhiteNumb,DrawOnGrayNumb,SelOnWhiteNumb,SelOnGrayNumb;
  CDC DrawOnWhiteChar,SelOnWhiteChar;
	int m_ElementsCount;
	struct _ElementId ElementId[11];
	CStdElemApp();

private:
  CBitmap DrawOnWhiteNumbBmp,DrawOnGrayNumbBmp,SelOnWhiteNumbBmp,SelOnGrayNumbBmp;
  CBitmap DrawOnWhiteCharBmp,SelOnWhiteCharBmp;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CStdElemApp)
	public:
	virtual BOOL InitInstance();
  virtual int ExitInstance();
	//}}AFX_VIRTUAL

	//{{AFX_MSG(CStdElemApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
}theApp;
