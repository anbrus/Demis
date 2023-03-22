//Файл Dasm.cpp

// Dasm.cpp : Defines the initialization routines for the DLL.
//

#include "stdafx.h"
#include "Dasm.h"
#include "Listing.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

static Listing listing;

/////////////////////////////////////////////////////////////////////////////
// CDasmApp

BEGIN_MESSAGE_MAP(CDasmApp, CWinApp)
	//{{AFX_MSG_MAP(CDasmApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDasmApp construction

CDasmApp::CDasmApp()
{
}


/////////////////////////////////////////////////////////////////////////////
// The one and only CDasmApp object

CDasmApp theApp;

void* PASCAL SegOffsToPtr(WORD Seg, WORD Offs)
//Возвращает указатель на ячейку с адресом Seg:Offs
{
	DWORD LinAdr = (((DWORD)Seg) << 4) + Offs;
	//Проверяем переполнение
	if (LinAdr > 0xFFFFF) LinAdr -= 0x100000;
	return LinAdr + (BYTE*)pEmData->Memory;
}

void AddDump(WORD DumpSeg, WORD DumpOffs, BYTE W)
//Добавляет дамп памяти в комментарий
{
	CString Temp, sVal;
	//Получаем указательна ячейку
	WORD* pVal = (WORD*)SegOffsToPtr(DumpSeg, DumpOffs);
	//Формируем строку
	Temp.Format("%04X:[%04X]=", DumpSeg, DumpOffs);
	if (W) sVal.Format("%04Xh ", *pVal);
	else sVal.Format("%02Xh ", *(BYTE*)pVal);
	Temp += sVal;
	//и добавляем её в комментарий
	Comment += Temp;
}

CString& ReadOffset(BYTE* pOffset, BYTE W, CString& s)
//Возвращает строковое представление содержимого слова
//по адресу pOffset и добавляет при необходимости дамп в комментарий
{
	s.Format("%s[%04X]", sLocalSeg, *(WORD*)pOffset);
	WORD GlInstr = CurOffs;
	if (SegChanged) GlInstr--;
	if ((pEmData->Reg.CS == CurSeg) && (pEmData->Reg.IP == GlInstr))
		AddDump(LocalSeg, *(WORD*)pOffset, W);
	return s;
}

