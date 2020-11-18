//
//	HSP3 Built-in commands
//	(内蔵コマンド・関数処理)
//	onion software/onitama 2004/6
//
#import "hsp3int.h"
//#import <algorithm> //sortを使用
#import "hspvar_double.h"
#import "hspvar_int.h"
#import "hspvar_label.h"
#import "hspvar_str.h"
#import "hspvar_struct.h"
#import "utility_string.h"
// LFを改行として扱う
#define MATCH_LF
#define CRSTR "\n"
#define EASE_LINEAR 0
#define EASE_QUAD_IN 1
#define EASE_QUAD_OUT 2
#define EASE_QUAD_INOUT 3
#define EASE_CUBIC_IN 4
#define EASE_CUBIC_OUT 5
#define EASE_CUBIC_INOUT 6
#define EASE_QUARTIC_IN 7
#define EASE_QUARTIC_OUT 8
#define EASE_QUARTIC_INOUT 9
#define EASE_BOUNCE_IN 10
#define EASE_BOUNCE_OUT 11
#define EASE_BOUNCE_INOUT 12
#define EASE_SHAKE_IN 13
#define EASE_SHAKE_OUT 14
#define EASE_SHAKE_INOUT 15
#define EASE_LOOP 4096
// デストラクタで自動的に sbFree を呼ぶ
//class CAutoSbFree {
//public:
//    CAutoSbFree(char **pptr);
//    ~CAutoSbFree();
//
//private:
//    // uncopyable;
//    CAutoSbFree(CAutoSbFree const &);
//    CAutoSbFree const &operator=(CAutoSbFree const &);
//
//private:
//    char **pptr_;
//};
//
//CAutoSbFree::CAutoSbFree(char **pptr) : pptr_(pptr) {}
//
//CAutoSbFree::~CAutoSbFree() {
//    //sbFree(*pptr_);
//}
@implementation ViewController (hsp3int)
//----Sort Routines
- (bool)less_int_1:(const DATA)lhs rhs:(const DATA)rhs {
    int cmp = (lhs.as.ikey - rhs.as.ikey);
    return (cmp < 0) || (cmp == 0 && lhs.info < rhs.info);
}
- (bool)less_int_0:(const DATA)lhs rhs:(const DATA)rhs {
    int cmp = (lhs.as.ikey - rhs.as.ikey);
    return (cmp > 0) || (cmp == 0 && lhs.info < rhs.info);
}
- (bool)less_double_1:(const DATA)lhs rhs:(const DATA)rhs {
    int cmp =
    (lhs.as.dkey < rhs.as.dkey ? -1 : (lhs.as.dkey > rhs.as.dkey ? 1 : 0));
    return (cmp < 0) || (cmp == 0 && lhs.info < rhs.info);
}
- (bool)less_double_0:(const DATA)lhs rhs:(const DATA)rhs {
    int cmp =
    (lhs.as.dkey < rhs.as.dkey ? -1 : (lhs.as.dkey > rhs.as.dkey ? 1 : 0));
    return (cmp > 0) || (cmp == 0 && lhs.info < rhs.info);
}
- (bool)less_str_1:(const DATA)lhs rhs:(const DATA)rhs {
    int cmp = (strcmp(lhs.as.skey, rhs.as.skey));
    return (cmp < 0) || (cmp == 0 && lhs.info < rhs.info);
}
- (bool)less_str_0:(const DATA)lhs rhs:(const DATA)rhs {
    int cmp = (strcmp(lhs.as.skey, rhs.as.skey));
    return (cmp > 0) || (cmp == 0 && lhs.info < rhs.info);
}
- (int)NoteToData:(char *)adr data:(DATA *)data {
    char *p = adr;
    int line = 0;
    while (*p != '\0') {
        data[line].as.skey = p;
        data[line].info = line;
        while (*p != '\0') {
            char c = *p;
            if (c == '\n' || c == '\r') {
                *p = '\0';
            }
            p++;
            if (c == '\n') break;
            if (c == '\r') {
                if (*p == '\n') p++;
                break;
            }
        }
        line++;
    }
    return line;
}
- (int)GetNoteLines:(char *)adr {
    int line = 0;
    char *p = adr;
    while (*p != '\0') {
        while (*p != '\0') {
            char c = *p++;
            if (c == '\n') break;
            if (c == '\r') {
                if (*p == '\n') p++;
                break;
            }
        }
        line++;
    }
    return line;
}
- (size_t)DataToNoteLen:(DATA *)data num:(int)num {
    size_t len = 0;
    int i;
    for (i = 0; i < num; i++) {
        char *s = data[i].as.skey;
        len += strlen(s) + 2;  // strlen("¥r¥n")
    }
    return len;
}
- (void)DataToNote:(DATA *)data adr:(char *)adr num:(int)num {
    int a;
    char *p;
    char *s;
    p = adr;
    for (a = 0; a < num; a++) {
        s = data[a].as.skey;
        strcpy(p, s);
        p += strlen(s);
        *p++ = 13;
        *p++ = 10;  // Add CR/LF
    }
    *p = 0;
}
//----Sort Interface
- (void)DataBye {
    if (hsp3int_data_temp != NULL) {
        [self mem_bye:hsp3int_data_temp];
    }
}
- (void)DataIni:(int)size {
    [self DataBye];
    hsp3int_data_temp = (DATA *)[self mem_ini:sizeof(DATA) * size];
    hsp3int_data_tmp_size = size;
}
// static void
// DataExpand( int size )
//{
//
//    if (size <= hsp3int_data_tmp_size) return;
//    int new_size = hsp3int_data_tmp_size;
//    if (new_size < 16) new_size = 16;
//    while (size > new_size) {
//        new_size *= 2;
//    }
//    hsp3int_data_temp = (DATA *)realloc( hsp3int_data_temp,
//    sizeof(DATA)*new_size );
//    memset( hsp3int_data_temp + hsp3int_data_tmp_size, 0,
//    sizeof(DATA)*(new_size - hsp3int_data_tmp_size) );
//    hsp3int_data_tmp_size = new_size;
//
//}
// static void
// DataInc( int n )
//{
//
//    DataExpand( n + 1 );
//    hsp3int_data_temp[n].info ++;
//
//}
/*------------------------------------------------------------*/
/*
 Easing Function
 */
