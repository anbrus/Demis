#pragma once

//���� Tables.h ��� ���������

#include "instructions.h"

typedef uint32_t(*_FirstByte)(uint8_t*);

extern _FirstByte FirstByte[256];