//Файл Emulator.cpp

#include <io.h>
#include <sys\stat.h>
#include <fcntl.h>
#include "emulator.h"
#include <process.h>
#include "SubFunc.h"

struct _EmulatorData Data;
struct _HostData *pHData;

void *SegSpace[32];
int SegSpaceCount=0;
WORD CurSeg;
BOOL SegChanged=FALSE;
void *pRom,*pMemoryEnd;

struct _InstrCounter {
  DWORD Owner;
  DWORD Counter;
}InstrCounter[1024];

typedef DWORD (*_FirstByte)(BYTE*);

#define VOID_OWNER -1

//Прототипы обработчиков КОП

DWORD UnkInstr(BYTE*);
DWORD Mov4(BYTE *pCOP);
DWORD JCond(BYTE *pCOP);
DWORD Mov1(BYTE *pCOP);
DWORD AcOp(BYTE *pCOP);
DWORD ALOp(BYTE *pCOP);
DWORD IO(BYTE *pCOP);
DWORD Push(BYTE *pCOP);
DWORD Pop(BYTE *pCOP);
DWORD Inc(BYTE *pCOP);
DWORD Dec(BYTE *pCOP);
DWORD Xchg(BYTE *pCOP);
DWORD ArOp(BYTE *pCOP);
DWORD Lxs(BYTE *pCOP);
DWORD Shift(BYTE *pCOP);
DWORD SegXS(BYTE *pCOP);
DWORD Jmp1(BYTE *pCOP);
DWORD Jmp2(BYTE *pCOP);
DWORD Test(BYTE *pCOP);
DWORD Call1(BYTE *pCOP);
DWORD Call2(BYTE *pCOP);
DWORD Ret(BYTE *pCOP);
DWORD Loop(BYTE *pCOP);
DWORD Flags(BYTE *pCOP);
DWORD Xlat(BYTE *pCOP);
DWORD DivMul(BYTE *pCOP);
DWORD Int(BYTE *pCOP);
DWORD Corr(BYTE *pCOP);
DWORD Expand(BYTE *pCOP);
DWORD Void(BYTE *pCOP);
DWORD Halt(BYTE *pCOP);
DWORD Rep1(BYTE *pCOP);
DWORD Rep2(BYTE *pCOP);
DWORD String(BYTE *pCOP);
DWORD AcFl(BYTE *pCOP);
DWORD Grp(BYTE *pCOP);
DWORD Grp2(BYTE *pCOP);
DWORD Stack286(BYTE *pCOP);
DWORD Bound(BYTE *pCOP);
DWORD Shift286(BYTE *pCOP);
DWORD Mul286(BYTE *pCOP);
DWORD Ext386(BYTE *pCOP);
DWORD Lea(BYTE *pCOP);

#include "Tables.h"

//---------------------Local Functions------------------------------------------

void InsertCounter(DWORD Index,DWORD Owner,DWORD Value)
{
  if(InstrCounter[Index].Owner!=VOID_OWNER) {
    //Сдвигаем
    DWORD ElCount=sizeof(InstrCounter)/sizeof(struct _InstrCounter);
    DWORD MemSize=(ElCount-Index-1)*sizeof(struct _InstrCounter);
    memcpy(&InstrCounter[Index+1],&InstrCounter[Index],MemSize);
  }
  //Добавляем
  InstrCounter[Index].Owner=Owner;
  InstrCounter[Index].Counter=Value;
}

void RemoveCounter(DWORD Index)
{
  DWORD ElCount=sizeof(InstrCounter)/sizeof(struct _InstrCounter);
  DWORD MemSize=(ElCount-Index-1)*sizeof(struct _InstrCounter);
  memcpy(&InstrCounter[Index],&InstrCounter[Index+1],MemSize);
  InstrCounter[ElCount-1].Owner=VOID_OWNER;
}

DWORD UnkInstr(BYTE*)  //Неизвестная инструкция
{
  return STOP_UNKNOWN_INSTRUCTION;
}

DWORD Mov4(BYTE *pCOP)  //Mov Reg,data
{
  BYTE COP=*pCOP;
  WORD wData=*(WORD*)((BYTE*)pCOP+1);
  SetRegister(COP&7,(COP&8)>>3,wData);
  return AddIP(COP&8 ? 3 : 2);
}

DWORD JCond(BYTE *pCOP)  //Условные переходы
{
  BYTE Jump;
  signed char Offs;
  switch(*pCOP) {
    case 0x70 :
    case 0x71 : Jump=Data.Reg.Flag.OF; break;
    case 0x72 :
    case 0x73 : Jump=Data.Reg.Flag.CF; break;
    case 0x74 :
    case 0x75 : Jump=Data.Reg.Flag.ZF; break;
    case 0x76 :
    case 0x77 : Jump=Data.Reg.Flag.CF|Data.Reg.Flag.ZF; break;
    case 0x78 :
    case 0x79 : Jump=Data.Reg.Flag.SF; break;
    case 0x7A :
    case 0x7B : Jump=Data.Reg.Flag.PF; break;
    case 0x7C :
    case 0x7D : Jump=Data.Reg.Flag.OF^Data.Reg.Flag.SF; break;
    case 0x7E :
    case 0x7F : Jump=(Data.Reg.Flag.OF^Data.Reg.Flag.SF)|Data.Reg.Flag.ZF; break;
    case 0xE3 : Jump=Data.Reg.CX!=0; break;
  }
  if(*pCOP&1) Jump=!Jump;
  Offs=Jump ? *(pCOP+1) : 0;
  return AddIP((BYTE)2+Offs);
}

DWORD Lea(BYTE *pCOP) {
	BYTE COP2 = *(pCOP + 1);
	WORD Addr = *(pCOP + 2);
	SetRegister(COP2 >> 3, 1, (WORD)Addr);

	return AddIP(4);
}

DWORD Mov1(BYTE *pCOP)  //Различные операции пересылки
{
  BYTE COP1=*pCOP,COP2=*(pCOP+1);
  BYTE W=COP1&1;
  void *Addr;
  DWORD Size=GetDecodedAddress(pCOP+1,W,&Addr)+1;
  WORD wData;
  switch(COP1) {
    //Mov r/m,r8
    case 0x88 : WriteRealMem(Addr,GetRegister(COP2>>3,0),0); break;
    //Mov r/m,r16
    case 0x89 : WriteRealMem(Addr,GetRegister(COP2>>3,1),1); break;
    //Mov r8,r/m
    case 0x8A : ReadRealMem(Addr,&wData,0); SetRegister(COP2>>3,0,wData); break;
    //Mov r16,r/m
    case 0x8B : ReadRealMem(Addr,&wData,1); SetRegister(COP2>>3,1,wData); break;
    //Mov r/m,seg
    case 0x8C : WriteRealMem(Addr,GetSegRegister(COP2>>3),1); break;
    //Mov seg,r/m
    case 0x8E : ReadRealMem(Addr,&wData,1); SetSegRegister(COP2>>3,wData); break;
    //Mov mem,data8
    case 0xC6 : wData=*(pCOP+Size); Size++; WriteRealMem(Addr,wData,0); break;
    //Mov mem,data16
    case 0xC7 : wData=*(WORD*)(pCOP+Size); Size+=2; WriteRealMem(Addr,wData,1); break;
  }
  return AddIP(Size);
}

DWORD AcOp(BYTE *pCOP)  //Mov Ac,Mem  Mov Mem,Ac  Movs
{
  BYTE COP1=*pCOP;
  BYTE W=COP1&1;
  WORD wData=*(WORD*)(pCOP+1);
  WORD Temp;
  BOOL AddSI,AddDI;
  switch(COP1>>1) {
    //Mov Ac,Mem
    case 0x50 : ReadVirtMem(CurSeg,wData,&Temp,W); SetRegister(0,W,Temp); return AddIP(3);
    //Mov Mem,Ac
    case 0x51 : WriteVirtMem(CurSeg,wData,Data.Reg.AX,W); return AddIP(3);
    //Movs
    case 0x52 : ReadVirtMem(Data.Reg.DS,Data.Reg.SI,&Temp,W);
                WriteVirtMem(Data.Reg.ES,Data.Reg.DI,Temp,W);
                AddSI=TRUE; AddDI=TRUE; break;
  }
  int Inc=Data.Reg.Flag.DF ? 1 : -1;
  Inc*=W+1;
  if(AddSI) Data.Reg.SI+=Inc;
  if(AddDI) Data.Reg.DI+=Inc;
  Data.Reg.CX-=W+1;
  return AddIP(1);
}

