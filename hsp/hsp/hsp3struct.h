
//
//		Structure for HSP
//
#ifndef __hsp3struct_h
#define __hsp3struct_h

#include "hsp3struct_var.h"
#include "hsp3struct_debug.h"

#ifdef _WIN64
#define PTR64BIT // ポインタは64bit
#else
#define PTR32BIT // ポインタは32bit
#endif

// command type
#define TYPE_MARK           0 // 記号(code = 文字コード)
#define TYPE_VAR            1 // ユーザー定義変数(code = 変数ID)
#define TYPE_STRING         2 // 文字列(code = DSオフセット)
#define TYPE_DNUM           3 // 実数値(code = DSオフセット)
#define TYPE_INUM           4 // 整数値(code = 値)
#define TYPE_STRUCT         5 // モジュール変数・構造体(code = minfoID)
#define TYPE_XLABEL         6 // 未使用
#define TYPE_LABEL          7 // ラベル名(code = OTオフセット)
#define TYPE_INTCMD         8 // 内蔵命令(code = コマンドID)
#define TYPE_EXTCMD         9 // 拡張命令(code = コマンドID)
#define TYPE_EXTSYSVAR     10 // 拡張システム変数(code = コマンドID)
#define TYPE_CMPCMD        11 // 比較命令(code = コマンドID)
#define TYPE_MODCMD        12 // ユーザー命令/関数(code = コマンドID)
#define TYPE_INTFUNC       13 // 内蔵関数(code = コマンドID)
#define TYPE_SYSVAR        14 // 内蔵システム変数(code = コマンドID)
#define TYPE_PROGCMD       15 // プログラム制御命令(code = コマンドID)
#define TYPE_DLLFUNC       16 // DLL拡張命令/関数(code = コマンドID)
#define TYPE_DLLCTRL       17 // DLLコントロール命令(code = コマンドID)
#define TYPE_USERDEF       18 // HSP3拡張プラグイン命令(code = コマンドID)
#define TYPE_ERROR         -1
#define TYPE_CALCERROR     -2
#define PARAM_OK            0
#define PARAM_SPLIT        -1
#define PARAM_END          -2
#define PARAM_DEFAULT      -3
#define PARAM_ENDSPLIT     -4
#define HSP3_FUNC_MAX      18
#define HSP3_TYPE_USER     18
#define EXFLG_0        0x1000
#define EXFLG_1        0x2000
#define EXFLG_2        0x4000
#define EXFLG_3        0x8000
#define CSTYPE         0x0fff

// HSP3.0 ヘッダー構造体
typedef struct hsp_header_t {
    char h1;          // H
    char h2;          // S
    char h3;          // P
    char h4;          // 3
    int version;      // バージョン番号の情報
    int max_val;      // VALオブジェクトの最大数
    int allsize;      // 合計ファイルサイズ
    int pt_cs;        // コード領域のオフセット
    int max_cs;       // コード領域のサイズ
    int pt_ds;        // データ領域のオフセット
    int max_ds;       // データ領域のサイズ
    int pt_ot;        // ラベル情報のオフセット
    int max_ot;       // ラベル情報のサイズ
    int pt_dinfo;     // 行番号情報のオフセット
    int max_dinfo;    // 行番号情報のサイズ
    int pt_linfo;     // ライブラリ情報のオフセット(2.3)
    int max_linfo;    // ライブラリ情報のサイズ(2.3)
    int pt_finfo;     // 関数情報のオフセット(2.3)
    int max_finfo;    // 関数情報のサイズ(2.3)
    int pt_minfo;     // モジュール情報のオフセット(2.5)
    int max_minfo;    // モジュール情報のサイズ(2.5)
    int pt_finfo2;    // 関数情報のオフセット2(2.5)
    int max_finfo2;   // 関数情報のサイズ2(2.5)
    int pt_hpidat;    // HPIデータのオフセット(3.0)
    short max_hpi;    // HPIデータのサイズ(3.0)
    short max_varhpi; // 変数型プラグインの数(3.0)
    int bootoption;   // 起動オプション
    int runtime;      // ランタイム名のオフセット
    int pt_sr;        // オプション領域のオフセット
    int max_sr;       // オプション領域のサイズ
    int opt1;         // 追加オプション領域のオフセット (3.6)
    int opt2;         // 追加オプション領域のサイズ (3.6)
} hsp_header_t;

