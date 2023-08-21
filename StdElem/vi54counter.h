#pragma once

#include "control_word.h"

#include <cstdint>

class Vi54Counter {
public:
    Vi54Counter();
    virtual ~Vi54Counter();

    void Write(uint8_t data);
    uint8_t Read();
    void WriteControlWord(uint8_t data);
    void Reset();
    void LatchCounter();
    void LatchStatus();
    void SetClk(bool v);
    void SetGate(bool v);
    inline bool GetOut() const { return out; };
    uint16_t GetCe() const;

private:
    ControlWordByte cwb;

    enum OlState {
        FOLLOW,
        STORE
    };

    uint16_t cr, ce, ol;
    uint8_t statusLatch;
    bool statusLatched = false;
    OlState stateOl = OlState::FOLLOW;
    int leastmostRead = 0;
    int leastmostWrite = 0;
    bool awaitingCount = false;
    bool isLoadCeRequired = false;
    bool gate_pin;
    bool gate_flipflop;
    bool clk, out, gate;
    bool odd_one = false; // Нечётная единица в 3-ем режиме
    bool count_cycle_completed = false;

    void startMode();
    void onLoadCrLeastByte();
    void pulseMode0();
    void pulseMode1();
    void pulseMode2();
    void pulseMode3();
    void pulseMode4();
    void pulseMode5();
};

uint16_t corr_bcd_dec(uint16_t v);