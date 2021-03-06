//
//	hsp3gr_linux.cpp header
//
#ifndef __hsp3gr_linux_h
#define __hsp3gr_linux_h
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "MyCALayer.h"
#import "ViewController.h"
#import "hsp3_code.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
#import "hsp3struct.h"
#import "hspvar_core.h"
#import "strbuf.h"
#import "supio_hsp3.h"
@interface ViewController (hsp3gr) {
}
- (void)hsp3typeinit_cl_extcmd:(HSP3TYPEINFO *)info;
- (void)hsp3typeinit_cl_extfunc:(HSP3TYPEINFO *)info;
- (int)cmdfunc_extcmd:(int)cmd;
- (void *)reffunc_function:(int *)type_res arg:(int)arg;
@end
#endif
