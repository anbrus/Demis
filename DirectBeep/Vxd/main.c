#define WANTVXDWRAPS

#include <basedef.h>
#include <vmm.h>
#include <debug.h>
#include <vxdwraps.h>
#include <vwin32.h>
#include <winerror.h>

#define CVXD_VERSION 0x400

typedef DIOCPARAMETERS *LPDIOC;


#define CTL_CODE(DeviceType,Function,Method,Access)(((DeviceType)<<16)|((Access)<<14)|((Function)<<2)|(Method))

// Define the method codes for how buffers are passed for I/O and FS controls
#define METHOD_BUFFERED                 0
#define METHOD_IN_DIRECT                1
#define METHOD_OUT_DIRECT               2
#define METHOD_NEITHER                  3

// Define the access check value for any access
//
//
// The FILE_READ_ACCESS and FILE_WRITE_ACCESS constants are also defined in
// ntioapi.h as FILE_READ_DATA and FILE_WRITE_DATA. The values for these
// constants *MUST* always be in sync.
#define FILE_ANY_ACCESS                 0
#define FILE_READ_ACCESS          ( 0x0001 )    // file & pipe
#define FILE_WRITE_ACCESS         ( 0x0002 )    // file & pipe

#define FILE_DEVICE_UNKNOWN             0x00000022
#define IOCTL_UNKNOWN_BASE              FILE_DEVICE_UNKNOWN

#define IOCTL_BEEP_ON CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0800, METHOD_BUFFERED, FILE_WRITE_ACCESS)
#define IOCTL_BEEP_OFF CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0801, METHOD_BUFFERED, 0)


#pragma VxD_LOCKED_CODE_SEG
#pragma VxD_LOCKED_DATA_SEG


// define wrappers for VWIN32_DIOCCompletionRoutine and Set_Thread_Time_Out
MAKE_HEADER(VOID,_stdcall, VWIN32_DIOCCompletionRoutine, (DWORD hEvent))
#define VWIN32_DIOCCompletionRoutine PREPEND(VWIN32_DIOCCompletionRoutine)

UCHAR ReadBytePort(USHORT Port)
{
  UCHAR RetVal;
  _asm {
    mov dx,Port
    in  al,dx
    mov RetVal,al
  }
  return RetVal;
}

void WriteBytePort(USHORT Port,UCHAR Val)
{
  _asm {
    mov dx,Port
    mov al,Val
    out dx,al
  }
}

DWORD _stdcall CVXD_W32_DeviceIOControl(DWORD dwService,DWORD dwDDB,DWORD hDevice,LPDIOC lpDIOCParms)
{
  DWORD dwRetVal;

  switch(dwService) {
  case DIOC_OPEN:
    // Must return 0 to tell WIN32 that this VxD supports DEVIOCTL
    dwRetVal = 0;
    break;
      
  case DIOC_CLOSEHANDLE:
    {
      UCHAR State61=ReadBytePort(0x61);
      WriteBytePort(0x61,(UCHAR)(State61&0xFC));
      dwRetVal = VXD_SUCCESS;
      break;
    }

  case IOCTL_BEEP_ON:
    {
      UCHAR State61=ReadBytePort(0x61);
      USHORT DivK=*((USHORT*)lpDIOCParms->lpvInBuffer);
      WriteBytePort(0x43,0xB6);  //10110110
      WriteBytePort(0x42,(UCHAR)(DivK));
      WriteBytePort(0x42,(UCHAR)(DivK>>8));
      WriteBytePort(0x61, (UCHAR)(State61|3));

      VWIN32_DIOCCompletionRoutine((DWORD)((OVERLAPPED *)lpDIOCParms->lpoOverlapped)->O_Internal);
      dwRetVal = VXD_SUCCESS;
      
      break;
    }

  case IOCTL_BEEP_OFF:
    {
      UCHAR State61=ReadBytePort(0x61);
      WriteBytePort(0x61, (UCHAR)(State61&0xFC));
      break;

      VWIN32_DIOCCompletionRoutine((DWORD)((OVERLAPPED *)lpDIOCParms->lpoOverlapped)->O_Internal);
      dwRetVal = VXD_SUCCESS;
      
      break;
    }
  default:
    dwRetVal = ERROR_NOT_SUPPORTED;
    break;
  }

  return dwRetVal;
}
