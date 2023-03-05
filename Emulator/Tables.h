#pragma once

//Файл Tables.h для эмулятора

#include "instructions.h"

typedef uint32_t(*_FirstByte)(uint8_t*);

extern _FirstByte FirstByte[256];