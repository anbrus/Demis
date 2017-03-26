#if !defined(AFX_REGSVIEW_H__3EF4AFB5_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_)
#define AFX_REGSVIEW_H__3EF4AFB5_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
#include "DebugFrame.h"
#include "RegisterEdit.h"
#include "Flag.h"
// RegsView.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CRegsView view

class CRegsView : public CView
{
protected:
	DECLARE_DYNCREATE(CRegsView)

// Attributes
public:
	CRegsView();           // protected constructor used by dynamic creation
	virtual ~CRegsView();

// Operations
public:
	void Update();
	CDebugFrame* pDebugFrame;
	void OnStopProgram(DWORD StopCode);
	virtual void OnStep();
	CFont m_Font;
	struct _EmulatorData* pEmData;
	struct _HostData* pHData;
	CRegisterEdit RegEdit[13];
  CFlag Flag[9];

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRegsView)
	public:
	virtual void OnInitialUpdate();
	protected:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
	//}}AFX_VIRTUAL

// Implementation
protected:
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	//{{AFX_MSG(CRegsView)
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg BOOL OnHelpInfo(HELPINFO* pHelpInfo);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_REGSVIEW_H__3EF4AFB5_EC50_11D3_AB19_8D10B4CD5562__INCLUDED_)
