//
//	hsp3int.cpp header
//
#ifndef __hsp3int_h
#define __hsp3int_h
#import <math.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <time.h>
#import "SineWave.h"
#import "ViewController.h"
#import "hsp3dpmread.h"
#import "hsp3_code.h"
#import "hsp3config.h"
#import "hsp3struct.h"
#import "hspvar_core.h"
#import "hspwnd_linux.h"
#import "strbuf.h"
#import "supio_hsp3.h"
#ifdef HSPRANDMT
#include <random>
#endif
#define STRNOTE_FIND_MATCH 0  // 完全一致
#define STRNOTE_FIND_FIRST 1  // 前方一致
#define STRNOTE_FIND_INSTR 2  // 部分一致
@interface ViewController (hsp3int) {
}
- (char *)note_update;
- (void *)reffunc_intfunc:(int *)type_res arg:(int)arg;
- (int)cmdfunc_intcmd:(int)cmd;
- (void)hsp3typeinit_intcmd:(HSP3TYPEINFO *)info;
- (void)hsp3typeinit_intfunc:(HSP3TYPEINFO *)info;
- (void)Select:(char *)str;
- (int)GetSize;
- (char *)GetStr;
- (int)GetMaxLine;
- (int)GetLine:(char *)nres line:(int)line;
- (int)GetLine:(char *)nres line:(int)line max:(int)max;
- (int)PutLine:(char *)nstr line:(int)line ovr:(int)ovr;
- (char *)GetLineDirect:(int)line;
- (void)ResumeLineDirect;
- (int)FindLine:(char *)nstr mode:(int)mode;
- (int)nnget:(char *)nbase line:(int)line;
- (int)FindLineSub:(char *)nstr mode:(int)mode;
@end
#endif
