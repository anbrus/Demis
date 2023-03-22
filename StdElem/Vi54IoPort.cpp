#include "stdafx.h"
#include "Vi54IoPort.h"

Vi54IoPort::Vi54IoPort(BOOL ArchMode, int id) : CElementBase(ArchMode, id) {
	pArchElemWnd = nullptr;
	pConstrElemWnd = nullptr;
	PointCount = 0;
	IdIndex = 12;
	Addresses.push_back(0);
}

Vi54IoPort::~Vi54IoPort() {

}

void Vi54IoPort::SetPortData(DWORD Addresses, DWORD Data) {
	Vi54.Write(3, static_cast<uint8_t>(Data));
}

DWORD Vi54IoPort::GetPortData(DWORD Addresses) {
	return Vi54.Read(3);
}

BOOL Vi54IoPort::Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) {
	Vi54.SetFreePinLevel(FreePinLevel > 0);
	Vi54.Reset();

	return CElementBase::Reset(bEditMode, pTickCounter, TaktFreq, FreePinLevel);
}

BOOL Vi54IoPort::Show(HWND hArchParentWnd, HWND hConstrParentWnd) {
	return TRUE;
}

BOOL Vi54IoPort::Save(HANDLE hFile) {
	return CElementBase::Save(hFile);
}

BOOL Vi54IoPort::Load(HANDLE hFile) {
	return CElementBase::Load(hFile);
}
