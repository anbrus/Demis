#include "instructions.h"

#include "emulator.h"
#include "SubFunc.h"
#include "Tables.h"

uint32_t UnkInstr(uint8_t*)  //Неизвестная инструкция
{
	return STOP_UNKNOWN_INSTRUCTION;
}

uint32_t Mov4(uint8_t* pCOP)  //Mov Reg,data
{
	uint8_t COP = *pCOP;
	uint16_t wData = *(uint16_t*)((uint8_t*)pCOP + 1);
	SetRegister(COP & 7, (COP & 8) >> 3, wData);
	return AddIP(COP & 8 ? 3 : 2);
}

uint32_t JCond(uint8_t* pCOP)  //Условные переходы
{
	bool Jump = false;
	signed char Offs;
	switch (*pCOP) {
	case 0x70:
	case 0x71: Jump = EmulatorData.Reg.Flag.OF; break;
	case 0x72:
	case 0x73: Jump = EmulatorData.Reg.Flag.CF; break;
	case 0x74:
	case 0x75: Jump = EmulatorData.Reg.Flag.ZF; break;
	case 0x76:
	case 0x77: Jump = EmulatorData.Reg.Flag.CF || EmulatorData.Reg.Flag.ZF; break;
	case 0x78:
	case 0x79: Jump = EmulatorData.Reg.Flag.SF; break;
	case 0x7A:
	case 0x7B: Jump = EmulatorData.Reg.Flag.PF; break;
	case 0x7C:
	case 0x7D: Jump = EmulatorData.Reg.Flag.OF ^ EmulatorData.Reg.Flag.SF; break;
	case 0x7E:
	case 0x7F: Jump = (EmulatorData.Reg.Flag.OF ^ EmulatorData.Reg.Flag.SF) || EmulatorData.Reg.Flag.ZF; break;
	case 0xE3: Jump = EmulatorData.Reg.CX != 0; break;
	}
	if (*pCOP & 1) Jump = !Jump;
	Offs = Jump ? *(pCOP + 1) : 0;
	return AddIP((uint8_t)2 + Offs);
}

uint32_t Lea(uint8_t* pCOP) {
	uint8_t COP2 = *(pCOP + 1);
	uint16_t Addr = *reinterpret_cast<uint16_t*>(pCOP + 2);
	SetRegister(COP2 >> 3, 1, (uint16_t)Addr);

	return AddIP(4);
}

uint32_t Mov1(uint8_t* pCOP)  //Различные операции пересылки
{
	uint8_t COP1 = *pCOP, COP2 = *(pCOP + 1);
	uint8_t W = COP1 & 1;
	void* Addr;
	uint32_t Size = GetDecodedAddress(pCOP + 1, W, &Addr) + 1;
	uint16_t wData;
	switch (COP1) {
		//Mov r/m,r8
	case 0x88: WriteRealMem(Addr, GetRegister(COP2 >> 3, 0), 0); break;
		//Mov r/m,r16
	case 0x89: WriteRealMem(Addr, GetRegister(COP2 >> 3, 1), 1); break;
		//Mov r8,r/m
	case 0x8A: ReadRealMem(Addr, &wData, 0); SetRegister(COP2 >> 3, 0, wData); break;
		//Mov r16,r/m
	case 0x8B: ReadRealMem(Addr, &wData, 1); SetRegister(COP2 >> 3, 1, wData); break;
		//Mov r/m,seg
	case 0x8C: WriteRealMem(Addr, GetSegRegister(COP2 >> 3), 1); break;
		//Mov seg,r/m
	case 0x8E: ReadRealMem(Addr, &wData, 1); SetSegRegister(COP2 >> 3, wData); break;
		//Mov mem,data8
	case 0xC6: wData = *(pCOP + Size); Size++; WriteRealMem(Addr, wData, 0); break;
		//Mov mem,data16
	case 0xC7: wData = *(uint16_t*)(pCOP + Size); Size += 2; WriteRealMem(Addr, wData, 1); break;
	}
	return AddIP(Size);
}

uint32_t AcOp(uint8_t* pCOP)  //Mov Ac,Mem  Mov Mem,Ac  Movs
{
	uint8_t COP1 = *pCOP;
	uint8_t W = COP1 & 1;
	uint16_t wData = *(uint16_t*)(pCOP + 1);
	uint16_t Temp;
	bool AddSI = false, AddDI = false;
	switch (COP1 >> 1) {
		//Mov Ac,Mem
	case 0x50: ReadVirtMem(CurSeg, wData, &Temp, W); SetRegister(0, W, Temp); return AddIP(3);
		//Mov Mem,Ac
	case 0x51: WriteVirtMem(CurSeg, wData, EmulatorData.Reg.AX, W); return AddIP(3);
		//Movs
	case 0x52: ReadVirtMem(EmulatorData.Reg.DS, EmulatorData.Reg.SI, &Temp, W);
		WriteVirtMem(EmulatorData.Reg.ES, EmulatorData.Reg.DI, Temp, W);
		AddSI = true; AddDI = true; break;
	}
	int Inc = EmulatorData.Reg.Flag.DF ? 1 : -1;
	Inc *= W + 1;
	if (AddSI) EmulatorData.Reg.SI += Inc;
	if (AddDI) EmulatorData.Reg.DI += Inc;
	EmulatorData.Reg.CX -= W + 1;
	return AddIP(1);
}

uint32_t ALOp(uint8_t* pCOP)  //Арифметико-логические операции
{
	uint8_t COP1 = *pCOP, COP2 = *(pCOP + 1);
	uint8_t W = COP1 & 1;
	uint16_t wData = *(uint16_t*)(pCOP + 1);
	void* Addr;
	uint32_t Size = GetDecodedAddress(pCOP + 1, W, &Addr) + 1;
	char Op = ' ';
	switch (COP1 & 0xF8) {  //Выбор типа операции
	case 0x08: Op = '|'; break;  //Or
	case 0x00: Op = '+'; break;  //Add
	case 0x10: Op = '#'; break;  //Adc
	case 0x18: Op = '_'; break;  //Sbb
	case 0x20: Op = '&'; break;  //And
	case 0x28: Op = '-'; break;  //Sub
	case 0x30: Op = '^'; break;  //Xor
	case 0x38: Op = '?'; break;  //Cmp
	}
	switch ((COP1 >> 1) & 3) {  //Выбор типа операндов
		//Op rm,r
	case 0: WriteRealMem(Addr, (uint16_t)Calculate(Op, *(uint16_t*)Addr, GetRegister(COP2 >> 3, W),
		W, 0xFFFF), W);
		break;
		//Op r,rm
	case 1: SetRegister(COP2 >> 3, W, (uint16_t)Calculate(Op, GetRegister(COP2 >> 3, W),
		*(uint16_t*)Addr, W, 0xFFFF));
		break;
		//Op Ac,Data
	case 2: SetRegister(0, W, (uint16_t)Calculate(Op, GetRegister(0, W), wData, W, 0xFFFF));
		Size = W + 2;
		break;
	}
	return AddIP(Size);
}

