	NAME	uudpt
KbdPort0=0
ModePort1=1
SOutPort0=0
FOutPort1=1
FOutPort2=2
FOutPort3=3
FOutPort4=4
PROutPort=5
SOutPort6=6
TOutPort7=7
TOutPort8=8
TOutPort9=9
TOutPort10=10
TOutPort11=11
TOutPort12=12
MOutPort13=13
KOutPort14=14
KOutPort15=15
Data	SEGMENT AT 0BA00H
	FreqTable DW 100 DUP (?)
	DelTable DW 100 DUP (?)
	KeyTable DB 100 DUP (?)
	TrfTable1 DB 10 DUP (?)
	TrfTable2 DW 17 DUP (?)
	Mode DB ?
	State DB ?
	RotDir DB ?
	InType DB ?
	KbdImage DW ?
	NextDig DB ?
	Frequenc DB 2 DUP (?)
	Turn DB 3 DUP (?)
	CodPosRot DB ?
	PCodPosRot DB ?
	Keyhol_BCD DB ?
	FreqDisp DB 4 DUP (?)
	TurnDisp DB 6 DUP (?)
	KeyDisp DB 2 DUP (?)
	EmpKbd DB ?
Data	ENDS
Stack	SEGMENT AT 0BA80H
	DW 100 DUP (?)
StkTop	LABEL WORD		
Stack	ENDS
Code	SEGMENT
	ASSUME	CS:Code,DS:Data,SS:Stack

;Модуль "Функциональная подготовка"
FuncPrep PROC NEAR
	;Цикл формирования таблицы частот
	LEA BX,FreqTable                ;Загрузка базового адреса частоты
	MOV AX,0050H     		;Введение минимальной частоты
	MOV [BX],AX			;Запись частоты
	INC BX				;Модификация 
	INC BX				;адреса
	MOV CL,1			;Счетчик цикла=1
FP1:	CMP CL,LENGTH FreqTable		;Все элементы ?
	JE  FP2	 			;Переход,если да
	XCHG AH,AL	 		;Увеличение
	ADD AL,01H	 		;
	DAA	 	 		;
	XCHG AH,AL	 		;частоты на один шаг
	MOV [BX],AX			;Запись частоты	
	INC BX				;Модификация 
	INC BX				;адреса
	INC CL				;и счетчика цикла
	JMP FP1
	;Цикл формирования таблицы задержек			
FP2:	LEA BX,DelTable 		;Загрузка базового адреса таблицы
					;задержек
	MOV AX,1000			;Введение максимальной задержки
	MOV CX,LENGTH DelTable		;Счетчик цикла=числу элементов
					;таблицы задержек
FP3:	MOV [BX],AX			;Запись задержки
	SUB AX,10			;Уменьшение задержки на один шаг
	INC BX				;Модификация 
	INC BX				;адреса
	LOOP FP3			;Все элементы ? Переход,если нет
	;Цикл формирования таблицы скважностей	
FP4:	LEA BX,KeyTable 		;Загрузка базового адреса таблицы
					;скважностей
	MOV AL,99H     			;Введение максимального значения
					;скважности
	MOV [BX],AL			;Запись скважности
	INC BX				;Модификация адреса
	MOV CL,1			;Счетчик цикла=1
FP5:	CMP CL,LENGTH KeyTable		;Все элементы ?
	JE FP6				;Переход,если да
	MOV [BX],AL			;Запись скважности
	SUB AL,1			;Уменьшение скважности на один шаг
	DAS				;Коррекция
	INC BX				;Модификация адреса 
	INC CL				;и счетчика цикла
	JMP FP5