DWORD DecodeSecondByte(BYTE* pCOP2, BYTE w, void** Address)
//Декодирует метод адресации как в эмуляторе
{
	BYTE B = *pCOP2 & 0xC7;
	signed short D8 = *(signed char*)(pCOP2 + 1);
	WORD D16 = *(WORD*)(pCOP2 + 1);
	BOOL W = (w & 1) == 1;
	BYTE Return;
	WORD Offset;
	WORD UsedSeg = LocalSeg;
	switch (B) {
	case 0x00: Offset = pEmData->Reg.BX + pEmData->Reg.SI; Return = 1; break;
	case 0x01: Offset = pEmData->Reg.BX + pEmData->Reg.DI; Return = 1; break;
	case 0x02: Offset = pEmData->Reg.BP + pEmData->Reg.SI; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 1; break;
	case 0x03: Offset = pEmData->Reg.BP + pEmData->Reg.DI; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 1; break;
	case 0x04: Offset = pEmData->Reg.SI; Return = 1; break;
	case 0x05: Offset = pEmData->Reg.DI; Return = 1; break;
	case 0x06: Offset = D16; Return = 3; break;
	case 0x07: Offset = pEmData->Reg.BX; Return = 1; break;

	case 0x40: Offset = pEmData->Reg.BX + pEmData->Reg.SI + D8; Return = 2; break;
	case 0x41: Offset = pEmData->Reg.BX + pEmData->Reg.DI + D8; Return = 2; break;
	case 0x42: Offset = pEmData->Reg.BP + pEmData->Reg.SI + D8; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 2; break;
	case 0x43: Offset = pEmData->Reg.BP + pEmData->Reg.DI + D8; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 2; break;
	case 0x44: Offset = pEmData->Reg.SI + D8; Return = 2; break;
	case 0x45: Offset = pEmData->Reg.DI + D8; Return = 2; break;
	case 0x46: Offset = pEmData->Reg.BP + D8; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 2; break;
	case 0x47: Offset = pEmData->Reg.BX + D8; Return = 2; break;

	case 0x80: Offset = pEmData->Reg.BX + pEmData->Reg.SI + D16; Return = 3; break;
	case 0x81: Offset = pEmData->Reg.BX + pEmData->Reg.DI + D16; Return = 3; break;
	case 0x82: Offset = pEmData->Reg.BP + pEmData->Reg.SI + D16; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 3; break;
	case 0x83: Offset = pEmData->Reg.BP + pEmData->Reg.DI + D16; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 3; break;
	case 0x84: Offset = pEmData->Reg.SI + D16; Return = 3; break;
	case 0x85: Offset = pEmData->Reg.DI + D16; Return = 3; break;
	case 0x86: Offset = pEmData->Reg.BP + D16; if (!SegChanged) UsedSeg = pEmData->Reg.SS; Return = 3; break;
	case 0x87: Offset = pEmData->Reg.BX + D16; Return = 3; break;

	case 0xC0: *Address = (void*)&pEmData->Reg.AX; return 1;
	case 0xC1: *Address = (void*)&pEmData->Reg.CX; return 1;
	case 0xC2: *Address = (void*)&pEmData->Reg.DX; return 1;
	case 0xC3: *Address = (void*)&pEmData->Reg.BX; return 1;
	case 0xC4: *Address = (void*)(W ? (BYTE*)&pEmData->Reg.SP : ((BYTE*)(&pEmData->Reg.AX)) + 1); return 1;
	case 0xC5: *Address = (void*)(W ? (BYTE*)&pEmData->Reg.BP : ((BYTE*)(&pEmData->Reg.CX)) + 1); return 1;
	case 0xC6: *Address = (void*)(W ? (BYTE*)&pEmData->Reg.SI : ((BYTE*)(&pEmData->Reg.DX)) + 1); return 1;
	case 0xC7: *Address = (void*)(W ? (BYTE*)&pEmData->Reg.DI : ((BYTE*)(&pEmData->Reg.BX)) + 1); return 1;
	}
	/*switch(B) {
	  case 0x00 : *Address=(void*)(pEmData->Reg.BX+pEmData->Reg.SI); Return=1; break;
	  case 0x01 : *Address=(void*)(pEmData->Reg.BX+pEmData->Reg.DI); Return=1; break;
	  case 0x02 : *Address=(void*)(pEmData->Reg.BP+pEmData->Reg.SI); Return=1; break;
	  case 0x03 : *Address=(void*)(pEmData->Reg.BP+pEmData->Reg.DI); Return=1; break;
	  case 0x04 : *Address=(void*)pEmData->Reg.SI; Return=1; break;
	  case 0x05 : *Address=(void*)pEmData->Reg.DI; Return=1; break;
	  case 0x06 : *Address=(void*)D16; Return=3; break;
	  case 0x07 : *Address=(void*)pEmData->Reg.BX; Return=1; break;

	  case 0x40 : *Address=(void*)(pEmData->Reg.BX+pEmData->Reg.SI+D8); Return=2; break;
	  case 0x41 : *Address=(void*)(pEmData->Reg.BX+pEmData->Reg.DI+D8); Return=2; break;
	  case 0x42 : *Address=(void*)(pEmData->Reg.BP+pEmData->Reg.SI+D8); Return=2; break;
	  case 0x43 : *Address=(void*)(pEmData->Reg.BP+pEmData->Reg.DI+D8); Return=2; break;
	  case 0x44 : *Address=(void*)(pEmData->Reg.SI+D8); Return=2; break;
	  case 0x45 : *Address=(void*)(pEmData->Reg.DI+D8); Return=2; break;
	  case 0x46 : *Address=(void*)(pEmData->Reg.BP+D8); Return=2; break;
	  case 0x47 : *Address=(void*)(pEmData->Reg.BX+D8); Return=2; break;

	  case 0x80 : *Address=(void*)(pEmData->Reg.BX+pEmData->Reg.SI+D16); Return=3; break;
	  case 0x81 : *Address=(void*)(pEmData->Reg.BX+pEmData->Reg.DI+D16); Return=3; break;
	  case 0x82 : *Address=(void*)(pEmData->Reg.BP+pEmData->Reg.SI+D16); Return=3; break;
	  case 0x83 : *Address=(void*)(pEmData->Reg.BP+pEmData->Reg.DI+D16); Return=3; break;
	  case 0x84 : *Address=(void*)(pEmData->Reg.SI+D16); Return=3; break;
	  case 0x85 : *Address=(void*)(pEmData->Reg.DI+D16); Return=3; break;
	  case 0x86 : *Address=(void*)(pEmData->Reg.BP+D16); Return=3; break;
	  case 0x87 : *Address=(void*)(pEmData->Reg.BX+D16); Return=3; break;

	  case 0xC0 : *Address=(void*)&pEmData->Reg.AX; return 1;
	  case 0xC1 : *Address=(void*)&pEmData->Reg.CX; return 1;
	  case 0xC2 : *Address=(void*)&pEmData->Reg.DX; return 1;
	  case 0xC3 : *Address=(void*)&pEmData->Reg.BX; return 1;
	  case 0xC4 : *Address=(void*)(W ? (BYTE*)&pEmData->Reg.SP : ((BYTE*)(&pEmData->Reg.AX))+1); return 1;
	  case 0xC5 : *Address=(void*)(W ? (BYTE*)&pEmData->Reg.BP : ((BYTE*)(&pEmData->Reg.CX))+1); return 1;
	  case 0xC6 : *Address=(void*)(W ? (BYTE*)&pEmData->Reg.SI : ((BYTE*)(&pEmData->Reg.DX))+1); return 1;
	  case 0xC7 : *Address=(void*)(W ? (BYTE*)&pEmData->Reg.DI : ((BYTE*)(&pEmData->Reg.BX))+1); return 1;
	}*/

	//*Address=VirtToReal(UsedSeg,Offset);  //Получить указатель
	* Address = SegOffsToPtr(UsedSeg, Offset);
	return Return;
}