uint32_t OutBytePort(uint16_t Port, uint8_t Value)
//Выводит байт Value в порт с адресом Port
{
	//::SendMessage(pHData->hHostWnd, WMU_WRITEPORT, Port, Value);
	pHData->WritePort(Port, Value);
	return 0;
}

uint32_t InBytePort(uint16_t Port, uint8_t* pValue)
//Читает в *Value содержимое порта Port
{
	//*pValue = (uint8_t)::SendMessage(pHData->hHostWnd, WMU_READPORT, Port, 0);
	*pValue = pHData->ReadPort(Port);
	return 0;
}

uint32_t IO(uint8_t* pCOP)  //In, Out
{
	uint16_t PortNumber;
	uint32_t PortData;
	uint32_t Size = 2;
	//Определение адреса порта
	if (*pCOP & 8) { PortNumber = EmulatorData.Reg.DX; Size = 1; }
	else PortNumber = *(pCOP + 1);
	uint32_t Status;
	if (*pCOP & 2) {  //Out
		Status = OutBytePort(PortNumber, (uint8_t)EmulatorData.Reg.AX);
		if (*pCOP & 1) Status |= OutBytePort(PortNumber + 1, EmulatorData.Reg.AX >> 8);
	}
	else {  //In
		Status = InBytePort(PortNumber, (uint8_t*)&PortData);
		if (*pCOP & 1) Status |= InBytePort(PortNumber + 1, 1 + (uint8_t*)&PortData);
		SetRegister(0, *pCOP & 1, (uint8_t)PortData);
	}
	if (Status) return Status;
	return AddIP(Size);
}

uint32_t Push(uint8_t* pCOP)
{
	uint16_t* pSource, Source = 0;
	uint32_t Size = 1;
	switch (*pCOP & 0xC0) {
		//Push sr
	case 0x00: Source = GetSegRegister((*pCOP >> 3) & 7); break;
		//Push r16
	case 0x40: Source = GetRegister(*pCOP & 7, 1); break;
		//Pushf
	case 0x80: Source = *(uint16_t*)&EmulatorData.Reg.Flag; break;
		//Push r/m
	case 0xC0:
		Size = GetDecodedAddress(pCOP + 1, 1, (void**)&pSource) + 1;
		ReadRealMem((void*)pSource, &Source, 1);
		break;
	}
	WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 2, Source, 1);
	EmulatorData.Reg.SP -= 2;
	return AddIP(Size);
}

uint32_t Pop(uint8_t* pCOP)
{
	uint16_t* pDest, Value;
	ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, &Value, 1);
	EmulatorData.Reg.SP += 2;
	uint32_t Size = 1;
	switch (*pCOP & 0xF0) {
		//Pop r/m
	case 0x80:
		Size = GetDecodedAddress(pCOP + 1, 1, (void**)&pDest) + 1;
		WriteRealMem((void*)pDest, Value, 1);
		break;
		//Pop r16
	case 0x50: SetRegister(*pCOP & 7, 1, Value); break;
		//Pop sr
	case 0x00:
	case 0x10: SetSegRegister(*pCOP >> 3, Value); break;
		//Popf
	case 0x90: *(uint16_t*)&EmulatorData.Reg.Flag = Value; break;
	}
	return AddIP(Size);
}

uint32_t Inc(uint8_t* pCOP)
{
	uint32_t Size = 1;
	uint16_t* Addr, Value;
	uint8_t W = *pCOP & 1;
	if (*pCOP & 0x80) {  //Inc r/m
		Size += GetDecodedAddress(pCOP + 1, W, (void**)&Addr);
		ReadRealMem(Addr, &Value, W);
		WriteRealMem(Addr, (uint16_t)Calculate('+', Value, 1, W, 0xFFFE), W);
	}
	else {  //Inc r16
		Value = GetRegister(*pCOP & 7, 1);
		SetRegister(*pCOP & 7, 1, (uint16_t)Calculate('+', Value, 1, 1, 0xFFFE));
	}
	return AddIP(Size);
}

uint32_t Dec(uint8_t* pCOP)
{
	uint32_t Size = 1;
	uint16_t* Addr, Value;
	uint8_t W = *pCOP & 1;
	if (*pCOP & 0x80) {  //Dec r/m
		Size += GetDecodedAddress(pCOP + 1, W, (void**)&Addr);
		ReadRealMem(Addr, &Value, W);
		WriteRealMem(Addr, (uint16_t)Calculate('-', Value, 1, W, 0xFFFE), W);
	}
	else {  //Dec r16
		Value = GetRegister(*pCOP & 7, 1);
		SetRegister(*pCOP & 7, 1, (uint16_t)Calculate('-', Value, 1, 1, 0xFFFE));
	}
	return AddIP(Size);
}

uint32_t Xchg(uint8_t* pCOP)
{
	uint16_t Temp, * Addr;
	uint32_t Size = 1;
	uint8_t Reg;
	if (*pCOP & 0x10) {  //Xchg AX,r16
		Temp = EmulatorData.Reg.AX;
		EmulatorData.Reg.AX = GetRegister(*pCOP & 7, 1);
		SetRegister(*pCOP & 7, 1, Temp);
	}
	else {  //Xchg r,r/m
		Reg = ((*(pCOP + 1)) >> 3) & 7;
		Size += GetDecodedAddress(pCOP + 1, *pCOP & 1, (void**)&Addr);
		Temp = GetRegister(Reg, *pCOP & 1);
		SetRegister(Reg, *pCOP & 1, *Addr);
		WriteRealMem((void*)Addr, Temp, *pCOP & 1);
	}
	return AddIP(Size);
}

uint32_t ArOp(uint8_t* pCOP)  //Ар.-лог. операции с непоср. данными
{
	uint32_t Size = 1;
	uint16_t* pDest, Source, Dest;
	char Op = ' ';
	uint8_t SW = *pCOP & 1;
	Size += GetDecodedAddress(pCOP + 1, SW, (void**)&pDest);
	if (*pCOP & 2) SW = 0;
	Source = *(pCOP + Size);
	if (SW) Source = *(uint16_t*)(pCOP + Size);
	if (*pCOP & 2) Source = (uint16_t)(signed char)Source; //Расширение знака
	Size += SW + 1;
	switch ((*(pCOP + 1)) & 0x38) {
	case 0x00: Op = '+'; break;  //Add
	case 0x08: Op = '|'; break;  //Or
	case 0x10: Op = '#'; break;  //Adc
	case 0x18: Op = '_'; break;  //Sbb
	case 0x20: Op = '&'; break;  //And
	case 0x28: Op = '-'; break;  //Sub
	case 0x30: Op = '^'; break;  //Xor
	case 0x38: Op = '?'; break;  //Cmp
	}
	Dest = (uint16_t)Calculate(Op, *pDest, Source, *pCOP & 1, 0xFFFF);
	WriteRealMem(pDest, Dest, *pCOP & 1);
	return AddIP(Size);
}

