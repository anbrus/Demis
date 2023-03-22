// Element.h: interface for the CElement class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "../StdElem.h"
#include "..\ElemInterface.h"
#include "..\definitions.h"
#include "ElementWnd.h"


class CElementWnd;
class CElemInterface;

class CElementBase:
	public CElement,
	public std::enable_shared_from_this<CElement>
{
public:
	CElementBase(BOOL ArchMode, int id);
	virtual ~CElementBase() override;

	int id;
	DWORD FreePinLevel;
	DWORD TaktFreq;
	CPoint ConPoint[MAX_CONNECT_POINT];
	int PointCount;
	BOOL ConPin[MAX_CONNECT_POINT];
	BOOL ConstrSelected;
	BOOL ArchSelected;
	CWnd* pArchParentWnd, *pConstrParentWnd;
	int64_t* pTickCounter;
	int IdIndex;
	CElementWnd* pArchElemWnd, *pConstrElemWnd;
	CString TipText;
	BOOL ModifiedFlag;
	std::vector<DWORD> Addresses;
	CMenu PopupMenu;
	BOOL EditMode;
	DWORD PinType[MAX_CONNECT_POINT];

	virtual int get_Id() override;
	virtual void put_Id(int id) override;
	virtual DWORD get_nType() override;
	virtual CString get_sName() override;
	virtual CString get_sClsId() override;
	virtual HWND get_hArchWnd() override;
	virtual HWND get_hConstrWnd() override;
	virtual std::vector<DWORD> GetAddresses() override;
	virtual BOOL get_bModifiedFlag() override;
	virtual CString get_sTipText() override;
	virtual BOOL get_bArchSelected() override;
	virtual void put_bArchSelected(BOOL newVal) override;
	virtual BOOL get_bConstrSelected() override;
	virtual void put_bConstrSelected(BOOL newVal) override;
	virtual DWORD get_nPointCount() override;
	virtual long get_nArchAngle() override;
	virtual void put_nArchAngle(long newVal) override;
	virtual long get_nConstrAngle() override;
	virtual void put_nConstrAngle(long newVal) override;

	virtual DWORD GetPointPos(DWORD nPointIndex) override { return (long)(ConPoint[nPointIndex].x + (ConPoint[nPointIndex].y << 16)); };
	//virtual void OnInstrCounterEvent() override;
	virtual void SetPinState(DWORD NewState) override;
	virtual DWORD GetPinState() override;
	virtual void SetPortData(DWORD Addresses, DWORD Data) override;
	virtual DWORD GetPortData(DWORD Addresses) override;
	virtual BOOL ConnectPin(DWORD PinIndex, BOOL Connect) override;
	virtual DWORD GetPinType(DWORD PinIndex) override;
	virtual BOOL Reset(BOOL bEditMode, __int64 *pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Load(HANDLE hFile) override;
	virtual BOOL Save(HANDLE hFile) override;
	BOOL IsArchRedrawRequired();
	BOOL IsConstrRedrawRequired();
	virtual void RedrawArchWnd(int64_t ticks) override;
	virtual void RedrawConstrWnd(int64_t ticks) override;
	virtual void OnVSync() override {};
	virtual void OnDelete() override {};
protected:
};
