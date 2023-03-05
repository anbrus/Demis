; В этом модуле собраны все процедуры
; так или иначе относящиеся к отображению 
; информации на знакосинтезирующем 
; дисплее

; Вывод на дисплей нуля
DispClear  PROC  NEAR
           PUSH  AX DI
           LEA   DI,Str

           MOV   AL,12
           MOV   CX,10
DC_cyc:    STOSB                     ; остальные отображаемые - пустые
           LOOP  DC_cyc

           XOR   AL,AL
           STOSB                     ; введено 0 разрядов перед зарятой
           STOSB                     ; точки нет

           MOV   AL,0FFh
           STOSB                     ; строку надо вводить заново
           
           XOR   AL,AL
           STOSB                     ; введено 0 разрядов после запятой
           POP   DI AX
           RET
DispClear  ENDP

; Вывод на дисплей нуля
DispZero   PROC  NEAR
           PUSH  AX DI
           LEA   DI,Str

           XOR   AL,AL
           STOSB                     ; младший разряд - нулевой

           MOV   AL,12
           MOV   CX,9
DZ_cyc:    STOSB                     ; остальные отображаемые - пустые
           LOOP  DZ_cyc

           XOR   AL,AL
           STOSB                     ; введено 0 разрядов перед зарятой
           
           MOV   AL,0FFh
           STOSB                     ; точку вводить нельзя нет
           STOSB                     ; строку надо вводить заново
           
           MOV   AL,1
           STOSB                     ; введено 1 разряд после запятой
           POP   DI AX
           RET
DispZero   ENDP

; Установка на дисплее нулевого времени
DispTimeZero PROC  NEAR
           CMP   ActButCode,Clr
           JNZ   DTZ_end
           
           PUSH  AX DI
           LEA   DI,Str

           MOV   AL,13
           STOSB                     ; минуты в нуле
           STOSB

           MOV   AL,11
           STOSB                     ; тере между минутами и часами
           
           MOV   AL,13
           STOSB                     ; часы в нуле
           STOSB
           
           MOV   AL,12
           MOV   CX,5
DTZ_cyc:   STOSB                     ; остальные отображаемые - пустые
           LOOP  DTZ_cyc

           XOR   AL,AL
           STOSB                     ; введено 0 разрядов перед зарятой
           STOSB                     ; точки нет
           STOSB                     ; строку надо вводить заново
           
           XOR   AL,AL
           STOSB                     ; введено 0 разрядов после запятой
           POP   DI AX
DTZ_end:   RET
DispTimeZero ENDP

DispDateZero PROC  NEAR
           CMP   ActButCode,Clr
           JNZ   DDZ_end
           
           PUSH  AX DI
           LEA   DI,Str

           MOV   AL,13
           STOSB                     ; день в нуле
           STOSB

           MOV   AL,11
           STOSB                     ; тере между днем и месяцем
           
           MOV   AL,13
           STOSB                     ; месяц в нуле
           STOSB
           
           MOV   AL,11
           STOSB                     ; тере между месяцем и годом
           
           MOV   AL,13
           STOSB                     ; год в нуле
           STOSB
           
           MOV   AL,12
           MOV   CX,2
DDZ_cyc:   STOSB                     ; остальные отображаемые - пустые
           LOOP  DDZ_cyc

           XOR   AL,AL
           STOSB                     ; введено 0 разрядов перед зарятой
           STOSB                     ; точки нет
           STOSB                     ; строку надо вводить заново
           
           XOR   AL,AL
           STOSB                     ; введено 0 разрядов после запятой
           MOV   Error,0
           POP   DI AX
DDZ_end:   RET
DispDateZero ENDP