DWORD ALOp(BYTE *pCOP)  //Арифметико-логические операции
{
  BYTE COP1=*pCOP,COP2=*(pCOP+1);
  BYTE W=COP1&1;
  WORD wData=*(WORD*)(pCOP+1);
  void *Addr;
  DWORD Size=GetDecodedAddress(pCOP+1,W,&Addr)+1;
  char Op;
  switch(COP1&0xF8) {  //Выбор типа операции
    case 0x08 : Op='|'; break;  //Or
    case 0x00 : Op='+'; break;  //Add
    case 0x10 : Op='#'; break;  //Adc
    case 0x18 : Op='_'; break;  //Sbb
    case 0x20 : Op='&'; break;  //And
    case 0x28 : Op='-'; break;  //Sub
    case 0x30 : Op='^'; break;  //Xor
    case 0x38 : Op='?'; break;  //Cmp
  }
  switch((COP1>>1)&3) {  //Выбор типа операндов
    //Op rm,r
    case 0 : WriteRealMem(Addr,(WORD)Calculate(Op,*(WORD*)Addr,GetRegister(COP2>>3,W),
               W,0xFFFF),W);
             break;
    //Op r,rm
    case 1 : SetRegister(COP2>>3,W,(WORD)Calculate(Op,GetRegister(COP2>>3,W),
               *(WORD*)Addr,W,0xFFFF));
             break;
    //Op Ac,Data
    case 2 : SetRegister(0,W,(WORD)Calculate(Op,GetRegister(0,W),wData,W,0xFFFF));
             Size=W+2;
             break;
  }
  return AddIP(Size);
}

DWORD OutBytePort(WORD Port,BYTE Value)
//Выводит байт Value в порт с адресом Port
{
  ::SendMessage(pHData->hHostWnd,WMU_WRITEPORT,Port,Value);
  return 0;
}

DWORD InBytePort(WORD Port,BYTE *pValue)
//Читает в *Value содержимое порта Port
{
  *pValue=(BYTE)::SendMessage(pHData->hHostWnd,WMU_READPORT,Port,0);
  return 0;
}

DWORD IO(BYTE *pCOP)  //In, Out
{
  WORD PortNumber;
  DWORD PortData;
  DWORD Size=2;
  //Определение адреса порта
  if(*pCOP&8) { PortNumber=Data.Reg.DX; Size=1; }
  else PortNumber=*(pCOP+1);
  DWORD Status;
  if(*pCOP&2) {  //Out
    Status=OutBytePort(PortNumber,(BYTE)Data.Reg.AX);
    if(*pCOP&1) Status|=OutBytePort(PortNumber+1,Data.Reg.AX>>8);
  }else {  //In
    Status=InBytePort(PortNumber,(BYTE*)&PortData);
    if(*pCOP&1) Status|=InBytePort(PortNumber+1,1+(BYTE*)&PortData);
    SetRegister(0,*pCOP&1,(BYTE)PortData);
  }
  if(Status) return Status;
  return AddIP(Size);
}

DWORD Push(BYTE *pCOP)
{
  WORD *pSource,Source;
  DWORD Size=1;
  switch(*pCOP&0xC0) {
    //Push sr
    case 0x00 : Source=GetSegRegister((*pCOP>>3)&7); break;
    //Push r16
    case 0x40 : Source=GetRegister(*pCOP&7,1); break;
    //Pushf
    case 0x80 : Source=*(WORD*)&Data.Reg.Flag; break;
    //Push r/m
    case 0xC0 :
      Size=GetDecodedAddress(pCOP+1,1,(void**)&pSource)+1;
      ReadRealMem((void*)pSource,&Source,1);
      break;
  }
  WriteVirtMem(Data.Reg.SS,Data.Reg.SP-2,Source,1);
  Data.Reg.SP-=2;
  return AddIP(Size);
}

DWORD Pop(BYTE *pCOP)
{
  WORD *pDest,Value;
  ReadVirtMem(Data.Reg.SS,Data.Reg.SP,&Value,1);
  Data.Reg.SP+=2;
  DWORD Size=1;
  switch(*pCOP&0xF0) {
    //Pop r/m
    case 0x80 :
      Size=GetDecodedAddress(pCOP+1,1,(void**)&pDest)+1;
      WriteRealMem((void*)pDest,Value,1);
      break;
    //Pop r16
    case 0x50 : SetRegister(*pCOP&7,1,Value); break;
    //Pop sr
    case 0x00 :
    case 0x10 : SetSegRegister(*pCOP>>3,Value); break;
    //Popf
    case 0x90 : *(WORD*)&Data.Reg.Flag=Value; break;
  }
  return AddIP(Size);
}

DWORD Inc(BYTE *pCOP)
{
  DWORD Size=1;
  WORD *Addr,Value;
  BYTE W=*pCOP&1;
  if(*pCOP&0x80) {  //Inc r/m
    Size+=GetDecodedAddress(pCOP+1,W,(void**)&Addr);
    ReadRealMem(Addr,&Value,W);
    WriteRealMem(Addr,(WORD)Calculate('+',Value,1,W,0xFFFE),W);
  }else {  //Inc r16
    Value=GetRegister(*pCOP&7,1);
    SetRegister(*pCOP&7,1,(WORD)Calculate('+',Value,1,1,0xFFFE));
  }
  return AddIP(Size);
}

DWORD Dec(BYTE *pCOP)
{
  DWORD Size=1;
  WORD *Addr,Value;
  BYTE W=*pCOP&1;
  if(*pCOP&0x80) {  //Dec r/m
    Size+=GetDecodedAddress(pCOP+1,W,(void**)&Addr);
    ReadRealMem(Addr,&Value,W);
    WriteRealMem(Addr,(WORD)Calculate('-',Value,1,W,0xFFFE),W);
  }else {  //Dec r16
    Value=GetRegister(*pCOP&7,1);
    SetRegister(*pCOP&7,1,(WORD)Calculate('-',Value,1,1,0xFFFE));
  }
  return AddIP(Size);
}

DWORD Xchg(BYTE *pCOP)
{
  WORD Temp,*Addr;
  DWORD Size=1;
  BYTE Reg;
  if(*pCOP&0x10) {  //Xchg AX,r16
    Temp=Data.Reg.AX;
    Data.Reg.AX=GetRegister(*pCOP&7,1);
    SetRegister(*pCOP&7,1,Temp);
  }else {  //Xchg r,r/m
    Reg=((*(pCOP+1))>>3)&7;
    Size+=GetDecodedAddress(pCOP+1,*pCOP&1,(void**)&Addr);
    Temp=GetRegister(Reg,*pCOP&1);
    SetRegister(Reg,*pCOP&1,*Addr);
    WriteRealMem((void*)Addr,Temp,*pCOP&1);
  }
  return AddIP(Size);
}

DWORD ArOp(BYTE *pCOP)  //Ар.-лог. операции с непоср. данными
{
  DWORD Size=1;
  WORD *pDest,Source,Dest;
  char Op;
  BYTE SW=*pCOP&1;
  Size+=GetDecodedAddress(pCOP+1,SW,(void**)&pDest);
  if(*pCOP&2) SW=0;
  Source=*(pCOP+Size);
  if(SW) Source=*(WORD*)(pCOP+Size);
  if(*pCOP&2) Source=(WORD)(signed char)Source; //Расширение знака
  Size+=SW+1;
  switch((*(pCOP+1))&0x38) {
    case 0x00 : Op='+'; break;  //Add
    case 0x08 : Op='|'; break;  //Or
    case 0x10 : Op='#'; break;  //Adc
    case 0x18 : Op='_'; break;  //Sbb
    case 0x20 : Op='&'; break;  //And
    case 0x28 : Op='-'; break;  //Sub
    case 0x30 : Op='^'; break;  //Xor
    case 0x38 : Op='?'; break;  //Cmp
  }
  Dest=(WORD)Calculate(Op,*pDest,Source,*pCOP&1,0xFFFF);
  WriteRealMem(pDest,Dest,*pCOP&1);
  return AddIP(Size);
}

