
#pragma once

#include "..\ElemInterface.h"
#include "..\definitions.h"
#include "resource.h"
#include "../StdElem.h"

extern "C" class CStdElemApp : public CWinApp
{
public:
	HostInterface* pHostInterface;

	CPen DrawPen, SelectPen;
	COLORREF DrawColor, BkColor, SelectColor, BlackColor, OnColor, GrayColor;
	CBrush BkBrush;
	CDC DrawOnWhiteNumb, DrawOnGrayNumb, SelOnWhiteNumb, SelOnGrayNumb;
	CDC DrawOnWhiteChar, SelOnWhiteChar;
	int m_ElementsCount;
	struct _ElementId ElementId[14];

	CStdElemApp();

private:
	CBitmap DrawOnWhiteNumbBmp, DrawOnGrayNumbBmp, SelOnWhiteNumbBmp, SelOnGrayNumbBmp;
	CBitmap DrawOnWhiteCharBmp, SelOnWhiteCharBmp;

	// Overrides
		// ClassWizard generated virtual function overrides
		//{{AFX_VIRTUAL(CStdElemApp)
public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

	//{{AFX_MSG(CStdElemApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

extern "C" CStdElemApp theApp;

class CStdElemLib : CElemLib {
public:
	CStdElemLib() {};
	virtual ~CStdElemLib() override {};

	HostInterface* pHostInterface=nullptr;
	
	virtual CString getLibraryName() override;
	virtual DWORD getElementsCount() override;
	virtual CString GetElementName(DWORD Index) override;
	virtual DWORD GetElementType(DWORD Index) override;
	virtual HBITMAP GetElementIcon(DWORD Index) override;
	virtual std::shared_ptr<CElement> CreateElement(const CString& name, bool isArchMode, int id) override;
};
