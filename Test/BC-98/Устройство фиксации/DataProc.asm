FindNextMin PROC NEAR
;          Установить значение DataVisioPointNum на след. минимум.
            mov   bx,Word Ptr DataVisioPointNum
            mov   dx,bx
            shl   bx,1        ;mul 2
            mov   ax,DataFixedValue[bx]                     
            inc   bx
            inc   bx
            
     fnmin1:mov   cx,bx
            shr   cx,1
            cmp   cx,word ptr MaxPointNumber
            je    Ovflfnmin
            cmp   ax,DataFixedValue[bx]                     
            ja    _efnmin1   
            mov   ax,DataFixedValue[bx]
            inc   bx          
            inc   bx          
            jmp   fnmin1                  
            
   _efnmin1:mov   ax,DataFixedValue[bx]
;            inc   bx
;            inc   bx
            
     fnmin2:mov   cx,bx
            shr   cx,1
            cmp   cx,word ptr MaxPointNumber
            je    Ovflfnmin
            cmp   ax,DataFixedValue[bx]                     
            jb    _efnmin2   
            mov   ax,DataFixedValue[bx]
            inc   bx          
            inc   bx          
            jmp   fnmin2        
            
   _efnmin2:shr   bx,1           
            dec   bx
            mov   word ptr DataVisioPointNum,bx            
            jmp  _efnmin3  
           
  Ovflfnmin:mov   word ptr DataVisioPointNum,dx                       
   _efnmin3:ret;
FindNextMin ENDP

FindPredMin PROC NEAR
;          Установить значение DataVisioPointNum на пред. минимум.
            mov   bx,Word Ptr DataVisioPointNum
            mov   dx,bx
            shl   bx,1        ;mul 2
            mov   ax,DataFixedValue[bx]                     
            dec   bx
            dec   bx
            
     fpmin1:mov   cx,bx
            shr   cx,1
            cmp   cx,0h
            je    Ovflfpmin
            cmp   ax,DataFixedValue[bx]                     
            ja   _efpmin1   
            mov   ax,DataFixedValue[bx]
            dec   bx          
            dec   bx          
            jmp   fpmin1                  

   _efpmin1:mov   ax,DataFixedValue[bx]
;            dec   bx
;            dec   bx
            
     fpmin2:mov   cx,bx
            shr   cx,1
            cmp   cx,0h
            je    Ovflfpmin
            cmp   ax,DataFixedValue[bx]                     
            jb    _efpmin2   
            mov   ax,DataFixedValue[bx]
            dec   bx          
            dec   bx          
            jmp   fpmin2        
            
   _efpmin2:shr   bx,1           
            inc   bx
            mov   word ptr DataVisioPointNum,bx            
            jmp  _efpmin3  
            
  Ovflfpmin:mov   word ptr DataVisioPointNum,dx                       
   _efpmin3:ret;
FindPredMin ENDP

FindNextMax PROC NEAR
;          Установить значение DataVisioPointNum на след. максимум.
            mov   bx,Word Ptr DataVisioPointNum
            mov   dx,bx
            shl   bx,1        ;mul 2
            mov   ax,DataFixedValue[bx]                     
            inc   bx
            inc   bx
            
     fnmax1:mov   cx,bx
            shr   cx,1
            cmp   cx,word ptr MaxPointNumber
            je    Ovflfnmax
            cmp   ax,DataFixedValue[bx]                     
            jb    _efnmax1   
            mov   ax,DataFixedValue[bx]
            inc   bx          
            inc   bx          
            jmp   fnmax1                  
            
   _efnmax1:mov   ax,DataFixedValue[bx]
;           inc   bx
;           inc   bx
            
     fnmax2:mov   cx,bx
            shr   cx,1
            cmp   cx,word ptr MaxPointNumber
            je    Ovflfnmax
            cmp   ax,DataFixedValue[bx]                     
            ja    _efnmax2   
            mov   ax,DataFixedValue[bx]
            inc   bx          
            inc   bx          
            jmp   fnmax2        
            
   _efnmax2:shr   bx,1           
            dec   bx
            mov   word ptr DataVisioPointNum,bx            
            jmp  _efnmax3  
           
  Ovflfnmax:mov   word ptr DataVisioPointNum,dx                       
   _efnmax3:ret;                                