#define HSPHED_BOOTOPT_DEBUGWIN       1 // 起動時デバッグウインドゥ表示
#define HSPHED_BOOTOPT_WINHIDE        2 // 起動時ウインドゥ非表示
#define HSPHED_BOOTOPT_DIRSAVE        4 // 起動時カレントディレクトリ変更なし
#define HSPHED_BOOTOPT_SAVER      0x100 // スクリーンセーバー
#define HSPHED_BOOTOPT_RUNTIME   0x1000 // 動的ランタイムを有効にする
#define HSPHED_BOOTOPT_NOMMTIMER 0x2000 // マルチメディアタイマーを無効にする
#define HSPHED_BOOTOPT_NOGDIP    0x4000 // GDI+による描画を無効にする
#define HSPHED_BOOTOPT_FLOAT32   0x8000 // 実数を32bit floatとして処理する
#define HSPHED_BOOTOPT_ORGRND   0x10000 // 標準の乱数発生を使用する
#define HPIDAT_FLAG_TYPEFUNC          0
#define HPIDAT_FLAG_SELFFUNC         -1
#define HPIDAT_FLAG_VARFUNC           1
#define HPIDAT_FLAG_DLLFUNC           2

// native HPIDAT
typedef struct MEM_HPIDAT {
    short flag;   // flag info
    short option;
    int libname;  // lib name index (DS)
    int funcname; // function name index (DS)
    void *libptr; // lib handle
} MEM_HPIDAT;

#ifdef PTR64BIT
typedef struct HPIDAT {
    short flag; // flag info
    short option;
    int libname;  // lib name index (DS)
    int funcname; // function name index (DS)
    int p_libptr; // lib handle
    
} HPIDAT;
#else
typedef MEM_HPIDAT HPIDAT;
#endif

#define LIBDAT_FLAG_NONE 0
#define LIBDAT_FLAG_DLL 1
#define LIBDAT_FLAG_DLLINIT 2
#define LIBDAT_FLAG_MODULE 3
#define LIBDAT_FLAG_COMOBJ 4

typedef struct LIBDAT {
    int flag;    // initalize flag
    int nameidx; // function name index (DS)
    // Interface IID ( Com Object )
    void *handle; // Lib handle
    int clsid;  // CLSID (DS) ( Com Object )
} library_t;

#ifdef PTR64BIT
typedef struct HED_LIBDAT {
    int flag;    // initalize flag
    int nameidx; // function name index (DS)
    // Interface IID ( Com Object )
    int p_hlib; // Lib handle
    int clsid;  // CLSID (DS) ( Com Object )
} HED_LIBDAT;
#else
typedef library_t HED_LIBDAT;
#endif

// multi parameter type
#define MPTYPE_NONE 0
#define MPTYPE_VAR 1
#define MPTYPE_STRING 2
#define MPTYPE_DNUM 3
#define MPTYPE_INUM 4
#define MPTYPE_STRUCT 5
#define MPTYPE_LABEL 7
#define MPTYPE_LOCALVAR -1
#define MPTYPE_ARRAYVAR -2
#define MPTYPE_SINGLEVAR -3
#define MPTYPE_FLOAT -4
#define MPTYPE_STRUCTTAG -5
#define MPTYPE_LOCALSTRING -6
#define MPTYPE_MODULEVAR -7
#define MPTYPE_PPVAL -8
#define MPTYPE_PBMSCR -9
#define MPTYPE_PVARPTR -10
#define MPTYPE_IMODULEVAR -11
#define MPTYPE_IOBJECTVAR -12
#define MPTYPE_LOCALWSTR -13
#define MPTYPE_FLEXSPTR -14
#define MPTYPE_FLEXWPTR -15
#define MPTYPE_PTR_REFSTR -16
#define MPTYPE_PTR_EXINFO -17
#define MPTYPE_PTR_DPMINFO -18
#define MPTYPE_NULLPTR -19
#define MPTYPE_TMODULEVAR -20
//#define MPTYPE_PTR_HWND -14
//#define MPTYPE_PTR_HDC -15
//#define MPTYPE_PTR_HINST -16
#define STRUCTPRM_SUBID_STACK -1
#define STRUCTPRM_SUBID_STID -2
#define STRUCTPRM_SUBID_DLL -3
#define STRUCTPRM_SUBID_DLLINIT -4
#define STRUCTPRM_SUBID_OLDDLL -5
#define STRUCTPRM_SUBID_OLDDLLINIT -6
#define STRUCTPRM_SUBID_COMOBJ -7
#define STRUCTCODE_THISMOD -1
#define TYPE_OFFSET_COMOBJ 0x1000

