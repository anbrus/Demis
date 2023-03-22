#include "vi54counter.h"

#include <cassert>

Vi54Counter::Vi54Counter() {
    Reset();
}

Vi54Counter::~Vi54Counter() {

}

void Vi54Counter::Reset() {
    cwb.byte = 0;
    cr = 0;
    ce = 0;
    ol = 0;
    statusLatch = 0;
    statusLatched = false;
    stateOl = OlState::FOLLOW;
    leastmostRead = 0;
    leastmostWrite = 0;
    isLoadCeRequired = false;
    awaitingCount = false;
    gate_pin = false;
    gate_flipflop = false;
    gate = false;
    out = false;
    clk = false;
}

void Vi54Counter::WriteControlWord(uint8_t data) {
    ControlWordByte cwb;
    cwb.byte = data;
    assert(cwb.cw.sc != 3);
    if (cwb.cw.rw == 0) {
        LatchCounter();
    }
    else {
        this->cwb = cwb;
        startMode();
    }
}

void Vi54Counter::Write(uint8_t data) {
    bool crUpdated = false;
    switch (cwb.cw.rw) {
        //Counter-Latch
    case 0: {
        //assert(false);
        break;
    }
          //Least
    case 1: {
        cr = data;
        crUpdated = true;
        break;
    }
          //Most
    case 2: {
        cr = (data << 8);
        crUpdated = true;
        break;
    }
          //Least-Most
    case 3: {
        if (leastmostWrite == 0) cr = cr & 0xff00 | data;
        else cr = cr & 0x00ff | (data << 8);

        if (leastmostWrite == 1) {
            crUpdated = true;
        }
        else {
            awaitingCount = true;
            onLoadCrLeastByte();
        }

        leastmostWrite = (leastmostWrite + 1) & 1;
        break;
    }
    }

    if (crUpdated) {
        switch (cwb.cw.mode) {
        case 0:
        case 4:
        {
            isLoadCeRequired = true;
            break;
        }
        case 2:
        case 6:
        case 3:
        case 7:
        {
            isLoadCeRequired = awaitingCount;
            break;
        }
        }
        awaitingCount = false;
    }
}

uint8_t Vi54Counter::Read() {
    if (statusLatched) {
        statusLatched = false;
        return statusLatch;
    }

    switch (cwb.cw.rw) {
        //Counter-Latch
    case 0: {
        //assert(false);
        return 0;
    }
          //Least
    case 1: {
        if (stateOl == OlState::STORE) {
            stateOl = OlState::FOLLOW;
            return ol & 0xff;
        }
        else {
            return ce & 0xff;
        }
    }
          //Most
    case 2: {
        if (stateOl == OlState::STORE) {
            stateOl = OlState::FOLLOW;
            return (ol >> 8) & 0xff;
        }
        else {
            return (ce >> 8) & 0xff;
        }
    }
          //Least-Most
    case 3: {
        uint8_t res;
        if (stateOl == OlState::STORE) {
            if (leastmostRead == 0) res = ol & 0xff;
            else res = (ol >> 8) & 0xff;
        }
        else {
            if (leastmostRead == 0) res = ce & 0xff;
            else res = (ce >> 8) & 0xff;
        }

        if (leastmostRead == 1)
            stateOl = OlState::FOLLOW;

        leastmostRead = (leastmostRead + 1) & 1;
        return res;
    }
    }

    return 0;
}

void Vi54Counter::LatchCounter() {
    // If a Counter is latched and then, some time later, latched again before the count is read, the second Counter Latch Command is ignored
    if (stateOl == OlState::STORE) return;

    ol = ce;
    stateOl = OlState::STORE;
    leastmostRead = 0;
}

uint16_t Vi54Counter::GetCe() const {
    return ce;
}

void Vi54Counter::LatchStatus() {

}

void Vi54Counter::startMode() {
    awaitingCount = true;
    isLoadCeRequired = false;
    switch (cwb.cw.mode) {
    case 0: {
        out = false;
        break;
    }
    case 1: {
        out = true;
        gate = false;
        gate_flipflop = false;
        break;
    }
    case 2:
    case 6: {
        out = true;
        gate = false;
        gate_flipflop = false;
        break;
    }
    case 3:
    case 7: {
        out = true;
        gate = false;
        gate_flipflop = false;
        odd_one = false;
        break;
    }
    case 4: {
        out = true;
        gate = false;
        gate_flipflop = false;
        break;
    }
    case 5: {
        out = true;
        gate = false;
        gate_flipflop = false;
        break;
    }
    }
}

