#pragma once

/////////////////////////////////////////////////////////////////////////////
// CDasmView view

class CDasmView : public CScrollView
{
protected:
	CDasmView();
	DECLARE_DYNCREATE(CDasmView)

public:
	void OnStepOver();
	void Update();
	CDebugFrame* pDebugFrame;
	BOOL ListChanged;
	void MakeDasmList();
	struct _LineInfo {
		DWORD Address;
		int LineNumber;
		CString LineText;
	}CursorLine, CurInstr, FirstLine, DasmList[128];

	void OnStopProgram(DWORD StopCode);
	int MakeDasmLine(struct _LineInfo& Line);
	void RemoveCursor(CDC& dc);
	void DrawCursor(CDC& dc);
	virtual ~CDasmView();
	void OnRunTo();
	void ScrollDown(DWORD Count);
	virtual void OnStep();
	int LinesHeight;
	void ScrollUp(DWORD Count);
	CFont m_Font;

protected:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
	virtual void OnInitialUpdate();     // first time after construct
	virtual void OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint);

	void MoveCursorUp();
	void MoveCursorDown();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnSetFocus(CWnd* pOldWnd);
	afx_msg void OnKillFocus(CWnd* pNewWnd);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnNewAddress();
	afx_msg BOOL OnHelpInfo(HELPINFO* pHelpInfo);

	DECLARE_MESSAGE_MAP()
};