typedef struct STRUCTPRM {
    short mptype; // Parameter type
    short subid;  // struct index
    int offset;   // offset from top
} struct_param_t;

//	DLL function flags
#define STRUCTDAT_OT_NONE 0
#define STRUCTDAT_OT_CLEANUP 1
#define STRUCTDAT_OT_STATEMENT 2
#define STRUCTDAT_OT_FUNCTION 4

//	Module function flags
#define STRUCTDAT_INDEX_FUNC -1
#define STRUCTDAT_INDEX_CFUNC -2
#define STRUCTDAT_INDEX_STRUCT -3
#define STRUCTDAT_FUNCFLAG_CLEANUP 0x10000

// function,module specific data

#ifdef PTR64BIT
typedef struct STRUCTDAT
{
    short index;  // base LIBDAT index
    short subid;  // struct index
    int prmindex; // STRUCTPRM index(MINFO)
    int prmmax;   // number of STRUCTPRM
    int nameidx;  // name index (DS)
    int size;     // struct size (stack)
    int otindex;  // OT index(Module) / cleanup flag(Dll)
    void* proc;   // proc address
    int funcflag; // function flags(Module)
} STRUCTDAT;

typedef struct HED_STRUCTDAT
{
    short index;  // base LIBDAT index
    short subid;  // struct index
    int prmindex; // STRUCTPRM index(MINFO)
    int prmmax;   // number of STRUCTPRM
    int nameidx;  // name index (DS)
    int size;     // struct size (stack)
    int otindex;  // OT index(Module) / cleanup flag(Dll)
    int funcflag; // function flags(Module)
} HED_STRUCTDAT;

#else
typedef struct STRUCTDAT {
    short index;  // base LIBDAT index
    short subid;  // struct index
    int prmindex; // STRUCTPRM index(MINFO)
    int prmmax;   // number of STRUCTPRM
    int nameidx;  // name index (DS)
    int size;     // struct size (stack)
    int otindex;  // OT index(Module) / cleanup flag(Dll)
    union {
        void *proc;   // proc address
        int funcflag; // function flags(Module)
    };
} struct_data_t;
typedef struct_data_t HED_STRUCTDAT;
#endif

//	Var Data for Multi Parameter
typedef struct MPVarData {
    value_t *pval;
    int aptr;
} multi_param_var_data_t;

//	Var Data for Module Function
typedef struct MPModVarData {
    short subid;
    short magic;
    value_t *pval;
    int aptr;
} multi_param_module_var_data_t;

#define MODVAR_MAGICCODE 0x55aa
#define IRQ_FLAG_NONE 0
#define IRQ_FLAG_DISABLE 1
#define IRQ_FLAG_ENABLE 2
#define IRQ_OPT_GOTO 0
#define IRQ_OPT_GOSUB 1
#define IRQ_OPT_CALLBACK 2

typedef struct IRQDAT {
    short flag;                                 // flag
    short opt;                                  // option value
    int custom;                                 // custom message value
    int custom2;                                // custom message value2
    int iparam;                                 // iparam option
    unsigned short *ptr;                        // jump ptr
    void (*callback)(struct IRQDAT *, int, int); // IRQ callback function
} IRQDAT;

typedef struct hsp_context_t HSPContext;