FP6:	;Формирование таблицы преобразования
	;для вывода числовой информации
	MOV BYTE PTR TrfTable1,3FH
	MOV BYTE PTR TrfTable1+1,0CH
	MOV BYTE PTR TrfTable1+2,76H
	MOV BYTE PTR TrfTable1+3,5EH
	MOV BYTE PTR TrfTable1+4,4DH
	MOV BYTE PTR TrfTable1+5,5BH
	MOV BYTE PTR TrfTable1+6,7BH
	MOV BYTE PTR TrfTable1+7,0EH
	MOV BYTE PTR TrfTable1+8,7FH
	MOV BYTE PTR TrfTable1+9,5FH
	;Формирование таблицы преобразования 
	;для вывода ШИМ-сигнала
	MOV WORD PTR TrfTable2,0000H
	MOV WORD PTR TrfTable2+2,0FFFFH
	MOV WORD PTR TrfTable2+4,5555H
	MOV WORD PTR TrfTable2+6,9249H
	MOV WORD PTR TrfTable2+8,1111H
	MOV WORD PTR TrfTable2+10,8421H
	MOV WORD PTR TrfTable2+12,1041H
	MOV WORD PTR TrfTable2+14,4081H
	MOV WORD PTR TrfTable2+16,0101H
	MOV WORD PTR TrfTable2+18,0201H
	MOV WORD PTR TrfTable2+20,0401H
	MOV WORD PTR TrfTable2+22,0801H
	MOV WORD PTR TrfTable2+24,1001H
	MOV WORD PTR TrfTable2+26,2001H
	MOV WORD PTR TrfTable2+28,4001H
	MOV WORD PTR TrfTable2+30,8001H
	MOV WORD PTR TrfTable2+32,0001H
	;Инициализация критических данных
	MOV State,00H			;Состояние="Пассивное"
	MOV RotDir,00H			;Направление вращения="Влево"
	MOV InType,00H			;Тип ввода="Частота"
	MOV Frequenc,0000H		;Частота=0
	LEA BX,Turn			;Обо-
	MOV CX,Length Turn		;ро-
FP7:	MOV BYTE PTR [BX],00H		;ты
	INC BX				;=
	LOOP FP7			;0
	MOV Keyhol_BCD,00H		;Скважность=0
	MOV CodPosRot,01H		;Позиция ротора=сегмент A
	MOV PCodPosRot,01H		;Предыдущая позиция=тому же
	RET
FuncPrep ENDP

;Модуль "Ввод режимов"
ModeInput PROC NEAR
	MOV State,00H   ;Состояние="Пассивное"
	IN AL,ModePort1	;Ввод переключателей
	TEST AL,04H	;Состояние="Активное" ?
	JZ MI0		;Переход,если нет
	MOV State,0FFH	;Состояние="Активное"
	JMP SHORT MI4	
MI0:	TEST AL,08H	;Направление вращения="Влево" ?
	JZ MI1		;Переход,если нет
	MOV RotDir,00H	;Направление вращения="Влево" 
	JMP SHORT MI4	;
MI1:	TEST AL,10H	;Направление вращения="Вправо" ?
	JZ MI2		;Переход,если нет
	MOV RotDir,0FFH	;Направление вращения="Вправо" 
	JMP SHORT MI4	
MI2:	TEST AL,20H	;Тип ввода="Частота" ?
	JZ MI3		;Переход,если нет
	MOV InType,00H	;Тип ввода="Частота" 
	JMP SHORT MI4	
MI3:	TEST AL,40H	;Тип ввода="Обороты" ?
	JZ MI4		;Переход,если нет
	MOV InType,0FFH	;Тип ввода="Обороты" 
MI4:	RET
ModeInput ENDP

;Модуль "Вывод сообщений о направлении вращения и типе ввода"
RtDrInTpMesOut PROC NEAR
	MOV AL,01H	;Сообщение "Направление вращения"="Влево"
	CMP RotDir,00H	;"Направление вращения"="Влево"?
	JE RDITMO1	;Переход,если да
	MOV AL,02H	;Сообщение "Направление вращения"="Вправо"
RDITMO1:CMP InType,00H	;"Тип ввода"="Частота"?
	JNE RDITMO2	;Переход,если нет
	OR AL,04H	;Сообщение "Направление вращения" и 
                        ;"Тип ввода"="Частота"
	JMP RDITMO3
RDITMO2:OR AL,08H	;Сообщение "Направление вращения" и 
                        ;"Тип ввода"="Обороты"		
RDITMO3:OUT MOutPort13,AL;Вывод сообщения
	RET
RtDrInTpMesOut ENDP

;Модуль	"Ввод с клавиатуры"
KbdInput PROC NEAR
	CMP State,00H   ;Состояние="Пассивное" ?
	JNE KI3		;Переход,если нет
	IN AL,ModePort1	;Ввод
	MOV AH,AL	;
	IN AL,KbdPort0	;	
	AND AH,03H	;клавиатуры	
	CMP AX,0	;Клавиатура активирована ?
	JE KI2		;Переход,если нет
	MOV KbdImage,AX	;Запись образа клавиатуры