uint32_t Lxs(uint8_t* pCOP)  //Les, Lds
{
	uint16_t* pSeg = &EmulatorData.Reg.ES;
	uint16_t* pSrc;
	uint32_t Size = 1;
	if (*pCOP & 1) pSeg = &EmulatorData.Reg.DS;
	Size += GetDecodedAddress(pCOP + 1, 1, (void**)&pSrc);
	SetRegister(((*(pCOP + 1)) >> 3) & 7, 1, *pSrc);
	*pSeg = *(pSrc + 1);
	return AddIP(Size);
}

uint32_t Shift(uint8_t* pCOP)  //Сдвиги
{
	uint8_t Count = 1;
	uint16_t* pSrc, Src;
	uint32_t Size = GetDecodedAddress(pCOP + 1, *pCOP & 1, (void**)&pSrc) + 1;
	Src = *pSrc;
	uint32_t Flags, OrigFlags = *(uint16_t*)&EmulatorData.Reg.Flag;
	_asm {
		pushfd
		pop eax
		and eax, 0xFFFFF72A  //Reset Arith. Flags
		mov edx, OrigFlags
		and edx, 0x000008D5  //Reset Ctrl. Flags
		or eax, edx
		mov Flags, eax       //Flags = флаги для эмулирующей машины
	}
	if (*pCOP & 2) Count = (uint8_t)EmulatorData.Reg.CX;
	if (*pCOP & 1) {
		switch (*(pCOP + 1) & 0x38) {
			//Общая схема: установить флаги из Flags
			//Выполнить сдвиг Src cl раз
			//Скопировать флаги в Flags
		case 0x00:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rol Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x08:
			_asm {
				push Flags
				popfd
				mov cl, Count
				ror Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x10:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcl Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x18:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcr Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x20:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shl Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x28:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shr Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x30: return STOP_UNKNOWN_INSTRUCTION;
		case 0x38:
			_asm {
				push Flags
				popfd
				mov cl, Count
				sar Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		}
	}
	else {
		switch (*(pCOP + 1) & 0x38) {
		case 0x00:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rol Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x08:
			_asm {
				push Flags
				popfd
				mov cl, Count
				ror Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x10:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcl Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x18:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcr Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x20:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shl Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x28:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shr Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x30: return STOP_UNKNOWN_INSTRUCTION;
		case 0x38:
			_asm {
				push Flags
				popfd
				mov cl, Count
				sar Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		}
	}
	WriteRealMem((void*)pSrc, Src, *pCOP & 1);
	Flags &= 0x000008D5;      //Reset Ctrl. Flags
	OrigFlags &= 0xFFFFF72A;  //Reset Arith. Flags
	OrigFlags |= Flags;
	*(uint16_t*)&EmulatorData.Reg.Flag = (uint16_t)OrigFlags;  //Установить новые флаги
	return AddIP(Size);
}

uint32_t SegXS(uint8_t* pCOP)  //Префикс замены сегмента
{
	CurSeg = GetSegRegister(*pCOP >> 3);
	SegChanged = TRUE;
	EmulatorData.Reg.IP++;
	//Определяем адрес следующей инструкции
	uint8_t* pNewCOP = (uint8_t*)VirtToReal(EmulatorData.Reg.CS, EmulatorData.Reg.IP);
	//и выполнение следующей инструкции
	uint32_t Res = INVALID_ADDRESS;
	if (pNewCOP) Res = FirstByte[*pNewCOP](pNewCOP);
	CurSeg = EmulatorData.Reg.DS;
	SegChanged = FALSE;

	return Res;
}

uint32_t Jmp1(uint8_t* pCOP)  //Безусловные переходы по адресу в инструкции
{
	short Diff = 0;
	switch (*pCOP & 3) {
		//Jmp Near
	case 1: Diff = *(short*)(pCOP + 1) + 3; break;
		//Jmp Far
	case 2:
		Diff = 0;
		EmulatorData.Reg.IP = *(uint16_t*)(pCOP + 1);
		EmulatorData.Reg.CS = *(uint16_t*)(pCOP + 3);
		break;
		//Jmp Short
	case 3: Diff = *(signed char*)(pCOP + 1) + 2; break;
	}
	EmulatorData.Reg.IP += Diff;
	return AddIP(0);
}

uint32_t Jmp2(uint8_t* pCOP)  //Безусловные переходы по адресу в ОЗУ
{
	uint16_t* Addr, Value;
	GetDecodedAddress(pCOP + 1, 1, (void**)&Addr);
	switch (*(pCOP + 1) & 0x38) {
		//Jmp Near
	case 0x20:
		ReadRealMem(Addr, &Value, 1);
		EmulatorData.Reg.IP = *(short*)&Value;
		break;
		//Jmp Far
	case 0x28:
		ReadRealMem(Addr, &Value, 1);
		EmulatorData.Reg.IP = Value;
		ReadRealMem(Addr + 2, &Value, 1);
		EmulatorData.Reg.CS = Value;
		break;
	}
	return AddIP(0);
}

uint32_t Test(uint8_t* pCOP)
{
	uint32_t Size = 1;
	uint16_t Value, * pValue;
	uint8_t W = *pCOP & 1;
	uint8_t Reg = *(pCOP + 1) >> 3;
	switch ((*pCOP >> 1) & 3) {
		//Test Ac,Data
	case 0:
		Value = *(uint16_t*)(pCOP + 1);
		Calculate('@', GetRegister(0, W), Value, W, 0xFFFF);
		Size = W + 2;
		break;
		//Test r,r/m
	case 2:
		Size += GetDecodedAddress(pCOP + 1, W, (void**)&pValue);
		Calculate('@', GetRegister(Reg, W), *pValue, W, 0xFFFF);
		break;
		//Test r/m,data
	case 3:
		Size += GetDecodedAddress(pCOP + 1, W, (void**)&pValue);
		ReadRealMem(pValue, &Value, W);
		pValue = (uint16_t*)(pCOP + Size);
		Calculate('@', Value, *pValue, W, 0xFFFF);
		Size += W + 1; break;
	}
	return AddIP(Size);
}

uint32_t Call1(uint8_t* pCOP) //Call sbr
{
	uint32_t Diff = *(uint16_t*)(uint8_t*)(pCOP + 1);
	EmulatorData.Reg.SP -= 2;
	if (*pCOP & 64) {  //Call Near
		//Запоминаем адрес возврата в стеке
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.IP + 3, 1);
		return AddIP(Diff + 3);
	}
	//Call Far
	//Запоминаем адрес возврата в стеке
	WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.CS, 1);
	EmulatorData.Reg.SP -= 2;
	WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.IP + 5, 1);
	EmulatorData.Reg.CS = *(uint16_t*)(uint8_t*)(pCOP + 3);
	EmulatorData.Reg.IP = (uint16_t)Diff;
	return AddIP(0);
}

uint32_t Call2(uint8_t* pCOP) //Call rm16
{
	uint16_t* Addr, Value;
	uint32_t Size = 1 + GetDecodedAddress(pCOP + 1, 1, (void**)&Addr);
	EmulatorData.Reg.SP -= 2;
	if (*(pCOP + 1) & 8) { //Call Far
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.CS, 1);
		EmulatorData.Reg.SP -= 2;
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.IP + (uint16_t)Size, 1);

		ReadRealMem(Addr, &Value, 1);
		EmulatorData.Reg.IP = Value;
		ReadRealMem(Addr + 1, &Value, 1);
		EmulatorData.Reg.CS = Value;
	}
	else {
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.IP + (uint16_t)Size, 1);
		ReadRealMem(Addr, &Value, 1);
		EmulatorData.Reg.IP = *(short*)&Value;
	}
	return AddIP(0);
	/*uint16_t *Addr,Disp;
	uint32_t Size=1+GetDecodedAddress(pCOP+1,1,(void**)&Addr);
	Data.Reg.SP-=2; ReadRealMem(Addr,&Disp,1);
	if(*(pCOP+1)&8) {  //Call Far
	  WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.CS,1);
	  Data.Reg.SP-=2;
	  WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+(uint16_t)Size,1);
	  Data.Reg.IP=Disp; ReadRealMem(Addr+1,&Data.Reg.CS,1);
	}else {  //Call Near
	  WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+(uint16_t)Size,1);
	  Data.Reg.IP+=Disp;
	}
	return AddIP(0);*/
}