DWORD GetDecodedAddress(BYTE* pCOP2, BYTE W, CString& s)
//Декодирует метод адресации и возвращает его строковое представление
//При необходимости добавляет дамп
{
	DWORD Size;
	W &= 0x01;
	BYTE B = *pCOP2 & 0xC7;
	BYTE bCOP3 = *(pCOP2 + 1);
	WORD wCOP3 = *(WORD*)(pCOP2 + 1);
	CString SD8;
	CString SD16, D16;
	if (bCOP3 < 0x80) SD8.Format("+%02Xh", bCOP3);
	else SD8.Format("-%02Xh", 256 - bCOP3);

	if (wCOP3 < 0x8000) SD16.Format("+%04Xh", wCOP3);
	else SD16.Format("-%04Xh", 65536 - wCOP3);
	D16.Format("%04Xh", wCOP3);
	BOOL MemoryAccess = TRUE;
	switch (B) {
	case 0x00: s = "[BX+SI]"; Size = 1; break;
	case 0x01: s = "[BX+DI]"; Size = 1; break;
	case 0x02: s = "[BP+SI]"; Size = 1; break;
	case 0x03: s = "[BP+DI]"; Size = 1; break;
	case 0x04: s = "[SI]"; Size = 1;  break;
	case 0x05: s = "[DI]"; Size = 1;  break;
	case 0x06: s.Format("[%s]", D16); Size = 3; break;
	case 0x07: s = "[BX]"; Size = 1; break;

	case 0x40: s.Format("[BX+SI%s]", SD8); Size = 2; break;
	case 0x41: s.Format("[BX+DI%s]", SD8); Size = 2; break;
	case 0x42: s.Format("[BP+SI%s]", SD8); Size = 2; break;
	case 0x43: s.Format("[BP+DI%s]", SD8); Size = 2; break;
	case 0x44: s.Format("[SI%s]", SD8); Size = 2;  break;
	case 0x45: s.Format("[DI%s]", SD8); Size = 2;  break;
	case 0x46: s.Format("[BP%s]", SD8); Size = 2;  break;
	case 0x47: s.Format("[BX%s]", SD8); Size = 2;  break;

	case 0x80: s.Format("[BX+SI%s]", SD16); Size = 3; break;
	case 0x81: s.Format("[BX+DI%s]", SD16); Size = 3; break;
	case 0x82: s.Format("[BP%s]", SD16); Size = 3; break;
	case 0x83: s.Format("[BP%s]", SD16); Size = 3; break;
	case 0x84: s.Format("[SI%s]", SD16); Size = 3; break;
	case 0x85: s.Format("[DI%s]", SD16); Size = 3; break;
	case 0x86: s.Format("[BP%s]", SD16); Size = 3; break;
	case 0x87: s.Format("[BX%s]", SD16); Size = 3; break;

	case 0xC0: s = W ? "AX" : "AL"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC1: s = W ? "CX" : "CL"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC2: s = W ? "DX" : "DL"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC3: s = W ? "BX" : "BL"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC4: s = W ? "SP" : "AH"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC5: s = W ? "BP" : "CH"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC6: s = W ? "SI" : "DH"; Size = 1; MemoryAccess = FALSE; break;
	case 0xC7: s = W ? "DI" : "BH"; Size = 1; MemoryAccess = FALSE; break;
	}
	s = sLocalSeg + s;
	//Если нет обращения к памяти, то всё
	if (!MemoryAccess) return Size;
	//Иначе добавляем дамп
	BYTE* Address;
	//Получаем адрес ячейки
	DecodeSecondByte(pCOP2, W, (void**)&Address);
	//Определяем смещение
	DWORD Adr86 = Address - (BYTE*)pEmData->Memory;
	WORD Offset = (WORD)(Adr86 - (((DWORD)LocalSeg) << 4));
	CString Temp;
	//Если необходимо, то ReadOffset добавит дамп
	ReadOffset((BYTE*)&Offset, W, Temp);
	return Size;
}

DWORD Unknown()  //Неизвестная инструкция
{
	CurLine.Format("db %02Xh", *pInstr);
	return 1;
}

CString& GetSegRegister(BYTE sr, CString& s)
//Возвращает строковое представление сегментного регистра с кодом sr
{
	switch (sr & 3) {
	case 0: s = "ES"; return s;
	case 1: s = "CS"; return s;
	case 2: s = "SS"; return s;
	case 3: s = "DS"; return s;
	}
	return s;
}

CString& GetRegister(BYTE reg, BYTE w, CString& s)
//Возвращает строковое представление РОН с кодом reg
{
	CString wReg, bReg;
	reg &= 7;
	w &= 1;
	switch (reg) {
	case 0: wReg = "AX"; bReg = "AL"; break;
	case 1: wReg = "CX"; bReg = "CL"; break;
	case 2: wReg = "DX"; bReg = "DL"; break;
	case 3: wReg = "BX"; bReg = "BL"; break;
	case 4: wReg = "SP"; bReg = "AH"; break;
	case 5: wReg = "BP"; bReg = "CH"; break;
	case 6: wReg = "SI"; bReg = "DH"; break;
	case 7: wReg = "DI"; bReg = "BH"; break;
	}
	if (w == 1) s = wReg;
	else s = bReg;
	return s;
}

DWORD ReadValue(BYTE* Addr, BYTE W, CString& s, BOOL SignExt = FALSE)
//Возвращает строковое представление содержимого ячейки с адресом Addr
{
	if (W) {
		s.Format("%04Xh", *(WORD*)Addr);
	}
	else {
		WORD Val = *Addr;
		if (SignExt) Val = (WORD)(signed char)Val;
		s.Format("%02Xh", Val);
	}
	return W + 1;
}

void AddIP(DWORD IP, int Val1, int Val2, BYTE W, CString& s)
//Возвращает строковое представление суммы IP+Val1+Val2
{
	int a;
	if (W) a = IP + (signed short)((signed short)Val1 + (signed short)Val2);
	else a = IP + (signed char)((signed char)Val1 + (signed char)Val2);
	s.Format("%04Xh", (WORD)a);
}

