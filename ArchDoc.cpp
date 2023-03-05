// ArchDoc.cpp : implementation file
//

#include "stdafx.h"
#include "Demis2000.h"
#include "ArchDoc.h"

#include <algorithm>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CArchDoc

IMPLEMENT_DYNCREATE(CArchDoc, CDocument)

CArchDoc::CArchDoc()
{
	for (size_t n = 0; n < Elements.size(); n++) Elements[n] = NULL;
}

BOOL CArchDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;
	return TRUE;
}

CArchDoc::~CArchDoc()
{
	for (size_t n = 0; n < Elements.size(); n++)
		if (Elements[n] != NULL) delete Elements[n];
}


BEGIN_MESSAGE_MAP(CArchDoc, CDocument)
	//{{AFX_MSG_MAP(CArchDoc)
	ON_UPDATE_COMMAND_UI(ID_FILE_SAVE, OnUpdateFileSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CArchDoc diagnostics

#ifdef _DEBUG
void CArchDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CArchDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CArchDoc serialization

void CArchDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
		ArchSave(ar);
	}
	else
	{
		ArchOpen(ar);
	}
}

/////////////////////////////////////////////////////////////////////////////
// CArchDoc commands

void CArchDoc::ArchOpen(CArchive &ar)
{
	DWORD Version;
	char Id[13];
	CString ClsId, Name;

	Id[12] = 0;
	ar.Read(Id, 12);
	if (strcmp(Id, "DEMISArchFmt") != 0) {
		MessageBox(NULL, "Неизвестный формат файла", "Ошибка", MB_OK | MB_ICONSTOP);
		return;
	}

	ar >> Version;
	if ((Version == 0x00000201) || (Version == 0x00000200)) {
		ConvertVersion0200To0202(ar, Version);
		Version = 0x00000202;
	}
	if (Version > 0x00000202) {
		MessageBox(NULL, "Неизвестная версия формата файла", "Ошибка", MB_OK | MB_ICONSTOP);
		return;
	}

	POSITION p = GetFirstViewPosition();
	CView* pV = GetNextView(p);
	CDocTemplate* pDocTemplate = GetDocTemplate();
	pDocTemplate->InitialUpdateFrame((CFrameWnd*)pV->GetParent(), this);

	int Count;
	ar >> Count;
	CPoint ArchPos, ConstrPos;
	WINDOWPLACEMENT Pls;
	Pls.length = sizeof(Pls);
	int ArchAngle, ConstrAngle;
	for (int n = 0; n < Count; n++) {
		ar >> Name >> ClsId;
		ar >> ArchPos.x >> ArchPos.y >> ConstrPos.x >> ConstrPos.y;
		if (Version >= 0x00000201) {
			ar >> ArchAngle;
			ar >> ConstrAngle;
		}
		else {
			ArchAngle = 0;
			ConstrAngle = 0;
		}
		ar.Flush();
		CElement* pElement = CreateElement(ClsId, Name, FALSE, n);
		if (!pElement) break;
		Elements[n] = pElement;

		if (!Elements[n]->Load(ar.GetFile()->m_hFile)) {
			MessageBox(NULL, "Ошибка загрузки архитектуры", "Ошибка", MB_OK | MB_ICONSTOP);
			return;
		}
		Elements[n]->put_nArchAngle(ArchAngle);
		Elements[n]->put_nConstrAngle(ConstrAngle);
		Elements[n]->Show(pView->m_hWnd, pView->m_hWnd);

		HWND hWnd = (HWND)Elements[n]->get_hArchWnd();
		if (hWnd) {
			::GetWindowPlacement(hWnd, &Pls);
			CRect Rect1(Pls.rcNormalPosition);
			Rect1.OffsetRect(ArchPos);
			::MoveWindow((HWND)Elements[n]->get_hArchWnd(), Rect1.left, Rect1.top,
				Rect1.Width(), Rect1.Height(), TRUE);
		}

		hWnd = (HWND)Elements[n]->get_hConstrWnd();
		if (hWnd) {
			::GetWindowPlacement(hWnd, &Pls);
			CRect Rect2(Pls.rcNormalPosition);
			Rect2.OffsetRect(ConstrPos);
			::MoveWindow((HWND)Elements[n]->get_hConstrWnd(), Rect2.left, Rect2.top,
				Rect2.Width(), Rect2.Height(), TRUE);
		}
	}
	for (size_t n = 0; n < Elements.size(); n++) {
		if (Elements[n] != NULL) pView->FindIntersections(Elements[n]);
	}

	UpdateAllViews(NULL);
}

