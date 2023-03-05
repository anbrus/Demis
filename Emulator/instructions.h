#pragma once

#include <cstdint>

//Прототипы обработчиков КОП

uint32_t UnkInstr(uint8_t*);
uint32_t Mov4(uint8_t* pCOP);
uint32_t JCond(uint8_t* pCOP);
uint32_t Mov1(uint8_t* pCOP);
uint32_t AcOp(uint8_t* pCOP);
uint32_t ALOp(uint8_t* pCOP);
uint32_t IO(uint8_t* pCOP);
uint32_t Push(uint8_t* pCOP);
uint32_t Pop(uint8_t* pCOP);
uint32_t Inc(uint8_t* pCOP);
uint32_t Dec(uint8_t* pCOP);
uint32_t Xchg(uint8_t* pCOP);
uint32_t ArOp(uint8_t* pCOP);
uint32_t Lxs(uint8_t* pCOP);
uint32_t Shift(uint8_t* pCOP);
uint32_t SegXS(uint8_t* pCOP);
uint32_t Jmp1(uint8_t* pCOP);
uint32_t Jmp2(uint8_t* pCOP);
uint32_t Test(uint8_t* pCOP);
uint32_t Call1(uint8_t* pCOP);
uint32_t Call2(uint8_t* pCOP);
uint32_t Ret(uint8_t* pCOP);
uint32_t Loop(uint8_t* pCOP);
uint32_t Flags(uint8_t* pCOP);
uint32_t Xlat(uint8_t* pCOP);
uint32_t DivMul(uint8_t* pCOP);
uint32_t Int(uint8_t* pCOP);
uint32_t Corr(uint8_t* pCOP);
uint32_t Expand(uint8_t* pCOP);
uint32_t Void(uint8_t* pCOP);
uint32_t Halt(uint8_t* pCOP);
uint32_t Rep1(uint8_t* pCOP);
uint32_t Rep2(uint8_t* pCOP);
uint32_t String(uint8_t* pCOP);
uint32_t AcFl(uint8_t* pCOP);
uint32_t Grp(uint8_t* pCOP);
uint32_t Grp2(uint8_t* pCOP);
uint32_t Stack286(uint8_t* pCOP);
uint32_t Bound(uint8_t* pCOP);
uint32_t Shift286(uint8_t* pCOP);
uint32_t Mul286(uint8_t* pCOP);
uint32_t Ext386(uint8_t* pCOP);
uint32_t Lea(uint8_t* pCOP);