DWORD Mov()
{
	CString Arg1, Arg2;
	DWORD Size = 1;
	CurLine = "MOV ";
	switch (*pInstr) {
		//Mov r/m,r
	case 0x88:	case 0x89:
		Size = 1 + GetDecodedAddress(pInstr + 1, W, Arg1);
		CurLine += Arg1; CurLine += ",";
		CurLine += GetRegister(*(pInstr + 1) >> 3, W, Arg2); break;
		//Mov r,r/m
	case 0x8A:	case 0x8B:
		Size = 1 + GetDecodedAddress(pInstr + 1, W, Arg1);
		CurLine += GetRegister(*(pInstr + 1) >> 3, W, Arg2);
		CurLine += ","; CurLine += Arg1; break;
		//Lea r, m
	case 0x8D:
		CurLine = "LEA ";
		Size = 2 + ReadValue(pInstr + 2, W, Arg2);
		CurLine += GetRegister(*(pInstr + 1) >> 3, W, Arg1);
		CurLine += ","; CurLine += Arg2; break;
		//Mov sr,r/m
	case 0x8E:
		Size = 1 + GetDecodedAddress(pInstr + 1, 1, Arg1);
		CurLine += GetSegRegister(*(pInstr + 1) >> 3, Arg2);
		CurLine += ","; CurLine += Arg1; break;
		//Mov r/m,sr
	case 0x8C:
		Size = 1 + GetDecodedAddress(pInstr + 1, 1, Arg1);
		CurLine += Arg1; CurLine += ",";
		CurLine += GetSegRegister(*(pInstr + 1) >> 3, Arg2); break;
		//Mov Ac,Mem
	case 0xA0: case 0xA1:
		Size = 3; ReadOffset(pInstr + 1, 1, Arg1);
		CurLine += GetRegister(0, W, Arg2);
		CurLine += ","; CurLine += Arg1; break;
		//Mov Mem,Ac
	case 0xA2: case 0xA3:
		Size = 3; ReadOffset(pInstr + 1, 1, Arg1);
		CurLine += Arg1; CurLine += ",";
		CurLine += GetRegister(0, W, Arg2); break;
		//Mov r,d
	case 0xB0: case 0xB1: case 0xB2: case 0xB3:
	case 0xB4: case 0xB5: case 0xB6: case 0xB7:
	case 0xB8: case 0xB9: case 0xBA: case 0xBB:
	case 0xBC: case 0xBD: case 0xBE: case 0xBF:
		Size = 1 + ReadValue(pInstr + 1, (*pInstr & 8) >> 3, Arg1);
		CurLine += GetRegister(*pInstr, (*pInstr & 8) >> 3, Arg2);
		CurLine += ","; CurLine += Arg1; break;
		//Mov r/m,d
	case 0xC6:
	case 0xC7:
		Size = 1 + GetDecodedAddress(pInstr + 1, W, Arg1);
		CurLine += Arg1; Size += ReadValue(pInstr + Size, W, Arg2);
		CurLine += ","; CurLine += Arg2; break;
	}
	return Size;
}

DWORD JCond()
{
	switch (*pInstr) {
	case 0x70: CurLine = "JO ";   break;
	case 0x71: CurLine = "JNO ";  break;
	case 0x72: CurLine = "JC ";   break;
	case 0x73: CurLine = "JNC ";  break;
	case 0x74: CurLine = "JZ ";   break;
	case 0x75: CurLine = "JNZ ";  break;
	case 0x76: CurLine = "JNA ";  break;
	case 0x77: CurLine = "JA ";   break;
	case 0x78: CurLine = "JS ";   break;
	case 0x79: CurLine = "JNS ";  break;
	case 0x7A: CurLine = "JP ";   break;
	case 0x7B: CurLine = "JNP ";  break;
	case 0x7C: CurLine = "JL ";   break;
	case 0x7D: CurLine = "JNL ";  break;
	case 0x7E: CurLine = "JNG ";  break;
	case 0x7F: CurLine = "JG ";   break;
	case 0xE3: CurLine = "JCXZ "; break;
	}
	CString Addr;
	AddIP(CurOffs, *(signed char*)(pInstr + 1), 2, 0, Addr);
	CurLine += Addr;
	return 2;
}

DWORD ALOp()
{
	switch (*pInstr & 0xF8) {
	case 0x00: CurLine = "ADD "; break;
	case 0x08: CurLine = "OR ";  break;
	case 0x10: CurLine = "ADC "; break;
	case 0x18: CurLine = "SBB "; break;
	case 0x20: CurLine = "AND "; break;
	case 0x28: CurLine = "SUB "; break;
	case 0x30: CurLine = "XOR "; break;
	case 0x38: CurLine = "CMP "; break;
	}
	CString Reg, Ref;
	GetRegister(*(pInstr + 1) >> 3, *pInstr & 1, Reg);
	DWORD Size;
	switch ((*pInstr >> 1) & 3) {
		//Op r/m,r
	case 0:
		Size = 1 + GetDecodedAddress(pInstr + 1, *pInstr & 1, Ref);
		CurLine += Ref; CurLine += ","; CurLine += Reg;
		break;
		//Op r,r/m
	case 1:
		Size = 1 + GetDecodedAddress(pInstr + 1, *pInstr & 1, Ref);
		CurLine += Reg; CurLine += ","; CurLine += Ref;
		break;
		//Op Ac,Data
	case 2:
		ReadValue(pInstr + 1, W, Ref);
		if (W) { Reg = "AX"; Size = 3; }
		else { Reg = "AL"; Size = 2; }
		CurLine += Reg; CurLine += ","; CurLine += Ref;
		break;
	}
	return Size;
}

DWORD IO()
{
	CString PortNumber;
	DWORD Size = 2;
	if (*pInstr & 8) { PortNumber = "DX"; Size = 1; }
	else PortNumber.Format("%02X", *(pInstr + 1));
	if (*pInstr & 2) {
		CurLine = "OUT "; CurLine += PortNumber;
		if (*pInstr & 1) CurLine += ",AX";
		else CurLine += ",AL";
	}
	else {
		if (*pInstr & 1) CurLine = "IN AX,";
		else CurLine = "IN AL,";
		CurLine += PortNumber;
	}
	return Size;
}

DWORD Push()
{
	CString Source;
	DWORD Size = 1;
	CurLine = "PUSH ";
	switch (*pInstr & 0xC0) {
		//Push sr
	case 0x00: CurLine += GetSegRegister((*pInstr >> 3) & 7, Source); break;
		//Push r16
	case 0x40: CurLine += GetRegister(*pInstr & 7, 1, Source); break;
		//Pushf
	case 0x80: CurLine = "PUSHF"; break;
		//Push r/m
	case 0xC0:
		Size = GetDecodedAddress(pInstr + 1, 1, Source) + 1;
		CurLine += Source;
		break;
	}
	return Size;
}