void CArchDoc::ArchSave(CArchive &ar)
{
	DWORD Version = 0x00000202;
	char Id[] = "DEMISArchFmt";
	ar.Write(Id, 12);
	int countElem = 0;
	for (size_t n = 0; n < Elements.size(); n++) {
		if (Elements[n] == NULL) continue;
		countElem++;
	}
	ar << Version << static_cast<int32_t>(countElem);
	for (size_t n = 0; n < Elements.size(); n++) {
		if (Elements[n] == NULL) continue;
		CString ElemName = Elements[n]->get_sName();
		CString ElemClsId = Elements[n]->get_sClsId();
		ar << ElemName;
		ar << ElemClsId;
		WINDOWPLACEMENT Pls;
		Pls.length = sizeof(Pls);
		::GetWindowPlacement((HWND)Elements[n]->get_hArchWnd(), &Pls);
		Pls.rcNormalPosition.left += pView->GetScrollPos(SB_HORZ);
		Pls.rcNormalPosition.top += pView->GetScrollPos(SB_VERT);
		ar << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		::GetWindowPlacement((HWND)Elements[n]->get_hConstrWnd(), &Pls);
		Pls.rcNormalPosition.left += pView->GetScrollPos(SB_HORZ);
		Pls.rcNormalPosition.top += pView->GetScrollPos(SB_VERT);
		ar << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		ar << Elements[n]->get_nArchAngle();
		ar << Elements[n]->get_nConstrAngle();
		ar.Flush();
		Elements[n]->Save(ar.GetFile()->m_hFile);
	}
}

BOOL CArchDoc::DeleteElement(int ElementIndex)
{
	//::ShowWindow((HWND)Element[ElementIndex]->get_hArchWnd(),SW_HIDE);
	//::ShowWindow((HWND)Element[ElementIndex]->get_hConstrWnd(),SW_HIDE);
	delete Elements[ElementIndex];
	Elements[ElementIndex] = NULL;
	SetModifiedFlag();

	return TRUE;
}

BOOL CArchDoc::OnOpenDocument(LPCTSTR lpszPathName)
{
	if (!CDocument::OnOpenDocument(lpszPathName))
		return FALSE;

	return TRUE;
}

void CArchDoc::OnUpdateFileSave(CCmdUI* pCmdUI)
{
	UpdateModifyStatus();
	pCmdUI->Enable(IsModified());
}

BOOL CArchDoc::AddElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show) {
	BOOL FreeFounded = FALSE;
	size_t n = 0;
	for (n = 0; n < Elements.size(); n++) {
		if (Elements[n] == NULL) { FreeFounded = TRUE; break; }
	}
	if (!FreeFounded) {
		MessageBox(NULL, "Слишком много элементов", "Ошибка", MB_OK | MB_ICONSTOP);
		return FALSE;
	}

	CElement* pElement = CreateElement((LPCTSTR)GUID, (LPCTSTR)Name, Show, n);
	Elements[n] = pElement;
	UpdateAllViews(NULL);

	return TRUE;
}

CElement* CArchDoc::CreateElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show, int handle)
{
	CElement* pElement = theApp.CreateExtElement(GUID, Name, pView->ArchMode, handle);
	if (!(void*)pElement) {
		CString Msg;
		Msg.Format("Невозможно создать элемент \"%s\".", Name);
		MessageBox(NULL, Msg, "Ошибка", MB_OK | MB_ICONSTOP);
		return nullptr;
	}

	//Elements[n]=pElement;
	pElement->put_Id(handle);
	pElement->put_bArchSelected(FALSE);
	pElement->put_bConstrSelected(FALSE);
	pElement->Reset(TRUE, &theApp.pEmData->Ticks,
		theApp.pPrjDoc->TaktFreq, theApp.pPrjDoc->FreePinLevel);
	if (Show) {
		pElement->Show(pView->m_hWnd, pView->m_hWnd);
	}
	SetModifiedFlag();

	return pElement;
}

void CArchDoc::UpdateModifyStatus()
{
	if (IsModified()) return;
	for (size_t n = 0; n < Elements.size(); n++) {
		if (Elements[n] == NULL) continue;
		if (Elements[n]->get_bModifiedFlag()) { SetModifiedFlag(); return; }
	}
}

