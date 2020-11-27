//
////
////	ahtobj.cpp structures
////
//#ifndef __ahtobj_h
//#define __ahtobj_h
//#import <Foundation/Foundation.h>
//#import <Cocoa/Cocoa.h>
//#import "membuf.h"
//#import "ahtmodel.h"
//#define AHTOBJ_FLAG_NONE 0
//#define AHTOBJ_FLAG_ENABLE 1
//#define AHTOBJ_FLAG_SLEEP 2
//#define AHTOBJ_ATTR_FIXED 1
//#define AHTOBJ_ATTR_RESIZE 2
//#define AHTOBJ_ATTR_ARROW 4
//#define AHTDEFAULT_OBJMAX 64
//enum {
//    AHTMODELFIND_MODE_START = 0,
//    AHTMODELFIND_MODE_ARRAYSEEK,
//    AHTMODELFIND_MODE_ARRAYPICK,
//    AHTMODELFIND_MODE_LEFTPICK,
//    AHTMODELFIND_MODE_END,
//};
//#define _FNMAX (260)
//#define HTP_MAGIC1 'H'
//#define HTP_MAGIC2 'T'
//#define HTP_MAGIC3 'P'
//#define HTP_MAGIC4 '1'
//typedef struct HTPOBJ
//{
//    //		HTP1.0 module table structure
//    //
//    int		ahtsource;			// AHT source file name (STRPTR)
//    int		propname;			// AHT property name (STRPTR)
//    int		defvalue;			// AHT default value (STRPTR)
//    int		ahtobj;				// AHT object value (STRPTR)
//} HTPOBJ;
//typedef struct HTPHED
//{
//    //		HTP1.0 header structure
//    //
//    char	h1;					// magic code1
//    char	h2;					// magic code2
//    char	h3;					// magic code3
//    char	h4;					// magic code4
//    int		ver;				// version code (1.0=0x1000)
//    int		max_mod;			// max count of modules
//    int		modtable;			// module table pointer (from file top)
//    int		strtable;			// string table pointer (from file top)
//    int		modsize;			// module table size
//    int		strsize;			// string table size
//    short	curpage;			// current page
//    short	maxpage;			// max page
//    int		opt1;				// (reserved)
//    int		opt2;				// (reserved)
//    int		opt3;				// (reserved)
//    int		opt4;				// (reserved)
//} HTPHED;
//typedef struct AHTPARTS
//{
//    //		AHT PARTS table structure
//    //
//    int		icon;				// IconID
//    char	name[128];			// Name
//    char	classname[128];		// Class Name
//} AHTPARTS;
//// AHTメイン
//@interface CAht : NSObject {
//    //        Private Data
//    //
//    int model_cnt;                // model alloc count
//    int mem_ahtmodel_size;        // allco size
//    AHTMODEL **mem_ahtmodel;    // model data
//    HTPHED hed;                    // HTP header
//    CMemBuf *stdbuf;            // debug message buffer
//    CMemBuf *objbuf;            // object data (file) buffer
//    CMemBuf *strbuf;            // string data (file) buffer
//    //        For Visual Tools
//    //
//    int curpage;            // current page
//    int maxpage;            // max pages
//    CMemBuf *objlist;        // search result data buffer
//    CMemBuf *ahtwrt_buf;    // text buffer for .hsp build
//    CMemBuf *ahtini_buf;    // text buffer for .hsp build (init)
//    char fname[_FNMAX];        // data file name
//    char prjdir[_FNMAX];    // project directory
//    char tooldir[_FNMAX];    // tool directory
//    //        For Model Find
//    //
//    int findmode;            // Model find mode
//    int findid;                // Find cursor
//    int parentid;            // Current Parent
//    //        Quick Parts Pick
//    //
//    int    maxparts;
//    int pickptr;
//    char linebuf[256];
//    AHTPARTS *mem_parts;
//}
////		Service
//-(void)Mesf:(char*)format, ...;
//-(void)SetPrjDir:(char*)name;
//-(void)SetPrjFile:(char*)name;
//-(void)SetToolDir:(char*)name;
//-(void)SetPage:(int)cur max:(int)max;
//-(int)GetCurrentPage;
//-(int)GetMaxPage;
//-(AHTMODEL*)AddModel;
//-(AHTMODEL*)EntryModel:(int)id;
//-(void)DeleteModel:(int)id;
//-(AHTMODEL*)GetModel:(int)id;
//-(char*)GetStdBuffer;
//-(int)GetModelCount;
//-(void)LinkModel:(int)id next_id:(int)next_id;
//-(void)UnlinkModel:(int)id;
//-(int)LoadProject:(char*)fname;
//-(int)LoadProjectApply:(int)modelid fileid:(int)fileid;
//-(void)LoadProjectEnd;
//-(int)SaveProject:(char*)fname;
//-(int)GetProjectFileModelMax;
//-(char*)GetProjectFileModel:(int)id;
//-(char*)GetProjectFileModelPath:(int)id;
//-(int)GetProjectFileModelID:(int)id;
//-(HTPOBJ*)GetProjectFileObject:(int)id;
//-(char*)GetProjectFileString:(int)ptr;
//-(AHTPARTS*)GetParts:(int)id;
//-(char*)GetPartsName:(int)id;
//-(char*)GetPartsClassName:(int)id;
//-(int)GetPartsIconID:(int)id;
//-(int)BuildParts:(char*)list path:(char*)path;
//-(void)BuildGlobalID;
//-(char*)SearchModelByClassName:(char*)clsname;
//-(void)FindModelStart;
//-(int)FindModel;
//-(int)FindModelGetParentId;
//-(void)UpdateModelProperty:(int)id;
//-(void)InitMakeBuffer;
//-(int)SaveMakeBuffer:(char*)fname;
//-(void)AddMakeBufferInit:(char*)str size:(int)size;//=0
//-(void)AddMakeBufferMain:(char*)str size:(int)size;//=0
//-(void)DisposeMakeBuffer;
////private
//-(void)Reset;
////-(void)DisposeObj;
//-(void)DisposeModel;
//-(void)SaveProjectSub:(AHTMODEL*)model;
//-(void)DisposeParts;
//-(int)BuildPartsSub:(int)id fname:(char*)fname;
//-(void)PickLineBuffer:(char*)out;
//-(int)BuildGlobalIDSub:(char*)fname pname:(char*)pname i:(int)i;
//
//@end
//#endif
