// InputPort.h: interface for the CInputPort class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INPUTPORT_H__AC326D83_78BA_11D4_8288_E863E1351E47__INCLUDED_)
#define AFX_INPUTPORT_H__AC326D83_78BA_11D4_8288_E863E1351E47__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "ElementBase.h"
#include "ElementWnd.h"

class CInputPort;

class CInPortArchWnd : public CElementWnd
{
public:
	CInPortArchWnd(CElementBase* pElement);
	virtual ~CInPortArchWnd();

	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks) override;
	void DrawDynamic(CDC* pDC);
	void DrawStatic(CDC* pDC);
	int Width, Height;

protected:
	CDC MemoryDC;

	afx_msg void OnAddress();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()
};

class CInputPort : public CElementBase
{
public:
	CInputPort(BOOL ArchMode, int id);
	virtual ~CInputPort();

	virtual DWORD GetPinState();
	virtual DWORD GetPortData();
	virtual void SetPinState(DWORD NewState);
	DWORD Value;
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel);
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd);
	virtual BOOL Save(HANDLE hFile);
	virtual BOOL Load(HANDLE hFile);
	void UpdateTipText();
};

#endif // !defined(AFX_INPUTPORT_H__AC326D83_78BA_11D4_8288_E863E1351E47__INCLUDED_)
