// StdEditDoc.h : interface of the CStdEditDoc class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_STDEDITDOC_H__DE83D43D_0EC0_11D4_ABA6_973E3284A366__INCLUDED_)
#define AFX_STDEDITDOC_H__DE83D43D_0EC0_11D4_ABA6_973E3284A366__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "StdEditView.h"

class CStdEditDoc : public CDocument
{
protected: // create from serialization only
	CStdEditDoc();
	DECLARE_DYNCREATE(CStdEditDoc)

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CStdEditDoc)
	public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);
	//}}AFX_VIRTUAL

// Implementation
public:
	CStdEditView* pView;
	virtual ~CStdEditDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

// Generated message map functions
protected:
	//{{AFX_MSG(CStdEditDoc)
	afx_msg void OnUpdateFileSave(CCmdUI* pCmdUI);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDEDITDOC_H__DE83D43D_0EC0_11D4_ABA6_973E3284A366__INCLUDED_)
