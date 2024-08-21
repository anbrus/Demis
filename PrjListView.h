#if !defined(AFX_PRJLISTVIEW_H__3FF8AEA3_0ED8_11D4_ABA6_973E3284A366__INCLUDED_)
#define AFX_PRJLISTVIEW_H__3FF8AEA3_0ED8_11D4_ABA6_973E3284A366__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// PrjListView.h : header file
//
#include "PrjDoc.h"

/////////////////////////////////////////////////////////////////////////////
// CPrjListView view

class CPrjListView : public CTreeView
{
protected:
	CPrjListView();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CPrjListView)

// Attributes
public:
  CImageList ImageList;
  HTREEITEM hGlobalFolder,hSourceFolder=0,hIncFolder=0,hArchFolder=0;

// Operations
public:
	//CWnd* pNewFocusWnd;
	void ShowPopupMenu();
	CPrjDoc* pDoc;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPrjListView)
	public:
	virtual void OnInitialUpdate();
	protected:
	virtual void OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint);
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CPrjListView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	//{{AFX_MSG(CPrjListView)
	afx_msg void OnFileSaveAs();
	afx_msg void OnFileAdd();
	afx_msg void OnSourceAdd();
	afx_msg void OnIncAdd();
	afx_msg void OnArchAdd();
	afx_msg void OnSourceOpen();
	afx_msg void OnIncOpen();
	afx_msg void OnSourceDel();
	afx_msg void OnIncDel();
	afx_msg void OnArchOpen();
	afx_msg void OnArchDel();
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnDblclk(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnReturn(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnRclick(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnItemExpanded(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnKeydown(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnContainsEntrypoint();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	void UpdateFileList();
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PRJLISTVIEW_H__3FF8AEA3_0ED8_11D4_ABA6_973E3284A366__INCLUDED_)
