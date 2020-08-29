//
//  hsp.h
//  hsp3cl
//
//  Created by dolphilia on 2016/01/18.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef hsp_h
#define hsp_h

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "debug_message.h"
#import "dpmread.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
#import "hsp3gr.h"
#import "hsp3int.h"
#import "hsp3struct.h"
#import "hsp3struct.h"
#import "hspwnd_linux.h"
#import "stack.h"
#import "strbuf.h"
#import "supio_hsp3.h"

#define HSP3_AXTYPE_NONE 0
#define HSP3_AXTYPE_ENCRYPT 1
#define CODE_EXPANDSTRUCT_OPT_NONE 0
#define CODE_EXPANDSTRUCT_OPT_LOCALVAR 1
#define fpconv(fp) (reinterpret_cast<void *>(reinterpret_cast<long>(fp)))

@interface ViewController (hsp) {
}
- (void)code_init;
- (void)code_bye;
- (void)code_termfunc;
- (void)code_setctx:(HSPContext *)ctx;
- (void)code_resetctx:(HSPContext *)_ctx;
- (void)code_setpc:(const unsigned short *)pc;
- (void)code_setpci:(const unsigned short *)pc;
- (void)code_call:(const unsigned short *)pc;
- (int)code_execcmd;
- (int)code_execcmd2;
- (int)code_exec_wait:(int)tick;
- (int)code_exec_await:(int)tick;
- (HSPERROR)code_geterror;
- (void)code_puterror:(HSPERROR)error;
- (void)code_next;
- (int)code_get;
- (char *)code_gets;
- (char *)code_getds:(const char *)defval;
- (char *)code_getdsi:(const char *)defval;
- (int)code_geti;
- (int)code_getdi:(const int)defval;
- (double)code_getd;
- (double)code_getdd:(const double)defval;
- (PVal *)code_getpval;
- (char *)code_getvptr:(PVal **)pval size:(int *)size;
- (APTR)code_getva:(PVal **)pval;
- (void)code_setva:(PVal *)pval aptr:(APTR)aptr type:(int)type ptr:(const void *)ptr;
- (unsigned short *)code_getlb;
- (unsigned short *)code_getlb2;
- (STRUCTDAT *)code_getstruct;
- (STRUCTPRM *)code_getstprm;
- (STRUCTDAT *)code_getcomst;
- (char *)code_get_proxyvar:(char *)ptr mptype:(int *)mptype;
- (APTR)code_getv_proxy:(PVal **)pval var:(MPVarData *)var mptype:(int)mptype;
- (void)code_expandstruct:(char *)p st:(STRUCTDAT *)st option:(int)option;
- (FlexValue *)code_setvs:(PVal *)pval aptr:(APTR)aptr ptr:(void *)ptr size:(int)size subid:(int)subid;
- (char *)code_stmpstr:(char *)src;
- (char *)code_stmp:(int)size;
- (char *)code_getsptr:(int *)type;
- (int)code_debug_init;
- (int)code_getdebug_line;
- (char *)code_getdebug_name;
- (int)code_getdebug_seekvar:(const char *)name;
- (char *)code_getdebug_varname:(int)val_id;
- (int)code_event:(int)event prm1:(int)prm1 prm2:(int)prm2 prm3:(void *)prm3;
- (void)code_bload:(char *)fname ofs:(int)ofs size:(int)size ptr:(void *)ptr;
- (void)code_bsave:(char *)fname ofs:(int)ofs size:(int)size ptr:(void *)ptr;
- (IRQDAT *)code_getirq:(int)id;
- (IRQDAT *)code_seekirq:(int)actid custom:(int)custom;
- (IRQDAT *)code_addirq;
- (int)code_isirq:(int)id;
- (int)code_isuserirq;
- (int)code_sendirq:(int)id iparam:(int)iparam wparam:(int)wparam lparam:(int)lparam;
- (int)code_checkirq:(int)id message:(int)message wparam:(int)wparam lparam:(int)lparam;
- (void)code_execirq:(IRQDAT *)irq wparam:(int)wparam lparam:(int)lparam;
- (void)code_setirq:(int)id opt:(int)opt custom:(int)custom ptr:(unsigned short *)ptr;
- (int)code_irqresult:(int *)value;
- (void)code_enableirq:(int)id sw:(int)sw;
- (HSP3TYPEINFO *)code_gettypeinfo:(int)type;
- (void)code_enable_typeinfo:(HSP3TYPEINFO *)info;
- (HSP3DEBUG *)code_getdbg;
- (char *)code_inidbg;
- (void)code_adddbg3:(char const *)s1 sep:(char const *)sep s2:(char const *)s2;
- (void)code_adddbg2:(char *)name str:(char *)str;
- (void)code_adddbg2:(char *)name val:(int)val;
- (void)code_adddbg:(char *)name str:(char *)str;
- (void)code_adddbg:(char *)name val:(double)val;
- (void)code_adddbg:(char *)name intval:(int)intval;
- (void)code_dbg_global;
- (void)code_dbgdump:(char const *)mem size:(int)size;
- (void)code_dbgvarinf_ext:(PVal *)pv src:(void *)src buf:(char *)buf;
- (char *)code_dbgvalue:(int)type;
- (char *)code_dbgvarinf:(char *)target option:(int)option;
- (void)code_dbgcurinf;
- (void)code_dbgclose:(char *)buf;
- (int)code_dbgset:(int)id;
- (char *)code_dbgcallstack;
- (void)code_dbgtrace;
- (void)code_delstruct:(PVal *)in_pval in_aptr:(APTR)in_aptr;
- (void)code_delstruct_all:(PVal *)pval;
- (void)code_checkarray:(PVal *)pval;
- (void)code_checkarray2:(PVal *)pval;
- (int)cmdfunc_gosub:(unsigned short *)subr;
- (void *)reffunc_sysvar:(int *)type_res arg:(int)arg;
@end

#endif /* hsp_h */
