#if !defined(AFX_TEXT_DLG_H_INCLUDED_)
#define AFX_TEXT_DLG_H_INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Resource.h"

class CTextDlg : public CDialog
{
// Construction
public:
  char* GetText() { return (char*)(LPCTSTR)Text; };
  void SetText(char* NewText) { Text=NewText; };
	CTextDlg(CWnd* pParent = NULL);

protected:
  CString	Text;
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);
};

#endif