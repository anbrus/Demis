#pragma once

#include "ElemInterface.h"
#include "StdElem.h"

#include <thread>

class CArchDoc;
/////////////////////////////////////////////////////////////////////////////
// CArchView view

class CArchView : public CScrollView
{
protected:
	struct ConPoint {
		std::shared_ptr<CElement> pElement;
		int PinNumber=0;
	};
	typedef CList<ConPoint, ConPoint&> PointList;

	PointList ConData[1024][MAX_CONNECT_POINT];
	CArchView();
	BOOL MoveMode = FALSE;
	BOOL CopyMode = FALSE;
	int SelectedCount=0;
	CPoint LastMousePoint;
	CPoint StartMousePoint;
	DECLARE_DYNCREATE(CArchView)

	// Attributes
public:
	// Operations
public:
	BOOL CreateElementButtons();
	void DeconnectSelected();
	DWORD GetPinState(int ElementIndex);
	CStatusBar m_StatusBar;
	int XRes=0, YRes=0;
	void ChangeMode(BOOL bConfigMode);
	BOOL ConfigMode=FALSE;
	BOOL ArchMode=FALSE;
	CToolBar ToolBar;
	CReBar ReBar;
	CBitmap* BtnBmp[256];
	std::vector<std::string> BtnNames;
	CArchDoc* pDoc=nullptr;
	void FindIntersections(const std::shared_ptr<CElement>& pElement);
	void DeconnectElement(int ElemIndex);

public:
	virtual BOOL Create(LPCTSTR lpszClassName, LPCTSTR lpszWindowName, DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID, CCreateContext* pContext = NULL) override;

	void OnPinStateChanged(DWORD PinState, int hElement);

protected:
	virtual void OnInitialUpdate() override;
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs) override;
	virtual void OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint) override;
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo) override;
	virtual void OnPrint(CDC* pDC, CPrintInfo* pInfo) override;
	virtual void OnDraw(CDC* pDC) override;
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CArchView();

	UINT Ind[3] = { 0, 0, 0 };
	std::thread threadRedraw;
	//std::thread threadVSync;
	int fps = 0;
	//bool isVSyncCatched = false;

	void ConnectSelected();
	BOOL MoveSelected(int ShiftX, int ShiftY);
	CPoint GetMinDist(const std::shared_ptr<CElement>& pFixedElement, const std::shared_ptr<CElement>& pMovedElement);
	BOOL ConnectElements(const std::shared_ptr<CElement>& pMovedElement, const std::shared_ptr<CElement>& pFixedElement);
	static void redrawChangedElements(CArchView* pArchView);
	//static void vsync(CArchView* pArchView);
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CArchView)
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnArchElemDel();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnArchMode();
	afx_msg void OnConstrMode();
	afx_msg void OnUpdateArchElemDel(CCmdUI* pCmdUI);
	afx_msg void OnUpdateAddElement(CCmdUI* pCmdUI);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg LPARAM OnAddElementByName(WPARAM wParam, LPARAM lParam);
	afx_msg LPARAM OnElementLButtonDown(WPARAM nFlags, LPARAM hElement);
	afx_msg LPARAM OnElementLButtonUp(WPARAM nFlags, LPARAM hElement);
	afx_msg LPARAM OnElementMouseMove(WPARAM nFlags, LPARAM hElement);
	afx_msg LPARAM OnArchElemDisconnect(WPARAM nFlags, LPARAM hElement);
	afx_msg LPARAM OnArchElemConnect(WPARAM nFlags, LPARAM hElement);
	//afx_msg LPARAM OnKillInstrCounter(WPARAM Void, LPARAM hElement);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnKeyUp(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnDestroy();
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