KI1:	IN AL,ModePort1	;Ввод	
	MOV AH,AL	;
	IN AL,KbdPort0	;	
	AND AH,03H	;клавиатуры	
	CMP AX,0	;Клавиатура активирована ?	
	JNE KI1		;Переход,если да
	JMP SHORT KI3	
KI2:	MOV KbdImage,AX	;Запись образа клавиатуры
KI3:	RET
KbdInput ENDP

;Модуль "Контроль ввода с клавиатуры"
KbdInContr PROC NEAR
	MOV EmpKbd,00H  ;Очистка флага пустой клавиатуры
	CMP KbdImage,0	;Образ клавиатуры пуст ?
	JNE KIC1	;Переход,если нет
	MOV EmpKbd,0FFH	;Установка флага пустой клавиатуры
KIC1:	RET
KbdInContr ENDP

;Модуль "Преобразование очередной цифры"
NxtDigTrf PROC NEAR
	CMP EmpKbd,0FFH	;Пустая клавиатура?
	JE NDT3		;Переход,если да
	MOV AX,KbdImage	;Чтение клавиатуры
	MOV CL,0	;Очистка накопителя кода цифры
NDT1:	SHR AX,1	;Выделение бита клавиатуры
	JC NDT2		;Бит активен?Переход,если да
	INC CL		;Инкремент кода цифры
	JMP SHORT NDT1
NDT2:	MOV NextDig,CL	;Запись кода цифры
NDT3:	RET
NxtDigTrf ENDP

;Модуль "Формирование информации в пассивном состоянии"
PsvStInfoForm PROC NEAR
	CMP State,00H           ;Состояние=пассивное ?
	JNE PSIF5	        ;Переход,если нет
	CMP EmpKbd,00H	        ;Не пустая клавиатура ?
	JNE PSIF3               ;Переход,если нет
	CMP InType,00H          ;Тип ввода="Частота" ?
	JNE PSIF1               ;Переход,если нет
	LEA BX,Frequenc		;Передача параметров 
	MOV CH,LENGTH Frequenc	;для сдвига частоты
	CALL SHL_4		;Сдвиг на тетраду влево
	MOV AL,Frequenc         ;Чтение младшего байта сдвинутой частоты
	OR AL,NextDig           ;Включение очередной цифры в частоту
	MOV Frequenc,AL         ;Запись новой частоты
	JMP PSIF3               ;
PSIF1:	LEA BX,Turn             ;Передача параметров
	MOV CH,LENGTH Turn	;для сдвига оборотов
	CALL SHL_4		;Сдвиг на тетраду влево
	MOV AL,Turn		;Чтение младшего байта сдвинутых оборотов
	OR AL,NextDig           ;Включение очередной цифры в обороты
	MOV Turn,AL             ;Запись новых оборотов
PSIF3:	MOV Keyhol_BCD,00H      ;Скважность=0
	MOV AL,CodPosRot        ;Сохранение 
	MOV PCodPosRot,AL       ;позиции ротора
	MOV Mode,00H            ;Режим="Режим 1"
	CMP BYTE PTR Turn,00H   ;Обороты=0 ?
	JNE PSIF4               ;
	CMP BYTE PTR Turn+1,00H ;
	JNE PSIF4               ;
	CMP BYTE PTR Turn+2,00H ;
	JNE PSIF4               ;
	JMP PSIF5               ;Переход,если да
PSIF4:	MOV Mode,0FFH           ;Режим="Режим 2"
PSIF5:	RET                     
PsvStInfoForm ENDP

;Модуль "Сдвиг массива байт влево на тетраду"
SHL_4 PROC NEAR
;Входные параметры:
;       BX-базовый адрес сдвигаемого массива
;       CH-число байт в массиве
	XOR AH,AH   ;Очистить AH
	XOR DL,DL   ;Очистить DL
	MOV CL,4    ;Счетчик сдвигов=4