DWORD Lxs(BYTE *pCOP)  //Les, Lds
{
  WORD *pSeg=&Data.Reg.ES;
  WORD *pSrc;
  DWORD Size=1;
  if(*pCOP&1) pSeg=&Data.Reg.DS;
  Size+=GetDecodedAddress(pCOP+1,1,(void**)&pSrc);
  SetRegister(((*(pCOP+1))>>3)&7,1,*pSrc);
  *pSeg=*(pSrc+1);
  return AddIP(Size);
}

DWORD Shift(BYTE *pCOP)  //Сдвиги
{
  BYTE Count=1;
  WORD *pSrc,Src;
  DWORD Size=GetDecodedAddress(pCOP+1,*pCOP&1,(void**)&pSrc)+1;
  Src=*pSrc;
  DWORD Flags,OrigFlags=*(WORD*)&Data.Reg.Flag;
  _asm {
    pushfd
    pop eax
    and eax,0xFFFFF72A  //Reset Arith. Flags
    mov edx,OrigFlags
    and edx,0x000008D5  //Reset Ctrl. Flags
    or eax,edx
    mov Flags,eax       //Flags = флаги для эмулирующей машины
  }
  if(*pCOP&2) Count=(BYTE)Data.Reg.CX;
  if(*pCOP&1) {
    switch(*(pCOP+1)&0x38) {
      //Общая схема: установить флаги из Flags
      //Выполнить сдвиг Src cl раз
      //Скопировать флаги в Flags
      case 0x00 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rol Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x08 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          ror Word Ptr Src,cl
          pushfd
          pop Flags
      } break;
      case 0x10 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcl Word Ptr Src,cl
          pushfd
          pop Flags
      } break;
      case 0x18 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcr Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x20 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shl Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x28 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shr Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x30 : return STOP_UNKNOWN_INSTRUCTION;
      case 0x38 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          sar Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
    }
  }else {
    switch(*(pCOP+1)&0x38) {
      case 0x00 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rol Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x08 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          ror Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x10 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcl Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x18 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcr Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x20 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shl Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x28 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shr Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x30 : return STOP_UNKNOWN_INSTRUCTION;
      case 0x38 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          sar Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
    }
  }
  WriteRealMem((void*)pSrc,Src,*pCOP&1);
  Flags&=0x000008D5;      //Reset Ctrl. Flags
  OrigFlags&=0xFFFFF72A;  //Reset Arith. Flags
  OrigFlags|=Flags;
  *(WORD*)&Data.Reg.Flag=(WORD)OrigFlags;  //Установить новые флаги
  return AddIP(Size);
}

DWORD SegXS(BYTE* pCOP)  //Префикс замены сегмента
{
  CurSeg=GetSegRegister(*pCOP>>3);
  SegChanged=TRUE;
  Data.Reg.IP++;
  //Определяем адрес следующей инструкции
  BYTE* pNewCOP=(BYTE*)VirtToReal(Data.Reg.CS,Data.Reg.IP);
  //Инкремент числа выполненных инструкций
  Data.Takts++;
  //и выполнение следующей инструкции
  DWORD Res=INVALID_ADDRESS;
  if(pNewCOP) Res=FirstByte[*pNewCOP](pNewCOP);
  CurSeg=Data.Reg.DS;
  SegChanged=FALSE;

  return Res;
}

DWORD Jmp1(BYTE *pCOP)  //Безусловные переходы по адресу в инструкции
{
  short Diff;
  switch(*pCOP&3) {
    //Jmp Near
    case 1 : Diff=*(short*)(pCOP+1)+3; break;
    //Jmp Far
    case 2 :
      Diff=0;
      Data.Reg.IP=*(WORD*)(pCOP+1);
      Data.Reg.CS=*(WORD*)(pCOP+3);
      break;
    //Jmp Short
    case 3 : Diff=*(signed char*)(pCOP+1)+2; break;
  }
  Data.Reg.IP+=Diff;
  return AddIP(0);
}

DWORD Jmp2(BYTE *pCOP)  //Безусловные переходы по адресу в ОЗУ
{
  WORD *Addr,Value;
  GetDecodedAddress(pCOP+1,1,(void**)&Addr);
  switch(*(pCOP+1)&0x38) {
    //Jmp Near
    case 0x20 :
      ReadRealMem(Addr,&Value,1);
      Data.Reg.IP=*(short*)&Value;
      break;
    //Jmp Far
    case 0x28 :
      ReadRealMem(Addr,&Value,1);
      Data.Reg.IP=Value;
      ReadRealMem(Addr+2,&Value,1);
      Data.Reg.CS=Value;
      break;
  }
  return AddIP(0);
}

DWORD Test(BYTE *pCOP)
{
  DWORD Size=1;
  WORD Value,*pValue;
  BYTE W=*pCOP&1;
  BYTE Reg=*(pCOP+1)>>3;
  switch((*pCOP>>1)&3) {
    //Test Ac,Data
    case 0 :
      Value=*(WORD*)(pCOP+1);
      Calculate('@',GetRegister(0,W),Value,W,0xFFFF);
      Size=W+2;
      break;
    //Test r,r/m
    case 2 :
      Size+=GetDecodedAddress(pCOP+1,W,(void**)&pValue);
      Calculate('@',GetRegister(Reg,W),*pValue,W,0xFFFF);
      break;
    //Test r/m,data
    case 3 :
      Size+=GetDecodedAddress(pCOP+1,W,(void**)&pValue);
      ReadRealMem(pValue,&Value,W);
      pValue=(WORD*)(pCOP+Size);
      Calculate('@',Value,*pValue,W,0xFFFF);
      Size+=W+1; break;
  }
  return AddIP(Size);
}

DWORD Call1(BYTE *pCOP) //Call sbr
{
  DWORD Diff=*(WORD*)(BYTE*)(pCOP+1);
  Data.Reg.SP-=2;
  if(*pCOP&64) {  //Call Near
    //Запоминаем адрес возврата в стеке
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+3,1);
    return AddIP(Diff+3);
  }
  //Call Far
  //Запоминаем адрес возврата в стеке
  WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.CS,1);
  Data.Reg.SP-=2;
  WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+5,1);
  Data.Reg.CS=*(WORD*)(BYTE*)(pCOP+3);
  Data.Reg.IP=(WORD)Diff;
  return AddIP(0);
}

DWORD Call2(BYTE *pCOP) //Call rm16
{
  WORD *Addr,Value;
  DWORD Size=1+GetDecodedAddress(pCOP+1,1,(void**)&Addr);
  Data.Reg.SP-=2;
  if(*(pCOP+1)&8) { //Call Far
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.CS,1);
    Data.Reg.SP-=2;
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+(WORD)Size,1);

    ReadRealMem(Addr,&Value,1);
    Data.Reg.IP=Value;
    ReadRealMem(Addr+1,&Value,1);
    Data.Reg.CS=Value;
  }else {
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+(WORD)Size,1);
    ReadRealMem(Addr,&Value,1);
    Data.Reg.IP=*(short*)&Value;
  }
  return AddIP(0);
  /*WORD *Addr,Disp;
  DWORD Size=1+GetDecodedAddress(pCOP+1,1,(void**)&Addr);
  Data.Reg.SP-=2; ReadRealMem(Addr,&Disp,1);
  if(*(pCOP+1)&8) {  //Call Far
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.CS,1);
    Data.Reg.SP-=2;
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+(WORD)Size,1);
    Data.Reg.IP=Disp; ReadRealMem(Addr+1,&Data.Reg.CS,1);
  }else {  //Call Near
    WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.IP+(WORD)Size,1);
    Data.Reg.IP+=Disp;
  }
  return AddIP(0);*/
}

