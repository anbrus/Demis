#pragma once

#include "vi54counter.h"

#include <cstdint>
#include <array>

class VI54 {
public:
    VI54();
    virtual ~VI54();

    void Write(int address, uint8_t data);
    uint8_t Read(int address);
    void Reset();
    Vi54Counter& GetCounter(int idx);
    void SetFreePinLevel(bool level);

private:
    bool freepinlevel = false;
    std::array<Vi54Counter, 3> counters;

    void readBack(ControlWordByte cwb);
};