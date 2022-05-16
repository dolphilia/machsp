//
//  c_wrapper.h
//  hsedle
//
//  Created by dolphilia on 2022/04/18.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#ifndef c_wrapper_h
#define c_wrapper_h

#include "utility.h"
#include "utility_stack.h"
#include "utility_string.h"
#include "utility_time.h"
#include "utility_com.h"
#include "utility_errmsg.h"

@interface cwrap : NSObject

// utility
+(int)tstrcmp:(const char*)str1 str2:(const char*)str2;
+(void)strcase:(char*)str;
+(void)strcase2:(char*)str str2:(char*)str2;
+(void)addext:(char*)st exstr:(const char*)exstr;
+(void)cutext:(char*)st;
+(void)cutlast:(char*)st;
+(void)cutlast2:(char*)st;
+(void)strcpy2:(char*)dest src:(const char*)src size:(size_t)size;
+(char*)strchr2:(char*)target code:(char)code;
+(int)is_sjis_char_head:(const unsigned char*)str pos:(int)pos;
+(char*)to_hsp_string_literal:(const char*)src;
+(int)atoi_allow_overflow:(const char*)s;
+(void)getpath:(const char*)src outbuf:(char*)outbuf p2:(int)p2;
+(void)ExecFile:(char*)stmp ps:(char*)ps mode:(int)mode;
+(void)dirinfo:(char*)p id:(int)id;
+(char*)strchr3:(char*)target code:(int)code sw:(int)sw findptr:(char**)findptr;
+(void)TrimCode:(char*)p code:(int)code;
+(void)TrimCodeL:(char*)p code:(int)code;
+(void)TrimCodeR:(char*)p code:(int)code;
+(void)Alert:(const char*)mes;
+(void)AlertV:(const char*)mes val:(int)val;
+(void)Alertf:(const char*)format, ... ;

// utility_stack
+(void)stack_init;
+(int)GetTagID:(char*)tag;
+(char*)GetTagName:(int)tagid;
+(int)PushTag:(int)tagid str:(char*)str;
+(char*)PopTag:(int)tagid;
+(char*)LookupTag:(int)tagid level:(int)level;
+(void)GetTagUniqueName:(int)tagid outname:(char*)outname;
+(int)StackCheck:(char*)res;

// utility_string
+(void)Select:(char*)str;
+(int)GetSize;
+(int)GetMaxLine;
+(int)GetLine:(char*)nres line:(int)line;
+(int)GetLine2:(char*)nres line:(int)line max:(int)max;
+(int)PutLine:(char*)nstr line:(int)line ovr:(int)ovr;
+(char*)GetLineDirect:(int)line;
+(void)ResumeLineDirect;
+(int)nnget:(char*)nbase line:(int)line;

// utility_time
+(int)GetTime:(int)index;
+(char*)CurrentTime;
+(char*)CurrentDate;

// utility_com
+(int)ConvertIID:(COM_GUID*)guid name:(char*)name;

// utility_errmsg
+(char*)cg_geterror:(int)error;

@end

#endif /* c_wrapper_h */