DWORD Ret(BYTE *pCOP)
{
  WORD Stk1,Stk2; ReadVirtMem(Data.Reg.SS,Data.Reg.SP,&Stk1,1);
  //Восстанавливаем IP и SP
  Data.Reg.SP+=2; Data.Reg.IP=Stk1;
  switch(*pCOP) {
    //Ret (Near)
    case 0xC3 : break;
    //Ret d (Near)
    case 0xC2 : Data.Reg.SP+=*(WORD*)(pCOP+1); break;
    //Ret (Far)
    case 0xCB :
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP,&Stk2,1);
      Data.Reg.SP+=2; Data.Reg.CS=Stk2;
      break;
    //Ret d (Far)
    case 0xCA :
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP,&Stk2,1);
      Data.Reg.SP+=2; Data.Reg.CS=Stk2;
      Data.Reg.SP+=*(WORD*)(pCOP+1); break;
    //Iret
    case 0xCF :
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP,&Data.Reg.CS,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+2,(WORD*)&Data.Reg.Flag,1);
      Data.Reg.SP+=4;
      break;
  }
  return AddIP(0);
}

DWORD Loop(BYTE *pCOP)  //Loop,LoopZ,LoopNZ
{
  DWORD Disp=(signed char)(2+*(signed char*)(pCOP+1));
  Data.Reg.CX--;
  if(Data.Reg.CX==0) return AddIP(2);
  switch(*pCOP) {
  //Loop
  case 0xE2 : return AddIP(Disp);
  //LoopZ
  case 0xE1 : if(Data.Reg.Flag.ZF) return AddIP(2); else return AddIP(Disp);
  //LoopNZ
  case 0xE0 : if(Data.Reg.Flag.ZF) return AddIP(Disp); else return AddIP(2);
  }
  return(STOP_UNKNOWN_INSTRUCTION);
}

DWORD Flags(BYTE *pCOP)  //Операции установки флагов
{
  switch(*pCOP) {
  //CMC
  case 0xF5 : Data.Reg.Flag.CF=~Data.Reg.Flag.CF; break;
  //CLC
  case 0xF8 : Data.Reg.Flag.CF=0; break;
  //STC
  case 0xF9 : Data.Reg.Flag.CF=1; break;
  //CLI
  case 0xFA : Data.Reg.Flag.IF=0; break;
  //STI
  case 0xFB : Data.Reg.Flag.IF=1; break;
  //CLD
  case 0xFC : Data.Reg.Flag.DF=0; break;
  //STD
  case 0xFD : Data.Reg.Flag.DF=1; break;
  }
  return AddIP(1);
}

DWORD Xlat(BYTE *pCOP)
{
  WORD Val;
  ReadVirtMem(Data.Reg.DS,Data.Reg.BX+(Data.Reg.AX&0x00FF),&Val,0);
  SetRegister(0,0,Val);
  return AddIP(1);
}

DWORD DivMul(BYTE *pCOP)
{
  BYTE W=*pCOP&1;
  WORD *Addr;
  DWORD Size=1+GetDecodedAddress(pCOP+1,W,(void**)&Addr);
  DWORD Op1=Data.Reg.AX;
  if(W) Op1|=((DWORD)Data.Reg.DX)<<16;
  WORD Op2;
  ReadRealMem(Addr,&Op2,W);
  char Op;
  switch((*(pCOP+1)>>3)&7) {
  case 0x04 : Op='*'; Op1&=0x0000FFFF; break;  //Mul
  case 0x05 : Op='x'; Op1&=0x0000FFFF; break;  //IMul
  case 0x06 : Op='/'; break;                   //Div
  case 0x07 : Op='\\'; break;                  //IDiv
  }
  DWORD Res;
  __try {  //Ловим переполнение при делении
    Res=Calculate(Op,Op1,Op2,W,0xFFFF);
  }__except(GetExceptionCode()&(EXCEPTION_INT_DIVIDE_BY_ZERO|EXCEPTION_INT_OVERFLOW) ?
            EXCEPTION_EXECUTE_HANDLER : EXCEPTION_CONTINUE_SEARCH) {
    //Поймали, вызываем Int 0
    WORD* pStk=(WORD*)VirtToReal(Data.Reg.SS,Data.Reg.SP);
    WriteRealMem(pStk-1,*(WORD*)&Data.Reg.Flag,1);
    WriteRealMem(pStk-2,Data.Reg.CS,1);
    WriteRealMem(pStk-3,Data.Reg.IP,1);
    Data.Reg.Flag.IF=0; Data.Reg.Flag.TF=0; Data.Reg.SP-=6;
    ReadVirtMem(0,0,&Data.Reg.IP,1);
    ReadVirtMem(0,2,&Data.Reg.CS,1);
    return AddIP(0);
  }
  Data.Reg.AX=(WORD)Res;
  if(W) Data.Reg.DX=(WORD)(Res>>16);
  return AddIP(Size);
}

DWORD Int(BYTE *pCOP)
{
  BYTE Type,Size=1;
  switch(*pCOP&3) {
    //Int3
    case 0 : Type=3; break;
    //Int type
    case 1 : Type=*(pCOP+1); Size=2; break;
    //IntO
    case 2 :
      if(Data.Reg.Flag.OF) { Type=4; break; }
      else return AddIP(1);
  }
  WORD* pStk=(WORD*)VirtToReal(Data.Reg.SS,Data.Reg.SP);
  WriteRealMem(pStk-1,*(WORD*)&Data.Reg.Flag,1);
  WriteRealMem(pStk-2,Data.Reg.CS,1);
  WriteRealMem(pStk-3,Data.Reg.IP+Size,1);
  Data.Reg.Flag.IF=0; Data.Reg.Flag.TF=0; Data.Reg.SP-=6;
  ReadVirtMem(0,Type*4,&Data.Reg.IP,1);
  ReadVirtMem(0,Type*4+2,&Data.Reg.CS,1);
  return AddIP(0);
}

DWORD Corr(BYTE *pCOP)  //Команды различных коррекций
{
  WORD rAX=Data.Reg.AX;
  DWORD Size=1,Flags,OrigFlags=*(WORD*)&Data.Reg.Flag;
  _asm {
    pushfd
    pop eax
    and eax,0xFFFFF72A  //Reset Arith. Flags
    mov edx,OrigFlags
    and edx,0x000008D5  //Reset Ctrl. Flags
    or eax,edx
    mov Flags,eax       //Flags = флаги для эмулирующей машины
  }
  switch(*pCOP) {
    //Общая схема: установить флаги из Flags
    //Выполнить коррекцию
    //Скопировать флаги в Flags
    case 0x27 :  
      _asm {
        push Flags
        popfd
        mov ax,rAX
        daa
        mov rAX,ax
        pushfd
        pop Flags
      } break;
    case 0x37 :
      _asm {
        push Flags
        popfd
        mov ax,rAX
        aaa
        mov rAX,ax
        pushfd
        pop Flags
      } break;
    case 0x2F :
      _asm {
        push Flags
        popfd
        mov ax,rAX
        das
        mov rAX,ax
        pushfd
        pop Flags
      } break;
    case 0x3F :
      _asm {
        push Flags
        popfd
        mov ax,rAX
        aas
        mov rAX,ax
        pushfd
        pop Flags
      } break;
    case 0xD4 :
      if(*(pCOP+1)!=10) return UnkInstr(pCOP);
      Size=2;
      _asm {
        push Flags
        popfd
        mov ax,rAX
        aam
        mov rAX,ax
        pushfd
        pop Flags
      } break;
    case 0xD5 :
      if(*(pCOP+1)!=10) return UnkInstr(pCOP);
      Size=2;
      _asm {
        push Flags
        popfd
        mov ax,rAX
        aad
        mov rAX,ax
        pushfd
        pop Flags
      } break;
  }
  Data.Reg.AX=rAX;
  Flags&=0x000008D5;      //Reset Ctrl. Flags
  OrigFlags&=0xFFFFF72A;  //Reset Arith. Flags
  OrigFlags|=Flags;
  *(WORD*)&Data.Reg.Flag=(WORD)OrigFlags;
  return AddIP(Size);
}

DWORD Expand(BYTE *pCOP)  //Команды расширения знака
{
  switch(*pCOP) {
    case 0x98 :  //CBW
      Data.Reg.AX&=0x00FF;
      if(Data.Reg.AX&0x80) Data.Reg.AX|=0xFF00; 
      break;
    case 0x99 :  //CWD
      Data.Reg.DX=0;
      if(Data.Reg.AX&0x8000) Data.Reg.DX=0xFFFF;
      break;
  }
  return AddIP(1);
}

