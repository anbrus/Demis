#ifdef __cplusplus
extern "C"
{
#include <ntddk.h>
}
#else
#include <ntddk.h>
#endif


#define FILE_DEVICE_UNKNOWN             0x00000022
#define IOCTL_UNKNOWN_BASE              FILE_DEVICE_UNKNOWN

#define IOCTL_BEEP_ON CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0800, METHOD_BUFFERED, FILE_WRITE_ACCESS)
#define IOCTL_BEEP_OFF CTL_CODE(IOCTL_UNKNOWN_BASE, 0x0801, METHOD_BUFFERED, 0)

void UnloadDriver(PDRIVER_OBJECT DriverObject);
NTSTATUS DispatchCreate(IN PDEVICE_OBJECT DeviceObject,IN PIRP Irp);
NTSTATUS DispatchClose(IN PDEVICE_OBJECT DeviceObject,IN PIRP Irp);
NTSTATUS DispatchIoctl(IN PDEVICE_OBJECT DeviceObject,IN PIRP Irp);

extern "C"
NTSTATUS DriverEntry(IN PDRIVER_OBJECT DriverObject,IN PUNICODE_STRING RegistryPath)
/*++
Routine Description:
    This routine is called when the driver is loaded by NT.
Arguments:
    DriverObject - Pointer to driver object created by system.
    RegistryPath - Pointer to the name of the services node for this driver.
Return Value:
    The function value is the final status from the initialization operation.
--*/
{
  NTSTATUS ntStatus;
  UNICODE_STRING DriverString;
  UNICODE_STRING DeviceString;
  PDEVICE_OBJECT pDeviceObject;
      
  // Point uszDriverString at the driver name
  RtlInitUnicodeString(&DriverString,L"\\Device\\DirectBeep");

  // Create and initialize device object
  ntStatus=IoCreateDevice(DriverObject,0,&DriverString,FILE_DEVICE_UNKNOWN,
    0,FALSE,&pDeviceObject);

  if(ntStatus!=STATUS_SUCCESS) return ntStatus;

  // Point uszDeviceString at the device name
  RtlInitUnicodeString(&DeviceString,L"\\DosDevices\\DirectBeep");

  // Create symbolic link to the user-visible name
  ntStatus=IoCreateSymbolicLink(&DeviceString,&DriverString);

  if(ntStatus!=STATUS_SUCCESS) {
    // Delete device object if not successful
    IoDeleteDevice(pDeviceObject);
    return ntStatus;
  }

  // Load structure to point to IRP handlers...
  DriverObject->DriverUnload                =UnloadDriver;
  DriverObject->MajorFunction[IRP_MJ_CREATE]=DispatchCreate;
  DriverObject->MajorFunction[IRP_MJ_CLOSE] =DispatchClose;
  DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DispatchIoctl;

  // Return success
  return ntStatus;
}


NTSTATUS DispatchCreate(IN PDEVICE_OBJECT DeviceObject,IN PIRP Irp)
{
  Irp->IoStatus.Status=STATUS_SUCCESS;
  Irp->IoStatus.Information=0;

  IoCompleteRequest(Irp,IO_NO_INCREMENT);
  return STATUS_SUCCESS;
}


NTSTATUS DispatchClose(IN PDEVICE_OBJECT DeviceObject,IN PIRP Irp)
{
  UCHAR State61=READ_PORT_UCHAR((PUCHAR)0x61);
  WRITE_PORT_UCHAR((PUCHAR)0x61,State61&0xFC);

  Irp->IoStatus.Status=STATUS_SUCCESS;
  Irp->IoStatus.Information=0;

  IoCompleteRequest(Irp,IO_NO_INCREMENT);
  return(STATUS_SUCCESS);
}


void UnloadDriver(PDRIVER_OBJECT DriverObject)
{
  UNICODE_STRING DeviceString;

  IoDeleteDevice(DriverObject->DeviceObject);

  RtlInitUnicodeString(&DeviceString,L"\\DosDevices\\DirectBeep");
  IoDeleteSymbolicLink(&DeviceString);
}


NTSTATUS DispatchIoctl(IN PDEVICE_OBJECT DeviceObject, IN PIRP Irp)
{
  KdPrint(("Enter Ioctl dispatcher\n"));

  PIO_STACK_LOCATION     irpStack = IoGetCurrentIrpStackLocation(Irp);
  NTSTATUS ntStatus=STATUS_SUCCESS;
    
  switch(irpStack->Parameters.DeviceIoControl.IoControlCode) {
  case IOCTL_BEEP_ON:
    {
      KdPrint(("Beep on..."));
      if(irpStack->Parameters.DeviceIoControl.InputBufferLength!=2) {
        ntStatus=STATUS_INVALID_PARAMETER;
        break;
      }

      UCHAR State61=READ_PORT_UCHAR((PUCHAR)0x61);
      USHORT DivK=*((USHORT*)Irp->AssociatedIrp.SystemBuffer);
      WRITE_PORT_UCHAR((PUCHAR)0x43,0xB6);  //10110110
      WRITE_PORT_UCHAR((PUCHAR)0x42,(UCHAR)(DivK));
      WRITE_PORT_UCHAR((PUCHAR)0x42,(UCHAR)(DivK>>8));
      WRITE_PORT_UCHAR((PUCHAR)0x61, State61|3);
      break;
    }
  case IOCTL_BEEP_OFF:
    {
      KdPrint(("Beep off..."));
      if(irpStack->Parameters.DeviceIoControl.InputBufferLength!=0) {
        ntStatus=STATUS_INVALID_PARAMETER;
        break;
      }

      UCHAR State61=READ_PORT_UCHAR((PUCHAR)0x61);
      WRITE_PORT_UCHAR((PUCHAR)0x61, State61&0xFC);
      break;
    }
  default:
    KdPrint(("Unknown Ioctl code..."));
    ntStatus=STATUS_INVALID_PARAMETER;
  }

  Irp->IoStatus.Status=ntStatus;
  Irp->IoStatus.Information=0;

  IoCompleteRequest(Irp, IO_NO_INCREMENT);

  if(ntStatus==STATUS_SUCCESS) KdPrint(("ok\n"));
  else KdPrint(("fail\n"));

  KdPrint(("Leave Ioctl dispatcher\n"));

  return ntStatus;
}
