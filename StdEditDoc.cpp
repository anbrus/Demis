// StdEditDoc.cpp : implementation of the CStdEditDoc class
//

#include "stdafx.h"
#include "Demis2000.h"

#include "StdEditDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc

IMPLEMENT_DYNCREATE(CStdEditDoc, CDocument)

BEGIN_MESSAGE_MAP(CStdEditDoc, CDocument)
	//{{AFX_MSG_MAP(CStdEditDoc)
	ON_UPDATE_COMMAND_UI(ID_FILE_SAVE, OnUpdateFileSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc construction/destruction

CStdEditDoc::CStdEditDoc()
{
}

CStdEditDoc::~CStdEditDoc()
{
}

BOOL CStdEditDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc serialization

void CStdEditDoc::Serialize(CArchive& ar)
{
	// CEditView contains an edit control which handles all serialization
	if (ar.IsStoring()) {
		CEdit& EditCtrl = ((CEditView*)m_viewList.GetHead())->GetEditCtrl();

		int lengthText = EditCtrl.GetWindowTextLength();
		std::vector<char> Buf;
		Buf.resize(lengthText + 1);

		DWORD Length = EditCtrl.GetWindowText(Buf.data(), lengthText + 1);
		if (theApp.pPrjDoc && theApp.pPrjDoc->encoding == Encoding::Utf8) {
			std::vector<wchar_t> wBuf;
			wBuf.resize(lengthText + 1);
			MultiByteToWideChar(1251, 0, Buf.data(), lengthText, wBuf.data(), lengthText + 1);
			int sizeUtf8 = WideCharToMultiByte(CP_UTF8, 0, wBuf.data(), lengthText, nullptr, 0, nullptr, nullptr);
			if (sizeUtf8 > 0) {
				std::vector<char> utf8Buf;
				utf8Buf.resize(sizeUtf8);
				WideCharToMultiByte(CP_UTF8, 0, wBuf.data(), lengthText, utf8Buf.data(), sizeUtf8, nullptr, nullptr);
				ar.Write(utf8Buf.data(), sizeUtf8);
			}
		}
		else {
			CharToOem(Buf.data(), Buf.data());
			ar.Write(Buf.data(), Length);
		}
	}

	if (ar.IsLoading()) {
		CEdit& EditCtrl = ((CEditView*)m_viewList.GetHead())->GetEditCtrl();

		size_t lengthText = static_cast<size_t>(ar.GetFile()->GetLength());
		char* Buf = new char[lengthText + 1];

		DWORD Length = ar.Read(Buf, lengthText);
		Buf[Length] = '\0';
		if (theApp.pPrjDoc && theApp.pPrjDoc->encoding == Encoding::Utf8) {
			std::vector<wchar_t> wBuf;
			wBuf.resize(lengthText+1);
			MultiByteToWideChar(CP_UTF8, 0, Buf, lengthText, wBuf.data(), lengthText + 1);
			WideCharToMultiByte(1251, 0, wBuf.data(), lengthText, Buf, lengthText + 1, nullptr, nullptr);
		}
		else {
			OemToChar(Buf, Buf);
		}
		EditCtrl.SetWindowText(Buf);
		delete[] Buf;
	}
	//((CEditView*)m_viewList.GetHead())->SerializeRaw(ar);
}

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc diagnostics

#ifdef _DEBUG
void CStdEditDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CStdEditDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CStdEditDoc commands

void CStdEditDoc::OnUpdateFileSave(CCmdUI* pCmdUI)
{
	if (IsModified()) pCmdUI->Enable(TRUE);
	else pCmdUI->Enable(FALSE);
}