DWORD Void(BYTE *pCOP)  //Неисполняемые инструкции
{
  switch(*pCOP) {
    case 0x9B : return AddIP(1);  //Wait
    case 0xF0 : return AddIP(1);  //Lock
  }
  return STOP_UNKNOWN_INSTRUCTION;
}

DWORD Halt(BYTE *pCOP) //!!!!!!!!!!!!!!!!!!!!!!!!
{
  return AddIP(0);
}

DWORD String(BYTE *pCOP)  //Строковые операции
{
  BYTE W=*pCOP&1;
  WORD Op1,Op2;
  BOOL ChangeSI=TRUE,ChangeDI=TRUE;
  switch(*pCOP&0xFE) {
  case 0xA4 : //MOVS
    ReadVirtMem(Data.Reg.DS,Data.Reg.SI,&Op1,W);
    WriteVirtMem(Data.Reg.ES,Data.Reg.DI,Op1,W);
    break;
  case 0xA6 : //CMPS
    ReadVirtMem(Data.Reg.DS,Data.Reg.SI,&Op1,W);
    ReadVirtMem(Data.Reg.ES,Data.Reg.DI,&Op2,W);
    Calculate('?',Op1,Op2,W,0xFFFF);
    break;
  case 0xAA : //STOS
    WriteVirtMem(Data.Reg.ES,Data.Reg.DI,Data.Reg.AX,W);
    ChangeSI=FALSE; break;
  case 0xAC : //LODS
    ReadVirtMem(Data.Reg.DS,Data.Reg.SI,&Data.Reg.AX,W);
    ChangeDI=FALSE; break;
  case 0xAE : //SCAS
    ReadVirtMem(Data.Reg.ES,Data.Reg.DI,&Op2,W);
    Calculate('?',Data.Reg.AX,Op2,W,0xFFFF);
    ChangeSI=FALSE;
    break;
  case 0x6C : //INS
    InBytePort(Data.Reg.DX,(BYTE*)&Op1);
    if(W) InBytePort(Data.Reg.DX+1,(BYTE*)&Op1+1);
    WriteVirtMem(Data.Reg.ES,Data.Reg.DI,Op1,W);
    break;
  case 0x6E : //OUTS
    ReadVirtMem(Data.Reg.DS,Data.Reg.SI,&Op1,W);
    OutBytePort(Data.Reg.DX,Op1&0xFF);
    if(W) OutBytePort(Data.Reg.DX+1,Op1>>8);
    break;
  }
  int Increment=Data.Reg.Flag.DF ? -(W+1) : W+1;
  if(ChangeSI) Data.Reg.SI+=Increment;
  if(ChangeDI) Data.Reg.DI+=Increment;
  return AddIP(1);
}

DWORD AcFl(BYTE *pCOP)
{
  switch(*pCOP) {
  case 0x9E : //SAHF
    *(BYTE*)&Data.Reg.Flag=*(BYTE*)&Data.Reg.AX;
    break;
  case 0x9F : //LAHF
    *(BYTE*)&Data.Reg.AX=*(BYTE*)&Data.Reg.Flag;
    break;
  }
  return AddIP(1);
}

DWORD Rep1(BYTE *pCOP)  //REPNE REPNZ
{
  switch(*(pCOP+1)&0xFE) {
  case 0xA6 : //REPNE CMPS
  case 0xAE : //REPNE SCAS
    FirstByte[*(pCOP+1)](pCOP+1);
    Data.Reg.CX--;
    if((Data.Reg.Flag.ZF==0)||(Data.Reg.CX==0)) return AddIP(1);
    break;
  default   : return STOP_UNKNOWN_INSTRUCTION;
  }
  return AddIP(-1);
}

DWORD Rep2(BYTE *pCOP)  //REP REPE PEPZ
{
  switch(*(pCOP+1)&0xFE) {
  case 0xA4 : //REP MOVS
  case 0xAA : //REP STOS
    FirstByte[*(pCOP+1)](pCOP+1);
    Data.Reg.CX--;
    if(Data.Reg.CX==0) return AddIP(1);
    break;
  case 0xA6 : //REPZ CMPS
  case 0xAE : //REPZ SCAS
    FirstByte[*(pCOP+1)](pCOP+1);
    Data.Reg.CX--;
    if((Data.Reg.Flag.ZF==1)||(Data.Reg.CX==0)) return AddIP(1);
    break;
  case 0x6C : //REP INS
  case 0x6E : //REP OUTS
    FirstByte[*(pCOP+1)](pCOP+1);
    Data.Reg.CX--;
    if(Data.Reg.CX==0) return AddIP(1);
    break;
  default   : return STOP_UNKNOWN_INSTRUCTION;
  }
  return AddIP(-1);
}

DWORD Neg(BYTE *pCOP)
{
  BYTE W=*pCOP&1;
  WORD *Addr;
  DWORD Size=1+GetDecodedAddress(pCOP+1,W,(void**)&Addr);
  WORD Op1=0,Op2=*Addr;
  WORD Res=(WORD)Calculate('-',Op1,Op2,W,0xFFFF);
  WriteRealMem((void*)Addr,Res,W);
  return AddIP(Size);
}

DWORD Not(BYTE *pCOP)
{
  BYTE W=*pCOP&1;
  WORD *Addr;
  DWORD Size=1+GetDecodedAddress(pCOP+1,W,(void**)&Addr);
  WORD Op1=0xFFFF,Op2=*Addr;
  WORD Res=(WORD)Calculate('^',Op1,Op2,W,0xFFFF);
  WriteRealMem((void*)Addr,Res,W);
  return AddIP(Size);
}

DWORD Grp(BYTE *pCOP)  //Группа инструкций с кодом 0FEh и 0FFh
{
  BYTE W=*pCOP&1;
  switch((*(pCOP+1)>>3)&7) {
    case 0x00 : return Inc(pCOP);
    case 0x01 : return Dec(pCOP);
    case 0x02 : return W ? Call2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
    case 0x03 : return W ? Call2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
    case 0x04 : return W ? Jmp2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
    case 0x05 : return W ? Jmp2(pCOP) : STOP_UNKNOWN_INSTRUCTION;
    case 0x06 : return W ? Push(pCOP) : STOP_UNKNOWN_INSTRUCTION;
  }
  return STOP_UNKNOWN_INSTRUCTION;
}

DWORD Grp2(BYTE *pCOP)  //Группа инструкций с кодом 0F6h и 0F7h
{
  switch((*(pCOP+1)>>3)&7) {
    case 0x00 : return Test(pCOP);
    case 0x02 : return Not(pCOP);
    case 0x03 : return Neg(pCOP);
    case 0x04 :
    case 0x05 :
    case 0x06 :
    case 0x07 : return DivMul(pCOP);
  }
  return STOP_UNKNOWN_INSTRUCTION;
}

