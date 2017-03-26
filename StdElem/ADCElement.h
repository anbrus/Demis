// ADCElement.h: interface for the CButtonElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ADC_H__AC326D84_78BA_11D4_8288_E863E1351E47__INCLUDED_)
#define AFX_ADC_H__AC326D84_78BA_11D4_8288_E863E1351E47__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CADCArchWnd : public CElementWnd  
{
public:
	void SetRange(BOOL HiPrecision);
	void DrawValue(CDC* pDC);
	virtual void Draw(CDC* pDC);
	CADCArchWnd(CElement* pElement);
	virtual ~CADCArchWnd();

protected:
	CRgn ADCRgn;
	CSliderCtrl Slider;
  //{{AFX_MSG(CADCArchWnd)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnDelay();
	afx_msg void OnLimits();
	afx_msg void OnHiPrecision();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CADCConstrWnd : public CElementWnd  
{
public:
	void SetRange(BOOL HiPrecision);
	virtual void Draw(CDC* pDC);
	CADCConstrWnd(CElement* pElement);
	virtual ~CADCConstrWnd();

protected:
	CSliderCtrl Slider;
  //{{AFX_MSG(CADCConstrWnd)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnDelay();
	afx_msg void OnLimits();
	afx_msg void OnHiPrecision();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CADCElement : public CElement  
{
public:
	BOOL HiPrecision;
  void OnHiPrecision();
	virtual void OnInstrCounterEvent();
	void OnLimits();
	CString LoLimit,HiLimit;
	DWORD StartState,ReadyState;
	virtual void SetPinState(DWORD NewState);
	DWORD Delay;
	void OnDelay();
	DWORD SliderState;
	virtual DWORD GetPinState();
  INT64 LastEventTakt;
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	virtual ~CADCElement();
	CADCElement(BOOL ArchMode,CElemInterface* pInterface);

protected:
	void ChangePinConfiguration();
	DWORD DelayTakts;
};

#endif // !defined(AFX_ADC_H__AC326D84_78BA_11D4_8288_E863E1351E47__INCLUDED_)
/////////////////////////////////////////////////////////////////////////////
// CADCDelayDlg dialog

class CADCDelayDlg : public CDialog
{
// Construction
public:
	CADCDelayDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CADCDelayDlg)
	enum { IDD = IDD_ADC_DELAY_DLG };
	UINT	Delay;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CADCDelayDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CADCDelayDlg)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
/////////////////////////////////////////////////////////////////////////////
// CADCLimitsDlg dialog

class CADCLimitsDlg : public CDialog
{
// Construction
public:
	CADCLimitsDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CADCLimitsDlg)
	enum { IDD = IDD_ADC_LIMITS_DLG };
	CString	m_HiLimit;
	CString	m_LoLimit;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CADCLimitsDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CADCLimitsDlg)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
