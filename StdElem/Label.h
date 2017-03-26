// Label.h: interface for the CLabel class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LABEL_H__70976933_77EB_11D4_8287_8B580A7A1447__INCLUDED_)
#define AFX_LABEL_H__70976933_77EB_11D4_8287_8B580A7A1447__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Element.h"
#include "ElementWnd.h"

class CLabelWnd : public CElementWnd
{
public:
  CLabelWnd(CElement* pElement) : CElementWnd(pElement) {};
	virtual void Draw(CDC* pDC);
  void UpdateSize();

protected:
  //{{AFX_MSG(CLabelWnd)
	afx_msg void OnLabelText();
	//}}AFX_MSG
  DECLARE_MESSAGE_MAP()
};

class CLabel : public CElement  
{
public:
	CFont Font;
  CLabelWnd* pLabelWnd;
  BOOL OnArch;
	CString Text;
  virtual BOOL Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	CLabel(BOOL ArchMode,CElemInterface* pInterface);
	virtual ~CLabel();
};

#endif // !defined(AFX_LABEL_H__70976933_77EB_11D4_8287_8B580A7A1447__INCLUDED_)
