// StdEditView.h : interface of the CStdEditView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_STDEDITVIEW_H__DE83D43F_0EC0_11D4_ABA6_973E3284A366__INCLUDED_)
#define AFX_STDEDITVIEW_H__DE83D43F_0EC0_11D4_ABA6_973E3284A366__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CStdEditDoc;

class CStdEditView : public CEditView
{
protected: // create from serialization only
	CStdEditView();
	DECLARE_DYNCREATE(CStdEditView)

// Attributes
public:
	CStdEditDoc* GetDocument();

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CStdEditView)
	public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnInitialUpdate();
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID, CCreateContext* pContext = NULL);
	//}}AFX_VIRTUAL

// Implementation
public:
	void UpdateRowColInd(int Row,int Col);
	CMenu EditMenu;
	int Row,Col;
	CFont Font;
	CStdEditDoc* pDoc;
	virtual ~CStdEditView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	CStatusBar m_StatusBar;
	//{{AFX_MSG(CStdEditView)
	afx_msg void OnChar(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in StdEditView.cpp
inline CStdEditDoc* CStdEditView::GetDocument()
   { return (CStdEditDoc*)m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDEDITVIEW_H__DE83D43F_0EC0_11D4_ABA6_973E3284A366__INCLUDED_)
