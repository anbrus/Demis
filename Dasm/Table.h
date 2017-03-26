//Файл Table.h для дизассемблера
_COPFunc COPFunc[256]={
  ALOp,    ALOp,    ALOp,    ALOp,    //00
  ALOp,    ALOp,    Push,    Pop,     //04
  ALOp,    ALOp,    ALOp,    ALOp,    //08
  ALOp,    ALOp,    Push,    Ext386,  //0C
  ALOp,    ALOp,    ALOp,    ALOp,    //10
  ALOp,    ALOp,    Push,    Pop,     //14
  ALOp,    ALOp,    ALOp,    ALOp,    //18
  ALOp,    ALOp,    Push,    Pop,     //1C
  ALOp,    ALOp,    ALOp,    ALOp,    //20
  ALOp,    ALOp,    SegXS,   Corr,    //24
  ALOp,    ALOp,    ALOp,    ALOp,    //28
  ALOp,    ALOp,    SegXS,   Corr,    //2C
  ALOp,    ALOp,    ALOp,    ALOp,    //30
  ALOp,    ALOp,    SegXS,   Corr,    //34
  ALOp,    ALOp,    ALOp,    ALOp,    //38
  ALOp,    ALOp,    SegXS,   Corr,    //3C
  IncDec,  IncDec,  IncDec,  IncDec,  //40
  IncDec,  IncDec,  IncDec,  IncDec,  //44
  IncDec,  IncDec,  IncDec,  IncDec,  //48
  IncDec,  IncDec,  IncDec,  IncDec,  //4C
  Push,    Push,    Push,    Push,    //50
  Push,    Push,    Push,    Push,    //54
  Pop,     Pop,     Pop,     Pop,     //58
  Pop,     Pop,     Pop,     Pop,     //5C
  Stack286,Stack286,Bound,   Unknown, //60
  Unknown, Unknown, Unknown, Unknown, //64
  Stack286,Mul286,  Stack286,Mul286,  //68
  String,  String,  String,  String,  //6C
  JCond,   JCond,   JCond,   JCond,   //70
  JCond,   JCond,   JCond,   JCond,   //74
  JCond,   JCond,   JCond,   JCond,   //78
  JCond,   JCond,   JCond,   JCond,   //7C
  ArOp,    ArOp,    ArOp,    ArOp,    //80
  Test,    Test,    Xchg,    Xchg,    //84
  Mov,     Mov,     Mov,     Mov,     //88
  Mov,     Mov,     Mov,     Pop,     //8C
  Xchg,    Xchg,    Xchg,    Xchg,    //90
  Xchg,    Xchg,    Xchg,    Xchg,    //94
  Unknown, Unknown, Call1,   Unknown, //98
  Push,    Pop,     Unknown, Unknown, //9C
  Mov,     Mov,     Mov,     Mov,     //A0
  String,  String,  String,  String,  //A4
  Test,    Test,    String,  String,  //A8
  String,  String,  String,  String,  //AC
  Mov,     Mov,     Mov,     Mov,     //B0
  Mov,     Mov,     Mov,     Mov,     //B4
  Mov,     Mov,     Mov,     Mov,     //B8
  Mov,     Mov,     Mov,     Mov,     //BC
  Shift,   Shift,   Ret,     Ret,     //C0
  Lxs,     Lxs,     Mov,     Mov,     //C4
  Stack286,Stack286,Ret,     Ret,     //C8
  Int,     Int,     Int,     Ret,     //CC
  Shift,   Shift,   Shift,   Shift,   //D0
  Corr,    Corr,    Unknown, Xlat,    //D4
  Unknown, Unknown, Unknown, Unknown, //D8
  Unknown, Unknown, Unknown, Unknown, //DC
  Loop,    Loop,    Loop,    JCond,   //E0
  IO,      IO,      IO,      IO,      //E4
  Call1,   Jmp1,    Jmp1,    Jmp1,    //E8
  IO,      IO,      IO,      IO,      //EC
  Unknown, Unknown, Rep,     Rep,     //F0
  Unknown, Flags,   Grp2,    Grp2,    //F4
  Flags,   Flags,   Flags,   Flags,   //F8
  Flags,   Flags,   Grp,     Grp      //FC
};
