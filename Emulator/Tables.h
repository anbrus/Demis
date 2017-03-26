//Файл Tables.h для эмулятора

_FirstByte FirstByte[256]={
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
  Inc,     Inc,     Inc,     Inc,     //40
  Inc,     Inc,     Inc,     Inc,     //44
  Dec,     Dec,     Dec,     Dec,     //48
  Dec,     Dec,     Dec,     Dec,     //4C
  Push,    Push,    Push,    Push,    //50
  Push,    Push,    Push,    Push,    //54
  Pop,     Pop,     Pop,     Pop,     //58
  Pop,     Pop,     Pop,     Pop,     //5C
  Stack286,Stack286,Bound,   UnkInstr,//60
  UnkInstr,UnkInstr,UnkInstr,UnkInstr,//64
  Stack286,Mul286,  Stack286,Mul286,  //68
  String,  String,  String,  String,  //6C
  JCond,   JCond,   JCond,   JCond,   //70
  JCond,   JCond,   JCond,   JCond,   //74
  JCond,   JCond,   JCond,   JCond,   //78
  JCond,   JCond,   JCond,   JCond,   //7C
  ArOp,    ArOp,    ArOp,    ArOp,    //80
  Test,    Test,    Xchg,    Xchg,    //84
  Mov1,    Mov1,    Mov1,    Mov1,    //88
  Mov1,    Lea,    Mov1,    Pop,     //8C
  Xchg,    Xchg,    Xchg,    Xchg,    //90
  Xchg,    Xchg,    Xchg,    Xchg,    //94
  Expand,  Expand,  Call1,   Void,    //98
  Push,    Pop,     AcFl,    AcFl,    //9C
  AcOp,    AcOp,    AcOp,    AcOp,    //A0
  String,  String,  String,  String,  //A4
  Test,    Test,    String,  String,  //A8
  String,  String,  String,  String,  //AC
  Mov4,    Mov4,    Mov4,    Mov4,    //B0
  Mov4,    Mov4,    Mov4,    Mov4,    //B4
  Mov4,    Mov4,    Mov4,    Mov4,    //B8
  Mov4,    Mov4,    Mov4,    Mov4,    //BC
  Shift286,Shift286,Ret,     Ret,     //C0
  Lxs,     Lxs,     Mov1,    Mov1,    //C4
  Stack286,Stack286,Ret,     Ret,     //C8
  Int,     Int,     Int,     Ret,     //CC
  Shift,   Shift,   Shift,   Shift,   //D0
  Corr,    Corr,    UnkInstr,Xlat,    //D4
  UnkInstr,UnkInstr,UnkInstr,UnkInstr,//D8
  UnkInstr,UnkInstr,UnkInstr,UnkInstr,//DC
  Loop,    Loop,    Loop,    JCond,   //E0
  IO,      IO,      IO,      IO,      //E4
  Call1,   Jmp1,    Jmp1,    Jmp1,    //E8
  IO,      IO,      IO,      IO,      //EC
  Void,    UnkInstr,Rep1,    Rep2,    //F0
  Halt,    Flags,   Grp2,    Grp2,    //F4
  Flags,   Flags,   Flags,   Flags,   //F8
  Flags,   Flags,   Grp,     Grp      //FC
};
