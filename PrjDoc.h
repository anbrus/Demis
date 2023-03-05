#pragma once
// PrjDoc.h : header file
//
#include <afxtempl.h>
/////////////////////////////////////////////////////////////////////////////
// CPrjDoc document

#include "PrjCfgDlg.h"

typedef struct {
  CString Path;
  DWORD Folder;  //0-Global, 1-SourceAsm, 2-SourceInc, 3-Arch
  DWORD Flag;
} PrjFile;

class CPrjListView;

class CPrjDoc : public CDocument
{
protected:
	CPrjDoc();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CPrjDoc)

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPrjDoc)
	public:
	virtual void Serialize(CArchive& ar);   // overridden for document i/o
	virtual void SetTitle(LPCTSTR lpszTitle);
	virtual BOOL OnOpenDocument(LPCTSTR lpszPathName);
	protected:
	virtual BOOL OnNewDocument();
	//}}AFX_VIRTUAL

// Implementation
public:
	int FreePinLevel;
	DWORD TaktFreq;
	BOOL LoadDoc(CArchive& ar);
	BOOL SaveDoc(CArchive& ar);
	void OnEmulatorCfg();
	CString PrjPath;
	DWORD RomSize;
	CDocument* OpenDocument(POSITION Pos);
	CPrjListView* pView;
	CList<PrjFile,PrjFile> FileList;

  virtual ~CPrjDoc();

#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	void RedrawArch();
	//{{AFX_MSG(CPrjDoc)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	void CopyProjectFiles(const CString& pathFrom, const CString& pathTo);
};


//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.