uint32_t Ret(uint8_t* pCOP)
{
	uint16_t Stk1, Stk2;
	ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, &Stk1, 1);
	//Восстанавливаем IP и SP
	EmulatorData.Reg.SP += 2; EmulatorData.Reg.IP = Stk1;
	switch (*pCOP) {
		//Ret (Near)
	case 0xC3: break;
		//Ret d (Near)
	case 0xC2: EmulatorData.Reg.SP += *(uint16_t*)(pCOP + 1); break;
		//Ret (Far)
	case 0xCB:
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, &Stk2, 1);
		EmulatorData.Reg.SP += 2; EmulatorData.Reg.CS = Stk2;
		break;
		//Ret d (Far)
	case 0xCA:
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, &Stk2, 1);
		EmulatorData.Reg.SP += 2; EmulatorData.Reg.CS = Stk2;
		EmulatorData.Reg.SP += *(uint16_t*)(pCOP + 1); break;
		//Iret
	case 0xCF:
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, &EmulatorData.Reg.CS, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 2, (uint16_t*)&EmulatorData.Reg.Flag, 1);
		EmulatorData.Reg.SP += 4;
		break;
	}
	return AddIP(0);
}

uint32_t Loop(uint8_t* pCOP)  //Loop,LoopZ,LoopNZ
{
	uint32_t Disp = (signed char)(2 + *(signed char*)(pCOP + 1));
	EmulatorData.Reg.CX--;
	if (EmulatorData.Reg.CX == 0) return AddIP(2);
	switch (*pCOP) {
		//Loop
	case 0xE2: return AddIP(Disp);
		//LoopZ
	case 0xE1: if (EmulatorData.Reg.Flag.ZF) return AddIP(2); else return AddIP(Disp);
		//LoopNZ
	case 0xE0: if (EmulatorData.Reg.Flag.ZF) return AddIP(Disp); else return AddIP(2);
	}
	return(STOP_UNKNOWN_INSTRUCTION);
}

uint32_t Flags(uint8_t* pCOP)  //Операции установки флагов
{
	switch (*pCOP) {
		//CMC
	case 0xF5: EmulatorData.Reg.Flag.CF = ~EmulatorData.Reg.Flag.CF; break;
		//CLC
	case 0xF8: EmulatorData.Reg.Flag.CF = 0; break;
		//STC
	case 0xF9: EmulatorData.Reg.Flag.CF = 1; break;
		//CLI
	case 0xFA: EmulatorData.Reg.Flag.IF = 0; break;
		//STI
	case 0xFB: EmulatorData.Reg.Flag.IF = 1; break;
		//CLD
	case 0xFC: EmulatorData.Reg.Flag.DF = 0; break;
		//STD
	case 0xFD: EmulatorData.Reg.Flag.DF = 1; break;
	}
	return AddIP(1);
}

uint32_t Xlat(uint8_t* pCOP)
{
	uint16_t Val;
	ReadVirtMem(CurSeg, EmulatorData.Reg.BX + (EmulatorData.Reg.AX & 0x00FF), &Val, 0);
	SetRegister(0, 0, Val);
	return AddIP(1);
}

uint32_t DivMul(uint8_t* pCOP)
{
	uint8_t W = *pCOP & 1;
	uint16_t* Addr;
	uint32_t Size = 1 + GetDecodedAddress(pCOP + 1, W, (void**)&Addr);
	uint32_t Op1 = EmulatorData.Reg.AX;
	if (W) Op1 |= ((uint32_t)EmulatorData.Reg.DX) << 16;
	uint16_t Op2;
	ReadRealMem(Addr, &Op2, W);
	char Op = ' ';
	switch ((*(pCOP + 1) >> 3) & 7) {
	case 0x04: Op = '*'; Op1 &= 0x0000FFFF; break;  //Mul
	case 0x05: Op = 'x'; Op1 &= 0x0000FFFF; break;  //IMul
	case 0x06: Op = '/'; break;                   //Div
	case 0x07: Op = '\\'; break;                  //IDiv
	}
	uint32_t Res;
	__try {  //Ловим переполнение при делении
		Res = Calculate(Op, Op1, Op2, W, 0xFFFF);
	}
	__except (GetExceptionCode()& (EXCEPTION_INT_DIVIDE_BY_ZERO | EXCEPTION_INT_OVERFLOW) ?
		EXCEPTION_EXECUTE_HANDLER : EXCEPTION_CONTINUE_SEARCH) {
		//Поймали, вызываем Int 0
		uint16_t* pStk = (uint16_t*)VirtToReal(EmulatorData.Reg.SS, EmulatorData.Reg.SP);
		WriteRealMem(pStk - 1, *(uint16_t*)&EmulatorData.Reg.Flag, 1);
		WriteRealMem(pStk - 2, EmulatorData.Reg.CS, 1);
		WriteRealMem(pStk - 3, EmulatorData.Reg.IP, 1);
		EmulatorData.Reg.Flag.IF = 0; EmulatorData.Reg.Flag.TF = 0; EmulatorData.Reg.SP -= 6;
		ReadVirtMem(0, 0, &EmulatorData.Reg.IP, 1);
		ReadVirtMem(0, 2, &EmulatorData.Reg.CS, 1);
		return AddIP(0);
	}
	EmulatorData.Reg.AX = (uint16_t)Res;
	if (W) EmulatorData.Reg.DX = (uint16_t)(Res >> 16);
	return AddIP(Size);
}

