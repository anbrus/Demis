// Element.cpp: implementation of the CElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ElementWnd.h"
#include "ElementBase.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CElementBase::CElementBase(BOOL ArchMode, int id):
	id(id)
{
	//this->pInterface = pInterface;
	ArchSelected = FALSE; ConstrSelected = FALSE;
	pTickCounter = NULL;
	EditMode = TRUE; Address = 0; ModifiedFlag = FALSE;
	pArchElemWnd = NULL; pConstrElemWnd = NULL;
	pArchParentWnd = NULL;
	TipText = "";
}

CElementBase::~CElementBase()
{
	if (pArchElemWnd) delete pArchElemWnd;
	if (pConstrElemWnd) delete pConstrElemWnd;
}

BOOL CElementBase::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
	pArchParentWnd = CWnd::FromHandle(hArchParentWnd);
	pConstrParentWnd = CWnd::FromHandle(hConstrParentWnd);

	return TRUE;
}

BOOL CElementBase::Reset(BOOL bEditMode, __int64 *pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)
{
	this->pTickCounter = pTickCounter;
	this->TaktFreq = TaktFreq;
	this->FreePinLevel = FreePinLevel;
	EditMode = bEditMode;

	return TRUE;
}

DWORD CElementBase::GetPinType(DWORD PinIndex)
{
	return PinType[PinIndex];
}

BOOL CElementBase::ConnectPin(DWORD PinIndex, BOOL Connect)
{
	ConPin[PinIndex] = Connect;
	return TRUE;
}

DWORD CElementBase::GetPortData()
{
	return 0;
}

void CElementBase::SetPortData(DWORD Data)
{
}

DWORD CElementBase::GetPinState()
{
	return 0;
}

void CElementBase::SetPinState(DWORD NewState)
{
}

BOOL CElementBase::Load(HANDLE hFile)
{
	ModifiedFlag = FALSE;
	return TRUE;
}

BOOL CElementBase::Save(HANDLE hFile)
{
	ModifiedFlag = FALSE;
	return TRUE;
}

/*void CElementBase::OnInstrCounterEvent()
{
}*/

BOOL CElementBase::IsArchRedrawRequired() {
	return pArchElemWnd != nullptr && pArchElemWnd->isRedrawRequired();
}

BOOL CElementBase::IsConstrRedrawRequired() {
	return pConstrElemWnd != nullptr && pConstrElemWnd->isRedrawRequired();
}

void CElementBase::RedrawArchWnd(int64_t ticks) {
	if (pArchElemWnd != nullptr) pArchElemWnd->Redraw(ticks);
}

void CElementBase::RedrawConstrWnd(int64_t ticks) {
	if (pConstrElemWnd != nullptr) pConstrElemWnd->Redraw(ticks);
}


int CElementBase::get_Id() { return id; }

void CElementBase::put_Id(int id) { this->id = id; }

DWORD CElementBase::get_nType() { return theApp.ElementId[IdIndex].Type; }

CString CElementBase::get_sName() { return theApp.ElementId[IdIndex].Name; }

CString CElementBase::get_sClsId() { return theApp.ElementId[IdIndex].ClsId; }

HWND CElementBase::get_hArchWnd() {
	if (pArchElemWnd) return pArchElemWnd->m_hWnd;
	else return NULL;
}

HWND CElementBase::get_hConstrWnd() {
	if (pConstrElemWnd) return pConstrElemWnd->m_hWnd;
	else return NULL;
}

DWORD CElementBase::get_nAddress() { return Address; }

BOOL CElementBase::get_bModifiedFlag() { return ModifiedFlag; }

CString CElementBase::get_sTipText() { return TipText; }

BOOL CElementBase::get_bArchSelected() { return ArchSelected; }

void CElementBase::put_bArchSelected(BOOL newVal) { ArchSelected = newVal; }

BOOL CElementBase::get_bConstrSelected() { return ConstrSelected; }

void CElementBase::put_bConstrSelected(BOOL newVal) { ConstrSelected = newVal; }

DWORD CElementBase::get_nPointCount() { return PointCount; }

long CElementBase::get_nArchAngle() { if (pArchElemWnd) return (long)pArchElemWnd->Angle; return 0;  }

void CElementBase::put_nArchAngle(long newVal) { if (pArchElemWnd) pArchElemWnd->Angle = newVal; }

long CElementBase::get_nConstrAngle() { if (pConstrElemWnd) return (long)pConstrElemWnd->Angle; return 0; }

void CElementBase::put_nConstrAngle(long newVal) { if (pConstrElemWnd) pConstrElemWnd->Angle = newVal; }
