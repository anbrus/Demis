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
	pView = nullptr;
}

BOOL CArchDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;
	return TRUE;
}

CArchDoc::~CArchDoc()
{
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

void CArchDoc::ArchOpen(CArchive& ar)
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
		std::shared_ptr<CElement> pElement = CreateElement(ClsId, Name, FALSE, n);
		if (!pElement) break;
		Elements[n] = pElement;

		if (!pElement->Load(ar.GetFile()->m_hFile)) {
			MessageBox(NULL, "Ошибка загрузки архитектуры", "Ошибка", MB_OK | MB_ICONSTOP);
			return;
		}
		pElement->put_nArchAngle(ArchAngle);
		pElement->put_nConstrAngle(ConstrAngle);
		pElement->Show(pView->m_hWnd, pView->m_hWnd);

		std::optional<HWND> optHWnd = pElement->get_hArchWnd();
		if (optHWnd) {
			::GetWindowPlacement(optHWnd.value(), &Pls);
			CRect Rect1(Pls.rcNormalPosition);
			Rect1.OffsetRect(ArchPos);
			::MoveWindow(optHWnd.value(), Rect1.left, Rect1.top,
				Rect1.Width(), Rect1.Height(), TRUE);
		}

		optHWnd = pElement->get_hConstrWnd();
		if (optHWnd) {
			::GetWindowPlacement(optHWnd.value(), &Pls);
			CRect Rect2(Pls.rcNormalPosition);
			Rect2.OffsetRect(ConstrPos);
			::MoveWindow(optHWnd.value(), Rect2.left, Rect2.top,
				Rect2.Width(), Rect2.Height(), TRUE);
		}
	}
	for (const auto pair : Elements) {
		pView->FindIntersections(pair.second);
	}

	UpdateAllViews(NULL);
}

void CArchDoc::ArchSave(CArchive& ar)
{
	DWORD Version = 0x00000202;
	char Id[] = "DEMISArchFmt";
	ar.Write(Id, 12);
	ar << Version << static_cast<int32_t>(Elements.size());
	for (const auto pair : Elements) {
		std::shared_ptr<CElement> pElement = pair.second;
		CString ElemName = pElement->get_sName();
		CString ElemClsId = pElement->get_sClsId();
		ar << ElemName;
		ar << ElemClsId;
		{
			WINDOWPLACEMENT Pls = { 0 };
			Pls.length = sizeof(Pls);
			std::optional<HWND> optHWnd = pElement->get_hArchWnd();
			if (optHWnd) {
				::GetWindowPlacement(optHWnd.value(), &Pls);
				Pls.rcNormalPosition.left += pView->GetScrollPos(SB_HORZ);
				Pls.rcNormalPosition.top += pView->GetScrollPos(SB_VERT);
			}
			ar << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		}
		{
			WINDOWPLACEMENT Pls = { 0 };
			Pls.length = sizeof(Pls);
			std::optional<HWND> optHWnd = pElement->get_hConstrWnd();
			if (optHWnd) {
				::GetWindowPlacement(optHWnd.value(), &Pls);
				Pls.rcNormalPosition.left += pView->GetScrollPos(SB_HORZ);
				Pls.rcNormalPosition.top += pView->GetScrollPos(SB_VERT);
			}
			ar << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		}
		ar << pElement->get_nArchAngle();
		ar << pElement->get_nConstrAngle();
		ar.Flush();
		pElement->Save(ar.GetFile()->m_hFile);
	}
}

BOOL CArchDoc::DeleteElement(int ElementIndex)
{
	const auto iter = Elements.find(ElementIndex);
	if (iter == Elements.cend()) return FALSE;

	std::shared_ptr<CElement> pElement = iter->second;
	std::optional<HWND> optHWnd = pElement->get_hArchWnd();
	if(optHWnd) ::ShowWindow(optHWnd.value(), SW_HIDE);
	optHWnd = pElement->get_hConstrWnd();
	if(optHWnd) ::ShowWindow(optHWnd.value(), SW_HIDE);
	pElement->OnDelete();
	Elements.erase(ElementIndex);
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

static int getNewElementId(const std::unordered_map<int, std::shared_ptr<CElement>>& elements) {
	int idNew = 0;
	const auto iterMax = std::max_element(elements.cbegin(), elements.cend(), [](const auto& a, const auto& b) { return a.first < b.first; });
	if (iterMax != elements.cend()) idNew = iterMax->first + 1;

	return idNew;
}

BOOL CArchDoc::AddElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show) {
	int idNew = getNewElementId(Elements);
	Elements[idNew] = CreateElement((LPCTSTR)GUID, (LPCTSTR)Name, Show, idNew);
	UpdateAllViews(NULL);

	return TRUE;
}

std::shared_ptr<CElement> CArchDoc::CreateElement(LPCTSTR GUID, LPCTSTR Name, BOOL Show, int handle)
{
	std::shared_ptr<CElement> pElement = theApp.CreateExtElement(GUID, Name, pView->ArchMode, handle);
	if (!pElement) {
		CString Msg;
		Msg.Format("Невозможно создать элемент \"%s\".", Name);
		MessageBox(NULL, Msg, "Ошибка", MB_OK | MB_ICONSTOP);
		return nullptr;
	}

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
	bool isModified = std::any_of(Elements.cbegin(), Elements.cend(), [](const auto& entry) { return entry.second->get_bModifiedFlag(); });
	if (isModified) SetModifiedFlag();
}

