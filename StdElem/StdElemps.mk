
StdElemps.dll: dlldata.obj StdElem_p.obj StdElem_i.obj
	link /dll /out:StdElemps.dll /def:StdElemps.def /entry:DllMain dlldata.obj StdElem_p.obj StdElem_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del StdElemps.dll
	@del StdElemps.lib
	@del StdElemps.exp
	@del dlldata.obj
	@del StdElem_p.obj
	@del StdElem_i.obj
