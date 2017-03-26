#pragma once

#include <windows.h>

extern inline void SetRegister(BYTE reg, BYTE w, WORD Value);
extern inline DWORD AddIP(DWORD Offs);
extern DWORD GetDecodedAddress(BYTE *pCOP2, BYTE w, void **Address);
extern inline WORD GetRegister(BYTE reg, BYTE w);
extern inline void SetRegister(BYTE reg, BYTE w, WORD Value);
extern inline DWORD WriteRealMem(void *Addr, WORD Data, BYTE Word);
extern inline DWORD ReadRealMem(void *Addr, WORD *Data, BYTE Word);
extern inline WORD GetSegRegister(BYTE sr);
extern inline void SetSegRegister(BYTE sr, WORD Dat);
extern inline DWORD ReadVirtMem(WORD Seg, WORD Offs, WORD *Data, BYTE Word);
extern inline DWORD WriteVirtMem(WORD Seg, WORD Offs, WORD Data, BYTE Word);
extern DWORD Calculate(char Op, DWORD a, WORD b, BYTE W, WORD Mask);