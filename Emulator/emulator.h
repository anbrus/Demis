#pragma once
#include <windows.h>
#include "..\definitions.h"

extern struct _EmulatorData EmulatorData;
extern HostInterface* pHData;
extern void *pRom, *pMemoryEnd;
extern WORD CurSeg;
extern BOOL SegChanged;
