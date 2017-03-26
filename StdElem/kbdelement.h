// KbdElement.h: interface for the CKbdElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_KBDELEMENT_H__66EA2333_6487_44AC_8CD9_ECE1E417D6A7__INCLUDED_)
#define AFX_KBDELEMENT_H__66EA2333_6487_44AC_8CD9_ECE1E417D6A7__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CKbdArchWnd : public CElementWnd  
{
public:
	void UpdateSize();
	CKbdArchWnd(CElement* pElement);
	virtual void Draw(CDC* pDC);
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
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CKbdConstrWnd : public CElementWnd  
{
public:
	void UpdateSize();
	CKbdConstrWnd(CElement* pElement);
	virtual void Draw(CDC* pDC);
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

class CKbdElement : public CElement  
{
public:
	virtual void OnInstrCounterEvent();
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
	CKbdElement(BOOL ArchMode,CElemInterface* pInterface);
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	virtual ~CKbdElement();
protected:
	int VibrCounter;
	void RecalcOutputs();
  CPoint LastChangedKey;
	void UpdateSize();
};

#endif // !defined(AFX_KBDELEMENT_H__66EA2333_6487_44AC_8CD9_ECE1E417D6A7__INCLUDED_)
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
