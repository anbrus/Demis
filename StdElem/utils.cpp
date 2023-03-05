#include "stdafx.h"

#include "utils.h"

void createCompatibleDc(CDC* pDC, CDC* pMemoryDC, int width, int height) {
	pMemoryDC->DeleteDC();
	pMemoryDC->CreateCompatibleDC(pDC);
	CBitmap bmp;
	bmp.CreateCompatibleBitmap(pDC, width, height);
	HGDIOBJ hBmpOld = pMemoryDC->SelectObject(bmp);
	DeleteObject(hBmpOld);
	pMemoryDC->PatBlt(0, 0, width, height, WHITENESS);
}

float luminance1(int64_t ticksOff, int64_t ticks, int64_t ticksAfterLight) {
	if (ticksOff == 0) return 0.0;
	if (ticksOff < 0) return 1.0;
	int64_t ticksToLight = ticksOff - ticks;
	if (ticksToLight < 0) return 0.0;
	if (ticksToLight > ticksAfterLight) return 1.0;
	return static_cast<float>(ticksToLight) / ticksAfterLight;
}

float luminance2(int64_t ticksOff, int64_t ticks, int64_t ticksAfterLight) {
	if (ticksOff == 0) return 0.0;
	if (ticksOff < 0) return 1.0;
	int64_t ticksToLight = ticksOff - ticks;
	if (ticksToLight < 0) return 0.0;
	if (ticksToLight >= ticksAfterLight / 2) {
		return 1.0;
	}
	return 2.0f * static_cast<float>(ticksToLight) / ticksAfterLight;
}

float luminance3(int64_t ticksOff, int64_t ticks, int64_t ticksAfterLight) {
	if (ticksOff == 0) return 0.0;
	if (ticksOff < 0) return 1.0;
	int64_t ticksToLight = ticksOff - ticks;
	if (ticksToLight < 0) return 0.0;
	return 1.0;
}

