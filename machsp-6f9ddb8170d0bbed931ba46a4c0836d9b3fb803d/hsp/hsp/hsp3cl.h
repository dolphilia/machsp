
//
//	hsp3cl.cpp header
//
#ifndef __hsp3cl_h
#define __hsp3cl_h

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "debug_message.h"
#import "dpmread.h"
#import "hsp.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
//#import "hsp3ext.h"
#import "hsp3gr.h"
#import "hsp3struct.h"
#import "strbuf.h"
#import "supio_hsp3.h"

#define HSP3_AXTYPE_NONE 0
#define HSP3_AXTYPE_ENCRYPT 1

@interface ViewController (hsp3cl) {
}
- (int)hsp3cl_exec;
- (int)hsp3cl_init:(char *)startfile;
- (void)hsp3win_dialog:(char *)mes;
- (void)hsp3cl_bye;
- (void)hsp3cl_msgfunc:(HSPContext *)hspctx;
- (void)hsp3cl_error;
- (void)Dispose;                             // HSP axの破棄
- (int)Reset:(int)mode;                      // HSP axの初期化を行なう
- (void)SetPackValue:(int)sum dec:(int)dec;  // packfile用の設定データを渡す
- (void)SetFileName:(char *)name;            // axファイル名を指定する
- (void *)copy_DAT:(char *)ptr size:(size_t)size;
- (LIBDAT *)copy_LIBDAT:(HSPHED *)hsphed ptr:(char *)ptr size:(size_t)size;
- (STRUCTDAT *)copy_STRUCTDAT:(HSPHED *)hsphed
                          ptr:(char *)ptr
                         size:(size_t)size;
@end

// int hsp3cl_exec( void );
// int hsp3cl_init( char *startfile );
// void hsp3win_dialog( char *mes );

#endif