/*------------------------------------------------------------*/
/*------------------------------------------------------------*/
- (double)_ease_linear:(double)t {
    return hsp3int_ease_diff * t + hsp3int_ease_start;
}
- (double)_ease_quad_in:(double)t {
    return hsp3int_ease_diff * t * t + hsp3int_ease_start;
}
- (double)_ease_quad_out:(double)t {
    return -hsp3int_ease_diff * t * (t - 2) + hsp3int_ease_start;
}
- (double)_ease_quad_inout:(double)t {
    double tt;
    tt = t * 2;
    if (tt < 1) {
        return hsp3int_ease_diff * 0.5 * tt * tt + hsp3int_ease_start;
    }
    tt = tt - 1;
    return -hsp3int_ease_diff * 0.5 * (tt * (tt - 2) - 1) + hsp3int_ease_start;
}
- (double)_ease_cubic_in:(double)t {
    return hsp3int_ease_diff * t * t * t + hsp3int_ease_start;
}
- (double)_ease_cubic_out:(double)t {
    double tt;
    tt = t - 1;
    return hsp3int_ease_diff * (tt * tt * tt + 1) + hsp3int_ease_start;
}
- (double)_ease_cubic_inout:(double)t {
    double tt;
    tt = t * 2;
    if (tt < 1) {
        return hsp3int_ease_diff * 0.5 * tt * tt * tt + hsp3int_ease_start;
    }
    tt = tt - 2;
    return hsp3int_ease_diff * 0.5 * (tt * tt * tt + 2) + hsp3int_ease_start;
}
- (double)_ease_quartic_in:(double)t {
    return hsp3int_ease_diff * t * t * t * t + hsp3int_ease_start;
}
- (double)_ease_quartic_out:(double)t {
    double tt;
    tt = t - 1;
    return -hsp3int_ease_diff * (tt * tt * tt * tt - 1) + hsp3int_ease_start;
}
- (double)_ease_quartic_inout:(double)t {
    double tt;
    tt = t * 2;
    if (tt < 1) {
        return hsp3int_ease_diff * 0.5 * tt * tt * tt * tt + hsp3int_ease_start;
    }
    tt = tt - 2;
    return -hsp3int_ease_diff * 0.5 * (tt * tt * tt * tt - 2) +
    hsp3int_ease_start;
}
- (double)_ease_bounce:(double)t {
    if (t < (1 / 2.75)) {
        return hsp3int_ease_diff * (7.5625 * t * t);
    } else if (t < (2 / 2.75)) {
        double tmp = t - 1.5 / 2.75;
        return hsp3int_ease_diff * (7.5625 * tmp * t + .75);
    } else if (t < (2.5 / 2.75)) {
        double tmp = t - 2.25 / 2.75;
        return hsp3int_ease_diff * (7.5625 * tmp * t + .9375);
    } else {
        double tmp = t - 2.625 / 2.75;
        return hsp3int_ease_diff * (7.5625 * tmp * t + .984375);
    }
}
- (double)_ease_bounce_in:(double)t {
    double tt;
    tt = (double)1 - t;
    return hsp3int_ease_diff - [self _ease_bounce:tt] + hsp3int_ease_start;
}
- (double)_ease_bounce_out:(double)t {
    return [self _ease_bounce:t] + hsp3int_ease_start;
}
- (double)_ease_bounce_inout:(double)t {
    double tt;
    if (t < 0.5) {
        tt = (double)1 - (t * 2);
        return (hsp3int_ease_diff - [self _ease_bounce:tt]) * 0.5 +
        hsp3int_ease_start;
    }
    return [self _ease_bounce:t * 2 - 1] * 0.5 + hsp3int_ease_diff * 0.5 +
    hsp3int_ease_start;
}
- (double)_ease_shake:(double)t {
    int pulse;
    double tt;
    tt = t * t * 8;
    pulse = (int)tt;
    tt -= (double)pulse;
    if (pulse & 1) {
        return ((double)1 - tt);
    }
    return tt;
}
- (double)_ease_shake_in:(double)t {
    double tt;
    tt = (double)1 - t;
    return (hsp3int_ease_diff * [self _ease_shake:tt]) * tt -
    hsp3int_ease_diff * 0.5 * tt + hsp3int_ease_start;
}
- (double)_ease_shake_out:(double)t {
    return (hsp3int_ease_diff * [self _ease_shake:t]) * t -
    hsp3int_ease_diff * 0.5 * t + hsp3int_ease_start;
}
- (double)_ease_shake_inout:(double)t {
    double tt;
    tt = t * 2;
    if (tt < 1) {
        return [self _ease_shake_in:tt];
    }
    tt = tt - 1;
    return [self _ease_shake_out:tt];
}
/*------------------------------------------------------------*/
- (void)initEase {
    hsp3int_ease_4096 = (double)1.0 / (double)4096.0;
}
- (void)setEase:(int)type
    value_start:(double)value_start
      value_end:(double)value_end {
    hsp3int_ease_type = type;
    hsp3int_ease_reverse = 0;
    hsp3int_ease_org_start = hsp3int_ease_start = value_start;
    hsp3int_ease_org_diff = hsp3int_ease_diff = value_end - value_start;
}
- (double)getEase:(double)value {
    int type;
    int reverse;
    double t;
    t = value;
    type = hsp3int_ease_type & (EASE_LOOP - 1);
    reverse = 0;
    if (hsp3int_ease_type & EASE_LOOP) {
        int ival;
        double dval;
        t = modf(t, &dval);
        ival = (int)dval;
        reverse = ival & 1;
    } else {
        if (t < 0) t = (double)0;
        if (t > 1) t = (double)1;
    }
    if (hsp3int_ease_reverse != reverse) {
        hsp3int_ease_reverse = reverse;  // リバース時の動作
        if (hsp3int_ease_reverse) {
            hsp3int_ease_start = hsp3int_ease_org_start + hsp3int_ease_org_diff;
            hsp3int_ease_diff = -hsp3int_ease_org_diff;
        } else {
            hsp3int_ease_start = hsp3int_ease_org_start;
            hsp3int_ease_diff = hsp3int_ease_org_diff;
        }
    }
    switch (type) {
        case EASE_QUAD_IN:
            return [self _ease_quad_in:t];
        case EASE_QUAD_OUT:
            return [self _ease_quad_out:t];
        case EASE_QUAD_INOUT:
            return [self _ease_quad_inout:t];
        case EASE_CUBIC_IN:
            return [self _ease_cubic_in:t];
        case EASE_CUBIC_OUT:
            return [self _ease_cubic_out:t];
        case EASE_CUBIC_INOUT:
            return [self _ease_cubic_inout:t];
        case EASE_QUARTIC_IN:
            return [self _ease_quartic_in:t];
        case EASE_QUARTIC_OUT:
            return [self _ease_quartic_out:t];
        case EASE_QUARTIC_INOUT:
            return [self _ease_quartic_inout:t];
        case EASE_BOUNCE_IN:
            return [self _ease_bounce_in:t];
        case EASE_BOUNCE_OUT:
            return [self _ease_bounce_out:t];
        case EASE_BOUNCE_INOUT:
            return [self _ease_bounce_inout:t];
        case EASE_SHAKE_IN:
            return [self _ease_shake_in:t];
        case EASE_SHAKE_OUT:
            return [self _ease_shake_out:t];
        case EASE_SHAKE_INOUT:
            return [self _ease_shake_inout:t];
        case EASE_LINEAR:
        default:
            break;
    }
    return [self _ease_linear:t];
}
- (double)getEase:(double)value maxvalue:(double)maxvalue {
    if (maxvalue == 0) {
        return (double)0;
    }
    return [self getEase:value / maxvalue];
}
- (int)getEaseInt:(int)i_value i_maxvalue:(int)i_maxvalue {
    int i;
    double value;
    if (i_maxvalue > 0) {
        value = (double)i_value / (double)i_maxvalue;
    } else {
        value = hsp3int_ease_4096 * i_value;
    }
    i = (int)[self getEase:value];
    return i;
}
/*------------------------------------------------------------*/
/*
 interface
 */