void Vi54Counter::SetGate(const bool v) {
    if (gate_pin == v) return;

    gate_pin = v;
    if (v) {
        switch (cwb.cw.mode) {
        case 1:
        case 5:
            gate_flipflop = true;
            break;
        case 2:
        case 6:
        case 3:
        case 7:
            gate = true;
            gate_flipflop = true;
            isLoadCeRequired = true;
            break;
        }
    }
    else {
        switch (cwb.cw.mode) {
        case 2:
        case 6:
        case 3:
        case 7:
            out = true;
            break;
        }
    }
}

void Vi54Counter::SetClk(const bool v) {
    if (clk == v) return;
    clk = v;
    if (awaitingCount) return;

    if (clk) { // Rising edge
        switch (cwb.cw.mode) {
        case 0:
        case 4:
            gate = gate_pin;
            break;
        case 1:
        case 5:
            gate = gate_flipflop;
            break;
        case 2:
        case 6:
        case 3:
        case 7:
            gate = gate_flipflop || gate_pin;
            break;
        }
        if (gate_flipflop) gate_flipflop = false;
        return;
    }

    // Falling edge
    switch (cwb.cw.mode) {
    case 0: {
        pulseMode0();
        break;
    }
    case 1: {
        if (gate) {
            isLoadCeRequired = true;
        }
        pulseMode1();
        break;
    }
    case 2:
    case 6: {
        pulseMode2();
        break;
    }
    case 3:
    case 7: {
        pulseMode3();
        break;
    }
    case 4: {
        pulseMode4();
        break;
    }
    case 5: {
        if (gate) {
            isLoadCeRequired = true;
        }
        pulseMode5();
        break;
    }
    }
}

void Vi54Counter::onLoadCrLeastByte() {
    switch (cwb.cw.mode) {
    case 0: {
        out = false;
        break;
    }
    }
}

// CMD______---------
void Vi54Counter::pulseMode0() {
    if (awaitingCount) return;
    if (isLoadCeRequired) {
        ce = cr;
        isLoadCeRequired = false;
        return;
    }

    if (!gate) return;

    ce -= 1;
    if (ce == 0) out = true;
}

// CMD--t_____----t_____------
void Vi54Counter::pulseMode1() {
    bool outNew = out;

    if (isLoadCeRequired) {
        ce = cr;
        outNew = false;
        isLoadCeRequired = false;
    }
    else {
        ce -= 1;
        if (ce == 0) outNew = true;
    }

    if (out != outNew) out = outNew;
}

// CMD----_----_----_-
void Vi54Counter::pulseMode2() {
    if (gate && isLoadCeRequired) {
        ce = cr;
        out = true;
        isLoadCeRequired = false;
        return;
    }
    else if (!gate) {
        out = true;
        return;
    }

    ce -= 1;
    if (ce == 0) ce = cr;

    bool outNew = ce != 1;
    if (out != outNew) out = outNew;
}

// CMD---__---__---__-
void Vi54Counter::pulseMode3() {
    if (gate && isLoadCeRequired) {
        ce = cr & 0xfffe;
        odd_one = (cr & 1) != 0;
        out = true;
        isLoadCeRequired = false;
        return;
    }
    else if (!gate) {
        out = true;
        return;
    }

    if (odd_one & out) {
        if (ce == 0) {
            ce = cr & 0xfffe;
            odd_one = (cr & 1) != 0;
            out = !out;
        }
        else {
            ce -= 2;
        }
    }
    else {
        ce -= 2;
        if (ce == 0) {
            ce = cr & 0xfffe;
            odd_one = (cr & 1) != 0;
            out = !out;
        }
    }
}


// CMD-----_-----------
void Vi54Counter::pulseMode4() {
    if (awaitingCount) return;
    if (isLoadCeRequired) {
        ce = cr;
        isLoadCeRequired = false;
        count_cycle_completed = false;
        return;
    }

    if (!gate) return;

    ce -= 1;
    if (ce == 0 && !count_cycle_completed) {
        out = false;
        count_cycle_completed = true;
    }
    else {
        out = true;
    }
}

void Vi54Counter::pulseMode5() {
    if (awaitingCount) return;
    if (isLoadCeRequired) {
        ce = cr;
        isLoadCeRequired = false;
        count_cycle_completed = false;

        return;
    }

    ce -= 1;
    if (ce == 0 && !count_cycle_completed) {
        out = false;
        count_cycle_completed = true;
    }
    else {
        out = true;
    }
}