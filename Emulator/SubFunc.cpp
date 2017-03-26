//Файл SubFunc.cpp
#include "SubFunc.h"
#include "emulator.h"

extern "C" DWORD ASMCALC(char,DWORD,WORD,BYTE,DWORD*);

DWORD Calculate(char Op,DWORD a,WORD b,BYTE W,WORD Mask)
//Выполняет арифметическую операцию с кодом Op над операндами a и b
//Mask - маска для флагов: 0-флаг не изменять, 1-можно изменять
{
  DWORD Fl=*(WORD*)&Data.Reg.Flag;  //Fl=флаги ВМ86
  DWORD dResult;
  dResult=ASMCALC(Op,a,b,W,&Fl);    //Посчитать
  Fl&=Mask;
  Fl&=0x08D5;  //0000 1000 1101 0101 сбросить упр. флаги
  *(WORD*)&Data.Reg.Flag&=~(Mask&0xF8FF); //Сбросить изменяемые флаги
  *(WORD*)&Data.Reg.Flag|=(Fl&0xF8FF);    //Установить арифм. флаги
  return dResult;
}

inline void* PASCAL VirtToReal(WORD Seg,WORD Offs)
//Возвращает указатель на ячейку адресуемую Seg:Offs
{
  DWORD LinAdr=(((DWORD)Seg)<<4)+Offs;  //Линейный адрес
  if(LinAdr>0xFFFFF) LinAdr-=0x100000;  //Убрать переполнение
  return LinAdr+(BYTE*)Data.Memory;
}

inline DWORD ReadRealMem(void *Addr,WORD *Data,BYTE Word)  //Segment Bound !!!
//Прочитать в *Data содержимое ячейки с адресом Addr
{
  if(Addr==NULL) return INVALID_ADDRESS;
  if(Word) *Data=*(WORD*)Addr;
  else *(BYTE*)Data=*(BYTE*)Addr;
  return 0;
}

inline DWORD WriteRealMem(void *Addr,WORD Data,BYTE Word)  //Segment Bound !!!
//Записать в ячейку с адресом Addr данные Data
{
  if(Addr==NULL) return INVALID_ADDRESS;
  if((Addr>=pRom)&&(Addr<=pMemoryEnd)) return 0;
  if(Word) *(WORD*)Addr=Data;
  else *(BYTE*)Addr=(BYTE)Data;
  return 0;
}

inline DWORD ReadVirtMem(WORD Seg,WORD Offs,WORD *Data,BYTE Word)  //Segment Bound !!!
//Прочитать в *Data содержимое ячейки с адресом Seg:Offs
{
  void *p=VirtToReal(Seg,Offs);
  return ReadRealMem(p,Data,Word);
}

inline DWORD WriteVirtMem(WORD Seg,WORD Offs,WORD Data,BYTE Word) //Segment Bound !!!
//Записать в ячейку с адресом Seg:Offs данные Data
{
  void *p=VirtToReal(Seg,Offs);
  return WriteRealMem(p,Data,Word);
}

inline DWORD AddIP(DWORD Offs)
//Увеличить IP на Offs и проверить на точку останова
{
  Data.Reg.IP+=(WORD)Offs;
  DWORD LinAddr=Data.Reg.IP+(((DWORD)Data.Reg.CS)<<4);  //Линейный адрес
  //Проверка на точку останова
  for(DWORD n=0; n<8; n++) {
    if(Data.BPX[n].Valid&&(Data.BPX[n].Addr==LinAddr))
      return STOP_BP_EXEC;
  }
  return 0;
}

inline void SetRegister(BYTE reg,BYTE w,WORD Value)
//Записывает данные Value в регистр общего назначения с кодом reg
{
  WORD *wReg;
  BYTE *bReg;
  reg&=7;
  w&=1;
  switch(reg) {
    case 0 : wReg=&Data.Reg.AX; bReg=(BYTE*)wReg; break;
    case 1 : wReg=&Data.Reg.CX; bReg=(BYTE*)wReg; break;
    case 2 : wReg=&Data.Reg.DX; bReg=(BYTE*)wReg; break;
    case 3 : wReg=&Data.Reg.BX; bReg=(BYTE*)wReg; break;
    case 4 : wReg=&Data.Reg.SP; bReg=((BYTE*)&Data.Reg.AX)+1; break;
    case 5 : wReg=&Data.Reg.BP; bReg=((BYTE*)&Data.Reg.CX)+1; break;
    case 6 : wReg=&Data.Reg.SI; bReg=((BYTE*)&Data.Reg.DX)+1; break;
    case 7 : wReg=&Data.Reg.DI; bReg=((BYTE*)&Data.Reg.BX)+1; break;
  }
  if(w==1) *wReg=Value;
  else *bReg=(BYTE)Value;
}