DWORD CArchDoc::ReadPort(DWORD PortAddress)
{
	DWORD Data;
	if (theApp.pPrjDoc->FreePinLevel == 0) Data = 0;
	else Data = 0xFFFFFFFF;

	const auto iterPorts = InputPorts.find(PortAddress);
	if (iterPorts == InputPorts.cend()) return Data;

	const std::vector<std::shared_ptr<CElement>>& elements = iterPorts->second;
	for (std::shared_ptr<CElement> const& pElement : elements) {
		if (theApp.pPrjDoc->FreePinLevel == 0) Data |= pElement->GetPortData(PortAddress);
		else Data &= pElement->GetPortData(PortAddress);
	}

	return Data;
}

void CArchDoc::WritePort(DWORD PortAddress, DWORD Data)
{
	const auto iterPorts = OutputPorts.find(PortAddress);
	if (iterPorts == OutputPorts.cend()) return;

	const std::vector<std::shared_ptr<CElement>>& elements = iterPorts->second;
	for (std::shared_ptr<CElement> const& pElement : elements) {
		pElement->SetPortData(PortAddress, Data);
	}
}

void CArchDoc::ChangeMode(BOOL ConfigMode)
{
	if (ConfigMode) {
		for (const auto entry : Elements) {
			std::shared_ptr<CElement> pElement = entry.second;

			pElement->Reset(ConfigMode, &theApp.pEmData->Ticks,
				theApp.pPrjDoc->TaktFreq, theApp.pPrjDoc->FreePinLevel);
			std::optional<HWND> optHWnd = pElement->get_hArchWnd();
			if (optHWnd) InvalidateRect(optHWnd.value(), NULL, TRUE);
			optHWnd = pElement->get_hConstrWnd();
			if (optHWnd) InvalidateRect(optHWnd.value(), NULL, TRUE);
		}
	}
	else {
		OutputPorts.clear();
		InputPorts.clear();
		for (const auto entry : Elements) {
			std::shared_ptr<CElement> pElement = entry.second;

			if (pElement->get_nType() & ET_INPUTPORT) {
				std::vector<DWORD> Addresses = pElement->GetAddresses();
				for (DWORD Address : Addresses) {
					const auto iterPorts = InputPorts.find(Address);
					if (iterPorts == InputPorts.cend()) {
						std::vector<std::shared_ptr<CElement>> elements;
						elements.push_back(pElement);
						InputPorts[Address] = elements;
					}
					else {
						std::vector<std::shared_ptr<CElement>>& elements = iterPorts->second;
						elements.push_back(pElement);
					}
				}
			}
			if (pElement->get_nType() & ET_OUTPUTPORT) {
				std::vector<DWORD> Addresses = pElement->GetAddresses();
				for (DWORD Address : Addresses) {
					const auto iterPorts = OutputPorts.find(Address);
					if (iterPorts == OutputPorts.cend()) {
						std::vector<std::shared_ptr<CElement>> elements;
						elements.push_back(pElement);
						OutputPorts[Address] = elements;
					}
					else {
						std::vector<std::shared_ptr<CElement>>& elements = iterPorts->second;
						elements.push_back(pElement);
					}
					pElement->SetPortData(Address, 0);
				}
			}
			pElement->put_bArchSelected(FALSE);
			pElement->put_bConstrSelected(FALSE);
			pElement->Reset(ConfigMode, &theApp.pEmData->Ticks,
				theApp.pPrjDoc->TaktFreq, theApp.pPrjDoc->FreePinLevel);
			std::optional<HWND> optHWnd = pElement->get_hArchWnd();
			if (optHWnd) InvalidateRect(optHWnd.value(), NULL, TRUE);
			optHWnd = pElement->get_hConstrWnd();
			if (optHWnd) InvalidateRect(optHWnd.value(), NULL, TRUE);
		}
	}
	pView->ChangeMode(ConfigMode);
}

