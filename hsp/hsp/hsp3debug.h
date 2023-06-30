
//
//	hsp3debug.cpp header
//

#ifndef __hsp3debug_h
#define __hsp3debug_h

#import "hsp3struct_debug.h"

#ifdef FLAG_HSPDEBUG
char *hsp_debug_get_error(HSPERROR error);
#else
char *hsp_debug_get_error(HSPERROR error);
#endif

#endif
