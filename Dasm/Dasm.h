// Dasm.h : main header file for the DASM DLL
//

#if !defined(AFX_DASM_H__661B108A_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_)
#define AFX_DASM_H__661B108A_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols
#include "..\definitions.h"

typedef DWORD (*_COPFunc)();

/////////////////////////////////////////////////////////////////////////////
// CDasmApp
// See Dasm.cpp for the implementation of this class
//

class CDasmApp : public CWinApp
{
public:
	CDasmApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDasmApp)
	public:
	//}}AFX_VIRTUAL

	//{{AFX_MSG(CDasmApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

DWORD Mov();
DWORD JCond();
DWORD ALOp();
DWORD IO();
DWORD Push();
DWORD Pop();
DWORD IncDec();
DWORD Xchg();
DWORD ArOp();
DWORD Lxs();
DWORD Shift();
DWORD SegXS();
DWORD Jmp1();
DWORD Jmp2();
DWORD Test();
DWORD Call1();
DWORD Call2();
DWORD Ret();
DWORD Loop();
DWORD Flags();
DWORD Int();
DWORD Xlat();
DWORD Corr();
DWORD String();
DWORD Grp();
DWORD Grp2();
DWORD Stack286();
DWORD Rep();
DWORD Bound();
DWORD Mul286();
DWORD Ext386();

BYTE* pInstr;
DWORD Unknown();
WORD CurSeg,CurOffs,LocalSeg;
BOOL SegChanged;
CString CurLine,Comment,sLocalSeg;
BYTE W;
struct _EmulatorData* pEmData;
#include "Table.h"

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DASM_H__661B108A_F7CB_11D3_AB48_E1A9BB448D63__INCLUDED_)
