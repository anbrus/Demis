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

struct _EmulatorData {      //Глобальные общие данные эмулятора
	struct _Registers Reg;
	INT64 Ticks;  //Счётчик тактов
	void *Memory;
	BOOL RunProg, Stopped;
	DWORD IntRequest;
	struct _BP BPX[8], BPR[8], BPW[8], BPI[8], BPO[8];
};

class HostInterface {                 //Глобальные общие данные оболочки
public:
	HostInterface() {};
	virtual ~HostInterface() {};

	HWND  hHostWnd=0;
	DWORD TaktFreq=1000000;                  //Тактовая частота в герцах
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
extern "C" DWORD PASCAL LoadProgram(char *ProgName, WORD Segment, WORD Offset);   //Загрузка программы для эмуляции
extern "C" DWORD PASCAL Assemble(char *AsmName, struct _ErrorData *pError); //Ассемблировать текст программы
extern "C" DWORD PASCAL StepInstruction(BOOL StepIn);  //Выполнить одну инструкцию с заходом или без
extern "C" DWORD WINAPI RunToBreakPoint(LPVOID);       //Выполнять до особой ситуации
extern "C" DWORD PASCAL ToggleBreakpoint(DWORD Type, DWORD Addr, DWORD Count);
//Установить точку останова заданного типа по заданному адресу на заданный проход
extern "C" struct _EmulatorData* PASCAL InitEmulator(HostInterface *pHostData);
//Возвращает указатель на данные эмулятора, получает указатель на данные оболочки
extern "C" DWORD PASCAL DasmInstr(DWORD Seg, DWORD Offs, struct _EmulatorData *EmData, char* s);
extern "C" DWORD PASCAL BackDasm(BYTE *Blk, DWORD BlkSize, DWORD IP, char *s);

extern "C" DWORD PASCAL AssembleFile(char *PrjPath, char *AsmName, std::vector<struct _ErrorData>& Errors);
extern "C" DWORD PASCAL LinkFiles(char* PrjPath, char* OBJNames, char* DMSName, std::vector<struct _ErrorData>& Errors);

extern "C" DWORD PASCAL SetTickTimer(DWORD Owner, int64_t ticks, std::function<void(DWORD)> handler);
extern "C" DWORD PASCAL KillTickTimer(DWORD Owner);

//Ошибки:
#define NO_ERRORS         0x000  //Нет ошибок
//LoadProgram:
#define UNKNOWN_SEGMENT   0x100  //Обнаружен неизвестный сегмент
#define MODULE_TOO_LARGE 0x101   //Модуль слишком большой
#define TOO_MUCH_SEGMENTS 0x102  //Слишком много сегментов
#define FILE_DAMAGED      0x103  //Файл повреждён
//Assemble:
#define ASSEMBLER_ERROR   0x200  //Ошибка ассемблирования
#define LINKER_ERROR      0x201  //Ошибка связывания
//Эмуляция:
#define STOP_UNKNOWN_INSTRUCTION 0x300  //Текущая инструкция не существует
#define STOP_BP_EXEC         0x301 //Достигнута точка останова по исполнению
#define STOP_BP_INPUT        0x302  //Текущая инструкция осуществляет вывод в порт
#define STOP_BP_OUTPUT       0x303  //Текущая инструкция осуществляет ввод из порта
#define STOP_BP_MEM_READ     0x304  //Сработала точка останова по чтению из памяти
#define STOP_BP_MEM_WRITE    0x305  //Сработала точка останова по записи в память
//Остальные:
#define INVALID_ADDRESS   0x002  //Неверный адрес
#define FILE_NOT_FOUND    0x001  //Файл не найден
#define NO_MEMORY         0x003  //Нехватает памяти
#define UNKNOWN_ERROR     0x004  //Неизвестная ошибка

//SetBreakPoint: Type:
#define BP_EXEC         0x001 //Установить точку останова по исполнению
#define BP_INPUT        0x002  //Установить точку останова на вывод в порт
#define BP_OUTPUT       0x003  //Установить точку останова на ввод из порта
#define BP_MEM_READ     0x004  //Установить точку останова по чтению из памяти
#define BP_MEM_WRITE    0x005  //Установить точку останова по записи в память

//Таймеры
#define IC_TOO_MANY_COUNTERS  0x401  //Слишком много таймеров
#define IC_COUNTER_NOT_FOUND  0x402  //Таймер не найден (для KillTimer)
#define IC_INVALID_PARAMETER  0x403

#endif