DWORD Pop()
{
	CString Dest;
	DWORD Size = 1;
	CurLine = "POP ";
	switch (*pInstr & 0xF0) {
		//Pop r/m
	case 0x80:
		Size = GetDecodedAddress(pInstr + 1, 1, Dest) + 1;
		CurLine += Dest;
		break;
		//Pop r16
	case 0x50: CurLine += GetRegister(*pInstr & 7, 1, Dest); break;
		//Pop sr
	case 0x00:
	case 0x10: CurLine += GetSegRegister(*pInstr >> 3, Dest); break;
		//Popf
	case 0x90: CurLine = "POPF"; break;
	}
	return Size;
}

DWORD IncDec()
{
	DWORD Size = 1;
	CString Addr;
	if (*pInstr & 0x80) {
		if (*(pInstr + 1) & 0x38) CurLine = "DEC ";
		else CurLine = "INC ";
		Size += GetDecodedAddress(pInstr + 1, *pInstr & 1, Addr);
		CurLine += Addr;
	}
	else {
		if (*pInstr & 8) CurLine = "DEC ";
		else CurLine = "INC ";
		CurLine += GetRegister(*pInstr & 7, 1, Addr);
	}
	return Size;
}

DWORD Xchg()
{
	CString Addr;
	DWORD Size = 1;
	BYTE Reg;
	CurLine = "XCHG ";
	if (*pInstr & 0x10) {  //Xchg AX,r16
		CurLine += "AX,";
		CurLine += GetRegister(*pInstr & 7, 1, Addr);
	}
	else {  //Xchg r,r/m
		Reg = ((*(pInstr + 1)) >> 3) & 7;
		Size += GetDecodedAddress(pInstr + 1, *pInstr & 1, Addr);
		CurLine += GetRegister(Reg, *pInstr & 1, Addr);
		CurLine += ",";
		CurLine += GetRegister(Reg, *pInstr & 1, Addr);
	}
	return Size;
}

DWORD ArOp()
{
	CString Op1, Op2;
	DWORD Size = 1 + GetDecodedAddress(pInstr + 1, *pInstr & 1, Op1);
	BYTE SW = W;
	if (*pInstr & 2) SW = 0;
	ReadValue(pInstr + Size, SW, Op2, *pInstr & 2);
	Size += SW + 1;
	switch ((*(pInstr + 1)) & 0x38) {
	case 0x00: CurLine = "ADD "; break;
	case 0x08: CurLine = "OR ";  break;
	case 0x10: CurLine = "ADC "; break;
	case 0x18: CurLine = "SBB "; break;
	case 0x20: CurLine = "AND "; break;
	case 0x28: CurLine = "SUB "; break;
	case 0x30: CurLine = "XOR "; break;
	case 0x38: CurLine = "CMP "; break;
	}
	CurLine += Op1; CurLine += ","; CurLine += Op2;
	return Size;
}

DWORD Lxs()  //Les, Lds
{
	CString Src, Dst;
	DWORD Size = 1;
	if (*pInstr & 1) CurLine = "LDS ";
	else CurLine = "LES ";
	Size += GetDecodedAddress(pInstr + 1, 1, Src);
	CurLine += GetRegister(((*(pInstr + 1)) >> 3) & 7, 1, Dst);
	CurLine += ","; CurLine += Src;
	return Size;
}

DWORD Shift()
{
	CString Src;
	DWORD Size = GetDecodedAddress(pInstr + 1, *pInstr & 1, Src) + 1;
	switch (*(pInstr + 1) & 0x38) {
	case 0x00: CurLine = "ROL "; CurLine += Src; break;
	case 0x08: CurLine = "ROR "; CurLine += Src; break;
	case 0x10: CurLine = "RCL "; CurLine += Src; break;
	case 0x18: CurLine = "RCR "; CurLine += Src; break;
	case 0x20: CurLine = "SHL "; CurLine += Src; break;
	case 0x28: CurLine = "SHR "; CurLine += Src; break;
	case 0x30: return Unknown();
	case 0x38: CurLine = "SAR "; CurLine += Src; break;
	}
	CurLine += ",";
	if ((pInstr[0] != 0xC0) && ((pInstr[0] != 0xC1))) {
		if (*pInstr & 2) CurLine += "CL";
		else CurLine += "1";
	}
	else {
		Size++;
		CString Count;
		Count.Format("%02Xh", pInstr[Size - 1]);
		CurLine += Count;
	}
	return Size;
}

DWORD SegXS()  //Префикс замены сегмента
{
	GetSegRegister(*pInstr >> 3, sLocalSeg);
	SegChanged = TRUE;
	sLocalSeg += ':';
	switch ((*pInstr >> 3) & 3) {
	case 0: LocalSeg = pEmData->Reg.ES; break;  //ES:
	case 1: LocalSeg = pEmData->Reg.CS; break;  //CS:
	case 2: LocalSeg = pEmData->Reg.SS; break;  //SS:
	case 3: LocalSeg = pEmData->Reg.DS; break;  //DS:
	}
	CurOffs++; pInstr++;
	W = *pInstr & 1;
	DWORD Res = 1 + COPFunc[*pInstr]();
	SegChanged = FALSE;
	return Res;
}

DWORD Jmp1()  //Переход по непоср. адресу
{
	DWORD Size;
	CString Dest;
	switch (*pInstr & 3) {
	case 1:
		AddIP(CurOffs, *(short*)(pInstr + 1), 3, 1, Dest);
		CurLine.Format("JMP Near %s", Dest);
		Size = 3;
		break;
	case 2:
		CurLine.Format("JMP Far %04X:%04X", *(WORD*)(pInstr + 3), *(WORD*)(pInstr + 1));
		Size = 5;
		break;
	case 3:
		AddIP(CurOffs, *(signed char*)(pInstr + 1), 2, 0, Dest);
		CurLine.Format("JMP Short %s", Dest);
		Size = 2;
		break;
	}
	return Size;
}

