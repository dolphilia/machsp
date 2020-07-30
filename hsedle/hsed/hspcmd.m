//
//		settings for HSP
//

char s_rec[1]= "";
char *hsp_prestr[] = {
    //
    //	label check
    //	  | opt value
    //	  | |
    //	  | | type
    //	  | | | keyword
    //	  | | |  |
    //	  | | |  |
    //	"$000 8 goto",
    //
    s_rec,
    
    //	program control commands (ver3.0)
    
    (char *)"$000 15 goto",
    (char *)"$001 15 gosub",
    (char *)"$002 15 return",
    (char *)"$003 15 break",
    (char *)"$004 15 repeat",
    (char *)"$005 15 loop",
    (char *)"$006 15 continue",
    (char *)"$007 15 wait",
    (char *)"$008 15 await",
    
    (char *)"$009 15 dim",
    (char *)"$00a 15 sdim",
    //	"$00d 15 skiperr",				// delete
    (char *)"$00b 15 foreach",				// (ver3.0)
    //	"$00c 15 eachchk",				// (ver3.0) hidden
    (char *)"$00d 15 dimtype",				// (ver3.0)
    (char *)"$00e 15 dup",
    (char *)"$00f 15 dupptr",				// (ver3.0)
    
    (char *)"$010 15 end",
    (char *)"$011 15 stop",
    (char *)"$012 15 newmod",				// (ver3.0)
    //	"$013 15 setmod",				// (ver3.0)
    (char *)"$014 15 delmod",				// (ver3.0)
    //	"$015 15 alloc",				// (changed 3.0)
    (char *)"$016 15 mref",					// (ver2.5)
    (char *)"$017 15 run",
    (char *)"$018 15 exgoto",				// ver2.6
    (char *)"$019 15 on",					// ver2.6
    (char *)"$01a 15 mcall",				// (ver3.0)
    (char *)"$01b 15 assert",				// (ver3.0)
    (char *)"$01c 15 logmes",				// (ver3.0)
    (char *)"$01d 15 newlab",				// (ver3.2)
    (char *)"$01e 15 resume",				// (ver3.2)
    (char *)"$01f 15 yield",				// (ver3.2)
    
    //	"$015 15 logmode",				// (ver2.55)
    //	"$016 15 logmes",				// (ver2.55)
    
    //	enhanced command (ver2.6)
    
    (char *)"$10000 8 onexit",
    (char *)"$10001 8 onerror",
    (char *)"$10002 8 onkey",
    (char *)"$10003 8 onclick",
    (char *)"$10004 8 oncmd",
    
    (char *)"$011 8 exist",
    (char *)"$012 8 delete",
    (char *)"$013 8 mkdir",
    (char *)"$014 8 chdir",
    
    (char *)"$015 8 dirlist",
    (char *)"$016 8 bload",
    (char *)"$017 8 bsave",
    (char *)"$018 8 bcopy",
    (char *)"$019 8 memfile",				// (changed on ver2.6*)
    
    //	no macro command (ver2.61)
    //
    (char *)"$000 11 if",
    (char *)"$001 11 else",
    
    //	normal commands
    
    (char *)"$01a 8 poke",
    (char *)"$01b 8 wpoke",
    (char *)"$01c 8 lpoke",
    (char *)"$01d 8 getstr",
    (char *)"$01e 8 chdpm",					// (3.0)
    (char *)"$01f 8 memexpand",				// (3.0)
    (char *)"$020 8 memcpy",				// (ver2.55)
    (char *)"$021 8 memset",				// (ver2.55)
    
    (char *)"$022 8 notesel",				// (changed on ver2.55)
    (char *)"$023 8 noteadd",				// (changed on ver2.55)
    (char *)"$024 8 notedel",				// (changed on ver2.55)
    (char *)"$025 8 noteload",				// (changed on ver2.6*)
    (char *)"$026 8 notesave",				// (changed on ver2.6*)
    (char *)"$027 8 randomize",				// (changed on ver3.0)
    (char *)"$028 8 noteunsel",				// (changed on ver3.0)
    (char *)"$029 8 noteget",				// (changed on ver2.55)
    (char *)"$02a 8 split",					// (3.2)
    (char *)"$02b 8 strrep",				// (3.4)
    (char *)"$02c 8 setease",				// (3.4)
    (char *)"$02d 8 sortval",				// (3.5)
    (char *)"$02e 8 sortstr",				// (3.5)
    (char *)"$02f 8 sortnote",				// (3.5)
    (char *)"$030 8 sortget",				// (3.5)

    
    //	enhanced command (ver2.2)
    
    (char *)"$10000 9 button",
    
    (char *)"$001 9 chgdisp",
    (char *)"$002 9 exec",
    (char *)"$003 9 dialog",
    
    //	"$007 9 palfade",				// delete
    //	"$009 9 palcopy",				// delete
    
    (char *)"$008 9 mmload",
    (char *)"$009 9 mmplay",
    (char *)"$00a 9 mmstop",
    (char *)"$00b 9 mci",
    
    (char *)"$00c 9 pset",
    (char *)"$00d 9 pget",
    (char *)"$00e 9 syscolor",				// (ver3.0)
    
    (char *)"$00f 9 mes", (char *)"$00f 9 print",
    (char *)"$010 9 title",
    (char *)"$011 9 pos",
    (char *)"$012 9 circle",				// (ver3.0)
    (char *)"$013 9 cls",
    (char *)"$014 9 font",
    (char *)"$015 9 sysfont",
    (char *)"$016 9 objsize",
    (char *)"$017 9 picload",
    (char *)"$018 9 color",
    (char *)"$019 9 palcolor",
    (char *)"$01a 9 palette",
    (char *)"$01b 9 redraw",
    (char *)"$01c 9 width",
    (char *)"$01d 9 gsel",
    (char *)"$01e 9 gcopy",
    (char *)"$01f 9 gzoom",
    (char *)"$020 9 gmode",
    (char *)"$021 9 bmpsave",
    
    //	"$022 9 text",					// delete
    
    (char *)"$022 9 hsvcolor",				// (ver3.0)
    (char *)"$023 9 getkey",
    
    (char *)"$024 9 listbox",
    (char *)"$025 9 chkbox",
    (char *)"$026 9 combox",
    
    (char *)"$027 9 input",
    (char *)"$028 9 mesbox",
    (char *)"$029 9 buffer",
    (char *)"$02a 9 screen",
    (char *)"$02b 9 bgscr",
    
    (char *)"$02c 9 mouse",
    (char *)"$02d 9 objsel",
    (char *)"$02e 9 groll",
    (char *)"$02f 9 line",
    
    (char *)"$030 9 clrobj",
    (char *)"$031 9 boxf",
    
    //	enhanced command (ver2.3)
    
    (char *)"$032 9 objprm",
    (char *)"$033 9 objmode",
    (char *)"$034 9 stick",
    //	"$041 9 objsend",				// delete
    (char *)"$035 9 grect",					// (ver3.0)
    (char *)"$036 9 grotate",				// (ver3.0)
    (char *)"$037 9 gsquare",				// (ver3.0)
    (char *)"$038 9 gradf",					// (ver3.2)
    (char *)"$039 9 objimage",				// (ver3.2)
    (char *)"$03a 9 objskip",				// (ver3.2)
    (char *)"$03b 9 objenable",				// (ver3.2)
    (char *)"$03c 9 celload",				// (ver3.2)
    (char *)"$03d 9 celdiv",				// (ver3.2)
    (char *)"$03e 9 celput",				// (ver3.2)
    
    (char *)"$03f 9 gfilter",				// (ver3.5)
    (char *)"$040 9 setreq",				// (ver3.5)
    (char *)"$041 9 getreq",				// (ver3.5)
    (char *)"$042 9 mmvol",					// (ver3.5)
    (char *)"$043 9 mmpan",					// (ver3.5)
    (char *)"$044 9 mmstat",				// (ver3.5)
    (char *)"$045 9 mtlist",				// (ver3.5)
    (char *)"$046 9 mtinfo",				// (ver3.5)
    (char *)"$047 9 devinfo",				// (ver3.5)
    (char *)"$048 9 devinfoi",				// (ver3.5)
    (char *)"$049 9 devprm",				// (ver3.5)
    (char *)"$04a 9 devcontrol",			// (ver3.5)
    (char *)"$04b 9 httpload",				// (ver3.5)
    (char *)"$04c 9 httpinfo",				// (ver3.5)
    (char *)"$05d 9 gmulcolor",				// (ver3.5)
    (char *)"$05e 9 setcls",				// (ver3.5)
    (char *)"$05f 9 celputm",				// (ver3.5)
    
    //================================================================================>>>MacOSX
    //
    // 音声関連
    // 90 qpush
    // 91 qplay 0 or 1
    // 92 qstop
    //
    (char *)"$091 9 qins",   //
    (char *)"$092 9 qpush",  //
    (char *)"$093 9 qstart", //
    (char *)"$094 9 qend",   //
    (char *)"$095 9 qplay",  //
    (char *)"$096 9 qstop",  //
    (char *)"$097 9 qvol",
    //
    (char *)"$0a0 9 slider",
    (char *)"$0a1 9 onmidi",
    //
    (char *)"$0b0 9 box", //矩形ライン（多角形）
    //
    (char *)"$0c0 9 antialiasing", //アンチエリアシング 0 or 1
    (char *)"$0c1 9 smooth", //アンチエリアシング 0 or 1
    //
    // c1 tri //三角形ライン
    // c2 trif //三角形塗りつぶし
    // c3 box
    // c4 polygon //多角形
    //
    //3D関連
    (char *)"$0d0 9 setcam",
    //================================================================================<<<MacOSX
    
    //	enhanced command (ver3.0)
    
    (char *)"$000 17 newcom",
    (char *)"$001 17 querycom",
    (char *)"$002 17 delcom",
    (char *)"$003 17 cnvstow",
    (char *)"$004 17 comres",
    (char *)"$005 17 axobj",
    (char *)"$006 17 winobj",
    (char *)"$007 17 sendmsg",
    (char *)"$008 17 comevent",
    (char *)"$009 17 comevarg",
    (char *)"$00a 17 sarrayconv",
    //"$00b 17 variantref",
    
    (char *)"$100 17 callfunc",
    (char *)"$101 17 cnvwtos",
    (char *)"$102 17 comevdisp",
    (char *)"$103 17 libptr",
    
    //	3.0 system vals
    
    (char *)"$000 14 system",
    (char *)"$001 14 hspstat",
    (char *)"$002 14 hspver",
    (char *)"$003 14 stat",
    (char *)"$004 14 cnt",
    (char *)"$005 14 err",
    (char *)"$006 14 strsize",
    (char *)"$007 14 looplev",					// (ver2.55)
    (char *)"$008 14 sublev",					// (ver2.55)
    (char *)"$009 14 iparam",					// (ver2.55)
    (char *)"$00a 14 wparam",					// (ver2.55)
    (char *)"$00b 14 lparam",					// (ver2.55)
    (char *)"$00c 14 refstr",
    (char *)"$00d 14 refdval",					// (3.0)
    //================================================================================>>>MacOSX
    (char *)"$020 14 dcnt",
    //================================================================================<<<MacOSX
    
    //	3.0 internal function
    (char *)"$000 13 int",
    (char *)"$001 13 rnd",
    (char *)"$002 13 strlen",
    (char *)"$003 13 length",					// (3.0)
    (char *)"$004 13 length2",					// (3.0)
    (char *)"$005 13 length3",					// (3.0)
    (char *)"$006 13 length4",					// (3.0)
    (char *)"$007 13 vartype",					// (3.0)
    (char *)"$008 13 gettime",
    (char *)"$009 13 peek",
    (char *)"$00a 13 wpeek",
    (char *)"$00b 13 lpeek",
    (char *)"$00c 13 varptr",					// (3.0)
    (char *)"$00d 13 varuse",					// (3.0)
    (char *)"$00e 13 noteinfo",					// (3.0)
    (char *)"$00f 13 instr",
    (char *)"$010 13 abs",						// (3.0)
    (char *)"$011 13 limit",					// (3.0)
    (char *)"$012 13 getease",					// (3.4)
    (char *)"$013 13 notefind",					// (3.5)
    
    //================================================================================>>>MacOSX
    (char *)"$020 13 qframe",
    (char *)"$021 13 qcount",
    (char *)"$030 13 clock",
    (char *)"$031 13 isretina",
    (char *)"$040 13 getmousex",
    (char *)"$041 13 getmousey",
    (char *)"$042 13 getmousedown",
    (char *)"$050 13 ginfo",
    //================================================================================<<<MacOSX
    
    //	3.0 string function
    (char *)"$100 13 str",
    (char *)"$101 13 strmid",
    (char *)"$103 13 strf",
    (char *)"$104 13 getpath",
    (char *)"$105 13 strtrim",					// (3.2)
    (char *)"$106 13 getfontfamilies",
    
    //================================================================================>>>MacOSX
    //regexp()
    //================================================================================<<<MacOSX
    
    //	3.0 math function
    (char *)"$180 13 sin",
    (char *)"$181 13 cos",
    (char *)"$182 13 tan",
    (char *)"$183 13 atan",
    (char *)"$184 13 sqrt",
    (char *)"$185 13 double",
    (char *)"$186 13 absf",
    (char *)"$187 13 expf",
    (char *)"$188 13 logf",
    (char *)"$189 13 limitf",
    (char *)"$18a 13 powf",						// (3.3)
    (char *)"$18b 13 geteasef",					// (3.4)
    
    //================================================================================>>>MacOSX
    (char *)"$190 13 qrate",
    (char *)"$191 13 qpi",
    (char *)"$1a0 13 rndf",
    (char *)"$1a1 13 randf",
    (char *)"$1a2 13 getretina",
    //================================================================================<<<MacOSX
    
    
    //	3.0 external sysvar,function
    
    (char *)"$000 10 mousex",
    (char *)"$001 10 mousey",
    (char *)"$002 10 mousew",					// (3.0)
    (char *)"$003 10 hwnd",						// (3.0)
    (char *)"$004 10 hinstance",				// (3.0)
    (char *)"$005 10 hdc",						// (3.0)
    
//    (char *)"$100 10 ginfo",
    (char *)"$101 10 objinfo",
    (char *)"$102 10 dirinfo",
    (char *)"$103 10 sysinfo",
    
    (char *)"$ffffffff 5 thismod",
    
    (char *)"*"
};