DWORD CArchDoc::ReadPort(DWORD PortAddress)
{
	POSITION Pos = InputPortList.GetHeadPosition();
	PortData PD;

	DWORD Data;
	if (theApp.pPrjDoc->FreePinLevel == 0) Data = 0;
	else Data = 0xFFFFFFFF;

	while (Pos) {
		PD = InputPortList.GetNext(Pos);
		if (PD.Address == PortAddress) {
			if (theApp.pPrjDoc->FreePinLevel == 0) Data |= PD.pElement->GetPortData();
			else Data &= PD.pElement->GetPortData();
		}
	}
	//if(Data)
	//  MessageBeep(-1);
	return Data;
}

void CArchDoc::WritePort(DWORD PortAddress, DWORD Data)
{
	POSITION Pos = OutputPortList.GetHeadPosition();
	PortData PD;
	while (Pos) {
		PD = OutputPortList.GetNext(Pos);
		if (PD.Address == PortAddress) PD.pElement->SetPortData(Data);
	}
}

void CArchDoc::ChangeMode(BOOL ConfigMode)
{
	if (ConfigMode) {
		for (size_t n = 0; n < Elements.size(); n++) {
			if (Elements[n] == NULL) continue;
			Elements[n]->Reset(ConfigMode, &theApp.pEmData->Ticks,
				theApp.pPrjDoc->TaktFreq, theApp.pPrjDoc->FreePinLevel);
			if (Elements[n]->get_hArchWnd()) InvalidateRect((HWND)Elements[n]->get_hArchWnd(), NULL, TRUE);
			if (Elements[n]->get_hConstrWnd()) InvalidateRect((HWND)Elements[n]->get_hConstrWnd(), NULL, TRUE);
		}
	}
	else {
		OutputPortList.RemoveAll();
		InputPortList.RemoveAll();
		PortData PD;
		for (size_t n = 0; n < Elements.size(); n++) {
			if (Elements[n] == NULL) continue;
			if (Elements[n]->get_nType()&ET_INPUTPORT) {
				PD.Address = Elements[n]->get_nAddress();
				PD.pElement = Elements[n];
				InputPortList.AddTail(PD);
			}
			if (Elements[n]->get_nType()&ET_OUTPUTPORT) {
				PD.Address = Elements[n]->get_nAddress();
				PD.pElement = Elements[n];
				OutputPortList.AddTail(PD);
			}
			Elements[n]->put_bArchSelected(FALSE);
			Elements[n]->put_bConstrSelected(FALSE);
			Elements[n]->Reset(ConfigMode, &theApp.pEmData->Ticks,
				theApp.pPrjDoc->TaktFreq, theApp.pPrjDoc->FreePinLevel);
			if (Elements[n]->get_hArchWnd()) InvalidateRect((HWND)Elements[n]->get_hArchWnd(), NULL, TRUE);
			if (Elements[n]->get_hConstrWnd()) InvalidateRect((HWND)Elements[n]->get_hConstrWnd(), NULL, TRUE);

			POSITION Pos = OutputPortList.GetHeadPosition();
			while (Pos) {
				OutputPortList.GetNext(Pos).pElement->SetPortData(0);
			}
		}
	}
	pView->ChangeMode(ConfigMode);
}