DWORD Jmp2()  //Переход по адресу из переменной
{
	CString Addr;
	DWORD Size;
	BYTE W = *pInstr & 1;
	Size = 1 + GetDecodedAddress(pInstr + 1, 1, Addr);
	switch (*(pInstr + 1) & 0x38) {
	case 0x20:
		CurLine.Format("JMP Near %s", Addr);
		break;
	case 0x28:
		CurLine.Format("JMP DWORD PTR %s", Addr);
		Size += W + 1; break;
	}
	return Size;
}

DWORD Test()
{
	DWORD Size = 1;
	CString Value1, Value2;
	BYTE W = *pInstr & 1;
	BYTE Reg = *(pInstr + 1) >> 3;
	switch ((*pInstr >> 1) & 3) {
	case 0:  //Test Ac,Data
		ReadValue(pInstr + 1, W, Value1);
		CurLine.Format("TEST %s,%s", GetRegister(0, W, Value2), Value1);
		Size = W + 2;	break;
	case 2:  //Test r,r/m
		Size += GetDecodedAddress(pInstr + 1, W, Value1);
		CurLine.Format("TEST %s,%s", GetRegister(Reg, W, Value2), Value1);
		break;
	case 3:  //Test r/m,Data
		Size += GetDecodedAddress(pInstr + 1, W, Value1);
		ReadValue(pInstr + Size, W, Value2);
		CurLine.Format("TEST %s,%s", Value1, Value2);
		Size += W + 1; break;
	}
	return Size;
}

DWORD Call1()  //Call Addr
{
	CurLine = "CALL ";
	if (*pInstr & 64) {
		CString Dest;
		AddIP(CurOffs, *(WORD*)(pInstr + 1), 3, 1, Dest);
		CurLine += Dest;
		return 3;
	}
	CurLine.Format("CALL Far %04X:%04X", *(WORD*)(pInstr + 3), *(WORD*)(pInstr + 1));
	return 5;
}

DWORD Call2() //Call rm16
{
	CString Addr;
	DWORD Size = 1 + GetDecodedAddress(pInstr + 1, 1, Addr);
	CurLine = "CALL ";
	if (*(pInstr + 1) & 8) CurLine += "DWord Ptr ";
	else CurLine += "Word Ptr ";
	CurLine += Addr;
	return Size;
}

DWORD Ret()
{
	CString V;
	CurLine = "RET";
	DWORD Size = 3;
	switch (*pInstr) {
		//Retn
	case 0xC3: CurLine += "N"; Size = 1; break;
		//Retn Data
	case 0xC2: ReadValue(pInstr + 1, 1, V); CurLine += "N "; CurLine += V; break;
		//Retf
	case 0xCB: CurLine += "F"; Size = 1; break;
		//Retf Data
	case 0xCA: ReadValue(pInstr + 1, 1, V); CurLine += "F "; CurLine += V; break;
		//IRet
	case 0xCF: CurLine = "IRET"; Size = 1;  break;
	}
	return Size;
}

DWORD Loop()  //Loop,LoopZ,LoopNZ
{
	CurLine = "LOOP";
	switch (*pInstr) {
	case 0xE2: break;
	case 0xE1: CurLine += "Z"; break;
	case 0xE0: CurLine += "NZ"; break;
	}
	CurLine += " ";
	CString Dest;
	AddIP(CurOffs, *(signed char*)(pInstr + 1), 2, 0, Dest);
	CurLine += Dest;
	return 2;
}

DWORD Hlt()
{
	CurLine = "HLT";

	return 1;
}

DWORD Flags()
{
	switch (*pInstr) {
	case 0xF8: CurLine = "CLC"; break;
	case 0xF5: CurLine = "CMC"; break;
	case 0xF9: CurLine = "STC"; break;
	case 0xFC: CurLine = "CLD"; break;
	case 0xFD: CurLine = "STD"; break;
	case 0xFA: CurLine = "CLI"; break;
	case 0xFB: CurLine = "STI"; break;
	}
	return 1;
}

DWORD Int()
{
	CurLine = "INT";
	CString Type;
	DWORD Size = 1;
	switch (*pInstr & 3) {
		//Int3
	case 0: CurLine += '3'; break;
		//Int Type
	case 1:
		Type.Format(" %02Xh", *(pInstr + 1));
		CurLine += Type; Size++; break;
		//IntO
	case 2: CurLine += 'O'; break;
	}
	return Size;
}

DWORD Xlat()
{
	CurLine = "XLAT";
	if ((pEmData->Reg.IP == CurOffs) && (pEmData->Reg.CS == CurSeg))
		AddDump(pEmData->Reg.DS, pEmData->Reg.BX + (pEmData->Reg.AX & 0xFF), 0);
	return 1;
}

DWORD Corr()
{
	DWORD Size = 1;
	switch (*pInstr) {
	case 0x27: CurLine = "DAA"; break;
	case 0x2F: CurLine = "DAS"; break;
	case 0x37: CurLine = "AAA"; break;
	case 0x3F: CurLine = "AAS"; break;
	case 0xD4:
		if (*(pInstr + 1) == 10) { CurLine = "AAM"; Size = 2; break; }
		else return Unknown();
	case 0xD5:
		if (*(pInstr + 1) == 10) { CurLine = "AAD"; Size = 2; break; }
		else return Unknown();
	}
	return Size;
}

