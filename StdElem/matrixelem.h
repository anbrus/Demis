// MATRIXELEMENT.h: interface for the CMatrixElement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MATRIXELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_)
#define AFX_MATRIXELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CMatrixArchWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC,BOOL Redraw);
	CMatrixArchWnd(CElement* pElement);
	virtual ~CMatrixArchWnd();

protected:
	BOOL HighLighted[8][8];
  //{{AFX_MSG(CMatrixArchWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnMatrixSize();
	afx_msg void OnTimer(UINT nIDEvent);
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};


class CMatrixConstrWnd : public CElementWnd  
{
public:
	virtual void Draw(CDC* pDC);
	void DrawValue(CDC* pDC,BOOL Redraw);
	CMatrixConstrWnd(CElement* pElement);
	virtual ~CMatrixConstrWnd();

protected:
	int SqrSize;
	BOOL HighLighted[8][8];
  //{{AFX_MSG(CMatrixConstrWnd)
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnMatrixSize();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CMatrixElement : public CElement  
{
protected:
  class CMatrixSizeDlg : public CDialog
  {
  // Construction
  public:
	  CMatrixSizeDlg(CWnd* pParent = NULL);   // standard constructor

  // Dialog Data
	  //{{AFX_DATA(CMatrixSizeDlg)
	enum { IDD = IDD_MATRIX_SIZE_DLG };
	int		m_XSize;
	int		m_YSize;
	//}}AFX_DATA


  // Overrides
	  // ClassWizard generated virtual function overrides
	  //{{AFX_VIRTUAL(CMatrixSizeDlg)
	  protected:
	  virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	  //}}AFX_VIRTUAL

  // Implementation
  protected:

	  // Generated message map functions
	  //{{AFX_MSG(CMatrixSizeDlg)
		  // NOTE: the ClassWizard will add member functions here
	  //}}AFX_MSG
	  DECLARE_MESSAGE_MAP()
  };

public:
	DWORD OldState;
  void OnTimer(UINT idEvent);
	virtual DWORD GetPinState();
	CSize MatrixSize;
	virtual void SetPinState(DWORD NewState);
	virtual void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	BOOL ActiveHigh;
	BOOL HighLighted[8][8];
  CMatrixElement(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CMatrixElement();
	void OnActiveHigh();
	void OnActiveLow();
	void OnMatrixSize();
protected:
	DWORD TimerId;
	void CreateConPoints();
	DWORD AfterLightTime;
	DWORD TimeToOff[8][8];
};


#endif // !defined(AFX_MATRIXELEMENT_H__2B5BCBC4_6D08_11D4_8D3A_000000000000__INCLUDED_)
