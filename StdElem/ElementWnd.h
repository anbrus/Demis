#if !defined(AFX_ELEMENTWND_H__F577FF1A_1B8A_4D61_8E9E_2C86D1FEC61C__INCLUDED_)
#define AFX_ELEMENTWND_H__F577FF1A_1B8A_4D61_8E9E_2C86D1FEC61C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// ElementWnd.h : header file
//

#include "Element.h"

/////////////////////////////////////////////////////////////////////////////
// CElementWnd window

class CElementWnd : public CWnd
{
// Construction
public:
	int Angle;
	CSize Size;
	CElementWnd(CElement* pElement);

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
	virtual ~CElementWnd();
  struct _FloatPoint {
    double x,y;
  };
  CArray<CPoint,CPoint> WorkPntArray;
  CArray<_FloatPoint,_FloatPoint> OrgPntArray;

  // Generated message map functions
protected:
  virtual void Draw(CDC* pDC) {};
	CElement *pElement;
	//{{AFX_MSG(CElementWnd)
	afx_msg void OnPaint();
	afx_msg void OnContextMenu(CWnd* pWnd, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg LRESULT OnPrint(WPARAM hDC,LPARAM nFlags);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ELEMENTWND_H__F577FF1A_1B8A_4D61_8E9E_2C86D1FEC61C__INCLUDED_)