DWORD String()
{
	switch (*pInstr) {
	case 0x6C: CurLine = "INSB";  break;
	case 0x6D: CurLine = "INSW";  break;
	case 0x6E: CurLine = "OUTSB"; break;
	case 0x6F: CurLine = "OUTSW"; break;
	case 0xA4: CurLine = "MOVSB"; break;
	case 0xA5: CurLine = "MOVSW"; break;
	case 0xA6: CurLine = "CMPSB"; break;
	case 0xA7: CurLine = "CMPSW"; break;
	case 0xAA: CurLine = "STOSB"; break;
	case 0xAB: CurLine = "STOSW"; break;
	case 0xAC: CurLine = "LODSB"; break;
	case 0xAD: CurLine = "LODSW"; break;
	case 0xAE: CurLine = "SCASB"; break;
	case 0xAF: CurLine = "SCASW"; break;
	}
	return 1;
}

DWORD Grp()  //Группа инструкций с кодом 0FEh, 0FFh
{
	switch ((*(pInstr + 1) >> 3) & 7) {
	case 0x00:
	case 0x01: return IncDec();
	case 0x02:
	case 0x03: return Call2();
	case 0x04:
	case 0x05: return Jmp2();
	case 0x06: return Push();
	}
	return Unknown();
}

DWORD Grp2()  //Группа инструкций с кодом 0F6h, 0F7h
{
	DWORD Size;
	CString Op2;
	switch ((*(pInstr + 1) >> 3) & 7) {
	case 0x00: return Test();
	case 0x02: CurLine = "NOT "; break;
	case 0x03: CurLine = "NEG "; break;
	case 0x04: CurLine = "MUL "; break;
	case 0x05: CurLine = "IMUL "; break;
	case 0x06: CurLine = "DIV "; break;
	case 0x07: CurLine = "IDIV "; break;
	}
	Size = 1 + GetDecodedAddress(pInstr + 1, W, Op2);
	CurLine += Op2;
	return Size;
}

DWORD Stack286()
{
	CString Arg;
	DWORD Size = 1;
	switch (*pInstr) {
		//Pusha
	case 0x60: CurLine = "PUSHA"; break;
		//Popa
	case 0x61: CurLine = "POPA"; break;
		//Push Data16
	case 0x68:
		Size += ReadValue(pInstr + Size, 1, Arg);
		CurLine = "PUSH " + Arg;
		break;
		//Push Data8
	case 0x6A:
		Size += ReadValue(pInstr + Size, 0, Arg, TRUE);
		CurLine = "PUSH " + Arg;
		break;
		//Enter
	case 0xC8:
	{
		WORD FrameSize = *(WORD*)(pInstr + 1);
		BYTE Level = *(pInstr + 3) % 32;
		CurLine.Format("ENTER %04Xh,%02Xh", FrameSize, Level);
		Size = 4;
		break;
	}
	//Leave
	case 0xC9:
		CurLine = "LEAVE";
		break;
	}
	return Size;
}

DWORD Rep()
{
	if (pInstr[0] == 0xF2) {
		CurLine = "REPNZ";
		return 1;
	}

	switch (pInstr[1]) {
	case 0xA4: //REP MOVS
	case 0xAA: //REP STOS
	case 0x6C: //REP INS
	case 0x6E: //REP OUTS
		CurLine = "REP";
		break;
	case 0xA6: //REPZ CMPS
	case 0xAE: //REPZ SCAS
		CurLine = "REPZ";
		break;
	default:
		CurLine = "REPZ";
	}
	return 1;
}

DWORD Bound()
{
	CString Source, Reg;
	CurLine = "BOUND ";
	GetRegister(pInstr[1] >> 3, 1, Reg);
	CurLine += Reg;
	CurLine += ",";
	DWORD Size = 1 + GetDecodedAddress(pInstr + 1, 1, Source);
	CurLine += Source;

	return Size;
}

DWORD Mul286()
{
	BYTE W = (pInstr[0] == 0x69) ? 1 : 0;
	CString Dest, Src, Data;
	CurLine = "IMUL ";
	GetRegister(pInstr[1] >> 3, 1, Dest);
	CurLine += Dest;
	CurLine += ",";
	DWORD Size = 1 + GetDecodedAddress(pInstr + 1, 1, Src);
	CurLine += Src;
	CurLine += ",";
	if (W) Data.Format("%04Xh", *(WORD*)(pInstr + Size));
	else {
		WORD Val = *(pInstr + Size);
		if (*pInstr & 2) Val = (WORD)(signed char)Val;
		Data.Format("%02Xh", Val);
	}
	CurLine += Data;

	return Size + 1 + W;
}

DWORD BTX(BYTE* pInstr)
{
	int Op;
	CString Src, BitNumber;
	DWORD Size = GetDecodedAddress(pInstr + 2, 1, Src);

	if (pInstr[1] == 0xBA) {
		switch ((pInstr[2] >> 3) & 7) {
		case 4: Op = 0; break;
		case 5: Op = 3; break;
		case 6: Op = 2; break;
		case 7: Op = 1; break;
		}
		BitNumber.Format("%02Xh", pInstr[Size + 2]);
		Size++;
	}
	else {
		switch (pInstr[1]) {
		case 0xA3: Op = 0; break;
		case 0xAB: Op = 3; break;
		case 0xB3: Op = 2; break;
		case 0xBB: Op = 1; break;
		}
		GetRegister(pInstr[2] >> 3, 1, BitNumber);
	}
	switch (Op) {
		//BT
	case 0: CurLine = "BT "; break;
		//BTC
	case 1: CurLine = "BTC "; break;
		//BTR
	case 2: CurLine = "BTR "; break;
		//BTS
	case 3: CurLine = "BTS "; break;
	}
	CurLine += Src; CurLine += ","; CurLine += BitNumber;

	return Size;
}

DWORD Setccc(BYTE* pInstr)
{
	CString Op;
	DWORD Size = GetDecodedAddress(pInstr + 2, 0, Op);
	CurLine += Op;

	return Size;
}

