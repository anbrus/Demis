# Microsoft Developer Studio Project File - Name="Demis2000" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=Demis2000 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Demis2000.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Demis2000.mak" CFG="Demis2000 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Demis2000 - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Demis2000 - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Demis2000 - Win32 Release"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x419 /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x419 /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 /nologo /subsystem:windows /profile /debug /machine:I386 /out:"Release/Demis.exe"

!ELSEIF  "$(CFG)" == "Demis2000 - Win32 Debug"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x419 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x419 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 /nologo /subsystem:windows /profile /debug /machine:I386 /out:"Debug/Demis.exe"
# SUBTRACT LINK32 /verbose

!ENDIF 

# Begin Target

# Name "Demis2000 - Win32 Release"
# Name "Demis2000 - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\ArchDoc.cpp
# End Source File
# Begin Source File

SOURCE=.\ArchFrame.cpp
# End Source File
# Begin Source File

SOURCE=.\ArchView.cpp
# End Source File
# Begin Source File

SOURCE=.\ChildFrm.cpp
# End Source File
# Begin Source File

SOURCE=.\DasmView.cpp
# End Source File
# Begin Source File

SOURCE=.\DebugFrame.cpp
# End Source File
# Begin Source File

SOURCE=.\Demis2000.cpp
# End Source File
# Begin Source File

SOURCE=.\Demis2000.rc
# End Source File
# Begin Source File

SOURCE=.\DumpView.cpp
# End Source File
# Begin Source File

SOURCE=.\Flag.cpp
# End Source File
# Begin Source File

SOURCE=.\MainFrm.cpp
# End Source File
# Begin Source File

SOURCE=.\PrjCfgDlg.cpp
# End Source File
# Begin Source File

SOURCE=.\PrjDoc.cpp
# End Source File
# Begin Source File

SOURCE=.\PrjFrame.cpp
# End Source File
# Begin Source File

SOURCE=.\PrjListView.cpp
# End Source File
# Begin Source File

SOURCE=.\RegisterEdit.cpp
# End Source File
# Begin Source File

SOURCE=.\RegsView.cpp
# End Source File
# Begin Source File

SOURCE=.\StackView.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE=.\StdEditDoc.cpp
# End Source File
# Begin Source File

SOURCE=.\StdEditView.cpp
# End Source File
# Begin Source File

SOURCE=.\StdElem.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\ArchDoc.h
# End Source File
# Begin Source File

SOURCE=.\ArchFrame.h
# End Source File
# Begin Source File

SOURCE=.\ArchView.h
# End Source File
# Begin Source File

SOURCE=.\ChildFrm.h
# End Source File
# Begin Source File

SOURCE=.\DasmView.h
# End Source File
# Begin Source File

SOURCE=.\DebugFrame.h
# End Source File
# Begin Source File

SOURCE=.\definitions.h
# End Source File
# Begin Source File

SOURCE=.\Demis2000.h
# End Source File
# Begin Source File

SOURCE=.\DumpView.h
# End Source File
# Begin Source File

SOURCE=.\ElemInterface.h
# End Source File
# Begin Source File

SOURCE=.\Flag.h
# End Source File
# Begin Source File

SOURCE=.\MainFrm.h
# End Source File
# Begin Source File

SOURCE=.\PrjCfgDlg.h
# End Source File
# Begin Source File

SOURCE=.\PrjDoc.h
# End Source File
# Begin Source File

SOURCE=.\PrjFrame.h
# End Source File
# Begin Source File

SOURCE=.\PrjListView.h
# End Source File
# Begin Source File

SOURCE=.\RegisterEdit.h
# End Source File
# Begin Source File

SOURCE=.\RegsView.h
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE=.\StackView.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# Begin Source File

SOURCE=.\StdEditDoc.h
# End Source File
# Begin Source File

SOURCE=.\StdEditView.h
# End Source File
# Begin Source File

SOURCE=.\StdElem.h
# End Source File
# Begin Source File

SOURCE=.\StdElem\StdElem.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\res\Arch.ico
# End Source File
# Begin Source File

SOURCE=.\res\archtype.bmp
# End Source File
# Begin Source File

SOURCE=.\res\ArchTypeC.bmp
# End Source File
# Begin Source File

SOURCE=.\res\Asm.ico
# End Source File
# Begin Source File

SOURCE=.\res\Clsdfold.ico
# End Source File
# Begin Source File

SOURCE=.\res\Debug.ico
# End Source File
# Begin Source File

SOURCE=.\res\Demis2000.ico
# End Source File
# Begin Source File

SOURCE=.\res\Demis2000.rc2
# End Source File
# Begin Source File

SOURCE=.\res\Demis2000Doc.ico
# End Source File
# Begin Source File

SOURCE=.\res\ico00001.ico
# End Source File
# Begin Source File

SOURCE=.\res\ico00002.ico
# End Source File
# Begin Source File

SOURCE=.\res\icon1.ico
# End Source File
# Begin Source File

SOURCE=.\res\idr_assm.ico
# End Source File
# Begin Source File

SOURCE=.\res\idr_main.ico
# End Source File
# Begin Source File

SOURCE=.\res\mainfram.bmp
# End Source File
# Begin Source File

SOURCE=.\res\Openfold.ico
# End Source File
# Begin Source File

SOURCE=.\res\Prj.ico
# End Source File
# Begin Source File

SOURCE=.\res\Toolbar.bmp
# End Source File
# Begin Source File

SOURCE=.\res\ToolBarC.bmp
# End Source File
# Begin Source File

SOURCE=".\–√¿“¿.bmp"
# End Source File
# End Group
# Begin Group "Libraries"

# PROP Default_Filter "lib"
# Begin Source File

SOURCE=.\Debug\Assm.dll
# End Source File
# Begin Source File

SOURCE=.\Debug\Dasm.dll
# End Source File
# Begin Source File

SOURCE=.\Debug\Emulator.lib
# End Source File
# Begin Source File

SOURCE=.\htmlhelp.lib
# End Source File
# End Group
# Begin Source File

SOURCE=.\Help\Demis.hhp

!IF  "$(CFG)" == "Demis2000 - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
OutDir=.\Release
InputPath=.\Help\Demis.hhp

"$(OutDir)\Demis.chm" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	makehelp.bat Release

# End Custom Build

!ELSEIF  "$(CFG)" == "Demis2000 - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
OutDir=.\Debug
InputPath=.\Help\Demis.hhp

"$(OutDir)\Demis.chm" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	makehelp.bat Debug

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Demis2000.reg
# End Source File
# Begin Source File

SOURCE=.\res\manifest.xml
# End Source File
# Begin Source File

SOURCE=.\ReadMe.txt
# End Source File
# End Target
# End Project
