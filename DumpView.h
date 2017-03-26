#if !defined(AFX_DUMPVIEW_H__3EF4AFB4_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_)
#define AFX_DUMPVIEW_H__3EF4AFB4_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// DumpView.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CDumpView view

class CDumpView : public CScrollView
{
protected:
	CDumpView();
  DECLARE_DYNCREATE(CDumpView)

  struct _LineInfo {
    WORD Offs,Seg;
    BYTE Data[16];
    CString LineText;
  }DumpList[128];

// Attributes
public:

// Operations
public:
	void Update();
	CDebugFrame* pDebugFrame;
	void OnStopProgram(DWORD StopCode);
	int LinesHeight;
	BOOL MakeDumpList();
	virtual ~CDumpView();
	void ChangeVal(char Char);
	void CursorUp();
	void CursorDown();
	void CursorRight();
	void CursorLeft();
	CSize CharSize;
	void Scroll(int Count);
	CPoint CursorPos;
	CFont m_Font;
	void OnStep();
	WORD StartSeg,StartOffs;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDumpView)
	protected:
	virtual void OnDraw(CDC* pDC);
	virtual void OnInitialUpdate();
	//}}AFX_VIRTUAL

// Implementation
protected:
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CDumpView)
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnSetFocus(CWnd* pOldWnd);
	afx_msg void OnKillFocus(CWnd* pNewWnd);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnNewAddress();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg BOOL OnHelpInfo(HELPINFO* pHelpInfo);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// CDumpCfg dialog

class CDumpCfg : public CDialog
{
// Construction
public:
	DWORD Seg,Offs;
	CDumpCfg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CDumpCfg)
	enum { IDD = IDD_DUMPCFG };
	CString	m_sAddress;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDumpCfg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CDumpCfg)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DUMPVIEW_H__3EF4AFB4_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_)
