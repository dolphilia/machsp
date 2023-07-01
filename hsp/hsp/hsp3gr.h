
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
#import "debug_message.h"
#import "hsp.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
#import "hsp3struct.h"
#import "hspvar_core.h"
#import "strbuf.h"
#import "supio_hsp3.h"

@interface ViewController (hsp3gr) {
}
- (void)hsp3typeinit_cl_extcmd:(hsp_type_info_t *)info;
- (void)hsp3typeinit_cl_extfunc:(hsp_type_info_t *)info;
- (int)cmdfunc_extcmd:(int)cmd;
- (void *)reffunc_function:(int *)type_res arg:(int)arg;
@end

#endif