DWORD Stack286(BYTE *pCOP)
{
  DWORD Size=1;
  switch(*pCOP) {
    //Pusha
    case 0x60 :
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-2 ,Data.Reg.AX,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-4 ,Data.Reg.CX,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-6 ,Data.Reg.DX,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-8 ,Data.Reg.BX,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-10,Data.Reg.SP,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-12,Data.Reg.BP,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-14,Data.Reg.SI,1);
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-16,Data.Reg.DI,1);
      Data.Reg.SP-=16;
      break;
    //Popa
    case 0x61 :
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+0 ,&Data.Reg.DI,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+2 ,&Data.Reg.SI,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+4 ,&Data.Reg.BP,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+8 ,&Data.Reg.BX,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+10,&Data.Reg.DX,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+12,&Data.Reg.CX,1);
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP+14,&Data.Reg.AX,1);

      Data.Reg.SP+=16;
      break;
    //Push Data16
    case 0x68 :
      WriteVirtMem(Data.Reg.SS,Data.Reg.SP-2 ,*(WORD*)(pCOP+1),1);
      Data.Reg.SP-=2;
      Size=3;
      break;
    //Push Data8
    case 0x6A :
      {
        WORD Op=(WORD)(signed char)*(pCOP+1);
        WriteVirtMem(Data.Reg.SS,Data.Reg.SP-2 ,Op,1);
        Data.Reg.SP-=2;
        Size=2;
        break;
      }
    //Enter
    case 0xC8 :
      {
        WORD FrameSize=*(WORD*)(pCOP+1);
        BYTE Level=*(pCOP+3)%32;

        //Push bp
        Data.Reg.SP-=2;
        WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Data.Reg.BP,1);

        WORD FramePtr=Data.Reg.SP;

        if(Level>0) {
          for(int i=1; i<=Level-1; i++) {
            Data.Reg.BP-=2;

            WORD Value;
            ReadVirtMem(Data.Reg.SS,Data.Reg.BP,&Value,1);
            Data.Reg.SP-=2;
            WriteVirtMem(Data.Reg.SS,Data.Reg.SP,Value,1);
          }
          Data.Reg.SP-=2;
          WriteVirtMem(Data.Reg.SS,Data.Reg.SP,FramePtr,1);
        }
        Data.Reg.BP=FramePtr;
        Data.Reg.SP-=FrameSize;
        Size=4;
        break;
      }
    //Leave
    case 0xC9 :
      Data.Reg.SP=Data.Reg.BP;
      ReadVirtMem(Data.Reg.SS,Data.Reg.SP,&Data.Reg.BP,1);
      Data.Reg.SP+=2;
      break;
  }
  return AddIP(Size);
}

DWORD Bound(BYTE *pCOP)
{
  WORD Index=GetRegister(*(pCOP+1)>>3,1);
  WORD* Bounds;
  DWORD Size=1+GetDecodedAddress(pCOP+1,1,(void**)&Bounds);
  if((Index<Bounds[0])||(Index>Bounds[1])) {
    WORD* pStk=(WORD*)VirtToReal(Data.Reg.SS,Data.Reg.SP);
    WriteRealMem(pStk-1,*(WORD*)&Data.Reg.Flag,1);
    WriteRealMem(pStk-2,Data.Reg.CS,1);
    WriteRealMem(pStk-3,Data.Reg.IP,1);
    Data.Reg.Flag.IF=0; Data.Reg.Flag.TF=0; Data.Reg.SP-=6;
    ReadVirtMem(0,5*4,&Data.Reg.IP,1);
    ReadVirtMem(0,5*4+2,&Data.Reg.CS,1);
    return AddIP(0);
  }

  return AddIP(Size);
}

DWORD Shift286(BYTE *pCOP)  //Сдвиги
{
  WORD *pSrc,Src;
  DWORD Size=2+GetDecodedAddress(pCOP+1,*pCOP&1,(void**)&pSrc);
  Src=*pSrc;
  DWORD Flags,OrigFlags=*(WORD*)&Data.Reg.Flag;
  _asm {
    pushfd
    pop eax
    and eax,0xFFFFF72A  //Reset Arith. Flags
    mov edx,OrigFlags
    and edx,0x000008D5  //Reset Ctrl. Flags
    or eax,edx
    mov Flags,eax       //Flags = флаги для эмулирующей машины
  }
  BYTE Count=pCOP[Size-1];
  if(pCOP[0]&1) {
    switch(pCOP[1]&0x38) {
      //Общая схема: установить флаги из Flags
      //Выполнить сдвиг Src cl раз
      //Скопировать флаги в Flags
      case 0x00 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rol Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x08 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          ror Word Ptr Src,cl
          pushfd
          pop Flags
      } break;
      case 0x10 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcl Word Ptr Src,cl
          pushfd
          pop Flags
      } break;
      case 0x18 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcr Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x20 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shl Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x28 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shr Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x30 : return STOP_UNKNOWN_INSTRUCTION;
      case 0x38 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          sar Word Ptr Src,cl
          pushfd
          pop Flags
        } break;
    }
  }else {
    switch(pCOP[1]&0x38) {
      case 0x00 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rol Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x08 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          ror Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x10 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcl Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x18 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          rcr Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x20 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shl Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x28 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          shr Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
      case 0x30 : return STOP_UNKNOWN_INSTRUCTION;
      case 0x38 : 
        _asm {
          push Flags
          popfd
          mov cl,Count
          sar Byte Ptr Src,cl
          pushfd
          pop Flags
        } break;
    }
  }
  WriteRealMem((void*)pSrc,Src,*pCOP&1);
  Flags&=0x000008D5;      //Reset Ctrl. Flags
  OrigFlags&=0xFFFFF72A;  //Reset Arith. Flags
  OrigFlags|=Flags;
  *(WORD*)&Data.Reg.Flag=(WORD)OrigFlags;  //Установить новые флаги
  return AddIP(Size);
}

DWORD Mul286(BYTE *pCOP)
{
  BYTE W=(*pCOP==0x69) ? 1 : 0;
  WORD *Addr;
  DWORD Size=1+GetDecodedAddress(pCOP+1,W,(void**)&Addr);
  WORD Op1=0,Op2;
  ReadRealMem(Addr,&Op1,W);
  if(W) {
    Op2=*(WORD*)(pCOP+Size);
    Size+=2;
  }else {
    Op2=*(pCOP+Size);
    Size++;
  }
  if(*pCOP&2) Op2=(WORD)(signed char)Op2; //Расширение знака

  DWORD Res=Calculate('x',Op1,Op2,1,0xFFFF);

  SetRegister(pCOP[1]>>3,1,(WORD)Res);

  return AddIP(Size);
}

DWORD Setccc(BOOL Set,BYTE *pCOP)
{
  BYTE *pByte;
  DWORD Size=GetDecodedAddress(pCOP+2,0,(void**)&pByte);
  if(Set) WriteRealMem(pByte,1,0);
  else WriteRealMem(pByte,0,0);
  return Size;
}

DWORD SHXD(BYTE *pCOP)
{
  WORD *pOp1,Op1,Op2;
  DWORD Size=GetDecodedAddress(pCOP+2,1,(void**)&pOp1);
  Op1=*pOp1;
  Op2=GetRegister(pCOP[2]>>3,1);

  DWORD Flags,OrigFlags=*(WORD*)&Data.Reg.Flag;
  _asm {
    pushfd
    pop eax
    and eax,0xFFFFF72A  //Reset Arith. Flags
    mov edx,OrigFlags
    and edx,0x000008D5  //Reset Ctrl. Flags
    or eax,edx
    mov Flags,eax       //Flags = флаги для эмулирующей машины
  }
  BYTE Count;
  if(pCOP[1]&1) {
    Count=Data.Reg.CX&0xFF;
  }else {
    Count=pCOP[Size+2];
    Size++;
  }
  if((pCOP[1]==0xA4)||(pCOP[1]==0xA5)) {
    _asm {
      push Flags
      popfd
      mov ax,Op2
      mov cl,Count
      SHLD Op1,ax,cl
      pushfd
      pop Flags
    }
  }else {
    _asm {
      push Flags
      popfd
      mov ax,Op2
      mov cl,Count
      SHRD Op1,ax,cl
      pushfd
      pop Flags
    }
  }
  WriteRealMem((void*)pOp1,Op1,1);
  Flags&=0x000008D5;      //Reset Ctrl. Flags
  OrigFlags&=0xFFFFF72A;  //Reset Arith. Flags
  OrigFlags|=Flags;
  *(WORD*)&Data.Reg.Flag=(WORD)OrigFlags;  //Установить новые флаги

  return Size;
}

DWORD BSX(BYTE *pCOP)
{
  WORD *pSrc,Src;
  DWORD Size=GetDecodedAddress(pCOP+2,1,(void**)&pSrc);
  Src=*pSrc;
  BOOL Found=FALSE,Forward=pCOP[1]==0xBC;
  int Index=Forward ? 0 : 15;
  for(int n=0; n<16; n++) {
    if(Forward) {
      if(Src&1) {
        Found=TRUE;
        break;
      }else {
        Src>>=1;
        Index++;
      }
    }else {
      if(Src&0x8000) {
        Found=TRUE;
        break;
      }else {
        Src<<=1;
        Index--;
      }
    }
  }
  if(Found) SetRegister(pCOP[2]>>3,1,Index);
  else SetRegister(pCOP[2]>>3,1,0);
  Data.Reg.Flag.ZF=!Found;

  return Size;
}