char 	*hsp_prepp[] =
{
    s_rec,
    
    (char *)"$000 0 #addition",
    (char *)"$000 0 #cmd",
    (char *)"$000 0 #comfunc",
    (char *)"$000 0 #const",
    (char *)"$000 0 #deffunc",
    (char *)"$000 0 #defcfunc",
    (char *)"$000 0 #define",
    (char *)"$000 0 #else",
    (char *)"$000 0 #endif",
    (char *)"$000 0 #enum",
    (char *)"$000 0 #epack",
    (char *)"$000 0 #func",
    (char *)"$000 0 #cfunc",
    (char *)"$000 0 #global",
    (char *)"$000 0 #if",
    (char *)"$000 0 #ifdef",
    (char *)"$000 0 #ifndef",
    (char *)"$000 0 #include",
    (char *)"$000 0 #modfunc",
    (char *)"$000 0 #modcfunc",					// (3.2)
    (char *)"$000 0 #modinit",
    (char *)"$000 0 #modterm",
    (char *)"$000 0 #module",
    (char *)"$000 0 #pack",
    (char *)"$000 0 #packopt",
    (char *)"$000 0 #regcmd",
    (char *)"$000 0 #runtime",
    (char *)"$000 0 #undef",
    (char *)"$000 0 #usecom",
    (char *)"$000 0 #uselib",
    (char *)"$000 0 #cmpopt",
    (char *)"$000 0 #defint",					// (3.3)
    (char *)"$000 0 #defdouble",
    (char *)"$000 0 #defnone",
    (char *)"$000 0 #bootopt",					// (3.5)
    
    (char *)"*"
};