void CArchDoc::CopySelected()
{
	std::unique_ptr<char[]> TempPath(new char[MAX_PATH + 1]);
	std::unique_ptr<char[]> TempName(new char[MAX_PATH + 1]);
	GetTempPath(MAX_PATH, TempPath.get());
	GetTempFileName(TempPath.get(), "DMS", 0, TempName.get());
	HANDLE hTempFile = ::CreateFile(TempName.get(), GENERIC_READ | GENERIC_WRITE, 0, NULL,
		CREATE_ALWAYS, FILE_ATTRIBUTE_TEMPORARY | FILE_FLAG_DELETE_ON_CLOSE, NULL);

	CFile TempFile(hTempFile);
	CArchive SaveAr(&TempFile, CArchive::store);

	int ElementsCount = 0;
	for (const auto entry : Elements) {
		std::shared_ptr < CElement> pElement = entry.second;

		BOOL Selected = pView->ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected();
		if (!Selected) continue;

		ElementsCount++;
	}

	for (const auto entry : Elements) {
		std::shared_ptr < CElement> pElement = entry.second;

		BOOL Selected = pView->ArchMode ? pElement->get_bArchSelected() : pElement->get_bConstrSelected();
		if (!Selected) continue;

		CString ElemName = pElement->get_sName();
		CString ElemClsId = pElement->get_sClsId();
		SaveAr << ElemName;
		SaveAr << ElemClsId;
		WINDOWPLACEMENT Pls = { 0 };
		Pls.length = sizeof(Pls);
		std::optional<HWND> optHWnd = pElement->get_hArchWnd();
		if (optHWnd) {
			::GetWindowPlacement(optHWnd.value(), &Pls);
		}
		SaveAr << Pls.rcNormalPosition.left << Pls.rcNormalPosition.top;
		Pls = { 0 };
		Pls.length = sizeof(Pls);
		optHWnd = pElement->get_hConstrWnd();
		if (optHWnd) {
			::GetWindowPlacement(optHWnd.value(), &Pls);
		}
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

	for (int n = 0; n < ElementsCount; n++) {
		int idNew = getNewElementId(Elements);

		LoadAr >> Name >> ClsId;
		LoadAr >> ArchPos.x >> ArchPos.y >> ConstrPos.x >> ConstrPos.y;
		int ArchAngle, ConstrAngle;
		LoadAr >> ArchAngle;
		LoadAr >> ConstrAngle;
		std::shared_ptr<CElement> pElement = CreateElement(ClsId, Name, FALSE, idNew);
		if (!pElement) break;
		Elements[idNew] = pElement;

		LoadAr.Flush();
		pElement->put_nArchAngle(ArchAngle);
		pElement->put_nConstrAngle(ConstrAngle);
		pElement->Load(LoadAr.GetFile()->m_hFile);
		pElement->Show(pView->m_hWnd, pView->m_hWnd);

		std::optional<HWND> optHArchWnd = pElement->get_hArchWnd();
		std::optional<HWND> optHConstrWnd = pElement->get_hConstrWnd();
		if (optHArchWnd) {
			WINDOWPLACEMENT Pls;
			Pls.length = sizeof(Pls);
			::GetWindowPlacement(optHArchWnd.value(), &Pls);
			CRect Rect1(Pls.rcNormalPosition);
			if (pView->ArchMode) Rect1.OffsetRect(ArchPos);
			::MoveWindow(optHArchWnd.value(), Rect1.left, Rect1.top,
				Rect1.Width(), Rect1.Height(), TRUE);
		}

		if (optHConstrWnd) {
			WINDOWPLACEMENT Pls;
			Pls.length = sizeof(Pls);
			::GetWindowPlacement(optHConstrWnd.value(), &Pls);
			CRect Rect2(Pls.rcNormalPosition);
			if (!pView->ArchMode) Rect2.OffsetRect(ConstrPos);
			::MoveWindow(optHConstrWnd.value(), Rect2.left, Rect2.top,
				Rect2.Width(), Rect2.Height(), TRUE);
		}

		if (pView->ArchMode) {
			if (optHArchWnd) ::ShowWindow(optHArchWnd.value(), SW_SHOW);
			if (optHConstrWnd) ::ShowWindow(optHConstrWnd.value(), SW_HIDE);
		}
		else {
			if (optHArchWnd) ::ShowWindow(optHArchWnd.value(), SW_HIDE);
			if (optHConstrWnd) ::ShowWindow(optHConstrWnd.value(), SW_SHOW);
		}
	}

	LoadAr.Close();
	TempFile.Close();
	UpdateAllViews(NULL);
}

/*void CArchDoc::OnTickTimer(DWORD hElement)
{
	CElement *pElement = Elements[hElement];
	pElement->OnInstrCounterEvent();
}*/

void CArchDoc::ConvertVersion0200To0202(CArchive& ar, DWORD OldVersion)
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

	CFile* pFile = ar.GetFile();
	ar.Flush();
	pFile->Close();
	pFile->Open(NewFileName, CFile::typeBinary | CFile::modeRead);
	pFile->Seek(16, CFile::begin);
}

CPoint CArchDoc::GetNearestConPoint(const CPoint& point, int typePin) {
	for (const auto& entry : Elements) {
		CElementPtr pElement = entry.second;
		std::optional<HWND> optHWnd = pElement->get_hArchWnd();
		if (!optHWnd) continue;

		WINDOWPLACEMENT pls;
		pls.length = sizeof(pls);
		CWnd::FromHandle(optHWnd.value())->GetWindowPlacement(&pls);

		for (size_t n = 0; n < pElement->get_nPointCount(); n++) {
			if ((pElement->GetPinType(n) & typePin) == 0) continue;
			DWORD pos = pElement->GetPointPos(n);
			int x = LOWORD(pos) + pls.rcNormalPosition.left;
			int y = HIWORD(pos) + pls.rcNormalPosition.top;
			if (std::abs(x - point.x) > 3 || std::abs(y - point.y) > 3) continue;
			return CPoint(x, y);
		}
	}
	return CPoint(-1, -1);
}