void CArchDoc::CopySelected()
{
	char TempPath[MAX_PATH + 1];
	char TempName[MAX_PATH + 1];
	GetTempPath(MAX_PATH, TempPath);
	GetTempFileName(TempPath, "DMS", 0, TempName);
	HANDLE hTempFile = ::CreateFile(TempName, GENERIC_READ | GENERIC_WRITE, 0, NULL,
		CREATE_ALWAYS, FILE_ATTRIBUTE_TEMPORARY | FILE_FLAG_DELETE_ON_CLOSE, NULL);

	CFile TempFile(hTempFile);
	CArchive SaveAr(&TempFile, CArchive::store);

	int ElementsCount = 0;
	for (CElement* pElement : Elements) {
		if (pElement == NULL) continue;
		BOOL Selected = pView->ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected();
		if (!Selected) continue;

		ElementsCount++;
	}

	for (CElement* pElement : Elements) {
		if (pElement == NULL) continue;

		BOOL Selected = pView->ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected();
		if (!Selected) continue;

		CString ElemName = pElement->get_sName();
		CString ElemClsId = pElement->get_sClsId();
		SaveAr << ElemName;
		SaveAr << ElemClsId;
		WINDOWPLACEMENT Pls;
		Pls.length = sizeof(Pls);
		::GetWindowPlacement((HWND)pElement->get_hArchWnd(), &Pls);
		SaveAr << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		::GetWindowPlacement((HWND)pElement->get_hConstrWnd(), &Pls);
		SaveAr << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		SaveAr << pElement->get_nArchAngle();
		SaveAr << pElement->get_nConstrAngle();
		SaveAr.Flush();
		pElement->Save(SaveAr.GetFile()->m_hFile);
	}
	SaveAr.Close();

	TempFile.SeekToBegin();
	CArchive LoadAr(&TempFile, CArchive::load);

	CString ClsId, Name;
	CPoint ArchPos, ConstrPos;
	WINDOWPLACEMENT Pls;
	Pls.length = sizeof(Pls);
	for (size_t n = 0; n < Elements.size(); n++) {
		if (!ElementsCount) break;
		if (Elements[n]) continue;

		LoadAr >> Name >> ClsId;
		LoadAr >> ArchPos.x >> ArchPos.y >> ConstrPos.x >> ConstrPos.y;
		int ArchAngle, ConstrAngle;
		LoadAr >> ArchAngle;
		LoadAr >> ConstrAngle;
		CElement* pElement = CreateElement(ClsId, Name, FALSE, n);
		if (!pElement) break;
		Elements[n] = pElement;

		LoadAr.Flush();
		Elements[n]->put_nArchAngle(ArchAngle);
		Elements[n]->put_nConstrAngle(ConstrAngle);
		Elements[n]->Load(LoadAr.GetFile()->m_hFile);
		Elements[n]->Show(pView->m_hWnd, pView->m_hWnd);

		::GetWindowPlacement((HWND)Elements[n]->get_hArchWnd(), &Pls);
		CRect Rect1(Pls.rcNormalPosition);
		if (pView->ArchMode) Rect1.OffsetRect(ArchPos);
		::MoveWindow((HWND)Elements[n]->get_hArchWnd(), Rect1.left, Rect1.top,
			Rect1.Width(), Rect1.Height(), TRUE);

		::GetWindowPlacement((HWND)Elements[n]->get_hConstrWnd(), &Pls);
		CRect Rect2(Pls.rcNormalPosition);
		if (!pView->ArchMode) Rect2.OffsetRect(ConstrPos);
		::MoveWindow((HWND)Elements[n]->get_hConstrWnd(), Rect2.left, Rect2.top,
			Rect2.Width(), Rect2.Height(), TRUE);

		HWND hArchWnd = (HWND)Elements[n]->get_hArchWnd();
		HWND hConstrWnd = (HWND)Elements[n]->get_hConstrWnd();
		if (pView->ArchMode) {
			if (hArchWnd) ::ShowWindow(hArchWnd, SW_SHOW);
			if (hConstrWnd) ::ShowWindow(hConstrWnd, SW_HIDE);
		}
		else {
			if (hArchWnd) ::ShowWindow(hArchWnd, SW_HIDE);
			if (hConstrWnd) ::ShowWindow(hConstrWnd, SW_SHOW);
		}

		ElementsCount--;
	}

	if (ElementsCount)
		MessageBox(NULL, "Слишком много элементов", "Ошибка", MB_OK | MB_ICONSTOP);

	LoadAr.Close();
	TempFile.Close();
	UpdateAllViews(NULL);
}

/*void CArchDoc::OnTickTimer(DWORD hElement)
{
	CElement *pElement = Elements[hElement];
	pElement->OnInstrCounterEvent();
}*/

