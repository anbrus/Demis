#pragma once

#include "ElementBase.h"
#include "ElementWnd.h"

#include <mutex>

class CMatrixArchWnd : public CElementWnd
{
public:
	CMatrixArchWnd(CElementBase* pElement);
	virtual ~CMatrixArchWnd();

	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks);
	void Resize();
	void Recreate();

protected:
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnMatrixSize();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()

private:
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC, BOOL Redraw);
};


class CMatrixConstrWnd : public CElementWnd
{
public:
	CMatrixConstrWnd(CElementBase* pElement);
	virtual ~CMatrixConstrWnd();

	virtual void Draw(CDC* pDC);
	virtual void Redraw(int64_t ticks);
	void Resize();
	void Recreate();

protected:
	int SqrSize;
	afx_msg void OnActiveHigh();
	afx_msg void OnActiveLow();
	afx_msg void OnMatrixSize();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()

private:
	CDC MemoryDC;

	void DrawStatic(CDC* pDC);
	void DrawDynamic(CDC* pDC, BOOL Redraw);
};

class CMatrixElement : public CElementBase
{
protected:
	class CMatrixSizeDlg : public CDialog
	{
		// Construction
	public:
		CMatrixSizeDlg(CWnd* pParent = NULL);   // standard constructor

		enum { IDD = IDD_MATRIX_SIZE_DLG };
		int		m_XSize;
		int		m_YSize;


	protected:
		virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	// Implementation
	protected:

		DECLARE_MESSAGE_MAP()
	};

public:
	std::mutex mutexDraw;
	int64_t* pTickCounter=nullptr;
	int64_t ticksAfterLight;
	DWORD PinState;
	CSize MatrixSize;
	BOOL ActiveHigh;
	// -1 - горит, 0 - не горит, > 0 - время до угасания
	int64_t HighLighted[8][8];

	CMatrixElement(BOOL ArchMode, int id);
	virtual ~CMatrixElement();

	virtual DWORD GetPinState() override;
	virtual void SetPinState(DWORD NewState) override;
	void UpdateTipText();
	virtual BOOL Reset(BOOL bEditMode, int64_t* pTickCounter, DWORD TaktFreq, DWORD FreePinLevel) override;
	virtual BOOL Show(HWND hArchParentWnd, HWND hConstrParentWnd) override;
	virtual BOOL Save(HANDLE hFile) override;
	virtual BOOL Load(HANDLE hFile) override;
	void OnActiveHigh();
	void OnActiveLow();
	void OnMatrixSize();
	bool IsRedrawRequired();

protected:
	DWORD TimerId;
	void CreateConPoints();
};