S1:	MOV AL,[BX] ;Чтение очередного байта
	SHL AX,CL   ;Сдвиг на тетраду влево
	OR AL,DL    ;Включение старшей тетрады предыдущего байта
	MOV [BX],AL ;Запись байта
	MOV DL,AH   ;Сохранение старшей тетрады
	XOR AH,AH   ;Приемник выдвигаемой тетрады=0
	INC BX      ;Модификация адреса
	DEC CH      ;Декремент числа байт
	JNZ S1      ;Переход,если не все байты
        RET 
SHL_4 ENDP

;Модуль "Формирование информации в режиме 1"
Md1InfoForm PROC NEAR
	CMP State,0FFH              ;Состояние="Активное" ?
	JNE M1IF2		    ;Переход,если нет
	CMP Mode,00H		    ;Режим="Режим 1" ?
	JNE M1IF2		    ;Переход,если нет
	CMP WORD PTR Frequenc,0000H ;Частота=0 ?
	JNE M1IF1		    ;Переход,если нет
	MOV Keyhol_BCD,00H	    ;Скважность=0
	JMP SHORT M1IF2             ;
M1IF1:	MOV AH,Frequenc+1	    ;Передача параметров
				    ;для преобразования старшего байта 
				    ;частоты из BCD-формата в двоичный
	CALL BCDTrans		    ;Преобразование BCD-формата в двоичный
	MOV BL,AL		    ;Формирование индекса в таблице 
	XOR BH,BH		    ;скважностей и в таблице задержек
	LEA SI,KeyTable		    ;Загрузка базового адреса таблицы 
				    ;сважностей
	MOV AL,[SI][BX]		    ;Выборка текущей скважности из таблицы
	MOV Keyhol_BCD,AL	    ;Запись текущей скважности
	MOV AL,BL      	            ;Формирование 
	MOV DL,TYPE DelTable        ;смещения элемента
	MUL DL		            ;относительно базового адреса
	MOV BX,AX	            ;таблицы задержек
	LEA SI,DelTable             ;Загрузка базового адреса таблицы
                                    ;задержек
	MOV CX,[SI][BX]             ;Выборка текущей задержки из таблицы=
                                    ;передача параметров для поворота 
				    ;двигателя
	CALL RotModul	            ;Поворот двигателя
M1IF2:  RET
Md1InfoForm ENDP

;Модуль "Преобразование BCD-формата в двоичный"
BCDTrans PROC NEAR
;Входной параметр:
;	AH-байт в BCD-формате
;Выходной параметр:
;	AL-двоичный байт (результат преобразования)
	XOR AL,AL    ;Очистить накопитель результата 
	MOV CX,8     ;Счетчик цикла=8
BT1:	SHR AX,1     ;Сдвиг на разряд вправо
	TEST AH,08H  ;Коррекция нужна ?
	JZ BT2       ;Переход,если нет
	MOV DL,AH    ;Выделение в DL
	AND DL,0F0H  ;старшей тетрады
	AND AH,0FH   ;Выделение в AH младшей тетрады
	SUB AH,3     ;Коррекция
	OR AH,DL     ;Объединение в AH старшей 
                     ;и скорректированной младшей тетрад
BT2:	LOOP BT1     ;Все разряды ? Переход,если нет
	RET
BCDTrans ENDP

;Модуль "Поворот двигателя"
RotModul PROC NEAR
;Входной параметр:
;	CX-текущая задержка
RM1:	LOOP RM1	  ;Цикл задержки
	CMP RotDir,00H    ;Вращение двигателя="Влево" ?
	JNE RM3		  ;переход,если нет
	CMP CodPosRot,01H ;Позиция ротора=сегмент A ?
	JNE RM2		  ;Переход,если нет
	MOV CodPosRot,20H ;Позиция ротора=сегмент F
	JMP SHORT RM5		  
RM2:	SHR CodPosRot,1   ;Поворот на один сегмент влево
	JMP SHORT RM5		  
RM3:  	CMP CodPosRot,20H ;Позиция ротора=сегмент F ?
	JNE RM4		  ;Переход,если нет
	MOV CodPosRot,01H ;Позиция ротора=сегмент A
	JMP SHORT RM5 	  ;
RM4:	SHL CodPosRot,1   ;Поворот на один сегмент влево
	JMP SHORT RM5     ;
RM5:	RET
RotModul ENDP

