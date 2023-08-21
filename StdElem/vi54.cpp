#include "vi54.h"

#include <cassert>

VI54::VI54()
{
    Reset();
}

VI54::~VI54() {

}

void VI54::SetFreePinLevel(bool level) {
    freepinlevel = level;
}

void VI54::Reset() {
    for (Vi54Counter& counter : counters) { counter.Reset(); };
}

void VI54::Write(const int address, const uint8_t data) {
    switch (address & 3) {
    case 0:
    case 1:
    case 2: {
        Vi54Counter& counter = counters.at(address);
        counter.Write(data);
        break;
    }
    case 3: {
        ControlWordByte cwb;
        cwb.byte = data;
        int idxCounter = cwb.cw.sc;
        if (idxCounter < 3) {
            Vi54Counter& counter = counters.at(cwb.cw.sc);
            counter.WriteControlWord(data);
        }
        else {
            readBack(cwb);
        }
        break;
    }
    }
}

uint8_t VI54::Read(const int address) {
    switch (address & 3) {
    case 0:
    case 1:
    case 2: {
        Vi54Counter& counter = counters.at(address);
        return counter.Read();
    }
    case 3:
        if (freepinlevel) return 0xff;
        else return 0x00;
    }

    return 0;
}

void VI54::readBack(ControlWordByte cwb) {
    //assert((cwb.byte & 0x01) == 0);

    if ((cwb.byte & 0x10) == 0) {
        if (cwb.byte & 0x02) counters[0].LatchStatus();
        if (cwb.byte & 0x04) counters[1].LatchStatus();
        if (cwb.byte & 0x08) counters[2].LatchStatus();
    }
    if ((cwb.byte & 0x20) == 0) {
        if (cwb.byte & 0x02) counters[0].LatchCounter();
        if (cwb.byte & 0x04) counters[1].LatchCounter();
        if (cwb.byte & 0x08) counters[2].LatchCounter();
    }
}

Vi54Counter& VI54::GetCounter(int idx) {
    return counters.at(idx);
}