inline WORD GetRegister(BYTE reg,BYTE w)
//Возвращает содержимое РОН с кодом reg
{
  WORD *wReg;
  BYTE *bReg;
  reg&=7;
  w&=1;
  switch(reg) {
    case 0 : wReg=&Data.Reg.AX; bReg=(BYTE*)wReg; break;
    case 1 : wReg=&Data.Reg.CX; bReg=(BYTE*)wReg; break;
    case 2 : wReg=&Data.Reg.DX; bReg=(BYTE*)wReg; break;
    case 3 : wReg=&Data.Reg.BX; bReg=(BYTE*)wReg; break;
    case 4 : wReg=&Data.Reg.SP; bReg=((BYTE*)&Data.Reg.AX)+1; break;
    case 5 : wReg=&Data.Reg.BP; bReg=((BYTE*)&Data.Reg.CX)+1; break;
    case 6 : wReg=&Data.Reg.SI; bReg=((BYTE*)&Data.Reg.DX)+1; break;
    case 7 : wReg=&Data.Reg.DI; bReg=((BYTE*)&Data.Reg.BX)+1; break;
  }
  if(w==1) return *wReg;
  else return *bReg;
}

inline WORD GetSegRegister(BYTE sr)
//Возвращает содержимое сегментного регистра с кодом sr
{
  sr&=3;
  switch(sr) {
    case 0 : return Data.Reg.ES;
    case 1 : return Data.Reg.CS;
    case 2 : return Data.Reg.SS;
    case 3 : return Data.Reg.DS;
  }
  return 0;
}

inline void SetSegRegister(BYTE sr,WORD Dat)
//Записывает данные Dat в сегм. регистр с кодом sr
{
  sr&=3;
  switch(sr) {
    case 0 : Data.Reg.ES=Dat; break;
    case 1 : Data.Reg.CS=Dat; break;
    case 2 : Data.Reg.SS=Dat; break;
    case 3 : Data.Reg.DS=Dat; break;
  }
}

DWORD GetDecodedAddress(BYTE *pCOP2,BYTE w,void **Address)
//Находит указатель на ячейку памяти, адрес которой закодирован
//во втором байте кода операции
{
  BYTE B=*pCOP2&0xC7;  //Выделить активные биты
  signed short D8=*(signed char*)(pCOP2+1);  //Следующий байт
  WORD D16=*(WORD*)(pCOP2+1);  //Следующее слово
  BOOL W=(w&1)==1;
  BYTE Return;  //Длина инструкции
  WORD Offset;
  WORD UsedSeg=CurSeg;
  switch(B) {
    case 0x00 : Offset=Data.Reg.BX+Data.Reg.SI; Return=1; break;
    case 0x01 : Offset=Data.Reg.BX+Data.Reg.DI; Return=1; break;
    case 0x02 : Offset=Data.Reg.BP+Data.Reg.SI; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=1; break;
    case 0x03 : Offset=Data.Reg.BP+Data.Reg.DI; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=1; break;
    case 0x04 : Offset=Data.Reg.SI; Return=1; break;
    case 0x05 : Offset=Data.Reg.DI; Return=1; break;
    case 0x06 : Offset=D16; Return=3; break;
    case 0x07 : Offset=Data.Reg.BX; Return=1; break;

    case 0x40 : Offset=Data.Reg.BX+Data.Reg.SI+D8; Return=2; break;
    case 0x41 : Offset=Data.Reg.BX+Data.Reg.DI+D8; Return=2; break;
    case 0x42 : Offset=Data.Reg.BP+Data.Reg.SI+D8; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=2; break;
    case 0x43 : Offset=Data.Reg.BP+Data.Reg.DI+D8; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=2; break;
    case 0x44 : Offset=Data.Reg.SI+D8; Return=2; break;
    case 0x45 : Offset=Data.Reg.DI+D8; Return=2; break;
    case 0x46 : Offset=Data.Reg.BP+D8; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=2; break;
    case 0x47 : Offset=Data.Reg.BX+D8; Return=2; break;

    case 0x80 : Offset=Data.Reg.BX+Data.Reg.SI+D16; Return=3; break;
    case 0x81 : Offset=Data.Reg.BX+Data.Reg.DI+D16; Return=3; break;
    case 0x82 : Offset=Data.Reg.BP+Data.Reg.SI+D16; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=3; break;
    case 0x83 : Offset=Data.Reg.BP+Data.Reg.DI+D16; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=3; break;
    case 0x84 : Offset=Data.Reg.SI+D16; Return=3; break;
    case 0x85 : Offset=Data.Reg.DI+D16; Return=3; break;
    case 0x86 : Offset=Data.Reg.BP+D16; if(!SegChanged) UsedSeg=Data.Reg.SS; Return=3; break;
    case 0x87 : Offset=Data.Reg.BX+D16; Return=3; break;

    case 0xC0 : *Address=(void*)&Data.Reg.AX; return 1;
    case 0xC1 : *Address=(void*)&Data.Reg.CX; return 1;
    case 0xC2 : *Address=(void*)&Data.Reg.DX; return 1;
    case 0xC3 : *Address=(void*)&Data.Reg.BX; return 1;
    case 0xC4 : *Address=(void*)(W ? (BYTE*)&Data.Reg.SP : ((BYTE*)(&Data.Reg.AX))+1); return 1;
    case 0xC5 : *Address=(void*)(W ? (BYTE*)&Data.Reg.BP : ((BYTE*)(&Data.Reg.CX))+1); return 1;
    case 0xC6 : *Address=(void*)(W ? (BYTE*)&Data.Reg.SI : ((BYTE*)(&Data.Reg.DX))+1); return 1;
    case 0xC7 : *Address=(void*)(W ? (BYTE*)&Data.Reg.DI : ((BYTE*)(&Data.Reg.BX))+1); return 1;
  }
  *Address=VirtToReal(UsedSeg,Offset);  //Получить указатель
  return Return;
}

