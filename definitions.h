#ifndef DEFINITIONS
#define DEFINITIONS

#include <vector>
#include <string>
#include <functional>
#include <chrono>

#define WMU_ELEMENT_LBUTTONDOWN (WM_USER+1501)
#define WMU_ELEMENT_LBUTTONUP   (WM_USER+1502)
#define WMU_ELEMENT_MOUSEMOVE   (WM_USER+1503)
//#define WMU_PINSTATECHANGED     (WM_USER+1504)
//#define WMU_READPORT            (WM_USER+1505)
//#define WMU_WRITEPORT           (WM_USER+1506)
#define WMU_INTREQUEST          (WM_USER+1507)
#define WMU_EMULSTOP            (WM_USER+1508)
//#define WMU_GETPINSTATE         (WM_USER+1509)
//#define WMU_SET_INSTRCOUNTER    (WM_USER+1510)
//#define WMU_KILL_INSTRCOUNTER   (WM_USER+1511)
//#define WMU_INSTRCOUNTER_EVENT  (WM_USER+1512)

struct _Flags {
	BYTE CF : 1,
		UnUsed1 : 1,
		PF : 1,
		UnUsed2 : 1,
		AF : 1,
		UnUsed3 : 1,
		ZF : 1,
		SF : 1,
		TF : 1,
		IF : 1,
		DF : 1,
		OF : 1,
		UnUsed4 : 4;
};

struct _Registers {
	WORD AX, BX, CX, DX,
		SI, DI, BP, SP,
		DS, ES, CS, SS,
		IP;
	struct _Flags Flag;
};

struct _BP {
	DWORD Addr : 20,
		Count : 11;
	BOOL  Valid : 1;
};

struct _EmulatorData {      //���������� ����� ������ ���������
	struct _Registers Reg;
	INT64 Ticks;  //������� ������
	void *Memory;
	BOOL RunProg, Stopped;
	DWORD IntRequest;
	struct _BP BPX[8], BPR[8], BPW[8], BPI[8], BPO[8];
};

class HostInterface {                 //���������� ����� ������ ��������
public:
	HostInterface() {};
	virtual ~HostInterface() {};

	HWND  hHostWnd=0;
	DWORD TaktFreq=1000000;                  //�������� ������� � ������
	DWORD RomSize=4096*1024;

	virtual void SetTickTimer(int64_t ticks, DWORD hElement, std::function<void(DWORD)> handler) = 0;
	virtual void WritePort(WORD port, BYTE value) = 0;
	virtual uint8_t ReadPort(WORD port) = 0;
	virtual void OnPinStateChanged(DWORD PinState, int hElement) = 0;

};

struct _ErrorData {
	DWORD Line;
	DWORD Type;  //0 - Error, 1 - Warning
	std::string Text;
	std::string File;
};

extern "C" void* PASCAL VirtToReal(WORD Seg, WORD Offs);
extern "C" DWORD PASCAL LoadProgram(char *ProgName, WORD Segment, WORD Offset);   //�������� ��������� ��� ��������
extern "C" DWORD PASCAL Assemble(char *AsmName, struct _ErrorData *pError); //�������������� ����� ���������
extern "C" DWORD PASCAL StepInstruction(BOOL StepIn);  //��������� ���� ���������� � ������� ��� ���
extern "C" DWORD WINAPI RunToBreakPoint(LPVOID);       //��������� �� ������ ��������
extern "C" DWORD PASCAL ToggleBreakpoint(DWORD Type, DWORD Addr, DWORD Count);
//���������� ����� �������� ��������� ���� �� ��������� ������ �� �������� ������
extern "C" struct _EmulatorData* PASCAL InitEmulator(HostInterface *pHostData);
//���������� ��������� �� ������ ���������, �������� ��������� �� ������ ��������
extern "C" DWORD PASCAL DasmInstr(DWORD Seg, DWORD Offs, struct _EmulatorData *EmData, char* s);
extern "C" DWORD PASCAL BackDasm(BYTE *Blk, DWORD BlkSize, DWORD IP, char *s);

extern "C" DWORD PASCAL AssembleFile(char *PrjPath, char *AsmName, std::vector<struct _ErrorData>& Errors);
extern "C" DWORD PASCAL LinkFiles(char* PrjPath, char* OBJNames, char* DMSName, std::vector<struct _ErrorData>& Errors);

extern "C" DWORD PASCAL SetTickTimer(DWORD Owner, int64_t ticks, std::function<void(DWORD)> handler);
extern "C" DWORD PASCAL KillTickTimer(DWORD Owner);

//������:
#define NO_ERRORS         0x000  //��� ������
//LoadProgram:
#define UNKNOWN_SEGMENT   0x100  //��������� ����������� �������
#define MODULE_TOO_LARGE 0x101   //������ ������� �������
#define TOO_MUCH_SEGMENTS 0x102  //������� ����� ���������
#define FILE_DAMAGED      0x103  //���� ��������
//Assemble:
#define ASSEMBLER_ERROR   0x200  //������ ���������������
#define LINKER_ERROR      0x201  //������ ����������
//��������:
#define STOP_UNKNOWN_INSTRUCTION 0x300  //������� ���������� �� ����������
#define STOP_BP_EXEC         0x301 //���������� ����� �������� �� ����������
#define STOP_BP_INPUT        0x302  //������� ���������� ������������ ����� � ����
#define STOP_BP_OUTPUT       0x303  //������� ���������� ������������ ���� �� �����
#define STOP_BP_MEM_READ     0x304  //��������� ����� �������� �� ������ �� ������
#define STOP_BP_MEM_WRITE    0x305  //��������� ����� �������� �� ������ � ������
//���������:
#define INVALID_ADDRESS   0x002  //�������� �����
#define FILE_NOT_FOUND    0x001  //���� �� ������
#define NO_MEMORY         0x003  //��������� ������
#define UNKNOWN_ERROR     0x004  //����������� ������

//SetBreakPoint: Type:
#define BP_EXEC         0x001 //���������� ����� �������� �� ����������
#define BP_INPUT        0x002  //���������� ����� �������� �� ����� � ����
#define BP_OUTPUT       0x003  //���������� ����� �������� �� ���� �� �����
#define BP_MEM_READ     0x004  //���������� ����� �������� �� ������ �� ������
#define BP_MEM_WRITE    0x005  //���������� ����� �������� �� ������ � ������

//�������
#define IC_TOO_MANY_COUNTERS  0x401  //������� ����� ��������
#define IC_COUNTER_NOT_FOUND  0x402  //������ �� ������ (��� KillTimer)
#define IC_INVALID_PARAMETER  0x403

#endif