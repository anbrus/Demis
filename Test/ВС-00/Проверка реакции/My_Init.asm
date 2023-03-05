
Initilize  Proc  Near            
           mov   Error[0]  , 73h  ; 
           mov   Error[1]  , 60h 
           mov   Error[2]  , 60h 
           mov   Error[3]  ,  0h 
           
           mov   Digit_s[0 ], 03Fh
           mov   Digit_s[1 ], 00Ch
           mov   Digit_s[2 ], 076h
           mov   Digit_s[3 ], 05Eh
           mov   Digit_s[4 ], 04Dh
           mov   Digit_s[5 ], 05Bh
           mov   Digit_s[6 ], 07Bh
           mov   Digit_s[7 ], 00Eh
           mov   Digit_s[8 ], 07Fh
           mov   Digit_s[9 ], 05Fh
           
           mov   Letters[0]  ,1Ch  ; Буква  "А"            
           mov   Letters[1]  ,22h
           mov   Letters[2]  ,22h
           mov   Letters[3]  ,3Eh
           mov   Letters[4]  ,22h
           mov   Letters[5]  ,22h
           mov   Letters[6]  ,22h
           
           mov   Letters[7]  ,3Eh  ; Буква  "Б"
           mov   Letters[8]  ,22h
           mov   Letters[9]  ,02h
           mov   Letters[10] ,1Eh
           mov   Letters[11] ,22h
           mov   Letters[12] ,22h
           mov   Letters[13] ,1Eh
           
           mov   Letters[14] ,1Eh  ; Буква  "В" 
           mov   Letters[15] ,22h
           mov   Letters[16] ,22h
           mov   Letters[17] ,1Eh
           mov   Letters[18] ,22h
           mov   Letters[19] ,22h
           mov   Letters[20] ,1Eh
           
           mov   Letters[21] ,3Eh  ; Буква  "Г" 
           mov   Letters[22] ,22h
           mov   Letters[23] ,02h
           mov   Letters[24] ,02h
           mov   Letters[25] ,02h
           mov   Letters[26] ,02h
           mov   Letters[27] ,02h
           
           mov   Letters[28] ,18h  ; Буква  "Д" 
           mov   Letters[29] ,14h
           mov   Letters[30] ,14h
           mov   Letters[31] ,14h
           mov   Letters[32] ,14h
           mov   Letters[33] ,3Eh
           mov   Letters[34] ,22h
           
           mov   Letters[35] ,3Eh  ; Буква  "Е"
           mov   Letters[36] ,22h
           mov   Letters[37] ,02h
           mov   Letters[38] ,1Eh
           mov   Letters[39] ,02h
           mov   Letters[40] ,22h
           mov   Letters[41] ,3Eh
           
           mov   Letters[42] ,2Ah  ; Буква  "Ж"
           mov   Letters[43] ,2Ah
           mov   Letters[44] ,2Ah
           mov   Letters[45] ,1Ch
           mov   Letters[46] ,2Ah
           mov   Letters[47] ,2Ah
           mov   Letters[48] ,2Ah
           
           mov   Letters[49] ,1Ch  ; Буква  "З"
           mov   Letters[50] ,22h
           mov   Letters[51] ,20h
           mov   Letters[52] ,1Ch
           mov   Letters[53] ,20h
           mov   Letters[54] ,22h
           mov   Letters[55] ,1Ch
           
           mov   Letters[56] ,22h  ; Буква  "И" 
           mov   Letters[57] ,22h
           mov   Letters[58] ,22h
           mov   Letters[59] ,32h
           mov   Letters[60] ,2Ah
           mov   Letters[61] ,26h
           mov   Letters[62] ,22h
           
           mov   Letters[63] ,2Ah  ; Буква  "Й" 
           mov   Letters[64] ,22h
           mov   Letters[65] ,22h
           mov   Letters[66] ,32h
           mov   Letters[67] ,2Ah
           mov   Letters[68] ,26h
           mov   Letters[69] ,22h
          
           mov   Letters[63] ,2Ah  ; Буква  "Й" 
           mov   Letters[64] ,22h
           mov   Letters[65] ,22h
           mov   Letters[66] ,32h
           mov   Letters[67] ,2Ah
           mov   Letters[68] ,26h
           mov   Letters[69] ,22h 
           
           mov   Letters[70] ,22h  ; Буква  "К" 
           mov   Letters[71] ,12h
           mov   Letters[72] ,0Ah
           mov   Letters[73] ,06h
           mov   Letters[74] ,0Ah
           mov   Letters[75] ,12h
           mov   Letters[76] ,22h
           
           mov   Letters[77] ,38h  ; Буква  "Л" 
           mov   Letters[78] ,24h
           mov   Letters[79] ,22h
           mov   Letters[80] ,22h
           mov   Letters[81] ,22h
           mov   Letters[82] ,22h
           mov   Letters[83] ,22h
           
           mov   Letters[84] ,22h  ; Буква  "М" 
           mov   Letters[85] ,36h
           mov   Letters[86] ,2Ah
           mov   Letters[87] ,2Ah
           mov   Letters[88] ,22h
           mov   Letters[89] ,22h
           mov   Letters[90] ,22h
           
           mov   Letters[91] ,22h  ; Буква  "Н" 
           mov   Letters[92] ,22h
           mov   Letters[93] ,22h
           mov   Letters[94] ,3Eh
           mov   Letters[95] ,22h
           mov   Letters[96] ,22h
           mov   Letters[97] ,22h
           
           mov   Letters[98] ,1Ch  ; Буква  "О" 
           mov   Letters[99] ,22h
           mov   Letters[100],22h
           mov   Letters[101],22h
           mov   Letters[102],22h
           mov   Letters[103],22h
           mov   Letters[104],1Ch
           
           mov   Letters[105] ,3Eh  ; Буква  "П" 
           mov   Letters[106] ,22h
           mov   Letters[107] ,22h
           mov   Letters[108] ,22h
           mov   Letters[109] ,22h
           mov   Letters[110] ,22h
           mov   Letters[111] ,22h
           
           mov   Letters[112] ,1Eh  ; Буква  "Р" 
           mov   Letters[113] ,22h
           mov   Letters[114] ,22h
           mov   Letters[115] ,1Eh
           mov   Letters[116] ,02h
           mov   Letters[117] ,02h
           mov   Letters[118] ,02h
           
           mov   Letters[119] ,3Eh  ; Буква  "С" 
           mov   Letters[120] ,22h
           mov   Letters[121] ,02h
           mov   Letters[122] ,02h
           mov   Letters[123] ,02h
           mov   Letters[124] ,22h
           mov   Letters[125] ,3Eh
           
           mov   Letters[126] ,3Eh  ; Буква  "T" 
           mov   Letters[127] ,2Ah
           mov   Letters[128] ,08h
           mov   Letters[129] ,08h
           mov   Letters[130] ,08h
           mov   Letters[131] ,08h
           mov   Letters[132] ,08h
                      
           mov   Letters[133] ,22h  ; Буква  "У" 
           mov   Letters[134] ,22h
           mov   Letters[135] ,22h
           mov   Letters[136] ,3Ch
           mov   Letters[137] ,20h
           mov   Letters[138] ,20h
           mov   Letters[139] ,1Ch
           
           mov   Letters[140] ,3Eh  ; Буква  "Ф"            
           mov   Letters[141] ,2Ah
           mov   Letters[142] ,2Ah
           mov   Letters[143] ,2Ah
           mov   Letters[144] ,3Eh
           mov   Letters[145] ,08h
           mov   Letters[146] ,08h
           
           mov   Letters[147] ,22h  ; Буква  "Х"            
           mov   Letters[148] ,22h
           mov   Letters[149] ,14h
           mov   Letters[150] ,08h
           mov   Letters[151] ,14h
           mov   Letters[152] ,22h
           mov   Letters[153] ,22h
           
           mov   Letters[154] ,12h  ; Буква  "Ц"            
           mov   Letters[155] ,12h
           mov   Letters[156] ,12h
           mov   Letters[157] ,12h
           mov   Letters[158] ,12h
           mov   Letters[159] ,3Eh
           mov   Letters[160] ,20h
           
           mov   Letters[161] ,22h  ; Буква  "Ч"            
           mov   Letters[162] ,22h
           mov   Letters[163] ,22h
           mov   Letters[164] ,3Ch
           mov   Letters[165] ,20h
           mov   Letters[166] ,20h
           mov   Letters[167] ,20h
           
           mov   Letters[168] ,2Ah  ; Буква  "Ш"            
           mov   Letters[169] ,2Ah
           mov   Letters[170] ,2Ah
           mov   Letters[171] ,2Ah
           mov   Letters[172] ,2Ah
           mov   Letters[173] ,2Ah
           mov   Letters[174] ,3Eh
           
           mov   Letters[175] ,2Ah  ; Буква  "Щ"            
           mov   Letters[176] ,2Ah
           mov   Letters[177] ,2Ah
           mov   Letters[178] ,2Ah
           mov   Letters[179] ,2Ah
           mov   Letters[180] ,7Eh
           mov   Letters[181] ,40h
           
           mov   Letters[182] ,03h  ; Буква  "Ъ"            
           mov   Letters[183] ,02h
           mov   Letters[184] ,02h
           mov   Letters[185] ,1Eh
           mov   Letters[186] ,22h
           mov   Letters[187] ,22h
           mov   Letters[188] ,1Eh
           
           mov   Letters[189] ,22h  ; Буква  "Ы"            
           mov   Letters[190] ,22h
           mov   Letters[191] ,26h
           mov   Letters[192] ,2Ah
           mov   Letters[193] ,2Ah
           mov   Letters[194] ,2Ah
           mov   Letters[195] ,2Eh
           
           mov   Letters[196] ,02h  ; Буква  "Ь"            
           mov   Letters[197] ,02h
           mov   Letters[198] ,02h
           mov   Letters[199] ,1Eh
           mov   Letters[200] ,22h
           mov   Letters[201] ,22h
           mov   Letters[202] ,1Eh
           
           mov   Letters[203] ,1Eh  ; Буква  "Э"            
           mov   Letters[204] ,20h
           mov   Letters[205] ,20h
           mov   Letters[206] ,3Ch
           mov   Letters[207] ,20h
           mov   Letters[208] ,20h
           mov   Letters[209] ,1Eh
           
           mov   Letters[210] ,12h  ; Буква  "Ю"            
           mov   Letters[211] ,2Ah
           mov   Letters[212] ,2Ah
           mov   Letters[213] ,2Eh
           mov   Letters[214] ,2Ah
           mov   Letters[215] ,2Ah
           mov   Letters[216] ,12h
           
           mov   Letters[217] ,3Ch  ; Буква  "Я"            
           mov   Letters[218] ,22h
           mov   Letters[219] ,22h
           mov   Letters[220] ,3Ch
           mov   Letters[221] ,30h
           mov   Letters[222] ,28h
           mov   Letters[223] ,26h
           
           mov   Letters[224] ,0h  ; Буква  " " 
           mov   Letters[225] ,0h
           mov   Letters[226] ,0h
           mov   Letters[227] ,0h
           mov   Letters[228] ,0h
           mov   Letters[229] ,0h
           mov   Letters[230] ,0h                                                   
           
           Call Init
           Ret
Initilize  EndP