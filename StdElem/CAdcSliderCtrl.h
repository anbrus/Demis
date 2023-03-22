#pragma once

class CAdcSliderCtrl : public CSliderCtrl
{
public:
	CAdcSliderCtrl();
	CBrush m_Brush;

	virtual ~CAdcSliderCtrl();

protected:
	afx_msg HBRUSH CtlColor(CDC* pDC, UINT nCtlColor);
	DECLARE_MESSAGE_MAP()
};
