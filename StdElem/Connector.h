#pragma once

#include "ElementBase.h"
#include "resource.h"

#include <vector>

class ConnectorArchWnd : public CElementWnd {
public:
	ConnectorArchWnd(CElementBase* pElement);
	virtual ~ConnectorArchWnd();

	virtual void Draw(CDC* pDC) override;
	virtual void Redraw(int64_t ticks) override;
	void updateSize();

protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnSettings();
	DECLARE_MESSAGE_MAP()

private:
	std::shared_ptr<CRgn> pRgn;
	int idxHandleCaptured = -1;
	CPoint pointMouse;
};


class Connector: public CElementBase
{
public:
	Connector(BOOL ArchMode, int id);
	virtual ~Connector();

	virtual void SetPinState(DWORD NewState) override;
	virtual DWORD GetPinState() override;
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;

private:
	std::vector<CPoint> handleLocations;
	DWORD pinState=0;

	void UpdateTipText();
	void OnSettings();

	friend class ConnectorArchWnd;
};

class ConnectorDlg : public CDialog
{
public:
	ConnectorDlg(CWnd* pParent = NULL);   // standard constructor

	enum { IDD = IDD_CONNECTOR_DLG };

	int countLegs=1;

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
};