DWORD BTX(BYTE *pCOP)
{
  int Op,BitNumber;
  WORD *pSrc,Src;
  DWORD Size=GetDecodedAddress(pCOP+2,1,(void**)&pSrc);
  Src=*pSrc;

  if(pCOP[1]==0xBA) {
    switch((pCOP[2]>>3)&7) {
    case 4 : Op=0; break;
    case 5 : Op=3; break;
    case 6 : Op=2; break;
    case 7 : Op=1; break;
    }
    BitNumber=pCOP[Size+2];
    Size++;
  }else {
    switch(pCOP[1]) {
    case 0xA3: Op=0; break;
    case 0xAB: Op=3; break;
    case 0xB3: Op=2; break;
    case 0xBB: Op=1; break;
    }
    BitNumber=GetRegister(pCOP[2]>>3,1)&0x0F;
  }
  Data.Reg.Flag.CF=(Src>>BitNumber)&1;
  switch(Op) {
  //BT
  case 0 : break;
  //BTC
  case 1 : Src^=1<<BitNumber; break;
  //BTR
  case 2 : Src&=~(1<<BitNumber); break;
  //BTS
  case 3 : Src|=1<<BitNumber; break;
  }
  WriteRealMem(pSrc,Src,1);

  return Size;
}

DWORD JCond386(BYTE *pCOP)
{
  BYTE Jump;
  signed short Offs;
  switch(*(pCOP+1)) {
    case 0x80 :
    case 0x81 : Jump=Data.Reg.Flag.OF; break;
    case 0x82 :
    case 0x83 : Jump=Data.Reg.Flag.CF; break;
    case 0x84 :
    case 0x85 : Jump=Data.Reg.Flag.ZF; break;
    case 0x86 :
    case 0x87 : Jump=Data.Reg.Flag.CF|Data.Reg.Flag.ZF; break;
    case 0x88 :
    case 0x89 : Jump=Data.Reg.Flag.SF; break;
    case 0x8A :
    case 0x8B : Jump=Data.Reg.Flag.PF; break;
    case 0x8C :
    case 0x8D : Jump=Data.Reg.Flag.OF^Data.Reg.Flag.SF; break;
    case 0x8E :
    case 0x8F : Jump=(Data.Reg.Flag.OF^Data.Reg.Flag.SF)|Data.Reg.Flag.ZF; break;
  }
  if(*(pCOP+1)&1) Jump=!Jump;
  Offs=Jump ? *(signed short*)(pCOP+2) : 0;
  return AddIP(Offs+4);
}

DWORD Ext386(BYTE *pCOP)
{
  if((pCOP[1]&0xF0)==0x80) return JCond386(pCOP);
  DWORD Size=2;
  BOOL Set=FALSE;

  switch(pCOP[1]) {
  //SETccc
  case 0x90: Size+=Setccc(Data.Reg.Flag.OF,pCOP); break;
  case 0x91: Size+=Setccc(!Data.Reg.Flag.OF,pCOP); break;
  case 0x92: Size+=Setccc(Data.Reg.Flag.CF,pCOP); break;
  case 0x93: Size+=Setccc(!Data.Reg.Flag.CF,pCOP); break;
  case 0x94: Size+=Setccc(Data.Reg.Flag.ZF,pCOP); break;
  case 0x95: Size+=Setccc(!Data.Reg.Flag.ZF,pCOP); break;
  case 0x96: Size+=Setccc(Data.Reg.Flag.CF&&Data.Reg.Flag.ZF,pCOP); break;
  case 0x97: Size+=Setccc(!(Data.Reg.Flag.CF&&Data.Reg.Flag.ZF),pCOP); break;
  case 0x98: Size+=Setccc(Data.Reg.Flag.SF,pCOP); break;
  case 0x99: Size+=Setccc(!Data.Reg.Flag.SF,pCOP); break;
  case 0x9A: Size+=Setccc(Data.Reg.Flag.PF,pCOP); break;
  case 0x9B: Size+=Setccc(!Data.Reg.Flag.PF,pCOP); break;
  case 0x9C: Size+=Setccc(Data.Reg.Flag.OF!=Data.Reg.Flag.SF,pCOP); break;
  case 0x9D: Size+=Setccc(Data.Reg.Flag.OF==Data.Reg.Flag.SF,pCOP); break;
  case 0x9E: Size+=Setccc(Data.Reg.Flag.ZF||(Data.Reg.Flag.SF!=Data.Reg.Flag.OF),pCOP); break;
  case 0x9F: Size+=Setccc(!Data.Reg.Flag.ZF&&(Data.Reg.Flag.SF==Data.Reg.Flag.OF),pCOP); break;
  //BT
  case 0xA3: Size+=BTX(pCOP); break;
  //BTS
  case 0xAB: Size+=BTX(pCOP); break;
  //SHLD
  case 0xA4:
  case 0xA5:
  //SHRD
  case 0xAC:
  case 0xAD: Size+=SHXD(pCOP); break;
  //BTR
  case 0xB3: Size+=BTX(pCOP); break;
  //BTX
  case 0xBA: Size+=BTX(pCOP); break;
  //BTC
  case 0xBB: Size+=BTX(pCOP); break;
  //BSF
  case 0xBC:
  //BSR
  case 0xBD: Size+=BSX(pCOP); break;
  default  : return STOP_UNKNOWN_INSTRUCTION;
  }

  return AddIP(Size);
}

DWORD EmulateCurrentInstr()  //Эмулирует исполнение тек. инструкции
{
  CurSeg=Data.Reg.DS;
  //Получаем указатель на инструкцию
  BYTE *pCOP=(BYTE*)VirtToReal(Data.Reg.CS,Data.Reg.IP);
  //Вызываем обработчик КОП
  DWORD Res=INVALID_ADDRESS;
  if(pCOP) {
    Res=FirstByte[*pCOP](pCOP);
    //Инкрементируем число исполненных инструкций
    Data.Takts++;
    if(InstrCounter[0].Owner!=VOID_OWNER) {
      InstrCounter[0].Counter--;
      while((InstrCounter[0].Counter==0)&&(InstrCounter[0].Owner!=VOID_OWNER)) {
        DWORD Owner=InstrCounter[0].Owner;
        RemoveCounter(0);
        ::SendMessage(pHData->hHostWnd,WMU_INSTRCOUNTER_EVENT,0,Owner);
      }
    }
  }
  return Res;
}

//---------------------Exportable Functions-------------------------------------
//Заголовок EXE-файла
struct _ExeHeader {                     // DOS .EXE header
    WORD   e_magic;                     // Magic number
    WORD   e_cblp;                      // Bytes on last page of file
    WORD   e_cp;                        // Pages in file
    WORD   e_crlc;                      // Relocations
    WORD   e_cparhdr;                   // Size of header in paragraphs
    WORD   e_minalloc;                  // Minimum extra paragraphs needed
    WORD   e_maxalloc;                  // Maximum extra paragraphs needed
    WORD   e_ss;                        // Initial (relative) SS value
    WORD   e_sp;                        // Initial SP value
    WORD   e_csum;                      // Checksum
    WORD   e_ip;                        // Initial IP value
    WORD   e_cs;                        // Initial (relative) CS value
    WORD   e_lfarlc;                    // File address of relocation table
    WORD   e_ovno;                      // Overlay number
};

