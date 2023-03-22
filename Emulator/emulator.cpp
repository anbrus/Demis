//Файл Emulator.cpp

#include "emulator.h"
#include "SubFunc.h"
#include "TickTimer.h"

#include <io.h>
#include <sys\stat.h>
#include <fcntl.h>
#include <process.h>
#include <algorithm>

#undef max

struct _EmulatorData EmulatorData;
HostInterface *pHData;

TickTimer tickTimer;
std::unordered_map<int, std::function<void(int64_t)>> InstructionListeners;
int64_t frequencyPerformanceCounter;
int64_t timeRunStart;
int64_t ticksRunStart;
int64_t ticksLastDelayToFreq;
int64_t ticksBetweenDelay;

void *SegSpace[32];
int SegSpaceCount = 0;
WORD CurSeg;
BOOL SegChanged = FALSE;
void *pRom, *pMemoryEnd;

#define VOID_OWNER -1


#include "Tables.h"


static int64_t ticksToPerformanceCounter(int64_t ticks, int64_t freq) {
	return freq * ticks / pHData->TaktFreq;
}

static void DelayToTaktFreq() {
	if (EmulatorData.Ticks - ticksLastDelayToFreq < ticksBetweenDelay) return;
	ticksLastDelayToFreq = EmulatorData.Ticks;

	int64_t timeToWait = timeRunStart + ticksToPerformanceCounter(EmulatorData.Ticks - ticksRunStart, frequencyPerformanceCounter);
	LARGE_INTEGER timeNow;
	while (true) {
		QueryPerformanceCounter(&timeNow);
		if (timeToWait <= timeNow.QuadPart) break;
	};
}

DWORD EmulateCurrentInstr()  //Эмулирует исполнение тек. инструкции
{
	CurSeg = EmulatorData.Reg.DS;
	//Получаем указатель на инструкцию
	BYTE *pCOP = (BYTE*)VirtToReal(EmulatorData.Reg.CS, EmulatorData.Reg.IP);
	//Вызываем обработчик КОП
	DWORD Res = INVALID_ADDRESS;
	if (pCOP) {
		Res = FirstByte[*pCOP](pCOP);
		//Инкрементируем число исполненных инструкций
		EmulatorData.Ticks+=6;
		tickTimer.onTicks(EmulatorData.Ticks);
		for (const auto& entry : InstructionListeners) {
			entry.second(EmulatorData.Ticks);
		}
	}

	return Res;
}

//---------------------Exportable Functions-------------------------------------
//Заголовок EXE-файла
struct _ExeHeader {                     // DOS .EXE header
	WORD   e_magic;                     // Magic number
	WORD   e_cblp;                      // Bytes on last page of file
	WORD   e_cp;                        // Pages in file
	WORD   e_crlc;                      // Relocations
	WORD   e_cparhdr;                   // Size of header in paragraphs
	WORD   e_minalloc;                  // Minimum extra paragraphs needed
	WORD   e_maxalloc;                  // Maximum extra paragraphs needed
	WORD   e_ss;                        // Initial (relative) SS value
	WORD   e_sp;                        // Initial SP value
	WORD   e_csum;                      // Checksum
	WORD   e_ip;                        // Initial IP value
	WORD   e_cs;                        // Initial (relative) CS value
	WORD   e_lfarlc;                    // File address of relocation table
	WORD   e_ovno;                      // Overlay number
};

