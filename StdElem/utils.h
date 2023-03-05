#pragma once

#include "Windows.h"

void createCompatibleDc(CDC* pDC, CDC* pMemoryDC, int width, int height);
float luminance1(int64_t ticksOff, int64_t ticks, int64_t ticksAfterLight);
float luminance2(int64_t ticksOff, int64_t ticks, int64_t ticksAfterLight);
float luminance3(int64_t ticksOff, int64_t ticks, int64_t ticksAfterLight);