uint32_t Int(uint8_t* pCOP)
{
	uint8_t Type = 0, Size = 1;
	switch (*pCOP & 3) {
		//Int3
	case 0: Type = 3; break;
		//Int type
	case 1: Type = *(pCOP + 1); Size = 2; break;
		//IntO
	case 2:
		if (EmulatorData.Reg.Flag.OF) { Type = 4; break; }
		else return AddIP(1);
	}
	uint16_t* pStk = (uint16_t*)VirtToReal(EmulatorData.Reg.SS, EmulatorData.Reg.SP);
	WriteRealMem(pStk - 1, *(uint16_t*)&EmulatorData.Reg.Flag, 1);
	WriteRealMem(pStk - 2, EmulatorData.Reg.CS, 1);
	WriteRealMem(pStk - 3, EmulatorData.Reg.IP + Size, 1);
	EmulatorData.Reg.Flag.IF = 0; EmulatorData.Reg.Flag.TF = 0; EmulatorData.Reg.SP -= 6;
	ReadVirtMem(0, Type * 4, &EmulatorData.Reg.IP, 1);
	ReadVirtMem(0, Type * 4 + 2, &EmulatorData.Reg.CS, 1);
	return AddIP(0);
}

uint32_t Corr(uint8_t* pCOP)  //Команды различных коррекций
{
	uint16_t rAX = EmulatorData.Reg.AX;
	uint32_t Size = 1, Flags, OrigFlags = *(uint16_t*)&EmulatorData.Reg.Flag;
	_asm {
		pushfd
		pop eax
		and eax, 0xFFFFF72A  //Reset Arith. Flags
		mov edx, OrigFlags
		and edx, 0x000008D5  //Reset Ctrl. Flags
		or eax, edx
		mov Flags, eax       //Flags = флаги для эмулирующей машины
	}
	switch (*pCOP) {
		//Общая схема: установить флаги из Flags
		//Выполнить коррекцию
		//Скопировать флаги в Flags
	case 0x27:
		_asm {
			push Flags
			popfd
			mov ax, rAX
			daa
			mov rAX, ax
			pushfd
			pop Flags
		} break;
	case 0x37:
		_asm {
			push Flags
			popfd
			mov ax, rAX
			aaa
			mov rAX, ax
			pushfd
			pop Flags
		} break;
	case 0x2F:
		_asm {
			push Flags
			popfd
			mov ax, rAX
			das
			mov rAX, ax
			pushfd
			pop Flags
		} break;
	case 0x3F:
		_asm {
			push Flags
			popfd
			mov ax, rAX
			aas
			mov rAX, ax
			pushfd
			pop Flags
		} break;
	case 0xD4:
		if (*(pCOP + 1) != 10) return UnkInstr(pCOP);
		Size = 2;
		_asm {
			push Flags
			popfd
			mov ax, rAX
			aam
			mov rAX, ax
			pushfd
			pop Flags
		} break;
	case 0xD5:
		if (*(pCOP + 1) != 10) return UnkInstr(pCOP);
		Size = 2;
		_asm {
			push Flags
			popfd
			mov ax, rAX
			aad
			mov rAX, ax
			pushfd
			pop Flags
		} break;
	}
	EmulatorData.Reg.AX = rAX;
	Flags &= 0x000008D5;      //Reset Ctrl. Flags
	OrigFlags &= 0xFFFFF72A;  //Reset Arith. Flags
	OrigFlags |= Flags;
	*(uint16_t*)&EmulatorData.Reg.Flag = (uint16_t)OrigFlags;
	return AddIP(Size);
}

uint32_t Expand(uint8_t* pCOP)  //Команды расширения знака
{
	switch (*pCOP) {
	case 0x98:  //CBW
		EmulatorData.Reg.AX &= 0x00FF;
		if (EmulatorData.Reg.AX & 0x80) EmulatorData.Reg.AX |= 0xFF00;
		break;
	case 0x99:  //CWD
		EmulatorData.Reg.DX = 0;
		if (EmulatorData.Reg.AX & 0x8000) EmulatorData.Reg.DX = 0xFFFF;
		break;
	}
	return AddIP(1);
}

uint32_t Void(uint8_t* pCOP)  //Неисполняемые инструкции
{
	switch (*pCOP) {
	case 0x9B: return AddIP(1);  //Wait
	case 0xF0: return AddIP(1);  //Lock
	}
	return STOP_UNKNOWN_INSTRUCTION;
}

uint32_t Halt(uint8_t* pCOP)
{
	if (EmulatorData.IntRequest && EmulatorData.Reg.Flag.IF)
		return AddIP(1);

	return AddIP(0);
}

uint32_t String(uint8_t* pCOP)  //Строковые операции
{
	uint8_t W = *pCOP & 1;
	uint16_t Op1, Op2;
	BOOL ChangeSI = TRUE, ChangeDI = TRUE;
	switch (*pCOP & 0xFE) {
	case 0xA4: //MOVS
		ReadVirtMem(EmulatorData.Reg.DS, EmulatorData.Reg.SI, &Op1, W);
		WriteVirtMem(EmulatorData.Reg.ES, EmulatorData.Reg.DI, Op1, W);
		break;
	case 0xA6: //CMPS
		ReadVirtMem(EmulatorData.Reg.DS, EmulatorData.Reg.SI, &Op1, W);
		ReadVirtMem(EmulatorData.Reg.ES, EmulatorData.Reg.DI, &Op2, W);
		Calculate('?', Op1, Op2, W, 0xFFFF);
		break;
	case 0xAA: //STOS
		WriteVirtMem(EmulatorData.Reg.ES, EmulatorData.Reg.DI, EmulatorData.Reg.AX, W);
		ChangeSI = FALSE; break;
	case 0xAC: //LODS
		ReadVirtMem(EmulatorData.Reg.DS, EmulatorData.Reg.SI, &EmulatorData.Reg.AX, W);
		ChangeDI = FALSE; break;
	case 0xAE: //SCAS
		ReadVirtMem(EmulatorData.Reg.ES, EmulatorData.Reg.DI, &Op2, W);
		Calculate('?', EmulatorData.Reg.AX, Op2, W, 0xFFFF);
		ChangeSI = FALSE;
		break;
	case 0x6C: //INS
		InBytePort(EmulatorData.Reg.DX, (uint8_t*)&Op1);
		if (W) InBytePort(EmulatorData.Reg.DX + 1, (uint8_t*)&Op1 + 1);
		WriteVirtMem(EmulatorData.Reg.ES, EmulatorData.Reg.DI, Op1, W);
		break;
	case 0x6E: //OUTS
		ReadVirtMem(EmulatorData.Reg.DS, EmulatorData.Reg.SI, &Op1, W);
		OutBytePort(EmulatorData.Reg.DX, Op1 & 0xFF);
		if (W) OutBytePort(EmulatorData.Reg.DX + 1, Op1 >> 8);
		break;
	}
	int Increment = EmulatorData.Reg.Flag.DF ? -(W + 1) : W + 1;
	if (ChangeSI) EmulatorData.Reg.SI += Increment;
	if (ChangeDI) EmulatorData.Reg.DI += Increment;
	return AddIP(1);
}

