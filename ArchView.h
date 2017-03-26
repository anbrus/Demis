#if !defined(AFX_ARCHVIEW_H__6A0AA639_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
#define AFX_ARCHVIEW_H__6A0AA639_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// ArchView.h : header file
//

#include "ElemInterface.h"
#include "StdElem.h"

class CArchDoc;
/////////////////////////////////////////////////////////////////////////////
// CArchView view

class CArchView : public CScrollView
{
protected:
  struct ConPoint{
    CElement *pElement;
    int PinNumber;
  };
  typedef CList<ConPoint,ConPoint&> PointList;

  PointList ConData[1024][MAX_CONNECT_POINT];
	CArchView();
	BOOL MoveMode,CopyMode;
	int SelectedCount;
	CPoint LastMousePoint;
	CPoint StartMousePoint;
	DECLARE_DYNCREATE(CArchView)

// Attributes
public:
// Operations
public:
	BOOL CreateElementButtons();
	void DeconnectSelected();
	DWORD GetPinState(int ElementIndex);
	CStatusBar m_StatusBar;
	int XRes,YRes;
	void ChangeMode(BOOL bConfigMode);
	BOOL ConfigMode;
	BOOL ArchMode;
  CToolBar ToolBar;
  CReBar ReBar;
  CBitmap *BtnBmp[256];
  CArchDoc* pDoc;
	void FindIntersections(CElement *pElement);

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CArchView)
	public:
  virtual BOOL OnEraseBkgnd(CDC* pDC);
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID, CCreateContext* pContext = NULL);
	protected:
	virtual void OnInitialUpdate();     // first time after construct
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint);
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnPrint(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnDraw(CDC* pDC);
	virtual LRESULT WindowProc(UINT message, WPARAM wParam, LPARAM lParam);
	//}}AFX_VIRTUAL

// Implementation
protected:
	UINT Ind[2];
	void ConnectSelected();
	BOOL MoveSelected(int ShiftX,int ShiftY);
	void DeconnectElement(int ElemIndex);
	CPoint GetMinDist(CElement *pFixedElement, CElement *pMovedElement);
	BOOL ConnectElements(CElement *pMovedElement,CElement *pFixedElement);
	virtual ~CArchView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CArchView)
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnArchElemDel();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnArchMode();
	afx_msg void OnConstrMode();
	afx_msg void OnUpdateArchElemDel(CCmdUI* pCmdUI);
	afx_msg void OnUpdateAddElement(CCmdUI* pCmdUI);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg LPARAM OnAddElementByName(WPARAM wParam,LPARAM lParam);
	afx_msg LPARAM OnElementLButtonDown(WPARAM nFlags,LPARAM hElement);
	afx_msg LPARAM OnElementLButtonUp(WPARAM nFlags,LPARAM hElement);
	afx_msg LPARAM OnElementMouseMove(WPARAM nFlags,LPARAM hElement);
	afx_msg LPARAM OnPinStateChanged(WPARAM PinState,LPARAM hElement);
	afx_msg LPARAM OnSetInstrCounter(WPARAM Value,LPARAM hElement);
	afx_msg LPARAM OnKillInstrCounter(WPARAM Void,LPARAM hElement);
	afx_msg LPARAM OnGetPinState(WPARAM wParam,LPARAM hElement);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnKeyUp(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnTimer(UINT nIDEvent);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ARCHVIEW_H__6A0AA639_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
