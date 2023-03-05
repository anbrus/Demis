#pragma once
// ElementWnd.h : header file
//

#include "ElementBase.h"

class CElementBase;

/////////////////////////////////////////////////////////////////////////////
// CElementWnd window

class CElementWnd : public CWnd
{
	// Construction
public:
	int Angle;
	CSize Size;
	CElementWnd(CElementBase* pElement);

	// Attributes
public:

	// Operations
public:

	// Overrides
		// ClassWizard generated virtual function overrides
		//{{AFX_VIRTUAL(CElementWnd)
		//}}AFX_VIRTUAL

	// Implementation
public:
	virtual void SetAngle(int nNewAngle);
	void scheduleRedraw();
	bool isRedrawRequired();
	virtual ~CElementWnd();
	struct _FloatPoint {
		double x, y;
	};
	CArray<CPoint, CPoint> WorkPntArray;
	CArray<_FloatPoint, _FloatPoint> OrgPntArray;
	virtual void Redraw(int64_t ticks)=0;

	// Generated message map functions
protected:
	bool m_isRedrawRequired = false;
	virtual void Draw(CDC* pDC) {};
	CElementBase *pElement;
	//{{AFX_MSG(CElementWnd)
	afx_msg void OnPaint();
	afx_msg void OnContextMenu(CWnd* pWnd, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg LRESULT OnPrint(WPARAM hDC, LPARAM nFlags);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.