DWORD PASCAL LoadProgram(char *ProgName, WORD Segment, WORD Offset)
//Загружает программу с именем ProgName по адресу Segment:Offset
{
	struct _ExeHeader Header;
	void* Address = VirtToReal(Segment, Offset);  //Адрес загрузки

	//Чистим ПЗУ
	for (BYTE* pBYTE = (BYTE*)Address; pBYTE <= pMemoryEnd; pBYTE++) {
		*pBYTE = 0;
	}

	//Определяем максимальный размер
	DWORD MaxSize = 1024L * 1024L - (((DWORD)Segment) << 4) - Offset;
	int hDms = open(ProgName, O_RDONLY | O_BINARY);
	if (hDms == -1) return FILE_NOT_FOUND;
	//Читаем заголовок
	read(hDms, &Header, sizeof(Header));
	//Определяем длину загружаемой части
	DWORD LoadSize = (Header.e_cp - 1) * 512 - Header.e_cparhdr * 16 + Header.e_cblp;
	if (Header.e_cblp == 0) LoadSize += 512;
	//Проверяем размеры
	if (MaxSize < LoadSize) return MODULE_TOO_LARGE;
	//Загружаем модуль в память
	lseek(hDms, Header.e_cparhdr * 16, SEEK_SET);
	read(hDms, Address, LoadSize);
	//Перемещаем указатель файла к области данных о перемещении
	lseek(hDms, Header.e_lfarlc, SEEK_SET);
	WORD RelSeg, RelOffs;
	DWORD Lin;
	//Выполняем перемещение
	for (int n = 0; n < Header.e_crlc; n++) {
		read(hDms, &RelOffs, 2); read(hDms, &RelSeg, 2);
		Lin = ((DWORD)RelSeg << 4) + RelOffs;
		*(WORD*)((BYTE*)Address + Lin) += Segment;
	}
	close(hDms);
	return 0;
}

DWORD PASCAL StepInstruction(BOOL StepIn)
{
	return EmulateCurrentInstr();
}

DWORD HandleIrq()
{
	int VectorNumber;
	for (VectorNumber = 0; VectorNumber < 40; VectorNumber++) {
		if ((EmulatorData.IntRequest >> VectorNumber) & 1) break;
	}
	bool isHlt = *reinterpret_cast<uint8_t*>(VirtToReal(EmulatorData.Reg.CS, EmulatorData.Reg.IP)) == 0xf4;
	if (isHlt) {
		EmulatorData.Reg.IP += 1;
	}
	WORD* pStk = (WORD*)VirtToReal(EmulatorData.Reg.SS, EmulatorData.Reg.SP);
	WriteRealMem(pStk - 1, *(WORD*)&EmulatorData.Reg.Flag, 1);
	WriteRealMem(pStk - 2, EmulatorData.Reg.CS, 1);
	WriteRealMem(pStk - 3, EmulatorData.Reg.IP, 1);
	EmulatorData.Reg.Flag.IF = 0; EmulatorData.Reg.Flag.TF = 0; EmulatorData.Reg.SP -= 6;
	ReadVirtMem(0, VectorNumber * 4, &EmulatorData.Reg.IP, 1);
	ReadVirtMem(0, VectorNumber * 4 + 2, &EmulatorData.Reg.CS, 1);
	EmulatorData.IntRequest ^= static_cast<uint64_t>(1) << VectorNumber;

	return AddIP(0);
}

DWORD WINAPI RunToBreakPoint(LPVOID)  //Исполнять до точки останова
{
	DWORD Status = 0;
	EmulatorData.Stopped = FALSE;  //Признак остановки программы
	ticksBetweenDelay = std::max(100ul, pHData->TaktFreq / 200);
	ticksRunStart = EmulatorData.Ticks;
	ticksLastDelayToFreq = EmulatorData.Ticks;
	LARGE_INTEGER now;
	QueryPerformanceCounter(&now);
	timeRunStart = now.QuadPart;
	while ((Status == 0) && EmulatorData.RunProg) { //Пока нет ошибок и не прервали
		Status = EmulateCurrentInstr();
		if (Status) break;
		if (EmulatorData.IntRequest&&EmulatorData.Reg.Flag.IF) Status = HandleIrq();

		DelayToTaktFreq();
	}
	//Извещаем отладчик об остановке
	::SendMessage(pHData->hHostWnd, WMU_EMULSTOP, Status, 0);
	EmulatorData.Stopped = TRUE;  //Признак остановки
	_endthread();
	return Status;
}

