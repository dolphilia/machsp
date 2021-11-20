//@
//
//	hsc3.cpp structures
//
#ifndef __hsc3_h
#define __hsc3_h
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
//#import "AppDelegate.h"
#import "membuf.h"
#import "label.h"
#import "token.h"
#import "utility_string.h"

#define HSC3TITLE "HSP script preprocessor"
#define HSC3TITLE2 "HSP code generator"
#define HSC3_OPT_NOHSPDEF 1
#define HSC3_OPT_DEBUGMODE 2
#define HSC3_OPT_MAKEPACK 4
#define HSC3_OPT_READAHT 8
#define HSC3_OPT_MAKEAHT 16
#define HSC3_OPT_UTF8IN 32		// UTF8ソースを入力
#define HSC3_OPT_UTF8OUT 64		// UTF8コードを出力
#define HSC3_MODE_DEBUG 1
#define HSC3_MODE_DEBUGWIN 2
#define HSC3_MODE_UTF8 4		// UTF8コードを出力
//class CMemBuf;
//class CToken;
/*
	rev 54
	lb_info の型を void * から CLabel * に変更。
	hsc3.cpp:207
	mingw : warning : void * 型の delete は未定義
	に対処。
 */
//class CLabel;
// HSC3 class
@interface CHsc3 : NSObject {
    //        Data
    //
    CMemBuf *errbuf;
    CMemBuf *pfbuf;
    CMemBuf *addkw;
    CMemBuf *outbuf;
    CMemBuf *ahtbuf;
    //        Private Data
    //
    int process_option;
    char common_path[512];            // common path
    //        for Header info
    int hed_option;
    char hed_runtime[64];
    //        for Compile Optimize
    int cmpopt;
    CLabel *lb_info;
}
-(char*)GetError;
-(int)GetErrorSize;
-(void)ResetError;
-(int)PreProcess:(char*)fname outname:(char*)outname option:(int)option rname:(char*)rname ahtoption:(void*)ahtoption;//=NULL );
//-(int)PreProcessAht:(char*)fname ahtoption:(void*)ahtoption mode:(int)mode;//=0 );
-(void)PreProcessEnd;
-(int)Compile:(char*)fname outname:(char*)outname mode:(int)mode;
-(void)SetCommonPath:(char*)path;
-(int)GetCmdList:(int)option;
-(int)OpenPackfile;
-(void)ClosePackfile;
-(void)GetPackfileOption:(char*)out keyword:(char*)keyword defval:(char*)defval;
-(int)GetPackfileOptionInt:(char*)keyword defval:(int)defval;
-(int)GetRuntimeFromHeader:(char*)fname res:(char*)res;
-(int)SaveOutbuf:(char*)fname;
-(int)SaveAHTOutbuf:(char*)fname;
-(void)AddSystemMacros:(CToken*)tk option:(int)option;
@end
#endif
