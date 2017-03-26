// BeepElement.cpp: implementation of the CBeepElement class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "stdelem.h"
#include "BeepElement.h"
#include <winioctl.h>

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

#define FILE_DEVICE_UNKNOWN 0x00000022
#define IOCTL_UNKNOWN_BASE FILE_DEVICE_UNKNOWN

#define IOCTL_BEEP_ON CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0800, METHOD_BUFFERED, FILE_WRITE_ACCESS)
#define IOCTL_BEEP_OFF CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0801, METHOD_BUFFERED, 0)

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBeepElement::CBeepElement(BOOL ArchMode,CElemInterface* pInterface)
  : CElement(ArchMode,pInterface)
{
  IdIndex=9;
  Enabled=FALSE;
  PointCount=1;
  ConPoint[0].x=2; ConPoint[0].y=10;
  ConPin[0]=FALSE; PinType[0]=PT_INPUT;
  Freq=1000;

  hWaveOut = nullptr;
  WAVEFORMATEX waveFormat;
  waveFormat.cbSize = sizeof(waveFormat);
  waveFormat.wFormatTag = WAVE_FORMAT_PCM;
  waveFormat.nChannels = 1;
  waveFormat.nSamplesPerSec = 44100;
  waveFormat.wBitsPerSample = 16;
  waveFormat.nBlockAlign = waveFormat.nChannels * waveFormat.wBitsPerSample / 8;
  waveFormat.nAvgBytesPerSec = waveFormat.nSamplesPerSec*waveFormat.nBlockAlign;
  waveOutOpen(&hWaveOut, WAVE_MAPPER, &waveFormat, 0, 0, CALLBACK_NULL);
  if(hWaveOut) {
	  updateWave();
  }

  pArchElemWnd=new CBeepArchWnd(this);
  pConstrElemWnd=new CBeepConstrWnd(this);

	HINSTANCE hInstOld = AfxGetResourceHandle();
  HMODULE hDll=GetModuleHandle(theApp.m_pszAppName);
	AfxSetResourceHandle(hDll);
  PopupMenu.LoadMenu(IDR_BEEP_MENU);
	AfxSetResourceHandle(hInstOld);

  OSVERSIONINFO os;
  os.dwOSVersionInfoSize=sizeof(os);
  GetVersionEx(&os);
  //NTOS=os.dwPlatformId==VER_PLATFORM_WIN32_NT;
}

CBeepElement::~CBeepElement()
{
	if (hWaveOut) {
		waveOutUnprepareHeader(hWaveOut, &headerWave, sizeof(headerWave));
		waveOutClose(hWaveOut);
		hWaveOut = nullptr;
	}
}

BOOL CBeepElement::Load(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version;
  File.Read(&Version,4);
  if(Version!=0x00010000) {
    MessageBox(NULL,"Генератор звука: неизвестная версия элемента","Ошибка",MB_ICONSTOP|MB_OK);
    return FALSE;
  }
  
  File.Read(&Freq,4);

  return CElement::Load(hFile);
}

BOOL CBeepElement::Save(HANDLE hFile)
{
  CFile File(hFile);

  DWORD Version=0x00010000;
  File.Write(&Version,4);

  File.Write(&Freq,4);

  return CElement::Save(hFile);
}

BOOL CBeepElement::Show(HWND hArchParentWnd, HWND hConstrParentWnd)
{
  if(!CElement::Show(hArchParentWnd,hConstrParentWnd)) return FALSE;

  CString ClassName=AfxRegisterWndClass(CS_DBLCLKS,
    ::LoadCursor(NULL,IDC_ARROW));
  pArchElemWnd->Create(ClassName,"Генератор звука",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pArchElemWnd->Size.cx,pArchElemWnd->Size.cy),pArchParentWnd,0);
  pConstrElemWnd->Create(ClassName,"Генератор звука",WS_VISIBLE|WS_OVERLAPPED|WS_CHILD|WS_CLIPSIBLINGS,
    CRect(0,0,pConstrElemWnd->Size.cx,pConstrElemWnd->Size.cy),pConstrParentWnd,0);

  UpdateTipText();

  return TRUE;
}

