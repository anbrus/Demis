#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <process.h>
#include <io.h>
#include <sys\stat.h>
#include <fcntl.h>

void main(int argc,char* argv[])
{
  char CmdLine[512],TasmName[512]; CmdLine[0]=0;
  for(int n=1; n<argc; n++) {
    strcat(CmdLine,argv[n]);
    strcat(CmdLine," ");
  }
  //printf("%s",CmdLine);
  //getch();
  strcpy(TasmName,argv[0]);
  *(strrchr(TasmName,'\\'))=0;
  strcat(TasmName,"\\tasm.exe");
  int hOut=creat("ERRORS.TXT",S_IWRITE);
  _asm {
    mov ah,0x46
    mov bx,hOut
    mov cx,1
    int 0x21
  }
  spawnl(P_WAIT,TasmName,TasmName,CmdLine,NULL);
  close(hOut);
}