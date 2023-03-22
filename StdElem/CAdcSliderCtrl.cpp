#include "stdafx.h"
#include "CAdcSliderCtrl.h"

#include "StdElemApp.h"

CAdcSliderCtrl::CAdcSliderCtrl()
{
	m_Brush.CreateSolidBrush(theApp.GrayColor);
}

CAdcSliderCtrl::~CAdcSliderCtrl()
{
}
BEGIN_MESSAGE_MAP(CAdcSliderCtrl, CSliderCtrl)
	//{{AFX_MSG_MAP(CColorSlider)
	ON_WM_CTLCOLOR_REFLECT()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CColorSlider message handlers

HBRUSH CAdcSliderCtrl::CtlColor(CDC* pDC, UINT nCtlColor)
{
	pDC -> SetBkColor(theApp.GrayColor);
	return m_Brush;
}
