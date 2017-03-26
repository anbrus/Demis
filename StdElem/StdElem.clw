; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CStdElemApp
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "stdelem.h"
LastPage=0

ClassCount=26
Class1=CADCArchWnd
Class2=CADCConstrWnd
Class3=CADCDelayDlg
Class4=CADCLimitsDlg
Class5=CAddressDlg
Class6=CBeepArchWnd
Class7=CBeepConstrWnd
Class8=CFreqDlg
Class9=CBtnArchWnd
Class10=CBtnConstrWnd
Class11=CElementWnd
Class12=CIndArchWnd
Class13=CIndConstrWnd
Class14=CInPortArchWnd
Class15=CKbdArchWnd
Class16=CKbdConstrWnd
Class17=CKbdCaptionsDlg
Class18=CKbdSizeDlg
Class19=CLabelWnd
Class20=CLedArchWnd
Class21=CLedConstrWnd
Class22=CMatrixArchWnd
Class23=CMatrixConstrWnd
Class24=CMatrixSizeDlg
Class25=COutPortArchWnd
Class26=CStdElemApp

ResourceCount=20
Resource1=IDR_KBD_MENU
Resource2=IDR_ADC_MENU
Resource3=IDR_BEEP_MENU
Resource4=IDR_MATRIX_MENU
Resource5=IDD_ADDRESS_DLG
Resource6=IDD_TEXT_DLG
Resource7=IDD_KBD_CAPTIONS_DLG
Resource8=IDD_KBD_SIZE_DLG
Resource9=IDD_ADC_DELAY_DLG
Resource10=IDD_ADC_LIMITS_DLG
Resource11=IDD_BEEP_FREQ_DLG
Resource12=IDR_LED_MENU
Resource13=IDR_OUTPUT_PORT_MENU
Resource14=IDR_LABEL_MENU
Resource15=IDR_INPUT_PORT_MENU
Resource16=IDR_BUTTON_MENU
Resource17=IDR_IND_MENU
Resource18=IDD_MATRIX_SIZE_DLG
Resource19=IDB_ADC_ELEMENT
Resource20=IDB_BEEP_ELEMENT

