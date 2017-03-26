// Test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "Test.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// The one and only application object

CWinApp theApp;

using namespace std;

#define FILE_DEVICE_UNKNOWN             0x00000022
#define IOCTL_UNKNOWN_BASE              FILE_DEVICE_UNKNOWN

#define IOCTL_BEEP_ON CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0800, METHOD_BUFFERED, FILE_WRITE_ACCESS)
#define IOCTL_BEEP_OFF CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0801, METHOD_BUFFERED, 0)

int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
	int nRetCode = 0;

	// initialize MFC and print and error on failure
	if (!AfxWinInit(::GetModuleHandle(NULL), NULL, ::GetCommandLine(), 0))
	{
		// TODO: change error code to suit your needs
		cerr << _T("Fatal Error: MFC initialization failed") << endl;
		nRetCode = 1;
	}
	else
	{
    if(argc!=2) {
      printf("Using:  Test.exe <Delay>\n");
      return 0;
    }

    DWORD BytesRet,Delay,DelayMax=0;
    
    sscanf(argv[1],"%d",&DelayMax);
    
    HANDLE hDirBeep=CreateFile("\\\\.\\DirectBeep",GENERIC_READ|GENERIC_WRITE,
      0/*FILE_SHARE_READ|FILE_SHARE_WRITE*/,0,OPEN_EXISTING,0,0);

    if(hDirBeep==INVALID_HANDLE_VALUE) {
      printf("Cannot open driver DirectBeep\n");
      return 0;
    }

    WORD DivK=2;
    for(int n=0; n<1000; n++) {
      DeviceIoControl(hDirBeep,IOCTL_BEEP_ON,&DivK,2,NULL,0,&BytesRet,NULL);
      for(Delay=0; Delay<DelayMax; Delay++) BytesRet*=BytesRet;
      DeviceIoControl(hDirBeep,IOCTL_BEEP_OFF,NULL,0,NULL,0,&BytesRet,NULL);
      for(Delay=0; Delay<DelayMax; Delay++) BytesRet*=BytesRet;
    }

    CloseHandle(hDirBeep);
	}

	return nRetCode;
}


