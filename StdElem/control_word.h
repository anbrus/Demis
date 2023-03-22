#pragma once

#include <cstdint>

#pragma pack(push, 1)
struct ControlWord {
    uint8_t bcd: 1;
    uint8_t mode: 3;
    uint8_t rw: 2;
    uint8_t sc: 2;
};

union ControlWordByte {
    ControlWord cw;
    uint8_t byte;
};
#pragma pack(pop)