;Модуль "Формирование информации в режиме 2"
Md2InfoForm PROC NEAR
	CMP State,0FFH		    ;Состояние="Активное" ?
	JNE M2IF0		    ;Переход,если нет
	CMP Mode,0FFH		    ;Режим="Режим 2" ?
	JNE M2IF2		    ;Переход,если нет
	CMP BYTE PTR Turn,00H       ;Число оборотов=0 ?
	JNE M2IF1		    ;
	CMP BYTE PTR Turn+1,00H     ;	
	JNE M2IF1		    ;
	CMP BYTE PTR Turn+2,00H     ;
	JNE M2IF1		    ;Переход,если нет
	MOV WORD PTR Frequenc,0000H ;Частота=0
	MOV Keyhol_BCD,00H	    ;Скважность=0
M2IF0:	JMP SHORT M2IF2		    
M2IF1:	MOV AH,Turn+2 	         ;Передача параметров
				 ;для преобразования старшего байта оборотов
				 ;из BCD-формата в двоичный
	CALL BCDTrans		 ;Преобразование BCD-формата в двоичный
	LEA SI,FreqTable	 ;Загрузка базового адреса таблицы частот
	MOV DL,TYPE FreqTable    ;Формирование смещения элемента
	MUL DL		         ;относительно базового адреса
	MOV BX,AX	         ;таблицы частот
	MOV AX,[SI][BX]		 ;Выборка текущей частоты из таблицы=
				 ;передача параметров для преобразования
				 ;старшего байта частоты из BCD-формата в
				 ;двоичный
	MOV WORD PTR Frequenc,AX ;Запись текущей частоты
	CALL BCDTrans		 ;Преобразование BCD-формата в двоичный
	MOV BL,AL		 ;Формирование индекса в таблице
	XOR BH,BH		 ;скважностей и в таблице задержек
	LEA SI,KeyTable		 ;Загрузка базового адреса таблицы 
				 ;скважностей
	MOV AL,[SI][BX]		 ;Выборка текущей скважности из таблицы
	MOV Keyhol_BCD,AL	 ;Запись текущей скважности
	MOV AL,BL      	         ;Формирование 
	MOV DL,TYPE DelTable     ;смещения элемента
	MUL DL		         ;относительно базового адреса
	MOV BX,AX	         ;таблицы задержек
	LEA SI,DelTable          ;Загрузка базового адреса таблицы
                                 ;задержек
	MOV CX,[SI][BX]          ;Выборка текущей задержки из таблицы=
                                 ;передача параметров для поворота 
				 ;двигателя
	CALL RotModul		 ;Поворот двигателя
	MOV AL,CodPosRot	 ;Чтение кода позиции ротора
	CMP PCodPosRot,AL	 ;Предыдущее значение=настоящему ?
	JNE M2IF2		 ;Переход,если нет
                                 ;Декремент числа оборотов
	MOV AL,Turn		 
	SUB AL,1		 
	DAS		 	 
	MOV Turn,AL		 
	MOV AL,Turn+1		 
	SBB AL,0		 
	DAS			 
	MOV Turn+1,Al		 
	MOV AL,Turn+2		 
	SBB AL,0		 
	DAS		 	 
	MOV Turn+2,Al		 
M2IF2:  RET
Md2InfoForm ENDP

;Модуль "Формирование массива отображения"
DispForm PROC NEAR
;Входные параметры:
;	SI-адрес входных данных
;	DI-адрес выходных данных
;	CH-число входных байт
	MOV CL,4    ;Счетчик сдвигов=4
DF1:	MOV AL,[SI] ;Чтение данных
	MOV AH,AL   ;Копирование данных
	AND AL,0FH  ;Выделение младшей тетрады
	MOV [DI],AL ;Запись в память
	INC DI      ;Инкремент адреса
	SHR AH,CL   ;Сдвиг копии данных на тетраду
	MOV [DI],AH ;Запись в память
	INC DI      ;Инкремент адреса
	INC SI      ;То же
	DEC CH      ;Все байты ?
	JNZ DF1     ;Переход,если нет
	RET
DispForm ENDP

;Модуль "Вывод позиции ротора"
PosRotOut PROC NEAR
	MOV     AL,CodPosRot   ;Чтение кода позици ротора
	OUT     PROutPort,AL   ;Вывод в порт
	RET
PosRotOut ENDP

