#if !defined(AFX_STACKVIEW_H__3EF4AFB6_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_)
#define AFX_STACKVIEW_H__3EF4AFB6_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// StackView.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CStackView view

class CStackView : public CScrollView
{
protected:
	CStackView();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CStackView)

// Attributes
public:

// Operations
public:
	void OnStopProgram(DWORD StopCode);

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CStackView)
	protected:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
	virtual void OnInitialUpdate();     // first time after construct
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CStackView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CStackView)
		// NOTE - the ClassWizard will add and remove member functions here.
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STACKVIEW_H__3EF4AFB6_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_)