BOOL CBeepElement::Reset(BOOL bEditMode,CURRENCY* pTickCounter,DWORD TaktFreq,DWORD FreePinLevel)
{
  Enabled=FALSE;

  Beep(FALSE);

  return CElement::Reset(bEditMode,pTickCounter,TaktFreq,FreePinLevel);
}

//////////////////////////////////////////////////////////////////////
// CBeepArchWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CBeepArchWnd, CElementWnd)
	//{{AFX_MSG_MAP(CBeepArchWnd)
	ON_WM_CREATE()
	ON_COMMAND(ID_BEEP_FREQ, OnBeepFreq)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBeepArchWnd::CBeepArchWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=71;
  Size.cy=35;
}

CBeepArchWnd::~CBeepArchWnd()
{

}

//////////////////////////////////////////////////////////////////////
// CBeepConstrWnd Class
//////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CBeepConstrWnd, CElementWnd)
	//{{AFX_MSG_MAP(CBeepConstrWnd)
	ON_COMMAND(ID_BEEP_FREQ, OnBeepFreq)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBeepConstrWnd::CBeepConstrWnd(CElement* pElement) : CElementWnd(pElement)
{
  Size.cx=50;
  Size.cy=50;
}

CBeepConstrWnd::~CBeepConstrWnd()
{

}

void CBeepArchWnd::Draw(CDC *pDC)
{
  CGdiObject* pOldPen;
  if(pElement->ArchSelected) {
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
    pDC->SetTextColor(theApp.SelectColor);
  }else {
    pOldPen=pDC->SelectObject(&theApp.DrawPen);
    pDC->SetTextColor(theApp.DrawColor);
  }

  pDC->MoveTo(10,22);
  pDC->LineTo(15,22);
  pDC->LineTo(15,17);
  pDC->LineTo(20,17);
  pDC->LineTo(20,22);
  pDC->LineTo(25,22);
  pDC->LineTo(25,17);
  pDC->LineTo(30,17);
  
  //Элемент "&"
  CFont BeepFont;
  BeepFont.CreatePointFont(100,"Arial");
  CGdiObject* pOldFont=pDC->SelectObject(&BeepFont);
  pDC->Rectangle(35,0,60,35);
  pDC->DrawText("&",CRect(35,0,60,35*2/3),
    DT_CENTER|DT_VCENTER|DT_SINGLELINE|DT_NOPREFIX);
  pDC->SelectObject(pOldFont);

  //Выводы
  pDC->MoveTo(2,10); pDC->LineTo(35,10);
  pDC->MoveTo(10,25); pDC->LineTo(35,25);

  //Диффузор
  pDC->MoveTo(60,10);
  pDC->LineTo(70,0);
  pDC->LineTo(70,34);
  pDC->LineTo(59,23);

  //Рисуем крестик, если надо
  if(!pElement->ConPin[0]) {
    CPen BluePen(PS_SOLID,0,RGB(0,0,255));
    pDC->SelectObject(&BluePen);
    pDC->MoveTo(pElement->ConPoint[0].x-2,pElement->ConPoint[0].y-2);
    pDC->LineTo(pElement->ConPoint[0].x+3,pElement->ConPoint[0].y+3);
    pDC->MoveTo(pElement->ConPoint[0].x-2,pElement->ConPoint[0].y+2);
    pDC->LineTo(pElement->ConPoint[0].x+3,pElement->ConPoint[0].y-3);
  }else { //или палочку
    pDC->MoveTo(0,pElement->ConPoint[0].y);
    pDC->LineTo(5,pElement->ConPoint[0].y);
  }

  //Восстанавливаем контекст
  pDC->SelectObject(pOldPen);
}

int CBeepArchWnd::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CElementWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
  UpdateRegionSize();

  return 0;
}