//	Plugin info data (3.0 compatible)
typedef struct HSP_ExtraInfomation_30 {
    //		HSP internal info data (2.6)
    //
    short ver; // Version Code
    short min; // Minor Version
    //
    int *er;      // Not Use
    char *pstr;   // String Buffer (master)
    char *stmp;   // String Buffer (sub)
    value_t **mpval; // Master PVAL
    //
    int *actscr;  // Active Window ID
    int *nptype;  // Next Parameter Type
    int *npval;   // Next Parameter Value
    int *strsize; // StrSize Buffer
    char *refstr; // RefStr Buffer
    //
    void *(*HspFunc_prm_getv)(void);

    int (*HspFunc_prm_geti)(void);

    int (*HspFunc_prm_getdi)(const int defval);

    char *(*HspFunc_prm_gets)(void);

    char *(*HspFunc_prm_getds)(const char *defstr);

    int (*HspFunc_val_realloc)(value_t *pv, int size, int mode);

    int (*HspFunc_fread)(char *fname, void *readmem, int rlen, int seekofs);

    int (*HspFunc_fsize)(char *fname);

    void *(*HspFunc_getbmscr)(int wid);

    int (*HspFunc_getobj)(int wid, int id, void *inf);

    int (*HspFunc_setobj)(int wid, int id, const void *inf);

    //		HSP internal info data (3.0)
    //
    int *npexflg;       // Next Parameter ExFlg
    HSPContext *hspctx; // HSP context ptr

    //		Enhanced data (3.0)
    //
    int (*HspFunc_addobj)(int wid);

    void (*HspFunc_puterror)(HSPERROR error);

    hspvar_proc_t *(*HspFunc_getproc)(int type);

    hspvar_proc_t *(*HspFunc_seekproc)(const char *name);

    void (*HspFunc_prm_next)(void);

    int (*HspFunc_prm_get)(void);

    double (*HspFunc_prm_getd)(void);

    double (*HspFunc_prm_getdd)(double defval);

    unsigned short *(*HspFunc_prm_getlb)(void);

    value_t *(*HspFunc_prm_getpval)(void);

    int (*HspFunc_prm_getva)(value_t **pval);

    void (*HspFunc_prm_setva)(value_t *pval, int aptr, int type, const void *ptr);

    char *(*HspFunc_malloc)(int size);

    void (*HspFunc_free)(void *ptr);

    char *(*HspFunc_expand)(char *ptr, int size);

    IRQDAT *(*HspFunc_addirq)(void);

    int (*HspFunc_hspevent)(int event, int prm1, int prm2, void *prm3);

    void (*HspFunc_registvar)(int flag, HSPVAR_COREFUNC func);

    void (*HspFunc_setpc)(const unsigned short *pc);

    void (*HspFunc_call)(const unsigned short *pc);

    void (*HspFunc_mref)(value_t *pval, int prm);

    void (*HspFunc_dim)(value_t *pval, int flag, int len0, int len1, int len2,
            int len3, int len4);

    void (*HspFunc_redim)(value_t *pval, int lenid, int len);

    void (*HspFunc_array)(value_t *pval, int offset);

} hsp_extra_info_30_t;

//	Plugin info data (3.1 or later)
typedef struct HSP_ExtraInfomation //追加情報
{
    //		HSP internal info data (2.6)
    //
    short ver; // Version Code
    short min; // Minor Version
    //
    int *er;      // Not Use
    char *pstr;   // String Buffer (master)
    char *stmp;   // String Buffer (sub)
    value_t **mpval; // Master PVAL
    //
    int *actscr;  // Active Window ID
    int *nptype;  // Next Parameter Type
    int *npval;   // Next Parameter Value
    int *strsize; // StrSize Buffer
    char *refstr; // RefStr Buffer
    //
    void *(*HspFunc_prm_getv)(void);

    int (*HspFunc_prm_geti)(void);

    int (*HspFunc_prm_getdi)(const int defval);

    char *(*HspFunc_prm_gets)(void);

    char *(*HspFunc_prm_getds)(const char *defstr);

    int (*HspFunc_val_realloc)(value_t *pv, int size, int mode);

    int (*HspFunc_fread)(char *fname, void *readmem, int rlen, int seekofs);

    int (*HspFunc_fsize)(char *fname);

    void *(*HspFunc_getbmscr)(int wid);

    int (*HspFunc_getobj)(int wid, int id, void *inf);

    int (*HspFunc_setobj)(int wid, int id, const void *inf);

    //		HSP internal info data (3.0)
    //
    int *npexflg;       // Next Parameter ExFlg
    HSPContext *hspctx; // HSP context ptr

    //		Enhanced data (3.0)
    //
    int (*HspFunc_addobj)(int wid);

    void (*HspFunc_puterror)(HSPERROR error);

    hspvar_proc_t *(*HspFunc_getproc)(int type);

    hspvar_proc_t *(*HspFunc_seekproc)(const char *name);

    void (*HspFunc_prm_next)(void);

    int (*HspFunc_prm_get)(void);

    double (*HspFunc_prm_getd)(void);

    double (*HspFunc_prm_getdd)(double defval);

    unsigned short *(*HspFunc_prm_getlb)(void);

    value_t *(*HspFunc_prm_getpval)(void);

    int (*HspFunc_prm_getva)(value_t **pval);

    void (*HspFunc_prm_setva)(value_t *pval, int aptr, int type, const void *ptr);

    char *(*HspFunc_malloc)(int size);

    void (*HspFunc_free)(void *ptr);

    char *(*HspFunc_expand)(char *ptr, int size);

    IRQDAT *(*HspFunc_addirq)(void);

    int (*HspFunc_hspevent)(int event, int prm1, int prm2, void *prm3);

    void (*HspFunc_registvar)(int flag, HSPVAR_COREFUNC func);

    void (*HspFunc_setpc)(const unsigned short *pc);

    void (*HspFunc_call)(const unsigned short *pc);

    void (*HspFunc_mref)(value_t *pval, int prm);

    void (*HspFunc_dim)(value_t *pval, int flag, int len0, int len1, int len2,
            int len3, int len4);

    void (*HspFunc_redim)(value_t *pval, int lenid, int len);

    void (*HspFunc_array)(value_t *pval, int offset);

    //		Enhanced data (3.1)
    //
    char *(*HspFunc_varname)(int id);

    int (*HspFunc_seekvar)(const char *name);

} hsp_extra_info_t;