uint32_t AcFl(uint8_t* pCOP)
{
	switch (*pCOP) {
	case 0x9E: //SAHF
		*(uint8_t*)&EmulatorData.Reg.Flag = *(uint8_t*)&EmulatorData.Reg.AX;
		break;
	case 0x9F: //LAHF
		*(uint8_t*)&EmulatorData.Reg.AX = *(uint8_t*)&EmulatorData.Reg.Flag;
		break;
	}
	return AddIP(1);
}

uint32_t Rep1(uint8_t* pCOP)  //REPNE REPNZ
{
	switch (*(pCOP + 1) & 0xFE) {
	case 0xA6: //REPNE CMPS
	case 0xAE: //REPNE SCAS
		FirstByte[*(pCOP + 1)](pCOP + 1);
		EmulatorData.Reg.CX--;
		if ((EmulatorData.Reg.Flag.ZF == 0) || (EmulatorData.Reg.CX == 0)) return AddIP(1);
		break;
	default: return STOP_UNKNOWN_INSTRUCTION;
	}
	return AddIP(-1);
}

uint32_t Rep2(uint8_t* pCOP)  //REP REPE PEPZ
{
	switch (*(pCOP + 1) & 0xFE) {
	case 0xA4: //REP MOVS
	case 0xAA: //REP STOS
		FirstByte[*(pCOP + 1)](pCOP + 1);
		EmulatorData.Reg.CX--;
		if (EmulatorData.Reg.CX == 0) return AddIP(1);
		break;
	case 0xA6: //REPZ CMPS
	case 0xAE: //REPZ SCAS
		FirstByte[*(pCOP + 1)](pCOP + 1);
		EmulatorData.Reg.CX--;
		if ((EmulatorData.Reg.Flag.ZF == 1) || (EmulatorData.Reg.CX == 0)) return AddIP(1);
		break;
	case 0x6C: //REP INS
	case 0x6E: //REP OUTS
		FirstByte[*(pCOP + 1)](pCOP + 1);
		EmulatorData.Reg.CX--;
		if (EmulatorData.Reg.CX == 0) return AddIP(1);
		break;
	default: return STOP_UNKNOWN_INSTRUCTION;
	}
	return AddIP(-1);
}

uint32_t Neg(uint8_t* pCOP)
{
	uint8_t W = *pCOP & 1;
	uint16_t* Addr;
	uint32_t Size = 1 + GetDecodedAddress(pCOP + 1, W, (void**)&Addr);
	uint16_t Op1 = 0, Op2 = *Addr;
	uint16_t Res = (uint16_t)Calculate('-', Op1, Op2, W, 0xFFFF);
	WriteRealMem((void*)Addr, Res, W);
	return AddIP(Size);
}

uint32_t Not(uint8_t* pCOP)
{
	uint8_t W = *pCOP & 1;
	uint16_t* Addr;
	uint32_t Size = 1 + GetDecodedAddress(pCOP + 1, W, (void**)&Addr);
	uint16_t Op1 = 0xFFFF, Op2 = *Addr;
	uint16_t Res = (uint16_t)Calculate('^', Op1, Op2, W, 0xFFFF);
	WriteRealMem((void*)Addr, Res, W);
	return AddIP(Size);
}

uint32_t Grp(uint8_t* pCOP)  //Группа инструкций с кодом 0FEh и 0FFh
{
	uint8_t W = *pCOP & 1;
	switch ((*(pCOP + 1) >> 3) & 7) {
	case 0x00: return Inc(pCOP);
	case 0x01: return Dec(pCOP);
	case 0x02: return W ? Call2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
	case 0x03: return W ? Call2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
	case 0x04: return W ? Jmp2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
	case 0x05: return W ? Jmp2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
	case 0x06: return W ? Push(pCOP) : STOP_UNKNOWN_INSTRUCTION;
	}
	return STOP_UNKNOWN_INSTRUCTION;
}

uint32_t Grp2(uint8_t* pCOP)  //Группа инструкций с кодом 0F6h и 0F7h
{
	switch ((*(pCOP + 1) >> 3) & 7) {
	case 0x00: return Test(pCOP);
	case 0x02: return Not(pCOP);
	case 0x03: return Neg(pCOP);
	case 0x04:
	case 0x05:
	case 0x06:
	case 0x07: return DivMul(pCOP);
	}
	return STOP_UNKNOWN_INSTRUCTION;
}

uint32_t Stack286(uint8_t* pCOP)
{
	uint32_t Size = 1;
	switch (*pCOP) {
		//Pusha
	case 0x60:
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 2, EmulatorData.Reg.AX, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 4, EmulatorData.Reg.CX, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 6, EmulatorData.Reg.DX, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 8, EmulatorData.Reg.BX, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 10, EmulatorData.Reg.SP, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 12, EmulatorData.Reg.BP, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 14, EmulatorData.Reg.SI, 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 16, EmulatorData.Reg.DI, 1);
		EmulatorData.Reg.SP -= 16;
		break;
		//Popa
	case 0x61:
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 0, &EmulatorData.Reg.DI, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 2, &EmulatorData.Reg.SI, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 4, &EmulatorData.Reg.BP, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 8, &EmulatorData.Reg.BX, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 10, &EmulatorData.Reg.DX, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 12, &EmulatorData.Reg.CX, 1);
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP + 14, &EmulatorData.Reg.AX, 1);

		EmulatorData.Reg.SP += 16;
		break;
		//Push Data16
	case 0x68:
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 2, *(uint16_t*)(pCOP + 1), 1);
		EmulatorData.Reg.SP -= 2;
		Size = 3;
		break;
		//Push Data8
	case 0x6A:
	{
		uint16_t Op = (uint16_t)(signed char)*(pCOP + 1);
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP - 2, Op, 1);
		EmulatorData.Reg.SP -= 2;
		Size = 2;
		break;
	}
	//Enter
	case 0xC8:
	{
		uint16_t FrameSize = *(uint16_t*)(pCOP + 1);
		uint8_t Level = *(pCOP + 3) % 32;

		//Push bp
		EmulatorData.Reg.SP -= 2;
		WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, EmulatorData.Reg.BP, 1);

		uint16_t FramePtr = EmulatorData.Reg.SP;

		if (Level > 0) {
			for (int i = 1; i <= Level - 1; i++) {
				EmulatorData.Reg.BP -= 2;

				uint16_t Value;
				ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.BP, &Value, 1);
				EmulatorData.Reg.SP -= 2;
				WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, Value, 1);
			}
			EmulatorData.Reg.SP -= 2;
			WriteVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, FramePtr, 1);
		}
		EmulatorData.Reg.BP = FramePtr;
		EmulatorData.Reg.SP -= FrameSize;
		Size = 4;
		break;
	}
	//Leave
	case 0xC9:
		EmulatorData.Reg.SP = EmulatorData.Reg.BP;
		ReadVirtMem(EmulatorData.Reg.SS, EmulatorData.Reg.SP, &EmulatorData.Reg.BP, 1);
		EmulatorData.Reg.SP += 2;
		break;
	}
	return AddIP(Size);
}

