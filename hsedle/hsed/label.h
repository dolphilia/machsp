
//
//	label.cpp structures
//
#ifndef __label_h
#define __label_h
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <string>
#import <map>
#import <set>
#define	maxname	256				// label name max
#define def_maxsymbol 0x10000	// Symbol Table Size (default)
#define def_maxblock 128		// Symbol Table Block max (default)
#define def_maxlab 4096			// label object max (default)
#define LAB_TYPE_MARK 0
#define LAB_TYPE_SYSVAL 7
#define LAB_TYPE_INTCMD 8
#define LAB_TYPE_EXTCMD 9
#define LAB_TYPE_IF 11
#define LAB_TYPE_PPVAL 0x110
#define LAB_TYPE_PPMAC 0x111
#define LAB_TYPE_PPMODFUNC 0x112
#define LAB_TYPE_PPDLLFUNC 0x113
#define LAB_TYPE_PPINTMAC 0x114
#define LAB_TYPE_PPEX_INTCMD 0x115
#define LAB_TYPE_PPEX_EXTCMD 0x116
#define LAB_TYPE_PPEX_PRECMD 0x117
#define LAB_TYPE_COMVAR 0x200
#define LAB_TYPE_PP_PREMODFUNC 0x212
#define LAB_DUMPMODE_RESCMD 3
#define LAB_DUMPMODE_DLLCMD 4
#define LAB_DUMPMODE_ALL 15
#define PRM_MASK 0xfff
#define PRM_FLAG_CTYPE 0x1000
#define LAB_INIT_NO 0
#define LAB_INIT_DONE 1
#define LAB_TYPEFIX_NONE 0
#define LAB_TYPEFIX_INT 4
#define LAB_TYPEFIX_DOUBLE 3
typedef std::set<std::string> FileNameSet;
typedef std::multimap<std::string, int> LabelMap;
typedef struct LABREL LABREL;
struct LABREL {
    LABREL	*link;				// link to next (NULL=end)
    int		rel_id;				// related id
};
typedef struct LABOBJ {
    int		flag;				// exist flag
    int		type;				// object type
    int		opt;				// option code
    short	eternal;			// eternal flag
    short	ref;				// reference flag
    int		hash;				// hash code
    char	*name;				// object name (lower case)
    char	*data;				// data field
    char	*data2;				// data field (opt)
    LABREL	*rel;				// relation id
    short	init;				// initalize flag
    short	typefix;			// force type
    char const* def_file;
    int def_line;
} LABOBJ;
//  label manager class
@interface CLabel : NSObject {
    //    data
    char *symbol;                        // Symbol Table
    LABOBJ *mem_lab;                    // Label object
    char *symblock[def_maxblock];        // Symbol Table Block
    int    curblock;                        // Current Block
    int    cur;                            // Current
    int    symcur;                            // Current Symbol Index
    int maxsymbol;                        // Max Symbol Size
    int maxlab;                            // Max Label Size
    char token[64];                        // Token for RegistList
    int casemode;                        // Case sensitive (0=none/other=ON)
    LabelMap labels;                    // Lookup table
    FileNameSet filenames;                // Pool of file names (pointed from def_file)
}
//CLabel();
//CLabel( int symmax, int worksize );
//~CLabel();
-(void)Reset;
-(int)Regist:(char*)name type:(int)type opt:(int)opt;
-(int)Regist2:(char*)name type:(int)type opt:(int)opt filename:(char const*)filename line:(int)line;
-(void)SetEternal:(int)id;
-(int)GetEternal:(int)id;
-(void)SetOpt:(int)id val:(int)val;
-(void)SetFlag:(int)id val:(int)val;
-(void)SetData:(int)id str:(char*)str;
-(void)SetData2:(int)id str:(char*)str size:(int)size;
-(void)SetInitFlag:(int)id val:(int)val;
-(void)SetForceType:(int)id val:(int)val;
-(int)Search:(char*)oname;
-(int)SearchLocal:(char*)oname loname:(char*)loname;
-(int)GetCount;
-(int)GetFlag:(int)id;
-(int)GetType:(int)id;
-(int)GetOpt:(int)id;
-(int)GetSymbolSize;
-(char*)GetName:(int)id;
-(char*)GetData:(int)id;
-(char*)GetData2:(int)id;
-(int)GetInitFlag:(int)id;
-(LABOBJ*)GetLabel:(int)id;
-(void)DumpLabel:(char*)str;
-(void)DumpHSPLabel:(char*)str option:(int)option maxsize:(int)maxsize;
-(int)RegistList:(char**)list modname:(char*)modname;
-(int)RegistList2:(char**)list modname:(char*)modname;
-(int)RegistList3:(char**)list;
-(int)GetNumEntry; //{ return cur; };
-(void)AddReference:(int)id;
-(int)GetReference:(int)id;
-(void)AddRelation:(int)id rel_id:(int)rel_id;
-(void)AddRelation_name:(char*)name rel_id:(int)rel_id;
-(int)SearchRelation:(int)id rel_id:(int)rel_id;
-(void)SetCaseMode:(int)flag;
-(void)SetDefinition:(int)id filename:(char const*)filename line:(int)line;
//private:
-(int)StrCase:(char*)str;
-(int)StrCmp:(char*)str1 str2:(char*)str2;
-(int)GetHash:(char*)str;
-(char*)Prt:(char*)str str2:(char*)str2;
-(int)HtoI;
-(char*)GetListToken:(char*)str;
-(char*)ExpandSymbolBuffer:(int)size;
-(void)DisposeSymbolBuffer;
-(void)MakeSymbolBuffer;
-(char*)RegistSymbol:(char*)str;
-(char*)RegistTable:(char*)str size:(int)size;
@end
#endif