;Модуль "Вывод числовой информации"
NumInfOut PROC NEAR
;Входные параметры:
;	SI-адрес входного массива отображения
;	DX-номер младшего порта дисплея
;	CX-количество выводимых знаков
	LEA BX,TrfTable1 ;Загрузка адреса таблицы преобразования
NIO1:	MOV AL,[SI]	 ;Чтение цифры
	XLAT		 ;Преобразование цифры
	OUT DX,AL	 ;Вывод цифры в порт
	INC SI		 ;Модификация адреса
	INC DX		 ;и номера порта
	LOOP NIO1	 ;Все цифры ? Переход,если нет
	RET
NumInfOut ENDP

;Модуль "Вывод ШИМ-сигнала"
SIMOut PROC NEAR
	MOV AH,Keyhol_BCD                  ;Чтение скважности
	CALL BCDTrans			   ;Преобразование BCD-формата
					   ;в двоичный
	CMP AL,16			   ;Скважность=>16
	JNBE SO1			   ;Переход,если да
	MOV DL,TYPE TrfTable2              ;Формирование смещения элемента
	MUL DL		     		   ;относительно базового адреса
	MOV BX,AX	     	           ;ШИМ-таблицы 
	LEA SI,TrfTable2		   ;Загрузка базового адреса  
					   ;ШИМ-таблицы
	MOV AX,[SI][BX]			   ;Выборка текущего ШИМ-сигнала
	JMP SHORT SO2			   
SO1:	MOV AX,TrfTable2+16*TYPE TrfTable2 ;Чтение последнего ШИМ-сигнала
SO2:	OUT SOutPort0,AL			   ;Вывод
	MOV AL,AH 			   ;
	OUT SOutPort6,AL			   ;ШИМ-сигнала
	RET
SIMOut ENDP

Begin:			       ;Системная подготовка	
	MOV 	AX,Data        ;Инициализация сегментных регистров	
	MOV	DS,AX
	MOV	AX,Stack
	MOV	SS,AX
	LEA	SP,StkTop      ;И указателя стека
	CALL	FuncPrep       ;Функциональная подготовка
Count:  
	CALL	ModeInput      ;Ввод режимов
	CALL    RtDrInTpMesOut ;Вывод сообщений о направлении вращения
			       ;и типе ввода
	CALL	KbdInput       ;Ввод с клавиатуры
	CALL 	KbdInContr     ;Контроль ввода с клавиатуры
	CALL	NxtDigTrf      ;Преобразование очередной цифры
	CALL	PsvStInfoForm  ;Формирование информации в пассивном состоянии
	CALL	Md1InfoForm    ;Формирование информации в режиме 1
	CALL	Md2InfoForm    ;Формирование информации в режиме 2
	LEA 	SI, Frequenc   ;Передача параметров
	LEA	DI, FreqDisp   ;для формирования массива отображения
	MOV	CH,2           ;частоты
	CALL	DispForm       ;Формирование массива отображения
	LEA 	SI,Turn        ;Передача параметров 
	LEA	DI,TurnDisp    ;для формирования массива отображения 
	MOV	CH,3           ;оборотов
	CALL	DispForm       ;Формирование массива отображения
	LEA 	SI,Keyhol_BCD  ;Передача параметров 
	LEA	DI,KeyDisp     ;для формирования массива отображения
	MOV	CH,1           ;скважности
	CALL	DispForm       ;Формирование массива отображения
	CALL	PosRotOut
	LEA  	SI,FreqDisp    ;Передача параметров
	MOV 	DX,FOutPort1   ;для вывода информации
	MOV	CX,4           ;на дисплей "Частота"
	CALL	NumInfOut      ;Вывод числовой информации
	LEA  	SI,TurnDisp    ;Передача параметров 
	MOV 	DX,TOutPort7   ;для вывода информации
	MOV	CX,6           ;на дисплей "Обороты"
	CALL	NumInfOut      ;Вывод числовой информации
	LEA  	SI,KeyDisp     ;Передача параметров
	MOV 	DX,KOutPort14  ;для вывода информации
	MOV	CX,2           ;на дисплей "Скважность"
	CALL	NumInfOut      ;Вывод числовой информации
	CALL	SIMOut         ;Вывод ШИМ-сигнала
	JMP	Count          ;
	ORG	07F0H          ;
Start:	JMP     Begin          ;
Code	ENDS
        END     Start