DWORD PASCAL LoadProgram(char *ProgName,WORD Segment,WORD Offset)
//Загружает программу с именем ProgName по адресу Segment:Offset
{
  struct _ExeHeader Header;
  void* Address=VirtToReal(Segment,Offset);  //Адрес загрузки

  //Чистим ПЗУ
  for(BYTE* pBYTE=(BYTE*)Address; pBYTE<=pMemoryEnd; pBYTE++) {
    *pBYTE=0;
  }

  //Определяем максимальный размер
  DWORD MaxSize=1024L*1024L-(((DWORD)Segment)<<4)-Offset;
  int hDms=open(ProgName,O_RDONLY|O_BINARY);
  if(hDms==-1) return FILE_NOT_FOUND;
  //Читаем заголовок
  read(hDms,&Header,sizeof(Header));
  //Определяем длину загружаемой части
  DWORD LoadSize=(Header.e_cp-1)*512-Header.e_cparhdr*16+Header.e_cblp;
  if(Header.e_cblp==0) LoadSize+=512;
  //Проверяем размеры
  if(MaxSize<LoadSize) return MODULE_TOO_LARGE;
  //Загружаем модуль в память
  lseek(hDms,Header.e_cparhdr*16,SEEK_SET);
  read(hDms,Address,LoadSize);
  //Перемещаем указатель файла к области данных о перемещении
  lseek(hDms,Header.e_lfarlc,SEEK_SET);
  WORD RelSeg,RelOffs;
  DWORD Lin;
  //Выполняем перемещение
  for(int n=0; n<Header.e_crlc; n++) {
    read(hDms,&RelOffs,2); read(hDms,&RelSeg,2);
    Lin=((DWORD)RelSeg<<4)+RelOffs;
    *(WORD*)((BYTE*)Address+Lin)+=Segment;
  }
  close(hDms);
  return 0;
}

DWORD PASCAL StepInstruction(BOOL StepIn)
{
  return EmulateCurrentInstr();
}

DWORD HandleIrq()
{
  int VectorNumber;
  for(VectorNumber=0; VectorNumber<32; VectorNumber++) {
    if((Data.IntRequest>>VectorNumber)&&1) break;
  }
  WORD* pStk=(WORD*)VirtToReal(Data.Reg.SS,Data.Reg.SP);
  WriteRealMem(pStk-1,*(WORD*)&Data.Reg.Flag,1);
  WriteRealMem(pStk-2,Data.Reg.CS,1);
  WriteRealMem(pStk-3,Data.Reg.IP+2,1);
  Data.Reg.Flag.IF=0; Data.Reg.Flag.TF=0; Data.Reg.SP-=6;
  ReadVirtMem(0,VectorNumber*4,&Data.Reg.IP,1);
  ReadVirtMem(0,VectorNumber*4+2,&Data.Reg.CS,1);
  Data.IntRequest^=1<<VectorNumber;

  return AddIP(0);
}

DWORD WINAPI RunToBreakPoint(LPVOID)  //Исполнять до точки останова
{
  DWORD Status=0;
  Data.Stopped=FALSE;  //Признак остановки программы
  while((Status==0)&&Data.RunProg) { //Пока нет ошибок и не прервали
    Status=EmulateCurrentInstr();
    if(Status) break;
    if(Data.IntRequest&&Data.Reg.Flag.IF) Status=HandleIrq();
  }
  //Извещаем отладчик об остановке
  ::SendMessage(pHData->hHostWnd,WMU_EMULSTOP,Status,0);
  Data.Stopped=TRUE;  //Признак остановки
  _endthread();
  return Status;
}

DWORD PASCAL ToggleBreakpoint(DWORD Type,DWORD Addr,DWORD Count)
//Установить/убрать точку останова
{
  BOOL Ok=FALSE;
  struct _BP *pBP,*pCurBP;
  //Находим указатель на нужный массив точек останова
  switch(Type) {
    case BP_EXEC      : pBP=Data.BPX; break;
    case BP_MEM_READ  : pBP=Data.BPR; break;
    case BP_MEM_WRITE : pBP=Data.BPW; break;
    case BP_INPUT     : pBP=Data.BPI; break;
    case BP_OUTPUT    : pBP=Data.BPO; break;
    default           : return FALSE;
  }
  //Find Old Breakpoint
  pCurBP=pBP;
  //Ищем имеющуюся точку останова
  for(DWORD n=0; n<8; n++) {
    if(pCurBP->Valid&&(pCurBP->Addr==Addr)) {
      //Нашли, удаляем
      pCurBP->Valid=FALSE;
      Ok=TRUE; break;
    }
    pCurBP++;
  }
  if(Ok) return TRUE;
  //Не нашли, ставим новую точку
  pCurBP=pBP;
  //Ищем первую не используемую
  for(DWORD n=0; n<8; n++) {
    if(pCurBP->Valid==FALSE) {
      pCurBP->Addr=Addr; pCurBP->Count=Count; pCurBP->Valid=TRUE;
      Ok=TRUE; break;
    }
    pCurBP++;
  }
  return Ok;
}

struct _EmulatorData* PASCAL InitEmulator(struct _HostData *pHostData)
//Инициализация эмулятора
{
  //Определяем адрес ПЗУ
  pRom=(BYTE*)pMemoryEnd-pHostData->RomSize;

  //Замусориваем память
  srand(GetTickCount());
  for(BYTE* pBYTE=(BYTE*)Data.Memory; pBYTE<pRom; pBYTE++) {
    *pBYTE=rand()&0xFF;
  }

  //Инициализация счётчиков инструкций
  for(int n=0; n<sizeof(InstrCounter)/sizeof(struct _InstrCounter); n++)
    InstrCounter[n].Owner=VOID_OWNER;

  //Обнуляем счётчик
  Data.Takts=0;
  //Обновляем указатель на данные интерфейса
  pHData=pHostData;
  //Инициализация прерываний
  Data.IntRequest=0;
  //Инициализируем регистры
  memset(&Data.Reg,0,sizeof(Data.Reg));
  Data.Reg.CS=0xFFFF;
  CurSeg=Data.Reg.DS;  //Текущий сегмент по умолчанию DS
  SegChanged=FALSE;
  //Удаляем точки останова
  for(int n=0; n<8; n++) {
    Data.BPX[n].Valid=FALSE;
    Data.BPW[n].Valid=FALSE; Data.BPR[n].Valid=FALSE;
    Data.BPO[n].Valid=FALSE; Data.BPI[n].Valid=FALSE;
  }
  Data.Stopped=TRUE;

  //Возвращаем указатель на данные эмулятора
  return &Data;
}

DWORD PASCAL SetInstrCounter(DWORD Owner,DWORD Value)
{
  if(Value==0) return IC_INVALID_PARAMETER;

  //Удаляем старый счётчик, если он был
  for(int n=0; n<sizeof(InstrCounter)/sizeof(struct _InstrCounter); n++) {
    if(InstrCounter[n].Owner==VOID_OWNER) break;
    if(InstrCounter[n].Owner==Owner) { RemoveCounter(n); break; }
  }

  //Ищем первый счётчик со временем больше заданного
  DWORD CurCount=0;
  int n;
  for(n=0; n<sizeof(InstrCounter)/sizeof(struct _InstrCounter); n++) {
    if(InstrCounter[n].Owner==VOID_OWNER) break;

    if(CurCount+InstrCounter[n].Counter>Value) break;
    CurCount+=InstrCounter[n].Counter;
  }
  if(n==sizeof(InstrCounter)/sizeof(struct _InstrCounter)) return IC_TOO_MANY_COUNTERS;

  DWORD NewValue=Value-CurCount;
  //if(InstrCounter[n].Owner!=VOID_OWNER) NewValue-=InstrCounter[n].Counter;
  InsertCounter(n,Owner,NewValue);
  for(int i=n+1; i<sizeof(InstrCounter)/sizeof(struct _InstrCounter); i++) {
    if(InstrCounter[i].Owner==VOID_OWNER) break;

    InstrCounter[i].Counter-=NewValue;
  }
  
  return NO_ERRORS;
}

DWORD PASCAL KillInstrCounter(DWORD Owner)
{
  for(int n=0; n<sizeof(InstrCounter)/sizeof(struct _InstrCounter); n++) {
    if(InstrCounter[n].Owner==VOID_OWNER) break;
    if(InstrCounter[n].Owner==Owner) { RemoveCounter(n); return NO_ERRORS; }
  }

  return IC_COUNTER_NOT_FOUND;
}

//Точка входа в библиотеку
BOOL APIENTRY DllMain(HANDLE,ULONG fdwReason,LPVOID)
{
  switch(fdwReason) {
    case DLL_PROCESS_ATTACH :
      //Выделяем 1Мб памяти для ВМ86
      Data.Memory=malloc(1024L*1024L+6);
      pMemoryEnd=(void*)((BYTE*)Data.Memory+1024L*1024L-1);
      break;
    case DLL_PROCESS_DETACH :
      //Освобождаем память
      free(Data.Memory);
      break;
  }
  return TRUE;
}
