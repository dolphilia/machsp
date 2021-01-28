//@
//
//	token.cpp structures
//
#ifndef __token_h
#define __token_h
#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <vector>
#import <string>
//#import <map>
#import <memory>
#import "label.h"
#import "tagstack.h"
#import "membuf.h"
#import "strnote.h"
#import "hspvar_core.h"
#import "errormsg.h"
#import "hsp3struct.h"
// token type
#define TK_NONE 0
#define TK_OBJ 1
#define TK_STRING 2
#define TK_DNUM 3
#define TK_NUM 4
#define TK_CODE 6
#define TK_LABEL 7
#define TK_VOID 0x1000
#define TK_SEPARATE 0x1001
#define TK_EOL 0x1002
#define TK_EOF 0x1003
#define TK_ERROR -1
#define TK_CALCERROR -2
#define TK_CALCSTOP -3
#define DUMPMODE_RESCMD 3
#define DUMPMODE_DLLCMD 4
#define DUMPMODE_ALL 15
#define CMPMODE_PPOUT 1
#define CMPMODE_OPTCODE 2
#define CMPMODE_CASE 4
#define CMPMODE_OPTINFO 8
#define CMPMODE_PUTVARS 16
#define CMPMODE_VARINIT 32
#define CMPMODE_OPTPRM 64
#define CMPMODE_SKIPJPSPC 128
#define CG_FLAG_ENABLE 0
#define CG_FLAG_DISABLE 1
#define CG_LASTCMD_NONE 0
#define CG_LASTCMD_LET 1
#define CG_LASTCMD_CMD 2
#define CG_LASTCMD_CMDIF 3
#define CG_LASTCMD_CMDMIF 4
#define CG_LASTCMD_CMDELSE 5
#define CG_LASTCMD_CMDMELSE 6
#define CG_IFLEV_MAX 128
#define CG_REPLEV_MAX 128
// option for 'GetTokenCG'
#define GETTOKEN_DEFAULT 0
#define GETTOKEN_NOFLOAT 1		// '.'を小数点と見なさない(整数のみ取得)
#define GETTOKEN_LABEL 2		// '*'に続く名前をラベルとして取得
#define GETTOKEN_EXPRBEG 4		// 式の先頭
#define CG_LOCALSTRUCT_MAX 256
#define CG_IFCHECK_SCOPE 0
#define CG_IFCHECK_LINE 1
#define CG_LIBMODE_NONE -1
#define CG_LIBMODE_DLL 0
#define CG_LIBMODE_DLLNEW 1
#define CG_LIBMODE_COM 2
#define CG_LIBMODE_COMNEW 3
#define	CALCVAR double
#define LINEBUF_MAX 0x10000
// line mode type
#define LMODE_ON 0
#define LMODE_STR 1
#define LMODE_COMMENT 2
#define LMODE_OFF 3
// macro default data storage
typedef struct MACDEF {
    int		index[32];				// offset to data
    char	data[1];
} MACDEF;
// module related define
#define OBJNAME_MAX 60
#define MODNAME_MAX 20
#define COMP_MODE_DEBUG 1
#define COMP_MODE_DEBUGWIN 2
#define COMP_MODE_UTF8 4
#define SWSTACK_MAX 32
#define HEDINFO_RUNTIME 0x1000		// 動的ランタイムを有効にする
#define HEDINFO_NOMMTIMER 0x2000	// マルチメディアタイマーを無効にする
#define HEDINFO_NOGDIP 0x4000		// GDI+による描画を無効にする
#define HEDINFO_FLOAT32 0x8000		// 実数を32bit floatとして処理する
#define HEDINFO_ORGRND 0x10000		// 標準の乱数発生を使用する
enum ppresult_t {
    PPRESULT_SUCCESS,				// 成功
    PPRESULT_ERROR,					// エラー
    PPRESULT_UNKNOWN_DIRECTIVE,		// 不明なプリプロセッサ命令（PreprocessNM）
    PPRESULT_INCLUDED,				// #include された
    PPRESULT_WROTE_LINE,			// 1行書き込まれた
    PPRESULT_WROTE_LINES,			// 2行以上書き込まれた
};
//class CLabel;
//class CMemBuf;
//class CTagStack;
//class CStrNote;
//class AHTMODEL;
#define SCNVBUF_DEFAULTSIZE 0x8000
#define SCNV_OPT_NONE 0
#define SCNV_OPT_SJISUTF8 1
//  token analysis class
typedef struct undefined_symbol_t {
    int pos;
    int len_include_modname;
    int len;
} undefined_symbol_t;