FindNextMax ENDP

FindPredMax PROC NEAR
;          Установить значение DataVisioPointNum на пред. максимум.
            mov   bx,Word Ptr DataVisioPointNum
            mov   dx,bx
            shl   bx,1        ;mul 2
            mov   ax,DataFixedValue[bx]                     
            dec   bx
            dec   bx
            
     fpmax1:mov   cx,bx
            shr   cx,1
            cmp   cx,0h
            je    Ovflfpmax
            cmp   ax,DataFixedValue[bx]                     
            jb   _efpmax1   
            mov   ax,DataFixedValue[bx]
            dec   bx          
            dec   bx          
            jmp   fpmax1                  

   _efpmax1:mov   ax,DataFixedValue[bx]
;            dec   bx
;            dec   bx
            
     fpmax2:mov   cx,bx
            shr   cx,1
            cmp   cx,0h
            je    Ovflfpmax
            cmp   ax,DataFixedValue[bx]                     
            ja    _efpmax2   
            mov   ax,DataFixedValue[bx]
            dec   bx          
            dec   bx          
            jmp   fpmax2        
            
   _efpmax2:shr   bx,1           
            inc   bx
            mov   word ptr DataVisioPointNum,bx            
            jmp  _efpmax3  
            
  Ovflfpmax:mov   word ptr DataVisioPointNum,dx                       
   _efpmax3:ret;
FindPredMax ENDP

CalcFirstProizv PROC NEAR
;          Вычислить значение 1-ой производной в точке DataVisioPointNum            
           mov  FirstValue, 0h;
           cmp  word ptr DataVisioPointNum,0h
           je   _end 
           mov  ax,word ptr MaxPointNumber                      
           cmp  word ptr DataVisioPointNum,ax
           je   _end 
           mov  bx,word ptr DataVisioPointNum 
           shl  bx,1                          ;mul 2
           mov  ax,DataFixedValue[bx-2]
           cmp  ax,DataFixedValue[bx+2]           
           ja   _Fp
           mov  ax,DataFixedValue[bx+2]
           sub  ax,DataFixedValue[bx-2]             
           mov  IsFOtr,0
           jmp _Fp1
       _Fp:sub  ax,DataFixedValue[bx+2]                            
           mov  IsFOtr,1
      _Fp1:xor  dx,dx
           div  word ptr DataFixedPeriod   
           shr  ax,1 
           mov  FirstValue,ax                                             
      _end:ret;
CalcFirstProizv ENDP

CalcSecondProizv PROC NEAR
;          Вычислить значение 2-ой производной в точке DataVisioPointNum 
           mov  SecondValue, 0h;
           cmp  word ptr DataVisioPointNum,1h
           jbe   _endsec 
           mov  ax,word ptr MaxPointNumber   
           dec  ax                   
           cmp  word ptr DataVisioPointNum,ax
           jae   _endsec 
           mov  bx,word ptr DataVisioPointNum 
           shl  bx,1                          ; mul 2
           mov  ax,word ptr DataFixedPeriod    
           mul  word ptr DataFixedPeriod
           mov  cx,ax   
           mov  dx,DataFixedValue[bx] 
           shl  dx,1                          ; mul 2                      
           mov  ax,DataFixedValue[bx-4]       ; 2*2
           add  ax,DataFixedValue[bx+4]       ; 0 + 4           
           cmp  ax,dx
           jae   _Sp
           xchg ax,dx
           sub  ax,dx
           mov  IsSOtr,1             
           jmp _Sp1
       _Sp:sub  ax,dx                            
           mov  IsSOtr,0 
      _Sp1:xor  dx,dx
           shl  cx,2                                  
           div  cx              
           mov  SecondValue,ax                                             
    _endsec:ret;
CalcSecondProizv ENDP

UpDateDataFields PROC NEAR
           push bx;
           push si;
           
           lea bx, DataFixedValue;
           mov si, Word Ptr DataVisioPointNum;
           shl si, 1
           mov ax, [bx + si]
           mov DataValue, ax;
           
           call CalcFirstProizv;
           call CalcSecondProizv;
           
           mov Byte Ptr IsPointNumUpDate, 00h;
           
           pop si;
           pop bx;
           ret;
UpDateDataFields ENDP;