#define HSP3_REPEAT_MAX 32

typedef struct LOOPDAT {
    int time;           // loop times left
    int cnt;            // count
    int step;           // count add value
    unsigned short *pt; // loop start ptr
} LOOPDAT;

// 実行モード
enum {
    RUNMODE_RUN = 0,
    RUNMODE_WAIT,
    RUNMODE_AWAIT,
    RUNMODE_STOP,
    RUNMODE_END,
    RUNMODE_ERROR,
    RUNMODE_RETURN,
    RUNMODE_INTJUMP,
    RUNMODE_ASSERT,
    RUNMODE_LOGMES,
    RUNMODE_EXITRUN,
    RUNMODE_MAX
};



typedef struct hsp_context_t {
    //	HSP Context
    //
    hsp_header_t *hsphed;          // HSP object file header
    unsigned short *mcs;     // current code segment ptr
    unsigned short *mem_mcs; // code segment ptr
    char *mem_mds;           // data segment ptr
    unsigned char *mem_di;   // Debug info ptr
    int *mem_ot;             // object temp segment ptr

    IRQDAT *mem_irq; // IRQ data ptr
    int irqmax;      // IRQ data count
    int iparam;      // IRQ Info data1
    int wparam;      // IRQ Info data2
    int lparam;      // IRQ Info data3

    value_t *mem_var;                     // var storage index
    hsp_extra_info_30_t exinfo;     // HSP function data(3.0)
    int runmode;                       // HSP execute mode
    int waitcount;                     // counter for wait
    int waitbase;                      // wait sleep base
    int waittick;                      // next tick for await
    int lasttick;                      // previous tick
    int sublev;                        // subroutine level
    LOOPDAT mem_loop[HSP3_REPEAT_MAX]; // repeat loop info
    int looplev;                       // repeat loop level
    HSPERROR err;                      // error code
    int hspstat;                       // HSP status
    int stat;                          // sysvar 'stat'
    int strsize;                       // sysvar 'strsize'
    char *refstr;                      // RefStr Buffer
    char *fnbuffer;                    // buffer for FILENAME
    void *instance;                    // Instance Handle (windows)
    int intwnd_id;                     // Window ID (interrupt)
    value_t *note_pval;                   // MemNote pval
    int note_aptr;                    // MemNote aptr
    value_t *notep_pval;                  // MemNote pval (previous)
    int notep_aptr;                   // MemNote aptr (previous)
    char *stmp;                        // String temporary buffer

    void *prmstack;               // Current parameter stack area
    library_t *mem_linfo;            // Library info
    struct_param_t *mem_minfo;         // Parameter info
    struct_data_t *mem_finfo;         // Function/Struct info
    int retval_level;             // subroutine level (return code)
    int endcode;                  // End result code
    void (*msgfunc)(struct hsp_context_t *); // Message Callback Proc.
    void *wnd_parent;             // Parent Window Handle
    double refdval;               // sysvar 'refdval'
    char *cmdline;                // Command Line Parameters

    hsp_extra_info_t *exinfo2; // HSP function data(3.1)

    int prmstack_max; // Parameter Stack Max(hsp3cnv) (3.3)
} hsp_context_t;

