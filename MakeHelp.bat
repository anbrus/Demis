del Help\Demis.hm

makehm ID_,HID_,0x10000 IDM_,HIDM_,0x10000 resource.h >>"Help\Demis.hm"
makehm IDP_,HIDP_,0x30000 resource.h >>"help\Demis.hm"
makehm IDR_,HIDR_,0x20000 resource.h >>"help\Demis.hm"
makehm IDD_,HIDD_,0x20000 resource.h >>"help\Demis.hm"
makehm IDW_,HIDW_,0x50000 resource.h >>"help\Demis.hm"
rem Help\HMFormat Help\Demis.hm
echo Add #define on each line of Help/Demis.hm and press any key
pause
echo Created Demis.hm

cd Help
"%programfiles(x86)%\HTML Help Workshop\hhc" Demis.hhp
move Demis.chm ..\%1
echo Created Demis.chm


