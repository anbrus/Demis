// Element.cpp : Implementation of CElement
#include "stdafx.h"
#include "StdElem.h"
#include "StdElemApp.h"
#include "ElemInterf.h"

#include "LedElement.h"
#include "OutputPort.h"
#include "Label.h"
#include "Indicator.h"
#include "IndicatorDyn.h"
#include "InputPort.h"
#include "Button.h"
#include "KbdElement.h"
#include "ADCElement.h"
#include "BeepElement.h"
#include "MatrixElem.h"

/////////////////////////////////////////////////////////////////////////////
// CElement


STDMETHODIMP CElemInterface::get_hElement(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

  *pVal=(long)hElement;

	return S_OK;
}

STDMETHODIMP CElemInterface::put_hElement(long newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	hElement=(HANDLE)newVal;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nType(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=(long)theApp.ElementId[pElement->IdIndex].Type;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_sName(BSTR *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=theApp.ElementId[pElement->IdIndex].Name.AllocSysString();

	return S_OK;
}

STDMETHODIMP CElemInterface::get_sClsId(BSTR *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=theApp.ElementId[pElement->IdIndex].ClsId.AllocSysString();

	return S_OK;
}

STDMETHODIMP CElemInterface::get_hArchWnd(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=0;
  if(pElement->pArchElemWnd) *pVal=(long)pElement->pArchElemWnd->m_hWnd;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_hConstrWnd(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=0;
  if(pElement->pConstrElemWnd) *pVal=(long)pElement->pConstrElemWnd->m_hWnd;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nAddress(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=(long)pElement->Address;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_bModifiedFlag(BOOL *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=pElement->ModifiedFlag;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_sTipText(BSTR *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=pElement->TipText.AllocSysString();

	return S_OK;
}

STDMETHODIMP CElemInterface::get_bArchSelected(BOOL *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=pElement->ArchSelected;

	return S_OK;
}

STDMETHODIMP CElemInterface::put_bArchSelected(BOOL newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	pElement->ArchSelected=newVal;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_bConstrSelected(BOOL *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=pElement->ConstrSelected;

	return S_OK;
}

STDMETHODIMP CElemInterface::put_bConstrSelected(BOOL newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	pElement->ConstrSelected=newVal;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nPointCount(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=(long)pElement->PointCount;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nPortData(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=(long)pElement->GetPortData();

	return S_OK;
}

STDMETHODIMP CElemInterface::put_nPortData(long newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	pElement->SetPortData((DWORD)newVal);

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nPinState(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=(long)pElement->GetPinState();

	return S_OK;
}

STDMETHODIMP CElemInterface::put_nPinState(long newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	pElement->SetPinState((DWORD)newVal);

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nArchAngle(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=0;
  if(pElement->pArchElemWnd) *pVal=(long)pElement->pArchElemWnd->Angle;

	return S_OK;
}

STDMETHODIMP CElemInterface::put_nArchAngle(long newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	if(pElement->pArchElemWnd) pElement->pArchElemWnd->Angle=newVal;

	return S_OK;
}

STDMETHODIMP CElemInterface::get_nConstrAngle(long *pVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pVal=0;
  if(pElement->pConstrElemWnd) *pVal=(long)pElement->pConstrElemWnd->Angle;

	return S_OK;
}

STDMETHODIMP CElemInterface::put_nConstrAngle(long newVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	if(pElement->pConstrElemWnd) pElement->pConstrElemWnd->Angle=newVal;

	return S_OK;
}

STDMETHODIMP CElemInterface::Show(long hArchParentWnd, long hConstrParentWnd, BOOL *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=pElement->Show((HWND)hArchParentWnd,(HWND)hConstrParentWnd);

	return S_OK;
}

STDMETHODIMP CElemInterface::Create(BSTR sElemName, BOOL bArchMode, BOOL *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

  *pRetVal=FALSE;
  for(int n=0; n<theApp.m_ElementsCount; n++) {
    if(theApp.ElementId[n].Name==sElemName) {
      switch(n) {
      case 0 : pElement=new CInputPort(bArchMode,this); *pRetVal=TRUE; break;
      case 1 : pElement=new COutputPort(bArchMode,this); *pRetVal=TRUE; break;
      case 2 : pElement=new CLedElement(bArchMode,this); *pRetVal=TRUE; break;
      case 3 : pElement=new CButtonElement(bArchMode,this); *pRetVal=TRUE; break;
      case 4 : pElement=new CLabel(bArchMode,this); *pRetVal=TRUE; break;
      case 5 : pElement=new CIndicator(bArchMode,this); *pRetVal=TRUE; break;
      case 6 : pElement=new CIndicatorDyn(bArchMode,this); *pRetVal=TRUE; break;
      case 7 : pElement=new CKbdElement(bArchMode,this); *pRetVal=TRUE; break;
      case 8 : pElement=new CADCElement(bArchMode,this); *pRetVal=TRUE; break;
      case 9 : pElement=new CBeepElement(bArchMode,this); *pRetVal=TRUE; break;
      case 10 : pElement=new CMatrixElement(bArchMode,this); *pRetVal=TRUE; break;
      }
    }
  }

	return S_OK;
}

STDMETHODIMP CElemInterface::Reset(BOOL bEditMode, CURRENCY *pTickCounter, long TaktFreq, long FreePinLevel, BOOL *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=pElement->Reset(bEditMode,pTickCounter,(DWORD)TaktFreq,(DWORD)FreePinLevel);

	return S_OK;
}

STDMETHODIMP CElemInterface::ConnectPin(long nPinIndex, BOOL bConnect, BOOL *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=pElement->ConnectPin(nPinIndex,bConnect);

	return S_OK;
}

STDMETHODIMP CElemInterface::GetPinType(long nPinIndex, long *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=(long)pElement->GetPinType(nPinIndex);

	return S_OK;
}

STDMETHODIMP CElemInterface::GetPointPos(long nPointIndex, long *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=(long)(pElement->ConPoint[nPointIndex].x+(pElement->ConPoint[nPointIndex].y<<16));

	return S_OK;
}

STDMETHODIMP CElemInterface::Save(long hFile, BOOL *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=pElement->Save((HANDLE)hFile);

	return S_OK;
}

STDMETHODIMP CElemInterface::Load(long hFile, BOOL *pRetVal)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	*pRetVal=pElement->Load((HANDLE)hFile);

	return S_OK;
}

STDMETHODIMP CElemInterface::OnInstrCounterEvent()
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState())

	pElement->OnInstrCounterEvent();

	return S_OK;
}

void CElemInterface::FinalRelease()
{
  // TODO: Add your specialized code here and/or call the base class
	AFX_MANAGE_STATE(AfxGetStaticModuleState())
  delete pElement;
  __super::FinalRelease();
}