#define HSPCTX_REFSTR_MAX 4096
#define HSPCTX_CMDLINE_MAX 1024
#define HSPSTAT_NORMAL 0
#define HSPSTAT_DEBUG 1
#define HSPSTAT_SSAVER 2
#define TYPE_EX_SUBROUTINE 0x100 // gosub用のスタックタイプ
#define TYPE_EX_CUSTOMFUNC 0x101 // deffunc呼び出し用のスタックタイプ
#define TYPE_EX_ENDOFPARAM 0x200 // パラメーター終端(HSPtoC)
#define TYPE_EX_ARRAY_VARS 0x201 // 配列要素付き変数用スタックタイプ(HSPtoC)
#define TYPE_EX_LOCAL_VARS 0x202 // ローカル変数用スタックタイプ(HSPtoC)

//    Subroutine Context
//
typedef struct {
    int stack_level;           // サブルーチン開始時のスタックレベル
    unsigned short *mcsret; // 呼び出し元PCポインタ(復帰用)
    struct_data_t *param;       // 引数パラメーターリスト
    void *old_stack;          // 以前のスタックアドレス
    int old_level;             // 以前のスタックレベル

} hsp_subroutine_t;

//		コールバックのオプション
//
#define HSPEVENT_ENABLE_COMMAND 1  // １ステップ実行時
#define HSPEVENT_ENABLE_HSPIRQ 2   // HSP内での割り込み発生時
#define HSPEVENT_ENABLE_GETKEY 4   // キーチェック時
#define HSPEVENT_ENABLE_FILE 8     // ファイル入出力時
#define HSPEVENT_ENABLE_MEDIA 16   // メディア入出力時
#define HSPEVENT_ENABLE_PICLOAD 32 // picload命令実行時

//		ファンクション型
//
// typedef int (* HSP3_CMDFUNC) (int);
// typedef void *(* HSP3_REFFUNC) (int *,int);
// typedef int (* HSP3_TERMFUNC) (int);
// typedef int (* HSP3_MSGFUNC) (int,int,int);
// typedef int (* HSP3_EVENTFUNC) (int,int,int,void *);

//    型ごとの情報
//    (*の項目は、親アプリケーションで設定されます)
//
typedef struct {
    short type;                     // *型タイプ値
    short option;                   // *オプション情報
    HSPContext *hspctx;             // *HSP Context構造体へのポインタ
    hsp_extra_info_t *hspexinfo; // *HSP_ExtraInfomation構造体へのポインタ

    //	ファンクション情報
    //
    int (*cmdfunc)(int);         // コマンド受け取りファンクション
    void *(*reffunc)(int *, int); // 参照受け取りファンクション
    int (*termfunc)(int);        // 終了受け取りファンクション

    int cmdfuncNumber;  //コマンド受け取りファンクション番号
    int reffuncNumber;  //参照受け取りファンクション番号
    int termfuncNumber; //終了受け取りファンクション番号

    // イベントコールバックファンクション
    //
    int (*msgfunc)(int, int, int); // Windowメッセージコールバック
    int (*eventfunc)(int, int, int, void *); // HSPイベントコールバック

} hsp_type_info_t;

// HSP割り込みID
enum {
    HSPIRQ_ONEXIT = 0,
    HSPIRQ_ONERROR,
    HSPIRQ_ONKEY,
    HSPIRQ_ONCLICK,
    HSPIRQ_USERDEF,
    HSPIRQ_MAX
};

// HSPイベントID
enum {
    HSPEVENT_NONE = 0,
    HSPEVENT_COMMAND,
    HSPEVENT_HSPIRQ,
    HSPEVENT_GETKEY,
    HSPEVENT_STICK,
    HSPEVENT_FNAME,
    HSPEVENT_FREAD,
    HSPEVENT_FWRITE,
    HSPEVENT_FEXIST,
    HSPEVENT_FDELETE,
    HSPEVENT_FMKDIR,
    HSPEVENT_FCHDIR,
    HSPEVENT_FCOPY,
    HSPEVENT_FDIRLIST1,
    HSPEVENT_FDIRLIST2,
    HSPEVENT_GETPICSIZE,
    HSPEVENT_PICLOAD,
    HSPEVENT_MAX
};

#endif
