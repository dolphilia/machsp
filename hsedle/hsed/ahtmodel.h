////
////	ahtmodel.cpp structures
////
//#ifndef __ahtmodel_h
//#define __ahtmodel_h
//#import <Foundation/Foundation.h>
//#import <Cocoa/Cocoa.h>
//#import "membuf.h"
//#define AHTMODEL_FLAG_NONE 0
//#define AHTMODEL_FLAG_READY 1
//#define AHTMODEL_FLAG_ERROR -1
//#define AHTMODEL_FLAG_NOLINK 0x100
//#define AHTMODEL_FNMAX (260)
//enum {
//    AHTTYPE_EDIT_INT = 0,		// 入力枠(結果=int,sub=最小,sub2=最大)
//    AHTTYPE_EDIT_DOUBLE,		// 入力枠(結果=double,sub=最小,sub2=最大)
//    AHTTYPE_EDIT_STRING,		// 入力枠(結果=str,sub=文字数,sub2=option 'w' or 'm')
//    AHTTYPE_CBOX_STRING,		// コンボボックス(結果=str,sub=選択肢,sub2=選択肢テキスト)
//    AHTTYPE_CHKB_INT,			// チェックボックス(0or1、sub=テキスト)
//    AHTTYPE_COLS_INT,			// 色選択(結果=int)
//    AHTTYPE_FONT_STRING,		// フォント選択(結果=str)
//    AHTTYPE_FILE_STRING,		// ファイル選択(sub=拡張子,sub2=選択名)
//    AHTTYPE_EXTF_STRING,		// 外部ツール起動(sub=拡張子,sub2=ツール名)
//    AHTTYPE_PARTS_INT,			// パーツID(sub=クラス名,sub2=参照名)
//    AHTTYPE_PARTS_PROP_STRING,	// パーツIDのプロパティ(sub=プロパティ名,sub2=option 'm')
//    AHTTYPE_PARTS_OPT_STRING,	// パーツIDのオプション(sub=オプション名,sub2=option 'm')
//    AHTTYPE_EDIT_STRING2,		// 入力枠(結果=str,sub=文字数,sub2=option 'w' or 'm')
//    AHTTYPE_MAX
//};
//#define AHTMODE_QUOTATION	1	// ダブルクォートで囲む
//#define AHTMODE_OUTPUT_PURE 2	// ahtout出力用クォート処理
//#define AHTMODE_READ_ONLY 4		// 修正不可
//#define AHTMODE_WITH_ID 8		// デフォルトでIDを付加する
//#define AHTMODE_OUTPUT_RAW 16	// 出力用データを処理しない// AHT Object Data
//typedef struct AHTOBJ {
//    //		Object data structure
//    //
//    int		cx, cy;			// Current Position
//    int		page;			// Current Page
//    int		next;			// Next Model ID (-1=none)
//    int		prev;			// Next Model ID (-1=none)
//    int		option1;		// Reserved
//    int		option2;		// Reserved
//    int		option3;		// Reserved
//    int		option4;		// Reserved
//} AHTOBJ;
//
//// AHTプロパティ情報
//@interface AHTPROP : NSObject {
//}
//-(void)SetId:(int)val;// { id = val; };
//-(void)SetMode:(int)mode;// { ahtmode |= mode; };
//-(void)ClearMode:(int)mode;// { ahtmode &= ~mode; };
//-(void)SetNewVal:(char*)data;
//-(char*)GetValue;
//-(int)GetValueInt;
//-(double)GetValueDouble;
//-(char*)GetOutValue;
//-(void)SetOutValue:(char*)data;    //	Data
//-(int)id;
//-(short)ahttype;		// property type (AHTTYPE_*)
//-(short)ahtmode;		// AHT mode flag
//-(char*)name;			// property name
//-(char*)help;			// property name (help)
//-(char*)defval;		// default value
//-(char*)defval2;		// default value (sub)
//-(char*)defval3;		// default value (sub2)
//-(char*)newval;		// New value
//-(int)nvsize;			// New value size
//-(char*)outname;		// value for output
//-(char*)orgname;		// property name (original)
//@end
//
//// AHTモデル情報
//@interface AHTMODEL : NSObject {
//    //        Routines    //        Data
//    int id;                    // ID
//    int flag;                // flag
//    bool findcheck;            // Check flag for find
//    AHTOBJ obj;                // Object Info
//    int prop_cnt;            // property count
//    int mem_prop_size;        // property data size
//    //AHTPROP **mem_prop;        // property data
//    AHTPROP *mem_prop;        // property data
//    CMemBuf *source;        // AHT source buffer
//    CMemBuf *propstr;        // string buffer for property
//    CMemBuf *exp;            // introduction string
//    CMemBuf *stdbuf;        // message output buffer
//    char name[128];            // display name
//    char classname[128];    // model name (class)
//    char author[32];        // author
//    char ver[32];            // version
//    char fpath[AHTMODEL_FNMAX];        // data path name
//    char fname[AHTMODEL_FNMAX];        // data file name
//    char helpkw[128];        // keyword for help
//    AHTPROP    *refprop;        // reference prop for name    c
//    char icon[32];            // icon filename (opt)
//    int    iconid;                // icon ID
//    int    global_id;            // Global ID
//    int dummy;                // Dummy Data
//    char s_glid[16];        // ID String Convert
//    char s_flag[16];        // Flag String Convert
//}
//-(void)SetAHTOption:(char*)name value:(char*)value;
//-(char*)GetAHTOption:(char*)name;
//-(AHTPROP*)AddProperty;
//-(AHTPROP*)SetProperty:(char*)propname name:(char*)name value:(char*)value;
//-(AHTPROP*)SetPropertyType:(char*)propname type:(int)type;
//-(AHTPROP*)SetPropertyDefault:(char*)propname value:(char*)value;
//-(AHTPROP*)SetPropertyDefaultInt:(char*)propname value:(int)value;
//-(AHTPROP*)SetPropertyDefaultStr:(char*)propname value:(char*)value;
//-(AHTPROP*)SetPropertyDefaultDouble:(char*)propname value:(double)value;
//-(AHTPROP*)GetProperty:(char*)propname;
//-(AHTPROP*)GetPropertyI:(int)id; //{ return mem_prop[id]; }
//-(AHTPROP*)GetPropertyFromAlias:(char*)propname;
//-(int)SetAHTPropertyString:(char*)propname str:(char*)str;
//-(int)GetPropertyID:(char*)propname;
//-(int)GetPropertyPossibleLines;
//-(void)UpdateProperty;
//-(int)SetProp:(AHTPROP*)prop name:(char*)name value:(char*)value;
//-(void)SetPropName:(AHTPROP*)prop value:(char*)value;
//-(void)SetPropOrgName:(AHTPROP*)prop value:(char*)value;
//-(void)SetPropHelp:(AHTPROP*)prop value:(char*)value;
//-(void)SetPropDefval:(AHTPROP*)prop value:(char*)value;
//-(void)SetPropDefval2:(AHTPROP*)prop value:(char*)value;
//-(void)SetPropDefval3:(AHTPROP*)prop value:(char*)value;
//-(void)SetId:(int)val; //{ id = val; }
//-(void)SetSource:(char*)filename;
//-(void)SetSourcePath:(char*)filename;
//-(void)SetName:(char*)name;
//-(void)SetClass:(char*)name;
//-(void)SetAuthor:(char*)name;
//-(void)SetVersion:(char*)name;
//-(void)SetIconFile:(char*)name;
//-(void)SetIconId:(int)id;
//-(void)SetStdBuffer:(CMemBuf*)buf;
//-(void)TerminateExp; //{ exp->Put(0); };
//-(void)SetHelpKeyword:(char*)name;
//-(char*)GetName;
//-(char*)GetClass; //{ return classname; }
//-(char*)GetAuthor; //{ return author; }
//-(char*)GetVersion; //{ return ver; }
//-(char*)GetIconFile; //{ return icon; }
//-(char*)GetSource; //{ return fname; }
//-(char*)GetSourcePath; //{ return fpath; }
//-(char*)GetHelpKeyword; //{ return helpkw; }
//-(int)GetId; //{ return id; }
//-(int)GetFlag; //{ return flag; }
//-(int)GetPropCount; //{ return prop_cnt; }
//-(int)GetGlobalId; //{ return global_id; }
//-(int)GetGlobalId2;
//-(int)GetIconId; //{ return iconid; }
//-(int)GetCurX; //{ return obj.cx; };
//-(int)GetCurY; //{ return obj.cy; };
//-(int)GetPage; //{ return obj.page; };
//-(int)GetNextID; //{ return obj.next; };
//-(int)GetPrevID; //{ return obj.prev; };
//-(void)SetCur:(int)x y:(int)y; //{ obj.cx=x; obj.cy=y; };
//-(void)SetPage:(int)page; //{ obj.page=page; };
//-(void)SetNextID:(int)id;
//-(void)SetPrevID:(int)id;
//-(void)Mesf:(char*)format, ...;
//-(void)SetFlag:(int)val; //{ flag |= val; };
//-(void)SetGlobalId:(int)val; //{ global_id = val; };
//-(AHTOBJ*)GetObj; //{ return &obj; };
//-(void)SetObj:(AHTOBJ*)val; //{ obj = *val; };
//-(void)ClearFindCheck; //{ findcheck = false; };
//-(void)SetFindCheck; //{ findcheck = true; };
//-(bool)GetFindCheck; //{ return findcheck; };
//@end
//#endif