void CBeepConstrWnd::Draw(CDC *pDC)
{
  CGdiObject* pOldPen;
  if(pElement->ConstrSelected)
    pOldPen=pDC->SelectObject(&theApp.SelectPen);
	else pOldPen=pDC->SelectObject(&theApp.DrawPen);

  CBrush SpBrush;
  if(pElement->ConstrSelected)
    SpBrush.CreateHatchBrush(HS_DIAGCROSS,theApp.SelectColor);
	else SpBrush.CreateHatchBrush(HS_DIAGCROSS,theApp.DrawColor);
  CGdiObject* pOldBrush=pDC->SelectObject(&SpBrush);

  pDC->Ellipse(0,0,Size.cx,Size.cy);

  pDC->SelectObject(pOldBrush);
  pDC->Ellipse(0,0,6,6);
  pDC->Ellipse(Size.cx,Size.cy,Size.cx-6,Size.cy-6);
  pDC->Ellipse(Size.cx,0,Size.cx-6,6);
  pDC->Ellipse(0,Size.cy,6,Size.cy-6);

  pDC->SelectObject(pOldBrush);
  pDC->SelectObject(pOldPen);
}

void CBeepElement::UpdateTipText()
{
  TipText="Генератор звука";
}

void CBeepElement::SetPinState(DWORD NewState)
{
  DWORD CurState=Enabled>0 ? 1 : 0;
  if((NewState&1)!=CurState) {
    Enabled=NewState&1;
    if(Enabled) Beep(TRUE);
    else Beep(FALSE);
  }
}


void CBeepArchWnd::UpdateRegionSize()
{
  if(BeepRgn.m_hObject) {
    SetWindowRgn(NULL,FALSE);
    BeepRgn.DeleteObject();
  }
  CPoint Pnts[]={
    CPoint(0,0),
    CPoint(Size.cx,0),
    CPoint(Size.cx,Size.cy),
    CPoint(10,Size.cy),
    CPoint(10,pElement->ConPoint[0].y+3),
    CPoint(0,pElement->ConPoint[0].y+3),
  };
  BeepRgn.CreatePolygonRgn(Pnts,sizeof(Pnts)/sizeof(CPoint),WINDING);
  SetWindowRgn(BeepRgn,FALSE);
}

void CBeepElement::OnChangeFreq()
{
  CFreqDlg FreqDlg;
  FreqDlg.m_Freq=Freq;
  if(FreqDlg.DoModal()==IDOK) {
    Freq=FreqDlg.m_Freq;
    ModifiedFlag=1;
	updateWave();
  }
}

void CBeepElement::updateWave() {
	if (Freq <= 20 || Freq>20000) {
		for (int n = 0; n < 44100; n++) {
			wave[n] = 32767;
		}
	}
	else {
		int period = 44100/Freq;
		countWaveSamples = 44100 / period * period;
		for (int n = 0; n < 44100; n++) {
			wave[n] = n%period > period / 2 ? 32767 : -32767;
		}
	}
}

void CBeepArchWnd::OnBeepFreq() 
{
  ((CBeepElement*)pElement)->OnChangeFreq();
}
/////////////////////////////////////////////////////////////////////////////
// CFreqDlg dialog


CFreqDlg::CFreqDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CFreqDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CFreqDlg)
	m_Freq = 0;
	//}}AFX_DATA_INIT
}


void CFreqDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CFreqDlg)
	DDX_Text(pDX, IDC_FREQ, m_Freq);
	DDV_MinMaxUInt(pDX, m_Freq, 0, 20000);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CFreqDlg, CDialog)
	//{{AFX_MSG_MAP(CFreqDlg)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CFreqDlg message handlers

void CBeepConstrWnd::OnBeepFreq() 
{
  ((CBeepElement*)pElement)->OnChangeFreq();
}

void CBeepElement::Beep(BOOL BeepOn)
{
	if (!hWaveOut) return;

	if (BeepOn) {
		memset(&headerWave, 0, sizeof(headerWave));
		headerWave.lpData = reinterpret_cast<LPSTR>(wave);
		headerWave.dwBufferLength = countWaveSamples*2;
		headerWave.dwFlags = WHDR_BEGINLOOP | WHDR_ENDLOOP;
		headerWave.dwLoops = 1 << 31;
		MMRESULT res=waveOutPrepareHeader(hWaveOut, &headerWave, sizeof(headerWave));
		res=waveOutWrite(hWaveOut, &headerWave, sizeof(headerWave));
		res++;
	}
	else waveOutReset(hWaveOut);
	//if(Freq==0) return;

}