@interface CToken : NSObject {
    //        Data
    //
    CLabel *lb;                        // label object
    CLabel *tmp_lb;                    // label object (preprocessor reference)
    CTagStack *tstack;                // tag stack object
    CMemBuf *errbuf;
    CMemBuf *wrtbuf;
    CMemBuf *packbuf;
    CMemBuf *ahtbuf;
    CStrNote *note;
//    AHTMODEL *ahtmodel;                // AHT process data
    char common_path[HSP_MAX_PATH];    // common path
    char search_path[HSP_MAX_PATH];    // search path
    int line;
    int val;
    int ttype;                        // last token type
    int texflag;
    char *lasttoken;                // last token point
    float val_f;
    double val_d;
    double fpbit;
    unsigned char *wp;
    unsigned char s2[1024];
    unsigned char *s3;
    char linebuf[LINEBUF_MAX];        // Line expand buffer
    char linetmp[LINEBUF_MAX];        // Line expand temp
    char errtmp[128];                // temp for error message
    char mestmp[128];                // meseage temp
    int incinf;                        // include level
    int mulstr;                        // multiline string flag
    short swstack[SWSTACK_MAX];        // generator sw stack (flag)
    short swstack2[SWSTACK_MAX];    // generator sw stack (mode)
    short swstack3[SWSTACK_MAX];    // generator sw stack (sw)
    int swsp;                        // generator sw stack pointer
    int swmode;                        // generator sw mode (0=if/1=else)
    int swlevel;                    // first stack level ( when off )
    int fileadd;                    // File Addition Mode (1=on)
    int swflag;                        // generator sw enable flag
    char *ahtkeyword;                // keyword for AHT
    char modname[MODNAME_MAX+2];    // Module Name Prefix
    int    modgc;                        // Global counter for Module
    int enumgc;                        // Global counter for Enum
    std::vector<undefined_symbol_t> undefined_symbols;
    int cs_lastptr;                    // パラメーターの初期CS位置
    int cs_lasttype;                // パラメーターのタイプ(単一時)
    int calccount;                    // パラメーター個数
    int pp_utf8;                    // ソースコードをUTF-8として処理する(0=無効)
    //        for CodeGenerator
    //
    int cg_flag;
    int cg_debug;
    int cg_iflev;
    int cg_valcnt;
    int cg_typecnt;
    int cg_pptype;
    int cg_locallabel;
    int cg_varhpi;
    int cg_putvars;
    int cg_defvarfix;
    int cg_utf8out;
    char *cg_ptr;
    char *cg_ptr_bak;
    char *cg_str;
    unsigned char *cg_wp;
    char cg_libname[1024];
    int    replev;
    int repend[CG_REPLEV_MAX];
    int iflev;
    int iftype[CG_IFLEV_MAX];
    int ifmode[CG_IFLEV_MAX];
    int ifscope[CG_IFLEV_MAX];
    int ifptr[CG_IFLEV_MAX];
    int ifterm[CG_IFLEV_MAX];
    int cg_lastcmd;
    int cg_lasttype;
    int cg_lastval;
    int cg_lastcs;
    CMemBuf *cs_buf;
    CMemBuf *ds_buf;
    CMemBuf *ot_buf;
    CMemBuf *di_buf;
    CMemBuf *li_buf;
    CMemBuf *fi_buf;
    CMemBuf *mi_buf;
    CMemBuf *fi2_buf;
    CMemBuf *hpi_buf;
#ifdef HSP_DS_POOL
    std::map<double, int> double_literal_table; // 定数プール用
    std::map<std::string, int> string_literal_table;
#endif
    //        for Header info
    int hed_option;
    char hed_runtime[64];
    int hed_cmpmode;
    int hed_autoopt_timer;
    //        for Struct
    int    cg_stnum;
    int    cg_stsize;
    int cg_stptr;
    int cg_libindex;
    int cg_libmode;
    int cg_localstruct[CG_LOCALSTRUCT_MAX];
    int cg_localcur;
    //        for Error
    //
    int cg_errline;
    int cg_orgline;
    char cg_orgfile[HSP_MAX_PATH];
    //        for SCNV
    //
    char *scnvbuf;            // SCNV変換バッファ
    int    scnvsize;            // SCNV変換バッファサイズ
}
//    CToken();
//    CToken( char *buf );
//    ~CToken();
//void InitSCNV( int size );
//char *ExecSCNV( char *srcbuf, int opt );
//void SetAHT( AHTMODEL *aht );
//void SetAHTBuffer( CMemBuf *aht );
-(CLabel*)GetLabelInfo;
-(void)SetLabelInfo:(CLabel*)lbinfo;
-(void)Error:(char*)mes;
-(void)LineError:(char*)mes line:(int)line fname:(char*)fname;
-(void)SetError:(char*)mes;
-(void)Mes:(char*)mes;
-(void)Mesf:(char*)format, ...;
-(void)SetErrorBuf:(CMemBuf*)buf;
-(void)ResetCompiler;
-(int)GetToken;
-(int)PeekToken;
-(int)Calc:(CALCVAR &)val;
-(char*)CheckValidWord;
//        For preprocess
//
-(ppresult_t)Preprocess:(char*)str;
-(ppresult_t)PreprocessNM:(char*)str;
-(void)PreprocessCommentCheck:(char*)str;
-(int)ExpandLine:(CMemBuf*)buf src:(CMemBuf*)src refname:(char*)refname;
-(int)ExpandFile:(CMemBuf*)buf fname:(char*)fname refname:(char*)refname;
-(void)FinishPreprocess:(CMemBuf*)buf;
-(void)SetCommonPath:(char*)path;
-(int)SetAdditionMode:(int)mode;
-(void)SetLook:(char*)buf;
-(char*)GetLook;
-(char*)GetLookResult;
-(int)GetLookResultInt;
-(int)LabelRegist:(char**)list mode:(int)mode;
-(int)LabelRegist2:(char**)list;
-(int)LabelRegist3:(char**)list;
-(int)LabelDump:(CMemBuf*)out option:(int)option;
-(int)GetLabelBufferSize;
-(int)RegistExtMacroPath:(char*)name str:(char*)str;
-(int)RegistExtMacro_str:(char*)name str:(char*)str;
-(int)RegistExtMacro_val:(char*)keyword val:(int)val;
-(void)SetPackfileOut:(CMemBuf*)pack;
-(int)AddPackfile:(char*)name mode:(int)mode;
-(void)InitSCNV:(int)size;
-(char*)ExecSCNV:(char*)srcbuf opt:(int)opt;
-(int)CheckByteSJIS:(unsigned char)byte;
-(int)CheckByteUTF8:(unsigned char)byte;
-(int)SkipMultiByte:(unsigned char)byte;
//        For Code Generate
//
-(int)GenerateCode:(char*)fname oname:(char*)oname mode:(int)mode;
-(int)GenerateCode_membuf:(CMemBuf*)srcbuf oname:(char*)oname mode:(int)mode;
-(void)PutCS:(int)type value:(int)value exflg:(int)exflg;
-(void)PutCS_double:(int)type value:(double)value exflg:(int)exflg;
-(void)PutCSSymbol:(int)label_id exflag:(int)exflag;
-(int)GetCS;
-(int)PutOT:(int)value;
-(int)PutDS_double:(double)value;
-(int)PutDS:(char*)str;
-(int)PutDSStr:(char*)str converts_to_utf8:(bool)converts_to_utf8;
-(int)PutDSBuf:(char*)str;
-(int)PutDSBuf_size:(char*)str size:(int)size;
-(char*)GetDS:(int)ptr;
-(void)SetOT:(int)id value:(int)value;
-(void)PutDI;
-(void)PutDI_int:(int)dbg_code a:(int)a subid:(int)subid;
-(void)PutDIVars;
-(void)PutDILabels;
-(void)PutDIParams;
-(void)PutHPI:(short)flag option:(short)option libname:(char*)libname funcname:(char*)funcname;
-(int)PutLIB:(int)flag name:(char*)name;
-(void)SetLIBIID:(int)id clsid:(char*)clsid;
-(int)PutStructParam:(short)mptype extype:(int)extype;
-(int)PutStructParamTag;
-(void)PutStructStart;
-(int)PutStructEnd:(char*)name libindex:(int)libindex otindex:(int)otindex funcflag:(int)funcflag;
-(int)PutStructEnd_int:(int)i name:(char*)name libindex:(int)libindex otindex:(int)otindex funcflag:(int)funcflag;
-(int)PutStructEndDll:(char*)name libindex:(int)libindex subid:(int)subid otindex:(int)otindex;
-(void)CalcCG:(int)ex;
-(int)GetHeaderOption; //{ return hed_option; }
-(char*)GetHeaderRuntimeName; //{ return hed_runtime; }
-(void)SetHeaderOption:(int)opt name:(char*)name; //{ hed_option=opt; strcpy( hed_runtime, name ); }
-(int)GetCmpOption; //{ return hed_cmpmode; }
-(void)SetCmpOption:(int)cmpmode; ///{ hed_cmpmode = cmpmode; }
-(void)SetUTF8Input:(int)utf8mode; //{ pp_utf8 = utf8mode; }
//private:
//        For preprocess
//
-(void)Pickstr;
-(char*)Pickstr2:(char*)str;
-(void)Calc_token;
-(void)Calc_factor:(CALCVAR &)v;
-(void)Calc_unary:(CALCVAR &)v;
-(void)Calc_muldiv:(CALCVAR &)v;
-(void)Calc_addsub:(CALCVAR &)v;
-(void)Calc_bool:(CALCVAR &)v;
-(void)Calc_bool2:(CALCVAR &)v;
-(void)Calc_compare:(CALCVAR &)v;
-(void)Calc_start:(CALCVAR &)v;
-(ppresult_t)PP_Define;
-(ppresult_t)PP_Const;
-(ppresult_t)PP_Enum;
-(ppresult_t)PP_SwitchStart:(int)sw;
-(ppresult_t)PP_SwitchEnd;
-(ppresult_t)PP_SwitchReverse;
-(ppresult_t)PP_Include:(int)is_addition;
-(ppresult_t)PP_Module;
-(ppresult_t)PP_Global;
-(ppresult_t)PP_Deffunc:(int)mode;
-(ppresult_t)PP_Defcfunc:(int)mode;
-(ppresult_t)PP_Struct;
-(ppresult_t)PP_Func:(char*)name;
-(ppresult_t)PP_Cmd:(char*)name;
-(ppresult_t)PP_Pack:(int)mode;
-(ppresult_t)PP_PackOpt;
-(ppresult_t)PP_RuntimeOpt;
-(ppresult_t)PP_CmpOpt;
-(ppresult_t)PP_Usecom;
//    ppresult_t PP_Aht( void );
//    ppresult_t PP_Ahtout( void );
//    ppresult_t PP_Ahtmes( void );
-(ppresult_t)PP_BootOpt;
-(void)SetModuleName:(char*)name;
-(char*)GetModuleName;
-(void)AddModuleName:(char*)str;
-(void)FixModuleName:(char*)str;
-(int)IsGlobalMode;
-(int)CheckModuleName:(char*)name;
-(char*)SkipLine:(char*)str pline:(int*)pline;
-(char*)ExpandStr:(char*)str opt:(int)opt;
-(char*)ExpandStrEx:(char*)str;
-(char*)ExpandStrComment:(char*)str opt:(int)opt;
-(char*)ExpandStrComment2:(char*)str;
-(char*)ExpandAhtStr:(char*)str;
-(char*)ExpandBin:(char*)str val:(int*)val;
-(char*)ExpandHex:(char*)str val:(int*)val;
-(char*)ExpandToken:(char*)str type:(int*)type ppmode:(int)ppmode;
-(int)ExpandTokens:(char*)vp buf:(CMemBuf*)buf lineext:(int*)lineext is_preprocess_line:(int)is_preprocess_line;
-(char*)SendLineBuf:(char*)str;
-(char*)SendLineBufPP:(char*)str lines:(int*)lines;
-(int)ReplaceLineBuf:(char*)str1 str2:(char*)str2 repl:(char*)repl macopt:(int)macopt macdef:(MACDEF*)macdef;
-(void)SetErrorSymbolOverdefined:(char*)keyword label_id:(int)label_id;
//        For Code Generate
//
-(int)GenerateCodeMain:(CMemBuf*)src;
-(void)RegisterFuncLabels;
-(int)GenerateCodeBlock;
-(int)GenerateCodeSub;
-(void)GenerateCodePP:(char*)buf;
-(void)GenerateCodeCMD:(int)id;
-(void)GenerateCodeLET:(int)id;
-(void)GenerateCodeVAR:(int)id ex:(int)ex;
-(void)GenerateCodePRM;
-(void)GenerateCodePRMN;
-(int)GenerateCodePRMF;
-(void)GenerateCodePRMF2;
-(void)GenerateCodePRMF3;
-(int)GenerateCodePRMF4:(int)t;
-(void)GenerateCodeMethod;
-(void)GenerateCodeLabel:(char*)name ex:(int)ex;
-(void)GenerateCodePP_regcmd;
-(void)GenerateCodePP_cmd;
-(void)GenerateCodePP_deffunc0:(int)is_command;
-(void)GenerateCodePP_deffunc;
-(void)GenerateCodePP_defcfunc;
-(void)GenerateCodePP_uselib;
-(void)GenerateCodePP_module;
-(void)GenerateCodePP_struct;
-(void)GenerateCodePP_func:(int)deftype;
-(void)GenerateCodePP_usecom;
-(void)GenerateCodePP_comfunc;
-(void)GenerateCodePP_defvars:(int)fixedvalue;
-(int)GetParameterTypeCG:(char*)name;
-(int)GetParameterStructTypeCG:(char*)name;
-(int)GetParameterFuncTypeCG:(char*)name;
-(int)GetParameterResTypeCG:(char*)name;
-(char*)GetTokenCG:(char*)str option:(int)option;
-(char*)GetTokenCG:(int)option;
-(char*)GetSymbolCG:(char*)str;
-(char*)GetLineCG;
-(char*)PickStringCG:(char*)str sep:(int)sep;
-(char*)PickStringCG2:(char*)str strsrc:(char**)strsrc;
-(char*)PickLongStringCG:(char*)str;
-(int)PickNextCodeCG;
-(void)CheckInternalListenerCMD:(int)opt;
-(void)CheckInternalProgCMD:(int)opt orgcs:(int)orgcs;
-(void)CheckInternalIF:(int)opt;
-(void)CheckCMDIF_Set:(int)mode;
-(void)CheckCMDIF_Fin:(int)mode;
-(int)SetVarsFixed:(char*)varname fixedvalue:(int)fixedvalue;
-(void)CalcCG_token;
-(void)CalcCG_token_exprbeg;
-(void)CalcCG_token_exprbeg_redo;
-(void)CalcCG_regmark:(int)mark;
-(void)CalcCG_factor;
-(void)CalcCG_unary;
-(void)CalcCG_muldiv;
-(void)CalcCG_addsub;
-(void)CalcCG_shift;
-(void)CalcCG_bool;
-(void)CalcCG_compare;
-(void)CalcCG_start;
-(bool)CG_optCode; //const { return (hed_cmpmode & CMPMODE_OPTCODE) != 0; }
-(bool)CG_optInfo; //const { return (hed_cmpmode & CMPMODE_OPTINFO) != 0; }
-(void)CG_MesLabelDefinition:(int)label_id;
@end
#endif