void CArchDoc::ConvertVersion0200To0202(CArchive &ar, DWORD OldVersion)
{
	CString NewFileName(ar.GetFile()->GetFilePath());
	NewFileName += ".new";
	CFile OutFile(NewFileName, CFile::modeWrite | CFile::typeBinary | CFile::modeCreate);

	CString ClsId, Name;

	char Id[] = "DEMISArchFmt";
	OutFile.Write(Id, 12);
	DWORD Version = 0x00000202;
	OutFile.Write(&Version, 4);

	int Count;
	ar >> Count;
	OutFile.Write(&Count, 4);

	POINT ArchPos, ConstrPos;
	int ArchAngle, ConstrAngle;
	BOOL Error = FALSE;
	for (int n = 0; n < Count; n++) {
		ar >> Name >> ClsId;
		DWORD Len;
		Len = Name.GetLength();
		OutFile.Write(&Len, 1);
		OutFile.Write((LPCTSTR)Name, Name.GetLength());
		Len = ClsId.GetLength();
		OutFile.Write(&Len, 1);
		OutFile.Write((LPCTSTR)ClsId, ClsId.GetLength());

		ar >> ArchPos.x >> ArchPos.y >> ConstrPos.x >> ConstrPos.y;
		OutFile.Write(&ArchPos.x, 4);
		OutFile.Write(&ArchPos.y, 4);
		OutFile.Write(&ConstrPos.x, 4);
		OutFile.Write(&ConstrPos.y, 4);

		if (OldVersion >= 0x00000201) {
			ar >> ArchAngle;
			ar >> ConstrAngle;
		}
		else {
			ArchAngle = 0;
			ConstrAngle = 0;
		}
		OutFile.Write(&ArchAngle, 4);
		OutFile.Write(&ConstrAngle, 4);

		while (TRUE) {
			BYTE Buf[16384];
			DWORD Version = 0x00010000;
			OutFile.Write(&Version, 4);
			if (strcmp(Name, "Порт ввода") == 0) {
				ar.Read(Buf, 4);
				OutFile.Write(Buf, 4);
				break;
			}
			if (strcmp(Name, "Порт вывода") == 0) {
				ar.Read(Buf, 4);
				OutFile.Write(Buf, 4);
				break;
			}
			if (strcmp(Name, "Светодиод") == 0) {
				ar.Read(Buf, 4);
				COLORREF Color = RGB(255, 0, 0);
				OutFile.Write(&Color, 4);
				OutFile.Write(Buf, 4);
				break;
			}
			if (strcmp(Name, "Кнопка") == 0) {
				DWORD BitAttrib;
				ar >> BitAttrib;
				OutFile.Write(&BitAttrib, 4);
				int TextLen;
				ar >> TextLen;
				OutFile.Write(&TextLen, 4);
				ar.Read(Buf, TextLen);
				OutFile.Write(Buf, TextLen);
				break;
			}
			if (strcmp(Name, "Текстовая метка") == 0) {
				DWORD OnArch;
				ar.Read(&OnArch, 4);
				OutFile.Write(&OnArch, 4);
				int TextLen;
				ar.Read(&TextLen, 4);
				OutFile.Write(&TextLen, 4);
				ar.Read(Buf, TextLen);
				OutFile.Write(Buf, TextLen);
				break;
			}
			if (strcmp(Name, "Семисегм. индикатор") == 0) {
				ar.Read(Buf, 4);
				OutFile.Write(Buf, 4);
				break;
			}
			if (strcmp(Name, "Клавиатура") == 0) {
				ar.Read(Buf, 16);
				OutFile.Write(Buf, 16);

				BYTE Len;
				for (int x = 0; x < 8; x++) {
					for (int y = 0; y < 8; y++) {
						ar.Read(&Len, sizeof(Len));
						OutFile.Write(&Len, 1);
						ar.Read(Buf, Len);
						OutFile.Write(Buf, Len);
					}
				}
				break;
			}
			if (strcmp(Name, "АЦП") == 0) {
				ar.Read(&Buf, 4);
				OutFile.Write(Buf, 4);

				int StrLen;
				ar.Read(&StrLen, 4);
				OutFile.Write(&StrLen, 4);
				ar.Read(Buf, StrLen);
				OutFile.Write(Buf, StrLen);

				ar.Read(&StrLen, 4);
				OutFile.Write(&StrLen, 4);
				ar.Read(Buf, StrLen);
				OutFile.Write(Buf, StrLen);

				DWORD HiPrecision = FALSE;
				OutFile.Write(&HiPrecision, 4);

				break;
			}
			if (strcmp(Name, "Генератор звука") == 0) {
				ar.Read(Buf, 4);
				OutFile.Write(Buf, 4);
				break;
			}
			if (strcmp(Name, "Матричный индикатор") == 0) {
				ar.Read(Buf, 12);
				OutFile.Write(Buf, 12);
				break;
			}

			MessageBox(NULL, "Ошибка преобразования формата с версии 2.00 к 2.02", "Ошибка", MB_OK | MB_ICONSTOP);
			Error = TRUE;
			break;
		}
		if (Error) break;
	}
	OutFile.Close();

	if (Error) return;

	CFile *pFile = ar.GetFile();
	ar.Flush();
	pFile->Close();
	pFile->Open(NewFileName, CFile::typeBinary | CFile::modeRead);
	pFile->Seek(16, CFile::begin);
}
