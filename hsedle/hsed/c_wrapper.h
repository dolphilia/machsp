//
//  c_wrapper.h
//  hsedle
//
//  Created by dolphilia on 2022/04/18.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#ifndef c_wrapper_h
#define c_wrapper_h

#include "str.h"
#include "vec.h"
#include "utility.h"
#include "utility_stack.h"
#include "utility_string.h"
#include "utility_time.h"
#include "utility_com.h"
#include "utility_errmsg.h"

@interface cwrap : NSObject

// str
+ (string)string_create:(const char *)str;

+ (void)string_add_char:(string *)s c:(char)c;

+ (void)string_add:(string *)s str:(const char *)str;

+ (void)string_insert:(string *)s pos:(str_size)pos str:(const char *)str;

+ (void)string_replace:(string *)s pos:(str_size)pos len:(str_size)len str:(const char *)str;

+ (void)string_remove:(string)s pos:(str_size)pos len:(str_size)len; // removing elements does not require reallocation
+ (void)string_free:(string)s;

+ (str_size)string_size:(string)s;

+ (str_size)string_get_alloc:(string)s;

// vec
+ (vector)vector_create;

+ (void)vector_free:(vector)vec;

+ (vector)_vector_add:(vector *)vec_addr type_size:(vec_type_t)type_size;

+ (vector)_vector_insert:(vector *)vec_addr type_size:(vec_type_t)type_size pos:(vec_size_t)pos;

+ (void)_vector_erase:(vector *)vec_addr type_size:(vec_type_t)type_size pos:(vec_size_t)pos len:(vec_size_t)len;

+ (void)_vector_remove:(vector *)vec_addr type_size:(vec_type_t)type_size pos:(vec_size_t)pos;

+ (void)vector_pop:(vector)vec;

+ (vector)_vector_copy:(vector)vec type_size:(vec_type_t)type_size;

+ (vec_size_t)vector_size:(vector)vec;

+ (vec_size_t)vector_get_alloc:(vector)vec;

// cvec
//+(void)vec_grow:(void**)vector i:(size_t)i s:(size_t)s;
//+(void)vec_delete:(void*)vector;

// utility
+ (int)tstrcmp:(const char *)str1 str2:(const char *)str2;

+ (void)strcase:(char *)str;

+ (void)strcase2:(char *)str str2:(char *)str2;

+ (void)addext:(char *)st exstr:(const char *)exstr;

+ (void)cutext:(char *)st;

+ (void)cutlast:(char *)st;

+ (void)cutlast2:(char *)st;

+ (void)strcpy2:(char *)dest src:(const char *)src size:(size_t)size;

+ (char *)strchr2:(char *)target code:(char)code;

+ (int)is_sjis_char_head:(const unsigned char *)str pos:(int)pos;

+ (char *)to_hsp_string_literal:(const char *)src;

+ (int)atoi_allow_overflow:(const char *)s;

+ (void)getpath:(const char *)src outbuf:(char *)outbuf p2:(int)p2;

+ (void)ExecFile:(char *)stmp ps:(char *)ps mode:(int)mode;

+ (void)dirinfo:(char *)p id:(int)id;

+ (char *)strchr3:(char *)target code:(int)code sw:(int)sw findptr:(char **)findptr;

+ (void)TrimCode:(char *)p code:(int)code;

+ (void)TrimCodeL:(char *)p code:(int)code;

+ (void)TrimCodeR:(char *)p code:(int)code;

+ (void)Alert:(const char *)mes;

+ (void)AlertV:(const char *)mes val:(int)val;

+ (void)Alertf:(const char *)format, ...;

// utility_stack
+ (void)stack_init;

+ (int)GetTagID:(char *)tag;

+ (char *)GetTagName:(int)tagid;

+ (int)PushTag:(int)tagid str:(char *)str;

+ (char *)PopTag:(int)tagid;

+ (char *)LookupTag:(int)tagid level:(int)level;

+ (void)GetTagUniqueName:(int)tagid outname:(char *)outname;

+ (int)StackCheck:(char *)res;

// utility_string
+ (void)Select:(char *)str;

+ (int)GetSize;

+ (int)GetMaxLine;

+ (int)GetLine:(char *)nres line:(int)line;

+ (int)GetLine2:(char *)nres line:(int)line max:(int)max;

+ (int)PutLine:(char *)nstr line:(int)line ovr:(int)ovr;

+ (char *)GetLineDirect:(int)line;

+ (void)ResumeLineDirect;

+ (int)nnget:(char *)nbase line:(int)line;

// utility_time
+ (int)GetTime:(int)index;

+ (char *)CurrentTime;

+ (char *)CurrentDate;

// utility_com
+ (int)ConvertIID:(COM_GUID *)guid name:(char *)name;

// utility_errmsg
+ (char *)cg_geterror:(int)error;

@end

#endif /* c_wrapper_h */
