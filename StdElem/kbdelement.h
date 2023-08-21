#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"
#include "Resource.h"

#include <random>

class CKbdArchWnd : public CElementWnd  
{
public:
	void UpdateSize();
	CKbdArchWnd(CElementBase* pElement);
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override {};
	virtual ~CKbdArchWnd();

protected:
	void UpdateRegionSize();
	CRgn KbdRgn;
	CPoint OldPoint;
	void PressKey(CPoint point,BOOL Press);
	CPoint KeyOffset;
	CSize BtnSize;
  //{{AFX_MSG(CKbdArchWnd)
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnDrebezg();
	afx_msg void OnKbdCaptions();
	afx_msg void OnKbdSize();
	afx_msg void OnFixable();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CKbdConstrWnd : public CElementWnd  
{
public:
	void UpdateSize();
	CKbdConstrWnd(CElementBase* pElement);
	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override {};
	virtual ~CKbdConstrWnd();

protected:
	CPoint OldPoint;
	void PressKey(CPoint point,BOOL Press);
	CSize BtnSize;
  //{{AFX_MSG(CKbdConstrWnd)
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnDrebezg();
	afx_msg void OnKbdCaptions();
	afx_msg void OnKbdSize();
	afx_msg void OnFixable();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CKbdElement : public CElementBase  
{
public:
	CKbdElement(BOOL ArchMode, int id);
	virtual ~CKbdElement();

	void OnTickTimer();
	void OnFixable();
	BOOL Drebezg,Fixable;
	void OnKbdSize();
	void OnKbdCaptions();
	void OnDrebezg();
	void OnKeyPressed(CPoint Key,BOOL Pressed);
	DWORD InputState,OutputState;
	virtual void SetPinState(DWORD NewState);
	virtual DWORD GetPinState();
	CString Caption[8][8];
	BOOL Pressed[8][8];
	CSize KbdSize;
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,int64_t* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
private:
	CPoint LastChangedKey;
	int64_t* pTickCounter = nullptr;
	int64_t ticksDrebezgEnd;
	std::default_random_engine rndEngine;
	std::uniform_int_distribution<int> distributionDrebezg = std::uniform_int_distribution<int>(2000, 5000);
	std::uniform_int_distribution<int> distributionBinary = std::uniform_int_distribution<int>(0, 1);

	void RecalcOutputs();
	void UpdateSize();
};

/////////////////////////////////////////////////////////////////////////////
// CKbdCaptionsDlg dialog

class CKbdCaptionsDlg : public CDialog
{
// Construction
public:
	CSize KbdSize;
	CString Caption[8][8];
	CKbdCaptionsDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CKbdCaptionsDlg)
	enum { IDD = IDD_KBD_CAPTIONS_DLG };
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CKbdCaptionsDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CKbdCaptionsDlg)
	afx_msg void OnNext();
	afx_msg void OnChangeX();
	afx_msg void OnChangeY();
	afx_msg void OnChangeCaption();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
/////////////////////////////////////////////////////////////////////////////
// CKbdSizeDlg dialog

class CKbdSizeDlg : public CDialog
{
// Construction
public:
	int Width,Height;
	CKbdSizeDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CKbdSizeDlg)
	enum { IDD = IDD_KBD_SIZE_DLG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CKbdSizeDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CKbdSizeDlg)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
