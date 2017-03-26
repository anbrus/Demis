#pragma once
#define WINVER 0x0501
#include <windows.h>
#include "..\definitions.h"

extern struct _EmulatorData Data;
extern void *pRom, *pMemoryEnd;
extern WORD CurSeg;
extern BOOL SegChanged;