/*------------------------------------------------------------*/
- (char *)note_update {
    char *p;
    if (vc_hspctx->note_pval == NULL) {
         @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    p = (char *)[self HspVarCorePtrAPTR:vc_hspctx->note_pval ofs:vc_hspctx->note_aptr];
    [self Select:p];
    return p;
}
- (void)cnvformat_expand:(char **)p
                capacity:(int *)capacity
                     len:(int)len
                       n:(int)n {
    int needed_size = len + n + 1;
    int capa = *capacity;
    if (needed_size > capa) {
        while (needed_size > capa) {
            capa *= 2;
        }
        *p = [self sbExpand:*p size:capa];
        *capacity = capa;
    }
}
- (char *)cnvformat {
    //		フォーマット付き文字列を作成する
    //
#if (WIN32 || _WIN32) && !__CYGWIN__
#define SNPRINTF _snprintf
#else
#define SNPRINTF snprintf
#endif
    char fstr[1024];
    char *fp;
    int capacity;
    int len;
    char *p;
    strncpy(fstr, [self code_gets], sizeof fstr);
    fstr[sizeof(fstr) - 1] = '\0';
    fp = fstr;
    capacity = 1024;
    p = [self sbAlloc:capacity];
    len = 0;
    //CAutoSbFree autofree(&p);
    while (1) {
        char fmt[32];
        int i;
        int val_type;
        void *val_ptr;
        // '%' までをコピー
        i = 0;
        while (fp[i] != '\0' && fp[i] != '%') {
            i++;
        }
        [self cnvformat_expand:&p capacity:&capacity len:len n:i];
        memcpy(p + len, fp, i);
        len += i;
        fp += i;
        if (*fp == '\0') break;
        // 変換指定を読み fmt にコピー
        i = (int)strspn(fp + 1, " #+-.0123456789") + 1;
        strncpy(fmt, fp, sizeof fmt);
        fmt[sizeof(fmt) - 1] = '\0';
        if (i + 1 < (int)(sizeof fmt)) fmt[i + 1] = '\0';
        fp += i;
        char specifier = *fp;
        fp++;
#if (WIN32 || _WIN32) && !__CYGWIN__
        if (specifier == 'I') {  // I64 prefix対応(VC++のみ)
            if ((fp[0] == '6') && (fp[1] = '4')) {
                memcpy(fmt + i + 1, fp, 3);
                fmt[i + 4] = 0;
                specifier = 'f';
                fp += 3;
            }
        }
#endif
        if (specifier == '\0') break;
        if (specifier == '%') {
            [self cnvformat_expand:&p capacity:&capacity len:len n:1];
            p[len++] = '%';
            continue;
        }
        // 引数を取得
        if ([self code_get] <= PARAM_END) {
             @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
        }
        switch (specifier) {
            case 'd':
            case 'i':
            case 'c':
            case 'o':
            case 'x':
            case 'X':
            case 'u':
            case 'p':
                val_type = HSPVAR_FLAG_INT;
                val_ptr = [self HspVarCoreCnvPtr:mpval flag:HSPVAR_FLAG_INT];
                break;
            case 'f':
            case 'e':
            case 'E':
            case 'g':
            case 'G':
                val_type = HSPVAR_FLAG_DOUBLE;
                val_ptr = [self HspVarCoreCnvPtr:mpval flag:HSPVAR_FLAG_DOUBLE];
                break;
            case 's':
                val_type = HSPVAR_FLAG_STR;
                val_ptr = [self HspVarCoreCnvPtr:mpval flag:HSPVAR_FLAG_STR];
                break;
            default: {
                 @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
            }
        }
        // snprintf が成功するまでバッファを広げていき、変換を行う
        while (1) {
            int n;
            int space = capacity - len - 1;
            if (val_type == HSPVAR_FLAG_INT) {
                n = SNPRINTF(p + len, space, fmt, *(int *)val_ptr);
            } else if (val_type == HSPVAR_FLAG_DOUBLE) {
                n = SNPRINTF(p + len, space, fmt, *(double *)val_ptr);
            } else {
                n = SNPRINTF(p + len, space, fmt, (char *)val_ptr);
            }
            if (n >= 0 && n < space) {
                len += n;
                break;
            }
            if (n >= 0) {
                space = n + 1;
            } else {
                space *= 2;
                if (space < 32) space = 32;
            }
            [self cnvformat_expand:&p capacity:&capacity len:len n:space];
        }
    }
    p[len] = '\0';
    char *result = [self code_stmp:len + 1];
    strcpy(result, p);
    [self sbFree:&p];
    return result;
}
- (void)var_set_str_len:(PVal *)pval
                   aptr:(APTR)aptr
                    str:(char *)str
                    len:(int)len {
    //		変数にstrからlenバイトの文字列を代入する
    //
    HspVarProc *proc = HspVarCoreGetProc(HSPVAR_FLAG_STR);
    if (pval->flag != HSPVAR_FLAG_STR) {
        if (aptr != 0) {
             @throw [self make_nsexception:HSPERR_INVALID_ARRAYSTORE];
        }
        [self HspVarCoreClear:pval flag:HSPVAR_FLAG_STR];
    }
    pval->offset = aptr;
    PDAT *dst;
    if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetPtr
        dst = [self HspVarInt_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetPtr
        dst = [self HspVarDouble_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetPtr
        dst = [self HspVarStr_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetPtr
        dst = [self HspVarLabel_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetPtr
        dst = [self HspVarLabel_GetPtr:pval];
    } else {
         @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    // HspVarCoreAllocBlock( pval, dst, len + 1 );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") ==
        0) {  //整数のAllocBlock
        [self HspVarInt_AllocBlock:pval pdat:dst size:len + 1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") ==
               0) {  //実数のAllocBlock
        [self HspVarDouble_AllocBlock:pval pdat:dst size:len + 1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") ==
               0) {  //文字列のAllocBlock
        [self HspVarStr_AllocBlock:pval pdat:dst size:len + 1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") ==
               0) {  //ラベルのAllocBlock
        [self HspVarLabel_AllocBlock:pval pdat:dst size:len + 1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") ==
               0) {  // structのAllocBlock
        [self HspVarLabel_AllocBlock:pval pdat:dst size:len + 1];
    } else {
         @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    char *ptr;
    if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetPtr
        ptr = (char *)[self HspVarInt_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetPtr
        ptr = (char *)[self HspVarDouble_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetPtr
        ptr = (char *)[self HspVarStr_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetPtr
        ptr = (char *)[self HspVarLabel_GetPtr:pval];
    } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetPtr
        ptr = (char *)[self HspVarLabel_GetPtr:pval];
    } else {
         @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    memcpy(ptr, str, len);
    ptr[len] = '\0';
}
- (int)cmdfunc_intcmd:(int)cmd {
    //		cmdfunc : TYPE_INTCMD
    //		(内蔵コマンド)
    //
    [self code_next];  // 次のコードを取得(最初に必ず必要です)
    switch (cmd) {  // サブコマンドごとの分岐
        case 0x00:  // onexit
        case 0x01:  // onerror
        case 0x02:  // onkey
        case 0x03:  // onclick
        case 0x04:  // oncmd
            [self cmdfunc_on:cmd];
            break;
        case 0x11:
            [self cmdfunc_exist];
            break;  // exist
        case 0x12:
            [self cmdfunc_delete];
            break;  // delete
        case 0x13:
            [self cmdfunc_mkdir];
            break;  // mkdir
        case 0x14:
            [self cmdfunc_chdir];
            break;  // chdir
        case 0x15:
            [self cmdfunc_dirlist];
            break;    // dirlist
        case 0x16:  // bload
        case 0x17:  // bsave
            [self cmdfunc_bload_bsave:cmd];
            break;
        case 0x18:
            [self cmdfunc_bcopy];
            break;  // bcopy
        case 0x19:
            [self cmdfunc_memfile];
            break;    // memfile
        case 0x1a:  // poke
        case 0x1b:  // wpoke
        case 0x1c:  // lpoke
            [self cmdfunc_poke_wpoke_lpoke:cmd];
            break;
        case 0x1d:
            [self cmdfunc_getstr];
            break;  // getstr
        case 0x1e:
            [self cmdfunc_chdpm];
            break;  // chdpm
        case 0x1f:
            [self cmdfunc_memexpand];
            break;  // memexpand
        case 0x20:
            [self cmdfunc_memcpy];
            break;  // memcpy
        case 0x21:
            [self cmdfunc_memset];
            break;  // memset
        case 0x22:
            [self cmdfunc_notesel];
            break;  // notesel
        case 0x23:
            [self cmdfunc_noteadd];
            break;  // noteadd
        case 0x24:
            [self cmdfunc_notedel];
            break;  // notedel
        case 0x25:
            [self cmdfunc_noteload];
            break;  // noteload
        case 0x26:
            [self cmdfunc_notesave];
            break;  // notesave
        case 0x27:
            [self cmdfunc_randomize];
            break;  // randomize
        case 0x28:
            [self cmdfunc_noteunsel];
            break;  // noteunsel
        case 0x29:
            [self cmdfunc_noteget];
            break;  // noteget
        case 0x2a:
            [self cmdfunc_split];
            break;  // split
        case 0x02b:
            [self cmdfunc_strrep];
            break;  // strrep
        case 0x02c:
            [self cmdfunc_setease];
            break;  // setease
        case 0x02d:
            [self cmdfunc_sortval];
            break;  // sortval
        case 0x02e:
            [self cmdfunc_sortstr];
            break;  // sortstr
        case 0x02f:
            [self cmdfunc_sortnote];
            break;  // sortnote
        case 0x030:
            [self cmdfunc_sortget];
            break;  // sortget
        default: {
             @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    return RUNMODE_RUN;
}
- (void)cmdfunc_on:(int)cmd {
    /*
     rev 45
     不具合 : (onxxx系命令) (ラベル型変数)  形式の書式でエラー
     に対処
     */
    int tval = *hsp3int_type;
    int opt = IRQ_OPT_GOTO;
    int cust;
    int actid;
    IRQDAT *irq;
    unsigned short *sbr;
    if (tval == TYPE_VAR) {
        if ((vc_hspctx->mem_var + *hsp3int_val)->flag == HSPVAR_FLAG_LABEL)
            tval = TYPE_LABEL;
    }
    if ((tval != TYPE_PROGCMD) && (tval != TYPE_LABEL)) {  // ON/OFF切り替え
        int i = [self code_geti];
        [self code_enableirq:cmd sw:i];
        return;
    }
    if (tval == TYPE_PROGCMD) {  // ジャンプ方法指定
        opt = *hsp3int_val;
        if (opt >= 2) {
             @throw [self make_nsexception:HSPERR_SYNTAX];
        }
        [self code_next];
    }
    sbr = [self code_getlb2];
    if (cmd != 0x04) {
        [self code_setirq:cmd opt:opt custom:-1 ptr:sbr];
        return;
    }
    cust = [self code_geti];
    actid = *(hsp3int_exinfo->actscr);
    irq = [self code_seekirq:actid custom:cust];
    if (irq == NULL) irq = [self code_addirq];
    irq->flag = IRQ_FLAG_ENABLE;
    irq->opt = opt;
    irq->ptr = sbr;
    irq->custom = cust;
    irq->custom2 = actid;
}
- (void)cmdfunc_exist {
    //カレントディレクトリ+パラメータ
    char *ps = [self code_gets];
    NSString *nPs = [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    nPs = [global.current_directory_path stringByAppendingPathComponent:nPs];
    //ファイルの有無をチェック
    BOOL isDir = NO;
    BOOL isExists = NO;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    // 0.エディタと同じディレクトリ
    // path = [[[[NSBundle mainBundle] bundlePath]
    // stringByDeletingLastPathComponent] stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:nPs isDirectory:&isDir];
    if (isExists) {  //存在する
        if (isDir) {   //ディレクトリ
            abc_hspctx.strsize = -2;
        } else {  //ファイル
            unsigned long long fileSize =
            [[filemanager attributesOfItemAtPath:nPs error:nil] fileSize];
            abc_hspctx.strsize = (int)fileSize;
        }
        //[[NSWorkspace sharedWorkspace] launchApplication:path];
        // return;
    } else {
        abc_hspctx.strsize = -1;
    }
}
- (void)cmdfunc_delete {
    //カレントディレクトリ+パラメータ
    char *ps = [self code_gets];
    NSString *nPs = [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    nPs = [global.current_directory_path stringByAppendingPathComponent:nPs];
    NSError *error = nil;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager removeItemAtPath:nPs error:&error];
    //[self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:[self code_gets]];
    //[self code_event:HSPEVENT_FEXIST + (cmd - 0x11) prm1:0 prm2:0 prm3:NULL];
}
- (void)cmdfunc_mkdir {
    char *ps = [self code_gets];
    NSString *nPs = [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    nPs = [global.current_directory_path stringByAppendingPathComponent:nPs];
    //ディレクトリを作成する
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:nPs
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
}
- (void)cmdfunc_chdir {
    char *ps = [self code_gets];
    NSString *nPs = [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    NSArray *paths = [nPs pathComponents];
    for (int i = 0; i < paths.count; i++) {
        if (i == 0 && [paths[i] isEqual:@"/"]) {  //初期化
            global.current_directory_path = @"/";
        } else if ([paths[i] isEqual:@".."]) {  //ディレクトリを一つ戻る
            global.current_directory_path =
            [global.current_directory_path stringByDeletingLastPathComponent];
        } else if (![paths[i] isEqual:@"/"]) {  //通常のパス
            global.current_directory_path = [global.current_directory_path
                                             stringByAppendingPathComponent:paths[i]];
        }
    }
    chdir([global.current_directory_path UTF8String]);
}
- (void)cmdfunc_dirlist {
    PVal *pval;
    APTR aptr;
    char *ptr;
    aptr = [self code_getva:&pval];
    [self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:[self code_gets]];
    int p1 = [self code_getdi:0];
    [self code_event:HSPEVENT_FDIRLIST1 prm1:p1 prm2:0 prm3:&ptr];
    [self code_setva:pval aptr:aptr type:TYPE_STRING ptr:ptr];
    [self code_event:HSPEVENT_FDIRLIST2 prm1:0 prm2:0 prm3:NULL];
}
- (void)cmdfunc_bload_bsave:(int)cmd {
    PVal *pval;
    char *ptr;
    int size;
    int tmpsize;
    [self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:[self code_gets]];
    ptr = [self code_getvptr:&pval size:&size];
    int p1 = [self code_getdi:-1];
    int p2 = [self code_getdi:-1];
    if ((p1 < 0) || (p1 > size)) p1 = size;
    if (cmd == 0x16) {
        tmpsize = p2;
        if (tmpsize < 0) tmpsize = 0;
        [self code_event:HSPEVENT_FREAD prm1:tmpsize prm2:p1 prm3:ptr];
    } else {
        [self code_event:HSPEVENT_FWRITE prm1:p2 prm2:p1 prm3:ptr];
    }
}
- (void)cmdfunc_bcopy {
    [self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:[self code_gets]];
    [self code_event:HSPEVENT_FCOPY prm1:0 prm2:0 prm3:[self code_gets]];
}
- (void)cmdfunc_memfile {
    PVal *pval;
    char *ptr;
    int size;
    ptr = [self code_getvptr:&pval size:&size];
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    if (p2 == 0) p2 = size - p1;
    [self dpm_memfile:ptr + p1 size:p2];
}
- (void)cmdfunc_poke_wpoke_lpoke:(int)cmd {
    PVal *pval;
    char *ptr;
    int size;
    int fl;
    int len;
    char *bp;
    ptr = [self code_getvptr:&pval size:&size];
    int p1 = [self code_getdi:0];
    int p2;
    if (p1 < 0) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    ptr += p1;
    if ([self code_get] <= PARAM_END) {
        fl = HSPVAR_FLAG_INT;
        bp = (char *)&p2;
        p2 = 0;
    } else {
        fl = mpval->flag;
        bp = mpval->pt;
    }
    if (cmd == 0x1a) {
        switch (fl) {
            case HSPVAR_FLAG_INT:
                if (p1 >= size) {
                     @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
                }
                *ptr = *bp;
                break;
            case HSPVAR_FLAG_STR:
                len = (int)strlen(bp);
                vc_hspctx->strsize = len;
                len++;
                if ((p1 + len) > size) {
                     @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
                }
                strcpy(ptr, bp);
                break;
            default: {
                 @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
        }
        return;
    }
    if (fl != HSPVAR_FLAG_INT) {
         @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    if (cmd == 0x1b) {
        if ((p1 + 2) > size) {
             @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
        }
        *(short *)ptr = (short)(*(short *)bp);
    } else {
        if ((p1 + 4) > size) {
             @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
        }
        *(int *)ptr = (*(int *)bp);
    }
}
- (void)cmdfunc_getstr {
    PVal *pval2;
    PVal *pval;
    APTR aptr;
    char *ptr;
    char *p;
    int size;
    aptr = [self code_getva:&pval];
    ptr = [self code_getvptr:&pval2 size:&size];
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:1024];
    if (p1 >= size) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    ptr += p1;
    p = [self code_stmp:p3 + 1];
    [self strsp_ini];
    vc_hspctx->stat = [self strsp_get:ptr dststr:p splitchr:p2 len:p3];
    vc_hspctx->strsize = [self strsp_getptr];
    [self code_setva:pval aptr:aptr type:HSPVAR_FLAG_STR ptr:p];
}
- (void)cmdfunc_chdpm {
    [self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:[self code_gets]];
    int p1 = [self code_getdi:-1];
    [self dpm_bye];
    int p2 = [self dpm_ini:vc_hspctx->fnbuffer dpmofs:0 chksum:-1 deckey:p1];
    if (p2) {
         @throw [self make_nsexception:HSPERR_FILE_IO];
    }
}
- (void)cmdfunc_memexpand {
    PVal *pval;
    APTR aptr;
    PDAT *ptr;
    aptr = [self code_getva:&pval];
    ptr = [self HspVarCorePtrAPTR:pval ofs:aptr];
    if ((pval->support & HSPVAR_SUPPORT_FLEXSTORAGE) == 0) {
         @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    int p1 = [self code_getdi:0];
    if (p1 < 64) p1 = 64;
    // HspVarCoreAllocBlock( pval, ptr, p1 );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") ==
        0) {  //整数のAllocBlock
        [self HspVarInt_AllocBlock:pval pdat:ptr size:p1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") ==
               0) {  //実数のAllocBlock
        [self HspVarDouble_AllocBlock:pval pdat:ptr size:p1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") ==
               0) {  //文字列のAllocBlock
        [self HspVarStr_AllocBlock:pval pdat:ptr size:p1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") ==
               0) {  //ラベルのAllocBlock
        [self HspVarLabel_AllocBlock:pval pdat:ptr size:p1];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") ==
               0) {  // structのAllocBlock
        [self HspVarLabel_AllocBlock:pval pdat:ptr size:p1];
    } else {
         @throw [self make_nsexception:HSPERR_SYNTAX];
    }
}
- (void)cmdfunc_memcpy {
    PVal *pval;
    char *sptr;
    char *tptr;
    int bufsize_t, bufsize_s;
    tptr = [self code_getvptr:&pval size:&bufsize_t];
    sptr = [self code_getvptr:&pval size:&bufsize_s];
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    if (p2 < 0 || p3 < 0) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    tptr += p2;
    sptr += p3;
    if ((p1 + p2) > bufsize_t) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    if ((p1 + p3) > bufsize_s) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    if (p1 > 0) {
        memmove(tptr, sptr, p1);
    }
}
- (void)cmdfunc_memset {
    PVal *pval;
    char *ptr;
    int size;
    ptr = [self code_getvptr:&pval size:&size];
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    if (p3 < 0) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    ptr += p3;
    if ((p3 + p2) > size) {
         @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
    }
    if (p2 > 0) {
        memset(ptr, p1, p2);
    }
}
- (void)cmdfunc_notesel {
    vc_hspctx->notep_aptr = vc_hspctx->note_aptr;
    vc_hspctx->notep_pval = vc_hspctx->note_pval;
    vc_hspctx->note_aptr = [self code_getva:&vc_hspctx->note_pval];
    if (vc_hspctx->note_pval->flag != HSPVAR_FLAG_STR) {
        [self code_setva:vc_hspctx->note_pval
                    aptr:vc_hspctx->note_aptr
                    type:TYPE_STRING
                     ptr:""];
    }
}
- (void)cmdfunc_noteadd {
    char *ps = [self code_gets];
    int p1 = [self code_getdi:-1];
    int p2 = [self code_getdi:0];
    NSString *nPs = [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    char *cStr = vc_hspctx->note_pval->pt;
    NSString *nStr =
    [NSString stringWithCString:cStr encoding:NSUTF8StringEncoding];
    __block NSString *nRet = @"";
    __block NSUInteger lineCount = 0;
    __block NSUInteger lineCount2 = 0;
    if (p2 == 0) {     //追加モード
        if (p1 == -1) {  //末尾に追加
            nRet = nStr;
            nRet = [nRet stringByAppendingString:@"\n"];
            nRet = [nRet stringByAppendingString:nPs];
        } else {
            [nStr enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                if (lineCount == p1) {
                    nRet = [nRet stringByAppendingString:nPs];
                    nRet = [nRet stringByAppendingString:@"\n"];
                }
                nRet = [nRet stringByAppendingString:line];
                nRet = [nRet stringByAppendingString:@"\n"];
                lineCount++;
            }];
        }
    } else {           //上書きモード
        if (p1 == -1) {  //末尾に追加
            [nStr enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                lineCount++;
            }];
            [nStr enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                if (lineCount - 1 == lineCount2) {
                    nRet = [nRet stringByAppendingString:nPs];
                    // stop = YES;
                } else {
                    nRet = [nRet stringByAppendingString:line];
                    nRet = [nRet stringByAppendingString:@"\n"];
                }
                lineCount2++;
            }];
        } else {
            [nStr enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                if (lineCount == p1) {
                    nRet = [nRet stringByAppendingString:nPs];
                    nRet = [nRet stringByAppendingString:@"\n"];
                } else {
                    nRet = [nRet stringByAppendingString:line];
                    nRet = [nRet stringByAppendingString:@"\n"];
                }
                lineCount++;
            }];
        }
    }
    char *ret = (char *)[nRet UTF8String];  // NSString -> char
    vc_hspctx->note_pval->pt = ret;  // noteselで指定されている変数に情報を書き込む
    vc_hspctx->note_pval->size = (int)strlen(ret) + 1;  //サイズを書き込む
}
- (void)cmdfunc_notedel {
    int p1 = [self code_getdi:0];
    char *cStr = vc_hspctx->note_pval->pt;
    NSString *nStr =
    [NSString stringWithCString:cStr encoding:NSUTF8StringEncoding];
    __block NSString *nRet = @"";
    __block NSUInteger lineCount = 0;
    [nStr enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (lineCount == p1) {
        } else {
            nRet = [nRet stringByAppendingString:line];
            nRet = [nRet stringByAppendingString:@"\n"];
        }
        lineCount++;
    }];
    char *ret = (char *)[nRet UTF8String];  // NSString -> char
    vc_hspctx->note_pval->pt = ret;  // noteselで指定されている変数に情報を書き込む
    vc_hspctx->note_pval->size = (int)strlen(ret) + 1;  //サイズを書き込む
}
- (void)cmdfunc_noteload {
    char *ps = [self code_gets];
    NSString *filename =
    [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    NSString *path;
    if (global.is_startax_in_resource) {  //リソース内にstart.axがある場合
        path = [NSBundle mainBundle].resourcePath;  //リソースディレクトリ
        path = [path stringByAppendingString:@"/"];
        path = [path stringByAppendingString:filename];
    } else if (![global.current_script_path
                 isEqual:@""]) {  //ソースコードのあるディレクトリ
        path = global.current_script_path;
    } else {  // hsptmp
        path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp"];
    }
    path = [path stringByAppendingString:@"/"];
    path = [path stringByAppendingString:filename];
    //ファイルを読み込む
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *str = [[NSString alloc]
                     initWithData:data
                     encoding:NSUTF8StringEncoding];  // NSData -> NSString
    char *ret = (char *)[str UTF8String];    // NSString -> char
    vc_hspctx->note_pval->pt = ret;  // noteselで指定されている変数に情報を書き込む
    vc_hspctx->note_pval->size = (int)strlen(ret) + 1;  //サイズを書き込む
}
- (void)cmdfunc_notesave {
    char *ps = [self code_gets];
    NSString *filename =
    [NSString stringWithCString:ps encoding:NSUTF8StringEncoding];
    NSString *path;
    if (![global.current_script_path
          isEqual:@""]) {  //ソースコードのあるディレクトリ
        path = global.current_script_path;
    } else {                     //ホームディレクトリ
        path = NSHomeDirectory();  //[NSHomeDirectory()
        //stringByAppendingString:@"/Documents/hsptmp"];
    }
    path = [path stringByAppendingString:@"/"];
    path = [path stringByAppendingString:filename];
    //
    char *cStr = vc_hspctx->note_pval->pt;
    NSString *nStr =
    [NSString stringWithCString:cStr encoding:NSUTF8StringEncoding];
    [nStr writeToFile:path
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:nil];
}
- (void)cmdfunc_randomize {
    int p2 = (int)time(0);  // Windows以外のランダムシード値
    int p1 = [self code_getdi:p2];
#ifdef HSPRANDMT
    mt.seed(p1);
#else
    srand(p1);
#endif
}
- (void)cmdfunc_noteunsel {
    vc_hspctx->note_aptr = vc_hspctx->notep_aptr;
    vc_hspctx->note_pval = vc_hspctx->notep_pval;
}
- (void)cmdfunc_noteget {
    PVal *pval;
    APTR aptr;
    char *p;
    [self note_update];
    aptr = [self code_getva:&pval];
    int p1 = [self code_getdi:0];
    p = [self GetLineDirect:p1];
    [self code_setva:pval aptr:aptr type:TYPE_STRING ptr:p];
    [self ResumeLineDirect];
}
- (void)cmdfunc_split {
    //	指定した文字列で分割された要素を代入する(fujidig)
    PVal *pval = NULL;
    int aptr = 0;
    char *sptr;
    char *sep;
    char *newsptr;
    int size;
    int sep_len;
    int n = 0;
    int is_last = 0;
    sptr = [self code_getvptr:&pval size:&size];
    if (pval->flag != HSPVAR_FLAG_STR) {
         @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    sep = [self code_gets];
    sep_len = (int)strlen(sep);
    while (1) {
        newsptr = [self strstr2:sptr src:sep];
        if (!is_last && *hsp3int_exinfo->npexflg & EXFLG_1) {
            // 分割結果の数が格納する変数より多ければ最後の変数に配列で格納していく
            // ただし最後の要素が a.2 のように要素指定があればそれ以降は全く格納しない
            if (aptr != 0) pval = NULL;
            is_last = 1;
            aptr = 0;
        }
        if (is_last) {
            aptr++;
            if (pval != NULL && aptr >= pval->len[1]) {
                if (pval->len[2] != 0) {
                     @throw [self make_nsexception:HSPVAR_ERROR_ARRAYOVER];
                }
                [self HspVarCoreReDim:pval lenid:1 len:aptr + 1];
            }
        } else {
            aptr = [self code_getva:&pval];
        }
        if (pval != NULL) {
            if (newsptr == NULL) {
                [self code_setva:pval aptr:aptr type:HSPVAR_FLAG_STR ptr:sptr];
            } else {
                [self var_set_str_len:pval
                                 aptr:aptr
                                  str:sptr
                                  len:(int)(newsptr - sptr)];
            }
        }
        n++;
        if (newsptr == NULL) {
            // 格納する変数の数が分割できた数より多ければ残った変数それぞれに空文字列を格納する
            while ((*hsp3int_exinfo->npexflg & EXFLG_1) == 0) {
                aptr = [self code_getva:&pval];
                [self code_setva:pval aptr:aptr type:HSPVAR_FLAG_STR ptr:""];
            }
            break;
        }
        sptr = newsptr + sep_len;
    }
    vc_hspctx->stat = n;
}
- (void)cmdfunc_strrep {
    PVal *pval;
    APTR aptr;
    char *ss;
    // char *s_rep;
    char *s_buffer;
    // char *s_result;
    aptr = [self code_getva:&pval];
    if (pval->flag != HSPVAR_FLAG_STR) {
         @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    s_buffer = (char *)[self HspVarCorePtrAPTR:pval ofs:aptr];
    ss = [self code_gets];
    if (*ss == 0) {
         @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
}
- (void)cmdfunc_setease {
    double dval;
    double dval2;
    dval = [self code_getd];
    dval2 = [self code_getd];
    int p1 = [self code_getdi:hsp3int_ease_type];
    [self setEase:p1 value_start:dval value_end:dval2];
}
- (void)cmdfunc_sortval {
    int a, i;
    PVal *p1;
    APTR ap;
    int order;
    ap = [self code_getva:&p1];   // パラメータ1:変数
    order = [self code_getdi:0];  // パラメータ2:数値
    i = p1->len[1];
    if (i <= 0) {
         @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    switch (p1->flag) {
        case HSPVAR_FLAG_DOUBLE: {
            double *dp;
            dp = (double *)p1->pt;
            [self DataIni:i];
            for (a = 0; a < i; a++) {
                hsp3int_data_temp[a].as.dkey = dp[a];
                hsp3int_data_temp[a].info = a;
            }
            if (order == 0) {
                //$
                // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_double_1);
            } else {
                //$
                // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_double_0);
            }
            for (a = 0; a < i; a++) {
                [self code_setva:p1
                            aptr:a
                            type:HSPVAR_FLAG_DOUBLE
                             ptr:&(hsp3int_data_temp[a].as.dkey)];  // 変数に値を代入
            }
            break;
        }
        case HSPVAR_FLAG_INT: {
            int *p;
            p = (int *)p1->pt;
            [self DataIni:i];
            for (a = 0; a < i; a++) {
                hsp3int_data_temp[a].as.ikey = p[a];
                hsp3int_data_temp[a].info = a;
            }
            if (order == 0) {
                //$
                // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_int_1);
            } else {
                //$
                // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_int_0);
            }
            for (a = 0; a < i; a++) {
                p[a] = hsp3int_data_temp[a].as.ikey;
            }
            break;
        }
        default: {
             @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
        }
    }
}
- (void)cmdfunc_sortstr {
    int i, len, order;
    char *p;
    PVal *pv;
    APTR ap;
    HspVarProc *proc;
    char **pvstr;
    ap = [self code_getva:&pv];   // パラメータ1:変数
    order = [self code_getdi:0];  // パラメータ2:数値
    if (pv->flag != 2) {
         @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    if ((pv->len[2] != 0) || (ap != 0)) {
         @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    proc = HspVarCoreGetProc(pv->flag);
    len = pv->len[1];
    [self DataIni:len];
    for (i = 0; i < len; i++) {
        p = (char *)[self HspVarCorePtrAPTR:pv ofs:i];
        hsp3int_data_temp[i].as.skey = p;
        hsp3int_data_temp[i].info = i;
    }
    if (order == 0) {
        //$
        // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_str_1);
    } else {
        //$
        // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_str_0);
    }
    pvstr = (char **)(pv->master);  // 変数に直接sbポインタを書き戻す
    for (i = 0; i < len; i++) {
        if (i == 0) {
            pv->pt = hsp3int_data_temp[i].as.skey;
            [self sbSetOption:pv->pt option:&pv->pt];
        } else {
            pvstr[i] = hsp3int_data_temp[i].as.skey;
            [self sbSetOption:pvstr[i] option:&pvstr[i]];
        }
    }
}
- (void)cmdfunc_sortnote {
    int i, sflag;
    char *p;
    char *stmp;
    PVal *pv;
    APTR ap;
    ap = [self code_getva:&pv];   // パラメータ1:変数
    sflag = [self code_getdi:0];  // パラメータ2:数値
    p = (char *)[self HspVarCorePtrAPTR:pv ofs:ap];
    i = [self GetNoteLines:p];
    if (i <= 0) {
         @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    [self DataIni:i];
    [self NoteToData:p data:hsp3int_data_temp];
    if (sflag == 0) {
        //$
        // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_str_1);
    } else {
        //$
        // std::sort(hsp3int_data_temp, hsp3int_data_temp + i, less_str_0);
    }
    stmp = [self code_stmp:(int)[self DataToNoteLen:hsp3int_data_temp num:i] + 1];
    [self DataToNote:hsp3int_data_temp adr:stmp num:i];
    [self code_setva:pv aptr:ap type:HSPVAR_FLAG_STR ptr:stmp];  // 変数に値を代入
}
- (void)cmdfunc_sortget {
    PVal *pv;
    APTR ap;
    int result;
    int n;
    ap = [self code_getva:&pv];
    n = [self code_getdi:0];
    if (hsp3int_data_temp == NULL) {
         @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    if (0 <= n && n < hsp3int_data_tmp_size) {
        result = hsp3int_data_temp[n].info;
    } else {
        result = 0;
    }
    [self code_setva:pv aptr:ap type:HSPVAR_FLAG_INT ptr:&result];
}
- (void *)reffunc_intfunc:(int *)type_res arg:(int)arg {
    //		reffunc : TYPE_INTFUNC
    //		(内蔵関数)
    //
    void *ptr;
    int chk;
    double dval;
    double dval2;
    int ival;
    char *sval;
    int p1, p2, p3;
    //			'('で始まるかを調べる
    //
    if (*hsp3int_type != TYPE_MARK) {
         @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    if (*hsp3int_val != '(') {
         @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    [self code_next];
    //		返値のタイプをargをもとに設定する
    //		0〜255   : int
    //		256〜383 : string
    //		384〜511 : double(double)
    //
    switch (arg >> 7) {
        case 2:                         // 返値がstr
            *type_res = HSPVAR_FLAG_STR;  // 返値のタイプを指定する
            ptr = NULL;                   // 返値のポインタ
            break;
        case 3:                            // 返値がdouble
            *type_res = HSPVAR_FLAG_DOUBLE;  // 返値のタイプを指定する
            ptr = &hsp3int_reffunc_intfunc_value;  // 返値のポインタ
            break;
        default:                        // 返値がint
            *type_res = HSPVAR_FLAG_INT;  // 返値のタイプを指定する
            ptr = &hsp3int_reffunc_intfunc_ivalue;  // 返値のポインタ
            break;
    }
    switch (arg) {
            //	int function
        case 0x000:  // int
        {
            int *ip;
            chk = [self code_get];
            if (chk <= PARAM_END) {
                 @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
            }
            ip = (int *)[self HspVarCoreCnvPtr:mpval flag:HSPVAR_FLAG_INT];
            hsp3int_reffunc_intfunc_ivalue = *ip;
            break;
        }
        case 0x001:  // rnd
            ival = [self code_geti];
            if (ival == 0) {
                 @throw [self make_nsexception:HSPERR_DIVIDED_BY_ZERO];
            }
#ifdef HSPRANDMT
        {
            std::uniform_int_distribution<int> dist(0, ival - 1);
            hsp3int_reffunc_intfunc_ivalue = dist(mt);
        }
#else
            hsp3int_reffunc_intfunc_ivalue = rand() % ival;
#endif
            break;
        case 0x002:  // strlen
            sval = [self code_gets];
            hsp3int_reffunc_intfunc_ivalue = (int)strlen(sval);
            break;
        case 0x003:  // length(3.0)
        case 0x004:  // length2(3.0)
        case 0x005:  // length3(3.0)
        case 0x006:  // length4(3.0)
        {
            PVal *pv;
            pv = [self code_getpval];
            hsp3int_reffunc_intfunc_ivalue = pv->len[arg - 0x002];
            break;
        }
        case 0x007:  // vartype(3.0)
        {
            PVal *pv;
            HspVarProc *proc;
            if (*hsp3int_type == TYPE_STRING) {
                sval = [self code_gets];
                proc = [self HspVarCoreSeekProc:sval];
                if (proc == NULL) {
                     @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
                }
                hsp3int_reffunc_intfunc_ivalue = proc->flag;
            } else {
                [self code_getva:&pv];
                hsp3int_reffunc_intfunc_ivalue = pv->flag;
            }
            break;
        }
        case 0x008:  // gettime
            ival = [self code_geti];
            hsp3int_reffunc_intfunc_ivalue = [self gettime:ival];
            break;
        case 0x009:  // peek
        case 0x00a:  // wpeek
        case 0x00b:  // lpeek
        {
            PVal *pval;
            char *ptr;
            int size;
            ptr = [self code_getvptr:&pval size:&size];
            p1 = [self code_getdi:0];
            if (p1 < 0) {
                 @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
            }
            ptr += p1;
            if (arg == 0x09) {
                if ((p1 + 1) > size) {
                     @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
                }
                hsp3int_reffunc_intfunc_ivalue = ((int)(*ptr)) & 0xff;
            } else if (arg == 0x0a) {
                if ((p1 + 2) > size) {
                     @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
                }
                hsp3int_reffunc_intfunc_ivalue = ((int)(*(short *)ptr)) & 0xffff;
            } else {
                if ((p1 + 4) > size) {
                     @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
                }
                hsp3int_reffunc_intfunc_ivalue = *(int *)ptr;
            }
            break;
        }
        case 0x00c:  // varptr
        {
            PVal *pval;
            APTR aptr;
            PDAT *pdat;
            STRUCTDAT *st;
            if (*hsp3int_type == TYPE_DLLFUNC) {
                st = &(vc_hspctx->mem_finfo[*hsp3int_val]);
                hsp3int_reffunc_intfunc_ivalue = (int)(size_t)(st->proc);
                [self code_next];
                break;
            }
            aptr = [self code_getva:&pval];
            pdat = [self HspVarCorePtrAPTR:pval ofs:aptr];
            hsp3int_reffunc_intfunc_ivalue = (int)(size_t)(pdat);
            break;
        }
        case 0x00d:  // varuse
        {
            PVal *pval;
            APTR aptr;
            PDAT *pdat;
            aptr = [self code_getva:&pval];
            if (pval->support & HSPVAR_SUPPORT_VARUSE) {
                pdat = [self HspVarCorePtrAPTR:pval ofs:aptr];
                // hsp3int_reffunc_intfunc_ivalue = HspVarCoreGetUsing( pval, pdat );
                if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") ==
                    0) {  //ラベルのAllocBlock
                    hsp3int_reffunc_intfunc_ivalue = [self HspVarLabel_GetUsing:pdat];
                } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") ==
                           0) {  // structのAllocBlock
                    hsp3int_reffunc_intfunc_ivalue = [self HspVarLabel_GetUsing:pdat];
                } else {
                     @throw [self make_nsexception:HSPERR_SYNTAX];
                }
            } else {
                 @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            break;
        }
        case 0x00e:  // noteinfo
            ival = [self code_getdi:0];
            [self note_update];
            switch (ival) {
                case 0:
                    hsp3int_reffunc_intfunc_ivalue = [self GetMaxLine];
                    break;
                case 1:
                    hsp3int_reffunc_intfunc_ivalue = [self GetSize];
                    break;
                default: {
                     @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
                }
            }
            break;
        case 0x00f:  // instr
        {
            PVal *pval;
            char *ptr;
            char *ps;
            char *ps2;
            int size;
            int p1;
            ptr = [self code_getvptr:&pval size:&size];
            if (pval->flag != HSPVAR_FLAG_STR) {
                 @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            p1 = [self code_getdi:0];
            if (p1 >= size) {
                 @throw [self make_nsexception:HSPERR_BUFFER_OVERFLOW];
            }
            ps = [self code_gets];
            if (p1 >= 0) {
                ptr += p1;
                ps2 = [self strstr2:ptr src:ps];
            } else {
                ps2 = NULL;
            }
            if (ps2 == NULL) {
                hsp3int_reffunc_intfunc_ivalue = -1;
            } else {
                hsp3int_reffunc_intfunc_ivalue = (int)(ps2 - ptr);
            }
            break;
        }
        case 0x010:  // abs
            hsp3int_reffunc_intfunc_ivalue = [self code_geti];
            if (hsp3int_reffunc_intfunc_ivalue < 0)
                hsp3int_reffunc_intfunc_ivalue = -hsp3int_reffunc_intfunc_ivalue;
            break;
        case 0x011:  // limit
            p1 = [self code_geti];
            p2 = [self code_geti];
            p3 = [self code_geti];
            hsp3int_reffunc_intfunc_ivalue = [self GetLimit:p1 min:p2 max:p3];
            break;
        case 0x012:  // getease
            p1 = [self code_geti];
            p2 = [self code_getdi:-1];
            hsp3int_reffunc_intfunc_ivalue = [self getEaseInt:p1 i_maxvalue:p2];
            break;
        case 0x013:  // notefind
        {
            char *ps;
            char *p;
            int findopt;
            ps = [self code_gets];
            p = [self code_stmpstr:ps];
            findopt = [self code_getdi:0];
            [self note_update];
            break;
        }
            //================================================================================>>>MacOSX
        case 0x020:  // qframe
        {
            if (qAudio->isInitialized != YES) {
                [qAudio start];
            }
            while (1) {
                if (global.in_number_frames == 0) {
                    usleep(1000);
                    continue;
                } else {
                    hsp3int_reffunc_intfunc_ivalue = global.in_number_frames;
                    break;
                }
            }
            break;
        }
        case 0x021:  // qcount
        {
            hsp3int_reffunc_intfunc_ivalue = (int)global.q_audio_buffer.count;
            break;
        }
        case 0x030:  // clock
        {
            hsp3int_reffunc_intfunc_ivalue = (int)clock();
            break;
        }
        case 0x031:  // isretina
        {
            if (global.backing_scale_factor > 1.0) {
                hsp3int_reffunc_intfunc_ivalue = 1;
            } else {
                hsp3int_reffunc_intfunc_ivalue = 0;
            }
            break;
        }
        case 0x40:  // getmousex
        {
            // printf("test");
            hsp3int_reffunc_intfunc_ivalue = [myView getMouseX];
            break;
        }
        case 0x41:  // getmousey
        {
            hsp3int_reffunc_intfunc_ivalue = [myView getMouseY];
            break;
        }
        case 0x42:  // getmousedown
        {
            if ([myView getIsMouseDown]) {  // YES
                hsp3int_reffunc_intfunc_ivalue = 1;
            } else {
                hsp3int_reffunc_intfunc_ivalue = 0;
            }
            break;
        }
        case 0x50:  // ginfo
        {
            p1 = [self code_geti];
            switch (p1) {
                case 0:
                    hsp3int_reffunc_intfunc_ivalue = [NSEvent mouseLocation].x;
                    break;
                case 1:
                    hsp3int_reffunc_intfunc_ivalue =
                    [NSScreen mainScreen].frame.size.height -
                    [NSEvent mouseLocation].y;
                    break;
                case 2:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ2は未実装です"];
                    break;
                case 3:
                    hsp3int_reffunc_intfunc_ivalue = myLayer->buf_index;
                    break;
                case 4:
                    hsp3int_reffunc_intfunc_ivalue = myWindow.frame.origin.x;
                    break;
                case 5:
                    hsp3int_reffunc_intfunc_ivalue =
                    [NSScreen mainScreen].frame.size.height -
                    myWindow.frame.origin.y - myWindow.frame.size.height;
                    break;
                case 6:
                    hsp3int_reffunc_intfunc_ivalue =
                    myWindow.frame.origin.x + myWindow.frame.size.width;
                    break;
                case 7:
                    hsp3int_reffunc_intfunc_ivalue =
                    [NSScreen mainScreen].frame.size.height - myWindow.frame.origin.y;
                    break;
                case 8:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ8は未実装です"];
                    break;
                case 9:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ9は未実装です"];
                    break;
                case 10:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ10は未実装です"];
                    break;
                case 11:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ11は未実装です"];
                    break;
                case 12:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ12は未実装です"];
                    break;
                case 13:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ13は未実装です"];
                    break;
                case 14:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ14は未実装です"];
                    break;
                case 15:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ15は未実装です"];
                    break;
                case 16:
                    hsp3int_reffunc_intfunc_ivalue = [myLayer get_current_color_r];
                    break;
                case 17:
                    hsp3int_reffunc_intfunc_ivalue = [myLayer get_current_color_g];
                    break;
                case 18:
                    hsp3int_reffunc_intfunc_ivalue = [myLayer get_current_color_b];
                    break;
                case 19:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ19は未実装です"];
                    break;
                case 20:
                    hsp3int_reffunc_intfunc_ivalue =
                    [NSScreen mainScreen].frame.size.width;
                    break;
                case 21:
                    hsp3int_reffunc_intfunc_ivalue =
                    [NSScreen mainScreen].frame.size.height;
                    break;
                case 22:
                    hsp3int_reffunc_intfunc_ivalue = [myLayer get_current_point_x];
                    break;
                case 23:
                    hsp3int_reffunc_intfunc_ivalue = [myLayer get_current_point_y];
                    break;
                case 24:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ24は未実装です"];
                    break;
                case 25:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ25は未実装です"];
                    break;
                case 26:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ26は未実装です"];
                    break;
                case 27:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ27は未実装です"];
                    break;
                case 256:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ256は未実装です"];
                    break;
                case 257:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ257は未実装です"];
                    break;
                case 258:
                    [self show_alert_dialog:@"ginfo関数の取得タイプ258は未実装です"];
                    break;
                default:
                    break;
            }
            break;
        }
            //================================================================================<<<MacOSX
            // str function
        case 0x100:  // str
        {
            char *sp;
            chk = [self code_get];
            if (chk <= PARAM_END) {
                 @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
            }
            sp = (char *)[self HspVarCoreCnvPtr:mpval flag:HSPVAR_FLAG_STR];
            ptr = (void *)sp;
            break;
        }
        case 0x101:  // strmid
        {
            PVal *pval;
            char *sptr;
            char *p;
            char chrtmp;
            int size;
            int i;
            int slen;
            sptr = [self code_getvptr:&pval size:&size];
            if (pval->flag != HSPVAR_FLAG_STR) {
                 @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            p1 = [self code_geti];
            p2 = [self code_geti];
            slen = (int)strlen(sptr);
            if (p1 < 0) {
                p1 = slen - p2;
                if (p1 < 0) p1 = 0;
            }
            if (p1 >= slen) p2 = 0;
            if (p2 > slen) p2 = slen;
            sptr += p1;
            ptr = p = [self code_stmp:p2 + 1];
            for (i = 0; i < p2; i++) {
                chrtmp = *sptr++;
                *p++ = chrtmp;
                if (chrtmp == 0) break;
            }
            *p = 0;
            break;
        }
        case 0x103:  // strf
            ptr = [self cnvformat];
            break;
        case 0x104:  // getpath
        {
            char *p;
            char pathname[HSP_MAX_PATH];
            p = vc_hspctx->stmp;
            strncpy(pathname, [self code_gets], HSP_MAX_PATH - 1);
            p1 = [self code_geti];
            [self getpath:pathname outbuf:p p2:p1];
            ptr = p;
            break;
        }
        case 0x105:  // strtrim
        {
            PVal *pval;
            char *sptr;
            char *p;
            int size;
            sptr = [self code_getvptr:&pval size:&size];
            if (pval->flag != HSPVAR_FLAG_STR) {
                 @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            p1 = [self code_getdi:0];
            p2 = [self code_getdi:32];
            ptr = p = [self code_stmp:size + 1];
            strcpy(p, sptr);
            switch (p1) {
                case 0:
                    [self TrimCodeL:p code:p2];
                    [self TrimCodeR:p code:p2];
                    break;
                case 1:
                    [self TrimCodeL:p code:p2];
                    break;
                case 2:
                    [self TrimCodeR:p code:p2];
                    break;
                case 3:
                    [self TrimCode:p code:p2];
                    break;
            }
            break;
        }
        case 0x106:  // getfontfamilies
        {
            NSString *fontfamilies = [[[NSFontManager sharedFontManager]
                                       availableFontFamilies] description];  //フォント一覧を取得する
            char *sp = (char *)[fontfamilies UTF8String];
            // chk = [self code_get];
            // if ( chk <= PARAM_END ) { throw HSPERR_INVALID_FUNCPARAM; }
            // sp = (char *)HspVarCoreCnvPtr( mpval, HSPVAR_FLAG_STR );
            ptr = sp;
            break;
        }
            //	double function
        case 0x180:  // sin
            dval = [self code_getd];
            hsp3int_reffunc_intfunc_value = sin(dval);
            break;
        case 0x181:  // cos
            dval = [self code_getd];
            hsp3int_reffunc_intfunc_value = cos(dval);
            break;
        case 0x182:  // tan
            dval = [self code_getd];
            hsp3int_reffunc_intfunc_value = tan(dval);
            break;
        case 0x183:  // atan
            dval = [self code_getd];
            dval2 = [self code_getdd:1.0];
            hsp3int_reffunc_intfunc_value = atan2(dval, dval2);
            break;
        case 0x184:  // sqrt
            dval = [self code_getd];
            hsp3int_reffunc_intfunc_value = sqrt(dval);
            break;
        case 0x185:  // double
        {
            double *dp;
            chk = [self code_get];
            if (chk <= PARAM_END) {
                 @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
            }
            dp = (double *)[self HspVarCoreCnvPtr:mpval flag:HSPVAR_FLAG_DOUBLE];
            hsp3int_reffunc_intfunc_value = *dp;
            break;
        }
        case 0x186:  // absf
            hsp3int_reffunc_intfunc_value = [self code_getd];
            if (hsp3int_reffunc_intfunc_value < 0)
                hsp3int_reffunc_intfunc_value = -hsp3int_reffunc_intfunc_value;
            break;
        case 0x187:  // expf
            dval = [self code_getd];
            hsp3int_reffunc_intfunc_value = exp(dval);
            break;
        case 0x188:  // logf
            dval = [self code_getd];
            hsp3int_reffunc_intfunc_value = log(dval);
            break;
        case 0x189:  // limitf
        {
            double d1, d2, d3;
            d1 = [self code_getd];
            d2 = [self code_getd];
            d3 = [self code_getd];
            if (d1 < d2) d1 = d2;
            if (d1 > d3) d1 = d3;
            hsp3int_reffunc_intfunc_value = d1;
            break;
        }
        case 0x18a:  // powf
            dval = [self code_getd];
            dval2 = [self code_getd];
            hsp3int_reffunc_intfunc_value = pow(dval, dval2);
            break;
        case 0x18b:  // geteasef
            dval = [self code_getd];
            dval2 = [self code_getdd:1.0];
            if (dval2 == 1.0) {
                hsp3int_reffunc_intfunc_value = [self getEase:dval];
            } else {
                hsp3int_reffunc_intfunc_value = [self getEase:dval maxvalue:dval2];
            }
            break;
            //================================================================================>>>MacOSX
        case 0x190:  // qrate
        {
            if (qAudio->isInitialized != YES) {
                [qAudio start];
            }
            while (1) {
                if ((int)qAudio->outSampleRate == 0) {
                    usleep(1000);
                    continue;
                } else {
                    hsp3int_reffunc_intfunc_value = (double)qAudio->outSampleRate;
                    break;
                }
            }
            break;
        }
        case 0x191:  // qpi
        {
            hsp3int_reffunc_intfunc_value = 3.14159265358979323846;
            break;
        }
        case 0x1a0:  // rndf
        {
            dval2 = [self code_getd];
            hsp3int_reffunc_intfunc_value =
            ((dval2 - 0.0) * ((float)arc4random() / 0x100000000)) + 0.0;
            break;
        }
        case 0x1a1:  // randf
        {
            dval = [self code_getd];
            dval2 = [self code_getd];
            hsp3int_reffunc_intfunc_value =
            ((dval2 - dval) * ((float)arc4random() / 0x100000000)) + dval;
            break;
        }
        case 0x1a2:  // getretina
        {
            hsp3int_reffunc_intfunc_value = global.backing_scale_factor;
            break;
        }
            //================================================================================<<<MacOSX
        default: {
             @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    //			')'で終わるかを調べる
    //
    if (*hsp3int_type != TYPE_MARK) {
         @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    if (*hsp3int_val != ')') {
         @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    [self code_next];
    return ptr;
}
/*------------------------------------------------------------*/
/*
 controller
 */
/*------------------------------------------------------------*/
- (int)termfunc_intcmd:(int)option {
    //		termfunc : TYPE_INTCMD
    //		(内蔵)
    //
    return 0;
}
- (void)hsp3typeinit_intcmd:(HSP3TYPEINFO *)info {
    hsp3int_ctx = info->hspctx;
    hsp3int_exinfo = info->hspexinfo;
    hsp3int_type = hsp3int_exinfo->nptype;
    hsp3int_val = hsp3int_exinfo->npval;
    [self initEase];
    // info->cmdfunc = cmdfunc_intcmd;
    info->cmdfuncNumber = 8;  //内臓コマンド memo.md
    // info->termfunc = termfunc_intcmd;
}
- (void)hsp3typeinit_intfunc:(HSP3TYPEINFO *)info {
    info->reffuncNumber = 5;  // reffunc_intfunc;
}
//================================================================================>>>CStrNote
//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------
- (void)Select:(char *)str {
    hsp3int_base = str;
}
- (int)GetSize {
    return (int)strlen(hsp3int_base);
}
- (char *)GetStr {
    return (char *)"";
}
//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------
- (int)nnget:(char *)nbase line:(int)line {
    //	指定した行の先頭ポインタを求める
    //		hsp3int_nn = 先頭ポインタ
    //		hsp3int_lastcr : CR/LFで終了している
    //		line   : line number(-1=最終行)
    //		result:0=ok/1=no line
    //
    int a, i;
    char a1;
    a = 0;
    hsp3int_lastcr = 0;
    hsp3int_nn = nbase;
    if (line < 0) {
        i = (int)strlen(nbase);
        if (i == 0) {
            return 0;
        }
        hsp3int_nn += i;
        a1 = *(hsp3int_nn - 1);
        if ((a1 == 10) || (a1 == 13)) hsp3int_lastcr++;
        return 0;
    }
    if (line) {
        while (1) {
            a1 = *hsp3int_nn;
            if (a1 == 0) {
                return 1;
            }
            hsp3int_nn++;
            //#ifdef MATCH_LF
            if (a1 == 10) {
                a++;
                if (a == line) break;
            }
            //#endif
            if (a1 == 13) {
                if (*hsp3int_nn == 10) hsp3int_nn++;
                a++;
                if (a == line) break;
            }
        }
    }
    hsp3int_lastcr++;
    return 0;
}
- (int)GetLine:(char *)nres line:(int)line {
    //		Get specified line from note
    //				result:0=ok/1=no line
    //
    char a1;
    char *pp;
    pp = nres;
    if ([self nnget:hsp3int_base line:line]) {
        return 1;
    }
    if (*hsp3int_nn == 0) return 1;
    while (1) {
        a1 = *hsp3int_nn++;
        if ((a1 == 0) || (a1 == 13)) break;
        //#ifdef MATCH_LF
        if (a1 == 10) break;
        //#endif
        *pp++ = a1;
    }
    *pp = 0;
    return 0;
}
- (int)GetLine:(char *)nres line:(int)line max:(int)max {
    //		Get specified line from note
    //				result:0=ok/1=no line
    //
    char a1;
    char *pp;
    int cnt;
    pp = nres;
    cnt = 0;
    if ([self nnget:hsp3int_base line:line]) {
        return 1;
    }
    if (*hsp3int_nn == 0) {
        return 1;
    }
    while (1) {
        if (cnt >= max) break;
        a1 = *hsp3int_nn++;
        if ((a1 == 0) || (a1 == 13)) break;
        //#ifdef MATCH_LF
        if (a1 == 10) break;
        //#endif
        *pp++ = a1;
        cnt++;
    }
    *pp = 0;
    return 0;
}
- (char *)GetLineDirect:(int)line {
    //		Get specified line from note
    //
    char a1;
    if ([self nnget:hsp3int_base line:line]) hsp3int_nn = hsp3int_nulltmp;
    hsp3int_lastnn = hsp3int_nn;
    while (1) {
        a1 = *hsp3int_lastnn;
        if ((a1 == 0) || (a1 == 13)) break;
        //#ifdef MATCH_LF
        if (a1 == 10) break;
        //#endif
        hsp3int_lastnn++;
    }
    hsp3int_lastcode = a1;
    *hsp3int_lastnn = 0;
    return hsp3int_nn;
}
- (void)ResumeLineDirect {
    //		Resume last GetLineDirect function
    //
    *hsp3int_lastnn = hsp3int_lastcode;
}
- (int)GetMaxLine {
    //		Get total lines
    //
    int a, b;
    char a1;
    a = 1;
    b = 0;
    hsp3int_nn = hsp3int_base;
    while (1) {
        a1 = *hsp3int_nn++;
        if (a1 == 0) {
            break;
        }
        //#ifdef MATCH_LF
        if ((a1 == 13) || (a1 == 10)) {
            if ((a1 == 13) && (*hsp3int_nn == 10)) {  // if (a1=13&&*hsp3int_nn==10) {
                hsp3int_nn++;
            }
            //#else
            if (a1 == 13) {
                if (*hsp3int_nn == 10) {
                    //                    hsp3int_nn++;
                }
                //#endif
                a++;
                b = 0;
            } else {
                b++;
            }
        }
        if (b == 0) {
            a--;
        }
        return a;
    }
    return 0;
}
- (int)PutLine:(char *)nstr line:(int)line ovr:(int)ovr {
    //		Pet specified line to note
    //				result:0=ok/1=no line
    //
    int a = 0, ln, la, lw;
    char a1;
    char *pp;
    char *p1;
    char *p2;
    char *nstr2 = NULL;
    if ([self nnget:hsp3int_base line:line]) {
        return 1;
    }
    if (hsp3int_lastcr == 0) {
        if (hsp3int_nn != hsp3int_base) {
            strcat(hsp3int_base, CRSTR);
            hsp3int_nn += 2;
        }
    }
    nstr = nstr2;
    if (nstr == NULL) {
        nstr = (char *)"";
    }
    pp = nstr;
    if (nstr2 != NULL) strcat(nstr, CRSTR);
    ln = (int)strlen(nstr);  // hsp3int_base new str + cr/lf
    la = (int)strlen(hsp3int_base);
    lw = la - (int)(hsp3int_nn - hsp3int_base) + 1;
    //
    if (ovr) {  // when overwrite mode
        p1 = hsp3int_nn;
        a = 0;
        while (1) {
            a1 = *p1++;
            if (a1 == 0) break;
            a++;
            //#ifdef MATCH_LF
            if ((a1 == 13) || (a1 == 10)) {
                if ((a1 == 13) && (*p1 == 10)) {
                    p1++;
                    a++;
                }
                //#else
                if (a1 == 13) {
                    if (*p1 == 10) {
                        //                            p1++;
                        //                            a++;
                    }
                    //#endif
                    break;
                }
            }
            ln = ln - a;
            lw = lw - a;
            if (lw < 1) lw = 1;
        }
        //
        if (ln >= 0) {
            p1 = hsp3int_base + la + ln;
            p2 = hsp3int_base + la;
            for (a = 0; a < lw; a++) {
                *p1-- = *p2--;
            }
        } else {
            p1 = hsp3int_nn + a + ln;
            p2 = hsp3int_nn + a;
            for (a = 0; a < lw; a++) {
                *p1++ = *p2++;
            }
        }
        //
        while (1) {
            a1 = *pp++;
            if (a1 == 0) break;
            *hsp3int_nn++ = a1;
        }
        return 0;
    }
    return 0;
}
- (int)FindLine:(char *)nstr mode:(int)mode {
    //		Search string from note
    //				nstr:search string
    //				mode:STRNOTE_FIND_*
    //				result:line number(-1:no match)
    //
    char a1;
    int curline, len, res;
    hsp3int_nn = hsp3int_base;
    curline = 0;
    len = 0;
    hsp3int_baseline = hsp3int_nn;  // 行の先頭ポインタ
    while (1) {
        a1 = *hsp3int_nn;
        if (a1 == 0) break;
        //#ifdef MATCH_LF
        if (a1 == 10) {
            if (len) {
                hsp3int_lastcode = a1;
                *hsp3int_nn = 0;
                res = [self FindLineSub:nstr mode:mode];
                *hsp3int_nn = hsp3int_lastcode;
                if (res) {
                    return curline;
                }
            }
            hsp3int_nn++;
            curline++;
            len = 0;
            hsp3int_baseline = hsp3int_nn;
            continue;
        }
        //#endif
        if (a1 == 13) {
            if (len) {
                hsp3int_lastcode = a1;
                *hsp3int_nn = 0;
                res = [self FindLineSub:nstr mode:mode];
                *hsp3int_nn = hsp3int_lastcode;
                if (res) {
                    return curline;
                }
            }
            hsp3int_nn++;
            curline++;
            len = 0;
            if (*hsp3int_nn == 10) hsp3int_nn++;  // LFをスキップ
            hsp3int_baseline = hsp3int_nn;
            continue;
        }
        hsp3int_nn++;
        len++;
    }
    //	最終行に文字列があればサーチ
    if (len) {
        if ([self FindLineSub:nstr mode:mode]) {
            return curline;
        }
    }
    return -1;
}
- (int)FindLineSub:(char *)nstr mode:(int)mode {
    //		全体サーチ用文字列比較
    //		mode : STRNOTE_FIND_MATCH = 完全一致
    //		       STRNOTE_FIND_FIRST = 前方一致
    //		       STRNOTE_FIND_INSTR = 部分一致
    //
    switch (mode) {
        case STRNOTE_FIND_MATCH:  // 完全一致
            if (strcmp(hsp3int_baseline, nstr) == 0) {
                return 1;
            }
            break;
        case STRNOTE_FIND_FIRST:  // 前方一致
        {
            char *p = [self strstr2:hsp3int_baseline src:nstr];
            if (p != NULL) {
                if (p == hsp3int_baseline) {
                    return 1;
                }
            }
            break;
        }
        case STRNOTE_FIND_INSTR:  // 部分一致
            if ([self strstr2:hsp3int_baseline src:nstr] != NULL) {
                return 1;
            }
            break;
        default:
            break;
    }
    return 0;
}
//================================================================================<<<CStrNote
@end