DWORD JCond386()
{
	switch (pInstr[1]) {
	case 0x80: CurLine = "JO ";   break;
	case 0x81: CurLine = "JNO ";  break;
	case 0x82: CurLine = "JC ";   break;
	case 0x83: CurLine = "JNC ";  break;
	case 0x84: CurLine = "JZ ";   break;
	case 0x85: CurLine = "JNZ ";  break;
	case 0x86: CurLine = "JNA ";  break;
	case 0x87: CurLine = "JA ";   break;
	case 0x88: CurLine = "JS ";   break;
	case 0x89: CurLine = "JNS ";  break;
	case 0x8A: CurLine = "JP ";   break;
	case 0x8B: CurLine = "JNP ";  break;
	case 0x8C: CurLine = "JL ";   break;
	case 0x8D: CurLine = "JNL ";  break;
	case 0x8E: CurLine = "JNG ";  break;
	case 0x8F: CurLine = "JG ";   break;
	}
	CString Addr;
	AddIP(CurOffs, *(signed short*)(pInstr + 2), 4, 1, Addr);
	CurLine += Addr;
	return 4;
}

DWORD Ext386()
{
	if ((pInstr[1] & 0xF0) == 0x80) return JCond386();

	DWORD Size = 2;

	switch (pInstr[1]) {
		//SETccc
	case 0x90: CurLine = "SETO ";   Size += Setccc(pInstr); break;
	case 0x91: CurLine = "SETNO ";  Size += Setccc(pInstr); break;
	case 0x92: CurLine = "SETC ";   Size += Setccc(pInstr); break;
	case 0x93: CurLine = "SETNC ";  Size += Setccc(pInstr); break;
	case 0x94: CurLine = "SETZ ";   Size += Setccc(pInstr); break;
	case 0x95: CurLine = "SETNZ ";  Size += Setccc(pInstr); break;
	case 0x96: CurLine = "SETBE ";  Size += Setccc(pInstr); break;
	case 0x97: CurLine = "SETNBE "; Size += Setccc(pInstr); break;
	case 0x98: CurLine = "SETS ";   Size += Setccc(pInstr); break;
	case 0x99: CurLine = "SETNS ";  Size += Setccc(pInstr); break;
	case 0x9A: CurLine = "SETP ";   Size += Setccc(pInstr); break;
	case 0x9B: CurLine = "SETNP ";  Size += Setccc(pInstr); break;
	case 0x9C: CurLine = "SETL ";   Size += Setccc(pInstr); break;
	case 0x9D: CurLine = "SETNL ";  Size += Setccc(pInstr); break;
	case 0x9E: CurLine = "SETLE ";  Size += Setccc(pInstr); break;
	case 0x9F: CurLine = "SETG ";   Size += Setccc(pInstr); break;
		//BT
	case 0xA3: Size += BTX(pInstr); break;
		//BTS
	case 0xAB: Size += BTX(pInstr); break;
		//SHLD
	case 0xA4:
	case 0xA5:
		//SHRD
	case 0xAC:
	case 0xAD:
		if ((pInstr[1] == 0xA4) || (pInstr[1] == 0xA5)) CurLine = "SHLD ";
		else CurLine = "SHRD ";
		{
			CString Op1, Reg, Count;
			Size += GetDecodedAddress(pInstr + 2, 1, Op1);
			GetRegister(pInstr[2] >> 3, 1, Reg);
			if (pInstr[1] & 1) Count = "CL";
			else {
				Count.Format("%02Xh", pInstr[Size]);
				Size++;
			}
			CurLine += Op1; CurLine += ","; CurLine += Reg; CurLine += ","; CurLine += Count;
		}
		break;
		//BTR
	case 0xB3: Size += BTX(pInstr); break;
		//BTX
	case 0xBA: Size += BTX(pInstr); break;
		//BTC
	case 0xBB: Size += BTX(pInstr); break;
		//BSF
	case 0xBC:
		//BSR
	case 0xBD:
		if (pInstr[1] == 0xBC) CurLine = "BSF ";
		else CurLine = "BSR ";
		{
			CString Src, Reg;
			Size += GetDecodedAddress(pInstr + 2, 1, Src);
			GetRegister(pInstr[2] >> 3, 1, Reg);
			CurLine += Reg;
			CurLine += ",";
			CurLine += Src;
		}
		break;
	default: return Unknown();
	}

	return Size;
}

static const char* spaces = "                                ";

//==========================================================
extern "C" DWORD PASCAL DasmInstr(DWORD Seg, DWORD Offs, struct _EmulatorData* EmData, char* s)
{
	pEmData = EmData;
	CurLine = s;
	Comment = "";  //Очищаем комментарий
	CurOffs = (WORD)Offs; CurSeg = (WORD)Seg;  //Текущие сегмент и смещение
	LocalSeg = pEmData->Reg.DS; sLocalSeg = "";  //Текущий сегмент по умолчанию
	SegChanged = FALSE;
	//Получаем адрес инструкции
	pInstr = (BYTE*)SegOffsToPtr(CurSeg, CurOffs);
	//Определяем наиболее вероятную разрядность операндов
	W = *pInstr & 1;
	//Вызываем обработчик
	DWORD Size = COPFunc[*pInstr]();
	//Копируем строку с дизассембл. инструкцией в выходную строку
	strcpy(s, (LPCTSTR)CurLine);

	std::optional<std::string> listingComment = listing.GetComment(Seg, Offs);
	if (listingComment) {
		Comment = "; ";
		Comment.Append(listingComment->c_str());

		int countSpaces = 24 - strlen(s);
		if (countSpaces > 0)
			strncat(s, spaces, countSpaces);
		strcat(s, (LPCTSTR)Comment);
	}

	//Возвращаем размер инструкции
	return Size;
}

extern "C" DWORD PASCAL ClearListing() {
	listing.Clear();

	return NO_ERRORS;
}

extern "C" DWORD PASCAL ParseListing(const std::string & pathLst) {
	if(listing.Parse(pathLst)) return NO_ERRORS;

	return UNKNOWN_ERROR;
}