DWORD PASCAL ToggleBreakpoint(DWORD Type, DWORD Addr, DWORD Count)
//Установить/убрать точку останова
{
	BOOL Ok = FALSE;
	std::unordered_map<DWORD, struct _BP> *pBP;
	//Находим указатель на нужный массив точек останова
	switch (Type) {
	case BP_EXEC: pBP = &EmulatorData.BPX; break;
	case BP_MEM_READ: pBP = &EmulatorData.BPR; break;
	case BP_MEM_WRITE: pBP = &EmulatorData.BPW; break;
	case BP_INPUT: pBP = &EmulatorData.BPI; break;
	case BP_OUTPUT: pBP = &EmulatorData.BPO; break;
	default: return FALSE;
	}
	if (pBP->contains(Addr))
		pBP->erase(Addr);
	else {
		struct _BP bp;
		bp.Addr = Addr;
		bp.Count = Count;
		(*pBP)[Addr] = bp;
	}

	return Ok;
}

struct _EmulatorData* PASCAL InitEmulator(HostInterface *pHostData)
	//Инициализация эмулятора
{
	//Определяем адрес ПЗУ
	pRom = (BYTE*)pMemoryEnd - pHostData->RomSize;

	//Замусориваем память
	srand(static_cast<uint32_t>(GetTickCount64()));
	for (BYTE* pBYTE = (BYTE*)EmulatorData.Memory; pBYTE < pRom; pBYTE++) {
		*pBYTE = rand() & 0xFF;
	}

	//Инициализация счётчиков инструкций
	tickTimer.Clear();
	InstructionListeners.clear();

	//Обнуляем счётчик
	EmulatorData.Ticks = 0;
	LARGE_INTEGER freq;
	QueryPerformanceFrequency(&freq);
	frequencyPerformanceCounter = freq.QuadPart;
	//Обновляем указатель на данные интерфейса
	pHData = pHostData;
	//Инициализация прерываний
	EmulatorData.IntRequest = 0;
	//Инициализируем регистры
	memset(&EmulatorData.Reg, 0, sizeof(EmulatorData.Reg));
	EmulatorData.Reg.CS = 0xFFFF;
	CurSeg = EmulatorData.Reg.DS;  //Текущий сегмент по умолчанию DS
	SegChanged = FALSE;
	//Удаляем точки останова
	EmulatorData.BPX.clear();
	EmulatorData.BPW.clear(); EmulatorData.BPR.clear();
	EmulatorData.BPO.clear(); EmulatorData.BPI.clear();
	EmulatorData.Stopped = TRUE;

	//Возвращаем указатель на данные эмулятора
	return &EmulatorData;
}

DWORD PASCAL SetTickTimer(DWORD Owner, int64_t ticks, int64_t interval, std::function<void(DWORD)> handler)
{
	tickTimer.AddTimer(ticks, interval, handler, Owner);

	return NO_ERRORS;
}

template<class T>
static int getNewElementId(const std::unordered_map<int, T>& elements) {
	int idNew = 0;
	const auto iterMax = std::max_element(elements.cbegin(), elements.cend(), [](const auto& a, const auto& b) { return a.first < b.first; });
	if (iterMax != elements.cend()) idNew = iterMax->first + 1;

	return idNew;
}

int PASCAL AddInstructionListener(std::function<void(int64_t)> handler) {
	int idNew = getNewElementId(InstructionListeners);
	InstructionListeners[idNew]=handler;

	return idNew;
}

void PASCAL DeleteInstructionListener(int id) {
	InstructionListeners.erase(id);
}

DWORD PASCAL KillTickTimer(DWORD Owner)
{
	if (tickTimer.RemoveTimer(Owner)) return NO_ERRORS;

	return IC_COUNTER_NOT_FOUND;
}

//Точка входа в библиотеку
BOOL APIENTRY DllMain(HANDLE, ULONG fdwReason, LPVOID)
{
	switch (fdwReason) {
	case DLL_PROCESS_ATTACH:
		//Выделяем 1Мб памяти для ВМ86
		EmulatorData.Memory = malloc(1024L * 1024L + 6);
		pMemoryEnd = (void*)((BYTE*)EmulatorData.Memory + 1024L * 1024L - 1);
		break;
	case DLL_PROCESS_DETACH:
		//Освобождаем память
		free(EmulatorData.Memory);
		break;
	}
	return TRUE;
}
