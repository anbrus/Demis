// BeepElement.h: interface for the CBeepElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BEEPELEMENT_H__5E8E5998_A134_4EC4_8427_7F4642CF4509__INCLUDED_)
#define AFX_BEEPELEMENT_H__5E8E5998_A134_4EC4_8427_7F4642CF4509__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
#include <Mmsystem.h>
#include <inttypes.h>
#include "ElementBase.h"
#include "ElementWnd.h"

class CBeepArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override {};
	CBeepArchWnd(CElementBase* pElement);
	virtual ~CBeepArchWnd();

protected:
	CRgn BeepRgn;
	void UpdateRegionSize();
  //{{AFX_MSG(CBeepArchWnd)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnBeepFreq();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CBeepConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override {};
	CBeepConstrWnd(CElementBase* pElement);
	virtual ~CBeepConstrWnd();

protected:
  //{{AFX_MSG(CBeepConstrWnd)
	afx_msg void OnBeepFreq();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CBeepElement : public CElementBase  
{
public:
	CBeepElement(BOOL ArchMode, int id);
	virtual ~CBeepElement();

	void OnChangeFreq();
	virtual void SetPinState(DWORD NewState);
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,int64_t* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
protected:
	void Beep(BOOL BeepOn);
	void updateWave();

	int16_t wave[44100];
	int countWaveSamples = 0;
	//BOOL NTOS;
	HWAVEOUT hWaveOut;
	WAVEHDR headerWave;
	DWORD Freq;
	BOOL Enabled;
};

#endif // !defined(AFX_BEEPELEMENT_H__5E8E5998_A134_4EC4_8427_7F4642CF4509__INCLUDED_)
/////////////////////////////////////////////////////////////////////////////
// CFreqDlg dialog

class CFreqDlg : public CDialog
{
// Construction
public:
	CFreqDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CFreqDlg)
	enum { IDD = IDD_BEEP_FREQ_DLG };
	UINT	m_Freq;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CFreqDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CFreqDlg)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