[CLS:CADCArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=ADCElement.h
ImplementationFile=ADCElement.cpp
Filter=W

[CLS:CADCConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=ADCElement.h
ImplementationFile=ADCElement.cpp

[CLS:CADCDelayDlg]
Type=0
BaseClass=CDialog
HeaderFile=ADCElement.h
ImplementationFile=ADCElement.cpp

[CLS:CADCLimitsDlg]
Type=0
BaseClass=CDialog
HeaderFile=ADCElement.h
ImplementationFile=ADCElement.cpp

[CLS:CAddressDlg]
Type=0
BaseClass=CDialog
HeaderFile=AddressDlg.h
ImplementationFile=AddressDlg.cpp

[CLS:CBeepArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=BeepElement.h
ImplementationFile=BeepElement.cpp

[CLS:CBeepConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=BeepElement.h
ImplementationFile=BeepElement.cpp

[CLS:CFreqDlg]
Type=0
BaseClass=CDialog
HeaderFile=BeepElement.h
ImplementationFile=BeepElement.cpp

[CLS:CBtnArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=Button.h
ImplementationFile=Button.cpp

[CLS:CBtnConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=Button.h
ImplementationFile=Button.cpp

[CLS:CElementWnd]
Type=0
BaseClass=CWnd
HeaderFile=ElementWnd.h
ImplementationFile=ElementWnd.cpp

[CLS:CIndArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=Indicator.h
ImplementationFile=Indicator.cpp

[CLS:CIndConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=Indicator.h
ImplementationFile=Indicator.cpp

[CLS:CInPortArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=InputPort.h
ImplementationFile=InputPort.cpp

[CLS:CKbdArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=kbdelement.h
ImplementationFile=KbdElement.cpp

[CLS:CKbdConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=kbdelement.h
ImplementationFile=KbdElement.cpp

[CLS:CKbdCaptionsDlg]
Type=0
BaseClass=CDialog
HeaderFile=kbdelement.h
ImplementationFile=KbdElement.cpp

[CLS:CKbdSizeDlg]
Type=0
BaseClass=CDialog
HeaderFile=kbdelement.h
ImplementationFile=KbdElement.cpp

[CLS:CLabelWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=Label.h
ImplementationFile=Label.cpp

[CLS:CLedArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=LedElement.h
ImplementationFile=LedElement.cpp

[CLS:CLedConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=LedElement.h
ImplementationFile=LedElement.cpp

[CLS:CMatrixArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=matrixelem.h
ImplementationFile=MatrixElem.cpp

[CLS:CMatrixConstrWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=matrixelem.h
ImplementationFile=MatrixElem.cpp

[CLS:CMatrixSizeDlg]
Type=0
HeaderFile=matrixelem.h
ImplementationFile=MatrixElem.cpp

[CLS:COutPortArchWnd]
Type=0
BaseClass=CElementWnd
HeaderFile=OutputPort.h
ImplementationFile=OutputPort.cpp

[CLS:CStdElemApp]
Type=0
BaseClass=CWinApp
HeaderFile=StdElemApp.h
ImplementationFile=StdElem.cpp

[DLG:IDD_ADC_DELAY_DLG]
Type=1
Class=CADCDelayDlg
ControlCount=5
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_STATIC,static,1342308866
Control4=IDC_DELAY,edit,1350639616
Control5=IDC_STATIC,static,1342308866

[DLG:IDD_ADC_LIMITS_DLG]
Type=1
Class=CADCLimitsDlg
ControlCount=8
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_STATIC,static,1342308866
Control4=IDC_HILIMIT,edit,1350631424
Control5=IDC_STATIC,static,1342308866
Control6=IDC_STATIC,static,1342308866
Control7=IDC_LOLIMIT,edit,1350631424
Control8=IDC_STATIC,static,1342308866

[DLG:IDD_ADDRESS_DLG]
Type=1
Class=CAddressDlg
ControlCount=3
Control1=IDC_ADDRESS,edit,1350631432
Control2=IDOK,button,1342242817
Control3=IDCANCEL,button,1342242816

[DLG:IDD_BEEP_FREQ_DLG]
Type=1
Class=CFreqDlg
ControlCount=5
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_STATIC,static,1342308864
Control4=IDC_FREQ,edit,1350639744
Control5=IDC_STATIC,static,1342308864

[DLG:IDD_KBD_CAPTIONS_DLG]
Type=1
Class=CKbdCaptionsDlg
ControlCount=9
Control1=IDC_X,combobox,1344339971
Control2=IDC_Y,combobox,1344339971
Control3=IDC_CAPTION,edit,1350631424
Control4=ID_NEXT,button,1342242817
Control5=IDOK,button,1342242816
Control6=IDCANCEL,button,1342242816
Control7=IDC_STATIC,static,1342308866
Control8=IDC_STATIC,static,1342308866
Control9=IDC_STATIC,static,1342308866

[DLG:IDD_KBD_SIZE_DLG]
Type=1
Class=CKbdSizeDlg
ControlCount=6
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_X,combobox,1344339971
Control4=IDC_Y,combobox,1344339971
Control5=IDC_STATIC,static,1342308866
Control6=IDC_STATIC,static,1342308866

[DLG:IDD_MATRIX_SIZE_DLG]
Type=1
Class=CMatrixSizeDlg
ControlCount=6
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_X,combobox,1344339971
Control4=IDC_Y,combobox,1344339971
Control5=IDC_STATIC,static,1342308866
Control6=IDC_STATIC,static,1342308866

[MNU:IDR_LED_MENU]
Type=1
Class=?
Command1=ID_ACTIVE_HIGH
Command2=ID_ACTIVE_LOW
Command3=ID_SELECT_COLOR
CommandCount=3

[MNU:IDR_OUTPUT_PORT_MENU]
Type=1
Class=?
Command1=ID_ADDRESS
Command2=ID_ROTATE
CommandCount=2

[MNU:IDR_LABEL_MENU]
Type=1
Class=?
Command1=ID_LABEL_TEXT
CommandCount=1

[MNU:IDR_INPUT_PORT_MENU]
Type=1
Class=?
Command1=ID_ADDRESS
CommandCount=1

[MNU:IDR_BUTTON_MENU]
Type=1
Class=?
Command1=ID_LABEL_TEXT
Command2=ID_NORMAL_OPENED
Command3=ID_NORMAL_CLOSED
Command4=ID_FIXABLE
Command5=ID_DREBEZG
CommandCount=5

[MNU:IDR_IND_MENU]
Type=1
Class=?
Command1=ID_ACTIVE_HIGH
Command2=ID_ACTIVE_LOW
CommandCount=2

[MNU:IDR_KBD_MENU]
Type=1
Class=?
Command1=ID_DREBEZG
Command2=ID_KBD_CAPTIONS
Command3=ID_KBD_SIZE
Command4=ID_FIXABLE
CommandCount=4

[MNU:IDR_ADC_MENU]
Type=1
Class=?
Command1=ID_DELAY
Command2=ID_LIMITS
Command3=ID_HI_PRECISION
CommandCount=3

[MNU:IDR_BEEP_MENU]
Type=1
Class=?
Command1=ID_BEEP_FREQ
CommandCount=1

[MNU:IDR_MATRIX_MENU]
Type=1
Class=?
Command1=ID_MATRIX_SIZE
Command2=ID_ACTIVE_HIGH
Command3=ID_ACTIVE_LOW
CommandCount=3

[DLG:IDD_TEXT_DLG]
Type=1
Class=?
ControlCount=3
Control1=IDC_TEXT,edit,1353781444
Control2=IDOK,button,1342242817
Control3=IDCANCEL,button,1342242816

[TB:IDB_ADC_ELEMENT]
Type=1
Command1=ID_BUTTON32772
CommandCount=1

[TB:IDB_BEEP_ELEMENT]
Type=1
Command1=ID_BUTTON32773
CommandCount=1