uint32_t Bound(uint8_t* pCOP)
{
	uint16_t Index = GetRegister(*(pCOP + 1) >> 3, 1);
	uint16_t* Bounds;
	uint32_t Size = 1 + GetDecodedAddress(pCOP + 1, 1, (void**)&Bounds);
	if ((Index < Bounds[0]) || (Index > Bounds[1])) {
		uint16_t* pStk = (uint16_t*)VirtToReal(EmulatorData.Reg.SS, EmulatorData.Reg.SP);
		WriteRealMem(pStk - 1, *(uint16_t*)&EmulatorData.Reg.Flag, 1);
		WriteRealMem(pStk - 2, EmulatorData.Reg.CS, 1);
		WriteRealMem(pStk - 3, EmulatorData.Reg.IP, 1);
		EmulatorData.Reg.Flag.IF = 0; EmulatorData.Reg.Flag.TF = 0; EmulatorData.Reg.SP -= 6;
		ReadVirtMem(0, 5 * 4, &EmulatorData.Reg.IP, 1);
		ReadVirtMem(0, 5 * 4 + 2, &EmulatorData.Reg.CS, 1);
		return AddIP(0);
	}

	return AddIP(Size);
}

uint32_t Shift286(uint8_t* pCOP)  //Сдвиги
{
	uint16_t* pSrc, Src;
	uint32_t Size = 2 + GetDecodedAddress(pCOP + 1, *pCOP & 1, (void**)&pSrc);
	Src = *pSrc;
	uint32_t Flags, OrigFlags = *(uint16_t*)&EmulatorData.Reg.Flag;
	_asm {
		pushfd
		pop eax
		and eax, 0xFFFFF72A  //Reset Arith. Flags
		mov edx, OrigFlags
		and edx, 0x000008D5  //Reset Ctrl. Flags
		or eax, edx
		mov Flags, eax       //Flags = флаги для эмулирующей машины
	}
	uint8_t Count = pCOP[Size - 1];
	if (pCOP[0] & 1) {
		switch (pCOP[1] & 0x38) {
			//Общая схема: установить флаги из Flags
			//Выполнить сдвиг Src cl раз
			//Скопировать флаги в Flags
		case 0x00:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rol Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x08:
			_asm {
				push Flags
				popfd
				mov cl, Count
				ror Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x10:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcl Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x18:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcr Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x20:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shl Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x28:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shr Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x30: return STOP_UNKNOWN_INSTRUCTION;
		case 0x38:
			_asm {
				push Flags
				popfd
				mov cl, Count
				sar Word Ptr Src, cl
				pushfd
				pop Flags
			} break;
		}
	}
	else {
		switch (pCOP[1] & 0x38) {
		case 0x00:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rol Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x08:
			_asm {
				push Flags
				popfd
				mov cl, Count
				ror Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x10:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcl Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x18:
			_asm {
				push Flags
				popfd
				mov cl, Count
				rcr Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x20:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shl Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x28:
			_asm {
				push Flags
				popfd
				mov cl, Count
				shr Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		case 0x30: return STOP_UNKNOWN_INSTRUCTION;
		case 0x38:
			_asm {
				push Flags
				popfd
				mov cl, Count
				sar Byte Ptr Src, cl
				pushfd
				pop Flags
			} break;
		}
	}
	WriteRealMem((void*)pSrc, Src, *pCOP & 1);
	Flags &= 0x000008D5;      //Reset Ctrl. Flags
	OrigFlags &= 0xFFFFF72A;  //Reset Arith. Flags
	OrigFlags |= Flags;
	*(uint16_t*)&EmulatorData.Reg.Flag = (uint16_t)OrigFlags;  //Установить новые флаги
	return AddIP(Size);
}

uint32_t Mul286(uint8_t* pCOP)
{
	uint8_t W = (*pCOP == 0x69) ? 1 : 0;
	uint16_t* Addr;
	uint32_t Size = 1 + GetDecodedAddress(pCOP + 1, W, (void**)&Addr);
	uint16_t Op1 = 0, Op2;
	ReadRealMem(Addr, &Op1, W);
	if (W) {
		Op2 = *(uint16_t*)(pCOP + Size);
		Size += 2;
	}
	else {
		Op2 = *(pCOP + Size);
		Size++;
	}
	if (*pCOP & 2) Op2 = (uint16_t)(signed char)Op2; //Расширение знака

	uint32_t Res = Calculate('x', Op1, Op2, 1, 0xFFFF);

	SetRegister(pCOP[1] >> 3, 1, (uint16_t)Res);

	return AddIP(Size);
}

uint32_t Setccc(BOOL Set, uint8_t* pCOP)
{
	uint8_t* pByte;
	uint32_t Size = GetDecodedAddress(pCOP + 2, 0, (void**)&pByte);
	if (Set) WriteRealMem(pByte, 1, 0);
	else WriteRealMem(pByte, 0, 0);
	return Size;
}

uint32_t SHXD(uint8_t* pCOP)
{
	uint16_t* pOp1, Op1, Op2;
	uint32_t Size = GetDecodedAddress(pCOP + 2, 1, (void**)&pOp1);
	Op1 = *pOp1;
	Op2 = GetRegister(pCOP[2] >> 3, 1);

	uint32_t Flags, OrigFlags = *(uint16_t*)&EmulatorData.Reg.Flag;
	_asm {
		pushfd
		pop eax
		and eax, 0xFFFFF72A  //Reset Arith. Flags
		mov edx, OrigFlags
		and edx, 0x000008D5  //Reset Ctrl. Flags
		or eax, edx
		mov Flags, eax       //Flags = флаги для эмулирующей машины
	}
	uint8_t Count;
	if (pCOP[1] & 1) {
		Count = EmulatorData.Reg.CX & 0xFF;
	}
	else {
		Count = pCOP[Size + 2];
		Size++;
	}
	if ((pCOP[1] == 0xA4) || (pCOP[1] == 0xA5)) {
		_asm {
			push Flags
			popfd
			mov ax, Op2
			mov cl, Count
			SHLD Op1, ax, cl
			pushfd
			pop Flags
		}
	}
	else {
		_asm {
			push Flags
			popfd
			mov ax, Op2
			mov cl, Count
			SHRD Op1, ax, cl
			pushfd
			pop Flags
		}
	}
	WriteRealMem((void*)pOp1, Op1, 1);
	Flags &= 0x000008D5;      //Reset Ctrl. Flags
	OrigFlags &= 0xFFFFF72A;  //Reset Arith. Flags
	OrigFlags |= Flags;
	*(uint16_t*)&EmulatorData.Reg.Flag = (uint16_t)OrigFlags;  //Установить новые флаги

	return Size;
}

uint32_t BSX(uint8_t* pCOP)
{
	uint16_t* pSrc, Src;
	uint32_t Size = GetDecodedAddress(pCOP + 2, 1, (void**)&pSrc);
	Src = *pSrc;
	BOOL Found = FALSE, Forward = pCOP[1] == 0xBC;
	int Index = Forward ? 0 : 15;
	for (int n = 0; n < 16; n++) {
		if (Forward) {
			if (Src & 1) {
				Found = TRUE;
				break;
			}
			else {
				Src >>= 1;
				Index++;
			}
		}
		else {
			if (Src & 0x8000) {
				Found = TRUE;
				break;
			}
			else {
				Src <<= 1;
				Index--;
			}
		}
	}
	if (Found) SetRegister(pCOP[2] >> 3, 1, Index);
	else SetRegister(pCOP[2] >> 3, 1, 0);
	EmulatorData.Reg.Flag.ZF = !Found;

	return Size;
}

uint32_t BTX(uint8_t* pCOP)
{
	int Op = 0, BitNumber;
	uint16_t* pSrc, Src;
	uint32_t Size = GetDecodedAddress(pCOP + 2, 1, (void**)&pSrc);
	Src = *pSrc;

	if (pCOP[1] == 0xBA) {
		switch ((pCOP[2] >> 3) & 7) {
		case 4: Op = 0; break;
		case 5: Op = 3; break;
		case 6: Op = 2; break;
		case 7: Op = 1; break;
		}
		BitNumber = pCOP[Size + 2];
		Size++;
	}
	else {
		switch (pCOP[1]) {
		case 0xA3: Op = 0; break;
		case 0xAB: Op = 3; break;
		case 0xB3: Op = 2; break;
		case 0xBB: Op = 1; break;
		}
		BitNumber = GetRegister(pCOP[2] >> 3, 1) & 0x0F;
	}
	EmulatorData.Reg.Flag.CF = (Src >> BitNumber) & 1;
	switch (Op) {
		//BT
	case 0: break;
		//BTC
	case 1: Src ^= 1 << BitNumber; break;
		//BTR
	case 2: Src &= ~(1 << BitNumber); break;
		//BTS
	case 3: Src |= 1 << BitNumber; break;
	}
	WriteRealMem(pSrc, Src, 1);

	return Size;
}

uint32_t JCond386(uint8_t* pCOP)
{
	bool Jump = false;
	signed short Offs;
	switch (*(pCOP + 1)) {
	case 0x80:
	case 0x81: Jump = EmulatorData.Reg.Flag.OF; break;
	case 0x82:
	case 0x83: Jump = EmulatorData.Reg.Flag.CF; break;
	case 0x84:
	case 0x85: Jump = EmulatorData.Reg.Flag.ZF; break;
	case 0x86:
	case 0x87: Jump = EmulatorData.Reg.Flag.CF || EmulatorData.Reg.Flag.ZF; break;
	case 0x88:
	case 0x89: Jump = EmulatorData.Reg.Flag.SF; break;
	case 0x8A:
	case 0x8B: Jump = EmulatorData.Reg.Flag.PF; break;
	case 0x8C:
	case 0x8D: Jump = EmulatorData.Reg.Flag.OF ^ EmulatorData.Reg.Flag.SF; break;
	case 0x8E:
	case 0x8F: Jump = (EmulatorData.Reg.Flag.OF ^ EmulatorData.Reg.Flag.SF) || EmulatorData.Reg.Flag.ZF; break;
	}
	if (*(pCOP + 1) & 1) Jump = !Jump;
	Offs = Jump ? *(signed short*)(pCOP + 2) : 0;
	return AddIP(Offs + 4);
}

uint32_t Ext386(uint8_t* pCOP)
{
	if ((pCOP[1] & 0xF0) == 0x80) return JCond386(pCOP);
	uint32_t Size = 2;
	BOOL Set = FALSE;

	switch (pCOP[1]) {
		//SETccc
	case 0x90: Size += Setccc(EmulatorData.Reg.Flag.OF, pCOP); break;
	case 0x91: Size += Setccc(!EmulatorData.Reg.Flag.OF, pCOP); break;
	case 0x92: Size += Setccc(EmulatorData.Reg.Flag.CF, pCOP); break;
	case 0x93: Size += Setccc(!EmulatorData.Reg.Flag.CF, pCOP); break;
	case 0x94: Size += Setccc(EmulatorData.Reg.Flag.ZF, pCOP); break;
	case 0x95: Size += Setccc(!EmulatorData.Reg.Flag.ZF, pCOP); break;
	case 0x96: Size += Setccc(EmulatorData.Reg.Flag.CF && EmulatorData.Reg.Flag.ZF, pCOP); break;
	case 0x97: Size += Setccc(!(EmulatorData.Reg.Flag.CF && EmulatorData.Reg.Flag.ZF), pCOP); break;
	case 0x98: Size += Setccc(EmulatorData.Reg.Flag.SF, pCOP); break;
	case 0x99: Size += Setccc(!EmulatorData.Reg.Flag.SF, pCOP); break;
	case 0x9A: Size += Setccc(EmulatorData.Reg.Flag.PF, pCOP); break;
	case 0x9B: Size += Setccc(!EmulatorData.Reg.Flag.PF, pCOP); break;
	case 0x9C: Size += Setccc(EmulatorData.Reg.Flag.OF != EmulatorData.Reg.Flag.SF, pCOP); break;
	case 0x9D: Size += Setccc(EmulatorData.Reg.Flag.OF == EmulatorData.Reg.Flag.SF, pCOP); break;
	case 0x9E: Size += Setccc(EmulatorData.Reg.Flag.ZF || (EmulatorData.Reg.Flag.SF != EmulatorData.Reg.Flag.OF), pCOP); break;
	case 0x9F: Size += Setccc(!EmulatorData.Reg.Flag.ZF && (EmulatorData.Reg.Flag.SF == EmulatorData.Reg.Flag.OF), pCOP); break;
		//BT
	case 0xA3: Size += BTX(pCOP); break;
		//BTS
	case 0xAB: Size += BTX(pCOP); break;
		//SHLD
	case 0xA4:
	case 0xA5:
		//SHRD
	case 0xAC:
	case 0xAD: Size += SHXD(pCOP); break;
		//BTR
	case 0xB3: Size += BTX(pCOP); break;
		//BTX
	case 0xBA: Size += BTX(pCOP); break;
		//BTC
	case 0xBB: Size += BTX(pCOP); break;
		//BSF
	case 0xBC:
		//BSR
	case 0xBD: Size += BSX(pCOP); break;
	default: return STOP_UNKNOWN_INSTRUCTION;
	}

	return AddIP(Size);
}
