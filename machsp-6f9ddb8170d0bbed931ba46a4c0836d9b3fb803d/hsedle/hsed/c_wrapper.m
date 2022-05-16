//
//  c_wrapper.m
//  hsedle
//
//  Created by dolphilia on 2022/04/18.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "c_wrapper.h"

@implementation cwrap

// utility

+(int)tstrcmp:(const char*)str1 str2:(const char*)str2 {
    return tstrcmp(str1, str2);
}

+(void)strcase:(char*)str {
    strcase(str);
}

+(void)strcase2:(char*)str str2:(char*)str2 {
    strcase2(str, str2);
}

+(void)addext:(char*)st exstr:(const char*)exstr {
    addext(st, exstr);
}

+(void)cutext:(char*)st {
    cutext(st);
}

+(void)cutlast:(char*)st {
    cutlast(st);
}

+(void)cutlast2:(char*)st {
    cutlast2(st);
}

+(void)strcpy2:(char*)dest src:(const char*)src size:(size_t)size {
    strcpy2(dest, src, size);
}

+(char*)strchr2:(char*)target code:(char)code {
    return strchr2(target, code);
}

+(int)is_sjis_char_head:(const unsigned char*)str pos:(int)pos {
    return is_sjis_char_head(str, pos);
}
+(char*)to_hsp_string_literal:(const char*)src {
    return to_hsp_string_literal(src);
}

+(int)atoi_allow_overflow:(const char*)s {
    return atoi_allow_overflow(s);
}

+(void)getpath:(const char*)src outbuf:(char*)outbuf p2:(int)p2 {
    getpath(src, outbuf, p2);
}

+(void)ExecFile:(char*)stmp ps:(char*)ps mode:(int)mode {
    ExecFile(stmp, ps, mode);
}

+(void)dirinfo:(char*)p id:(int)id {
    dirinfo(p, id);
}

+(char*)strchr3:(char*)target code:(int)code sw:(int)sw findptr:(char**)findptr {
    return strchr3(target, code, sw, findptr);
}

+(void)TrimCode:(char*)p code:(int)code {
    TrimCode(p, code);
}

+(void)TrimCodeL:(char*)p code:(int)code {
    TrimCodeL(p, code);
}

+(void)TrimCodeR:(char*)p code:(int)code {
    TrimCodeR(p, code);
}

+(void)Alert:(const char*)mes {
    Alert(mes);
}

+(void)AlertV:(const char*)mes val:(int)val {
    AlertV(mes, val);
}

+(void)Alertf:(const char*)format, ... {
    Alertf(format); /// @warning 可変長引数に未対応
}


// utility_stack

+(void)stack_init {
    stack_init();
}

+(int)GetTagID:(char*)tag {
    return GetTagID(tag);
}

+(char*)GetTagName:(int)tagid {
    return GetTagName(tagid);
}

+(int)PushTag:(int)tagid str:(char*)str {
    return PushTag(tagid, str);
}

+(char*)PopTag:(int)tagid {
    return PopTag(tagid);
}

+(char*)LookupTag:(int)tagid level:(int)level {
    return LookupTag(tagid, level);
}

+(void)GetTagUniqueName:(int)tagid outname:(char*)outname {
    GetTagUniqueName(tagid, outname);
}

+(int)StackCheck:(char*)res {
    return StackCheck(res);
}


// utility_string

+(void)Select:(char*)str {
    Select(str);
}

+(int)GetSize {
    return GetSize();
}

+(int)GetMaxLine {
    return GetMaxLine();
}

+(int)GetLine:(char*)nres line:(int)line {
    return GetLine(nres, line);
}

+(int)GetLine2:(char*)nres line:(int)line max:(int)max {
    return GetLine2(nres, line, max);
}

+(int)PutLine:(char*)nstr line:(int)line ovr:(int)ovr {
    return PutLine(nstr, line, ovr);
}

+(char*)GetLineDirect:(int)line {
    return GetLineDirect(line);
}

+(void)ResumeLineDirect {
    ResumeLineDirect();
}

+(int)nnget:(char*)nbase line:(int)line {
    return nnget(nbase, line);
}


// utility_time

+(int)GetTime:(int)index {
    return GetTime(index);
}

+(char*)CurrentTime {
    return CurrentTime();
}

+(char*)CurrentDate {
    return CurrentDate();
}


// utility_com

+(int)ConvertIID:(COM_GUID*)guid name:(char*)name {
    return ConvertIID(guid, name);
}


// utility_errmsg

+(char*)cg_geterror:(int)error {
    return cg_geterror(error);
}

@end
