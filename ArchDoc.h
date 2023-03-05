#if !defined(AFX_ARCHDOC_H__6A0AA638_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
#define AFX_ARCHDOC_H__6A0AA638_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// ArchDoc.h : header file
//
#include "MainFrm.h"
#include "definitions.h"
#include "ArchView.h"	// Added by ClassView
#include "ElemInterface.h"
#include "StdElem.h"

#include <array>

/////////////////////////////////////////////////////////////////////////////
// CArchDoc document

class CArchDoc : public CDocument
{
protected:
	CArchDoc();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CArchDoc)

	struct PortData {
		DWORD Address;
		CElement *pElement;
	};
	CList<PortData, PortData&> InputPortList, OutputPortList;

	// Attributes
public:
	//int ElemCount;
	std::array<CElement*, 1024> Elements;

	virtual void Serialize(CArchive& ar);   // overridden for document i/o
	virtual BOOL OnOpenDocument(LPCTSTR lpszPathName);

// Implementation
public:
	void CopySelected();
	void ChangeMode(BOOL ConfigMode);
	void WritePort(DWORD PortAddress, DWORD Data);
	DWORD ReadPort(DWORD PortAddress);
	//void OnTickTimer(DWORD hElement);
	void UpdateModifyStatus();
	CElement* CreateElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show, int handle);
	BOOL AddElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show);
	BOOL DeleteElement(int ElementIndex);
	CArchView *pView;
	void ArchOpen(CArchive& ar);
	void ArchSave(CArchive& ar);
	virtual ~CArchDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	virtual BOOL OnNewDocument();
	void ConvertVersion0200To0202(CArchive &ar, DWORD OldVersion);
	//{{AFX_MSG(CArchDoc)
	afx_msg void OnUpdateFileSave(CCmdUI* pCmdUI);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ARCHDOC_H__6A0AA638_E53B_11D3_AB02_D4AED9F34A62__INCLUDED_)
