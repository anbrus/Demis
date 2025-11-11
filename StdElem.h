#pragma once

#include <string>
#include <memory>
#include <vector>
#include <optional>

class CElement
{
public:
	/*BOOL CreateInstance(CString &ElemI);
	CElement();*/
	virtual ~CElement() {};

	virtual int get_Id()=0;
	virtual void put_Id(int id) = 0;
	virtual DWORD get_nType() = 0;
	virtual CString get_sName() = 0;
	virtual CString get_sClsId() = 0;
	virtual std::optional<HWND> get_hArchWnd() = 0;
	virtual std::optional<HWND> get_hConstrWnd() = 0;
	virtual std::vector<DWORD> GetAddresses() = 0;
	virtual BOOL get_bModifiedFlag() = 0;
	virtual CString get_sTipText() = 0;
	virtual BOOL get_bArchSelected() = 0;
	virtual void put_bArchSelected(BOOL newVal) = 0;
	virtual BOOL get_bConstrSelected() = 0;
	virtual void put_bConstrSelected(BOOL newVal) = 0;
	virtual DWORD get_nPointCount() = 0;
	virtual DWORD GetPortData(DWORD Addresses) = 0;
	virtual void SetPortData(DWORD Addresses, DWORD newVal) = 0;
	virtual DWORD GetPinState() = 0;
	virtual void SetPinState(DWORD newVal) = 0;
	virtual long get_nArchAngle() = 0;
	virtual void put_nArchAngle(long newVal) = 0;
	virtual long get_nConstrAngle() = 0;
	virtual void put_nConstrAngle(long newVal) = 0;

	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd)=0;
	//virtual BOOL Create(CString &sElemName, BOOL bArchMode)=0;
	virtual BOOL Reset(BOOL bEditMode, __int64 *pTickCounter, DWORD TaktFreq, DWORD FreePinLevel)=0;
	virtual BOOL ConnectPin(DWORD nPinIndex, BOOL bConnect)=0;
	virtual DWORD GetPinType(DWORD nPinIndex)=0;
	virtual DWORD GetPointPos(DWORD nPointIndex)=0;
	virtual BOOL Save(HANDLE hFile)=0;
	virtual BOOL Load(HANDLE hFile)=0;
	//virtual void OnInstrCounterEvent()=0;
	virtual BOOL IsArchRedrawRequired()=0;
	virtual BOOL IsConstrRedrawRequired()=0;
	virtual void RedrawArchWnd(int64_t ticks)=0;
	virtual void RedrawConstrWnd(int64_t ticks)=0;
	virtual void OnVSync() = 0;
	virtual void OnDelete() = 0;
protected:
	//IElement *pInterface;
};


typedef std::shared_ptr<CElement> CElementPtr;

class CElemLib
{
public:
	//BOOL CreateInstance(CString &ElemID);
	//CElemLib();
	virtual ~CElemLib() {};

	virtual CString getLibraryName()=0;
	virtual DWORD getElementsCount() =0;
	virtual CString GetElementName(DWORD Index) =0;
	virtual DWORD GetElementType(DWORD Index) =0;
	virtual HBITMAP GetElementIcon(DWORD Index) =0;
	virtual std::shared_ptr<CElement> CreateElement(const CString& name, bool isArchMode, int id) = 0;
};

