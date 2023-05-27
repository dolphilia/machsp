
//
// トークン解析
//

#include "hsp3config.h"
#include "label.h"
#include "membuf.h"
#include "token.h"
#import "AppDelegate.h"
#import "c_wrapper.h"

#define s3size 0x8000

//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------

/// メッセージ登録
///
void CToken::Mes(char *mes) {
    errbuf->PutStr(mes);
    errbuf->PutStr((char *) "\r\n");
}

/// メッセージ登録
/// 
/// フォーマット付き
///
void CToken::Mesf(char *format, ...) {
    char txtbuf[1024];
    va_list args;
    va_start(args, format);
    vsprintf(txtbuf, format, args);
    va_end(args);
    errbuf->PutStr(txtbuf);
    errbuf->PutStr((char *) "\r\n");
}

/// エラーメッセージ登録
///
void CToken::Error(char *mes) {
    char tmp[256];
    sprintf(tmp, "#Error:%s\r\n", mes);
    errbuf->PutStr(tmp);
}

/// エラーメッセージ登録(line/filename)
///
void CToken::LineError(char *mes, int line, char *fname) {
    char tmp[256];
    sprintf(tmp, "#Error:%s in line %d [%s]\r\n", mes, line, fname);
    errbuf->PutStr(tmp);
}

/// エラーメッセージバッファ登録
///
void CToken::SetErrorBuf(CMemBuf *buf) {
    errbuf = buf;
}

/// packfile出力バッファ登録
///
void CToken::SetPackfileOut(CMemBuf *pack) {
    packbuf = pack;
    packbuf->PutStr((char *) ";\r\n;\tsource generated packfile\r\n;\r\n");
}

/// エラーメッセージ仮登録
///
void CToken::SetError(char *mes) {
    strcpy(errtmp, mes);
}

/// packfile出力
///
/// mode: 0=name/1=+name/2=other
///
int CToken::AddPackfile(char *name, int mode) {
    //CStrNote note;
    int max;
    char packadd[1024];
    char tmp[1024];
    char *s;

    strcpy(packadd, name);
    strcase(packadd);
    if (mode < 2) {
        [cwrap Select:packbuf->GetBuffer()];
        max = [cwrap GetMaxLine];
        //note.Select(packbuf->GetBuffer());
        //max = note.GetMaxLine();
        for (int i = 0; i < max; i++) {
            [cwrap GetLine:tmp line:i];
            //note.GetLine(tmp, i);
            s = tmp;
            if (*s == '+')
                s++;
            if (tstrcmp(s, packadd))
                return -1;
        }
        if (mode == 1)
            packbuf->PutStr((char *) "+");
    }
    packbuf->PutStr(packadd);
    packbuf->PutStr((char *) "\r\n");
    return 0;
}

//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------

CToken::CToken(void) {
    s3 = (unsigned char *) malloc(s3size);
    lb = new CLabel;
    tmp_lb = NULL;
    hed_cmpmode = CMPMODE_OPTCODE | CMPMODE_OPTPRM | CMPMODE_SKIPJPSPC;
    //tstack = new CTagStack;
    [cwrap stack_init];
    errbuf = NULL;
    packbuf = NULL;
    ahtmodel = NULL;
    ahtbuf = NULL;
    scnvbuf = NULL;

    undefined_symbols = (undefined_symbol_t *) [cwrap vector_create];

    ResetCompiler();
}

CToken::CToken(char *buf) {
    s3 = (unsigned char *) malloc(s3size);
    lb = new CLabel;
    tmp_lb = NULL;
    hed_cmpmode = CMPMODE_OPTCODE | CMPMODE_OPTPRM | CMPMODE_SKIPJPSPC;
    //tstack = new CTagStack;
    [cwrap stack_init];
    errbuf = NULL;
    packbuf = NULL;
    ahtmodel = NULL;
    ahtbuf = NULL;
    scnvbuf = NULL;

    undefined_symbols = (undefined_symbol_t *) [cwrap vector_create];

    ResetCompiler();
}

CToken::~CToken(void) {
    if (scnvbuf != NULL)
        InitSCNV(-1);
    if (tstack != NULL) {
        delete tstack;
        tstack = NULL;
    }
    if (lb != NULL) {
        delete lb;
        lb = NULL;
    }
    if (s3 != NULL) {
        free(s3);
        s3 = NULL;
    }
}

/// ラベル情報取り出し
///
/// CLabel *を取得したらそちらで、deleteすること
///
CLabel *CToken::GetLabelInfo(void) {
    CLabel *res;
    res = lb;
    lb = NULL;
    return res;
}

/// ラベル情報設定
///
void CToken::SetLabelInfo(CLabel *lbinfo) {
    tmp_lb = lbinfo;
}

void CToken::ResetCompiler(void) {
    //	buffer = buf;
    //	wp = (unsigned char *)buf;
    line = 1;
    fpbit = 256.0;
    incinf = 0;
    swsp = 0;
    swmode = 0;
    swlevel = 0;
    SetModuleName((char *) "");
    modgc = 0;
    search_path[0] = 0;
    lb->Reset();
    fileadd = 0;

    //		reset header info
    hed_option = 0;
    hed_runtime[0] = 0;
    hed_autoopt_timer = 0;
    pp_utf8 = 0;
}

void CToken::SetAHT(AHTMODEL *aht) {
    ahtmodel = aht;
}

void CToken::SetAHTBuffer(CMemBuf *aht) {
    ahtbuf = aht;
}

void CToken::SetLook(char *buf) {
    wp = (unsigned char *) buf;
}

char *CToken::GetLook(void) {
    return (char *) wp;
}

char *CToken::GetLookResult(void) {
    return (char *) s2;
}

int CToken::GetLookResultInt(void) {
    return val;
}

/// Strings pick sub
///
void CToken::Pickstr(void) {
    int a = 0;
    unsigned char cur_char;
    while (1) {
        pickag:
        cur_char = (unsigned char) *wp;
        if (cur_char >= 0x81) {
            if (cur_char < 0xa0) { // s-jis code
                s3[a++] = cur_char;
                wp++;
                s3[a++] = *wp;
                wp++;
                continue;
            } else if (cur_char >= 0xe0) { // s-jis code2
                s3[a++] = cur_char;
                wp++;
                s3[a++] = *wp;
                wp++;
                continue;
            }
        }

        if (cur_char == 0x5c) { // '\' extra control
            wp++;
            cur_char = tolower(*wp);
            switch (cur_char) {
                case 'n':
                    s3[a++] = 13;
                    cur_char = 10;
                    break;
                case 't':
                    cur_char = 9;
                    break;
                case 'r':
                    s3[a++] = 13;
                    wp++;
                    goto pickag;
                case 0x22:
                    s3[a++] = cur_char;
                    wp++;
                    goto pickag;
            }
        }
        if (cur_char == 0) {
            wp = NULL;
            break;
        }
        if (cur_char == 10) {
            wp++;
            line++;
            break;
        }
        if (cur_char == 13) {
            wp++;
            if (*wp == 10)
                wp++;
            line++;
            break;
        }
        if (cur_char == 0x22) {
            wp++;
            if (*wp == 0)
                wp = NULL;
            break;
        }
        s3[a++] = cur_char;
        wp++;
    }
    s3[a] = 0;
}

/// Strings pick sub '〜'
///
char *CToken::Pickstr2(char *str) {
    unsigned char *ptr = (unsigned char *) str;
    unsigned char *pp = s3;
    unsigned char cur_char;

    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char == 0x27) {
            ptr++;
            break;
        }
        if (cur_char == 0x5c) { // '\'チェック
            ptr++;
            cur_char = tolower(*ptr);
            if (cur_char < 32)
                continue;
            switch (cur_char) {
                case 'n':
                    *pp++ = 13;
                    cur_char = 10;
                    break;
                case 't':
                    cur_char = 9;
                    break;
                case 'r':
                    cur_char = 13;
                    break;
            }
        }
        int skip = SkipMultiByte(cur_char);
        if (skip) { // 全角文字チェック
            for (int i = 0; i < skip; i++) {
                *pp++ = cur_char;
                ptr++;
                cur_char = *ptr;
            }
        }
        ptr++;
        *pp++ = cur_char;
    }
    *pp = 0;
    return (char *) ptr;
}

int CToken::CheckModuleName(char *name) {
    unsigned char *ptr = (unsigned char *) name;
    unsigned char cur_char;

    while (1) { // normal object name
        cur_char = *ptr;
        if (cur_char == 0)
            return 0;
        if (cur_char < 0x30)
            break;
        if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
            break;
        if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
            break;
        if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
            break;
        ptr++;
        ptr += SkipMultiByte(cur_char); // 全角文字チェック
    }
    return -1;
}

/// get new word from wp ( result:s3 )
///
/// result : word type
///
int CToken::GetToken(void) {
    int rval = TK_OBJ;
    int a = 0;
    int b;
    int minmode = 0;
    unsigned char cur_char;
    int fpflag;
    int *fpival;
    unsigned char *wp_bak = nullptr;
    int ft_bak;

    if (wp == NULL)
        return TK_NONE;

    while (1) {
        cur_char = *wp;
        if ((cur_char != 32) && (cur_char != 9)) // Skip Space & Tab
            break;
        wp++;
    }

    if (cur_char == 0) { // End of Source
        wp = NULL;
        return TK_NONE;
    }
    if (cur_char == 13) { // Line Break
        wp++;
        if (*wp == 10)
            wp++;
        line++;
        return TK_NONE;
    }
    if (cur_char == 10) { // Unix Line Break
        wp++;
        line++;
        return TK_NONE;
    }

    //	Check Extra Character
    if (cur_char < 0x30)
        rval = TK_NONE;
    if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
        rval = TK_NONE;
    if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
        rval = TK_NONE;
    if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
        rval = TK_NONE;

    if (cur_char == ':' || cur_char == '{' || cur_char == '}') { // multi statement
        wp++;
        return TK_SEPARATE;
    }

    if (cur_char == '0') {
        unsigned char next_char = wp[1];
        if (next_char == 'x') { // when hex code (0x)
            wp++;
            cur_char = '$';
        }
        if (next_char == 'b') { // when bin code (0b)
            wp++;
            cur_char = '%';
        }
    }
    if (cur_char == '$') { // when hex code ($)
        wp++;
        val = 0;
        while (1) {
            cur_char = toupper(*wp);
            b = -1;
            if (cur_char == 0) {
                wp = NULL;
                break;
            }
            if ((cur_char >= 0x30) && (cur_char <= 0x39))
                b = cur_char - 0x30;
            if ((cur_char >= 0x41) && (cur_char <= 0x46))
                b = cur_char - 55;
            if (cur_char == '_')
                b = -2;
            if (b == -1)
                break;
            if (b >= 0) {
                s3[a++] = cur_char;
                val = (val << 4) + b;
            }
            wp++;
        }
        s3[a] = 0;
        return TK_NUM;
    }

    if (cur_char == '%') { // when bin code (%)
        wp++;
        val = 0;
        while (1) {
            cur_char = *wp;
            b = -1;
            if (cur_char == 0) {
                wp = NULL;
                break;
            }
            if ((cur_char >= 0x30) && (cur_char <= 0x31))
                b = cur_char - 0x30;
            if (cur_char == '_')
                b = -2;
            if (b == -1)
                break;
            if (b >= 0) {
                s3[a++] = cur_char;
                val = (val << 1) + b;
            }
            wp++;
        }
        s3[a] = 0;
        return TK_NUM;
    }

    if ((cur_char >= 0x30) && (cur_char <= 0x39)) { // when 0-9 numerical
        fpflag = 0;
        ft_bak = 0;
        while (1) {
            cur_char = *wp;
            if (cur_char == 0) {
                wp = NULL;
                break;
            }
            if (cur_char == '.') {
                if (fpflag) {
                    break;
                }
                unsigned char next_char = *(wp + 1);
                if ((next_char < 0x30) || (next_char > 0x39))
                    break;
                wp_bak = wp;
                ft_bak = a;
                fpflag = 3;
                //fpflag = -1;
                s3[a++] = cur_char;
                wp++;
                continue;
            }
            if ((cur_char < 0x30) || (cur_char > 0x39))
                break;
            s3[a++] = cur_char;
            wp++;
        }
        s3[a] = 0;
        if (wp != NULL) {
            if (*wp == 'k') {
                fpflag = 1;
                wp++;
            }
            if (*wp == 'f') {
                fpflag = 2;
                wp++;
            }
            if (*wp == 'd') {
                fpflag = 3;
                wp++;
            }
            if (*wp == 'e') {
                fpflag = 4;
                wp++;
            }
        }

        if (fpflag < 0) {                // 小数値でない時は「.」までで終わり
            s3[ft_bak] = 0;
            wp = wp_bak;
            fpflag = 0;
        }

        switch (fpflag) {
            case 0: // 通常の整数
                val = atoi_allow_overflow((char *) s3);
                if (minmode)
                    val = -val;
                break;
            case 1: // int固定小数
                val_d = atof((char *) s3);
                val = (int) (val_d * fpbit);
                if (minmode)
                    val = -val;
                break;
            case 2: // int形式のfloat値を返す
                val_f = (float) atof((char *) s3);
                if (minmode)
                    val_f = -val_f;
                fpival = (int *) &val_f;
                val = *fpival;
                break;
            case 4: // double値(指数表記)
                s3[a++] = 'e';
                cur_char = *wp;
                if ((cur_char == '-') || (cur_char == '+')) {
                    s3[a++] = cur_char;
                    wp++;
                }
                while (1) {
                    cur_char = *wp;
                    if ((cur_char < 0x30) || (cur_char > 0x39))
                        break;
                    s3[a++] = cur_char;
                    wp++;
                }
                s3[a] = 0;
            case 3: // double値
                val_d = atof((char *) s3);
                if (minmode)
                    val_d = -val_d;
                return TK_DNUM;
        }
        return TK_NUM;
    }

    if (cur_char == 0x22) { // when "string"
        wp++;
        Pickstr();
        return TK_STRING;
    }

    if (cur_char == 0x27) { // when 'char'
        wp++;
        wp = (unsigned char *) Pickstr2((char *) wp);
        val = *(unsigned char *) s3;
        return TK_NUM;
    }

    if (rval == TK_NONE) { // token code
        wp++;
        unsigned char next_char = *wp;
        if (cur_char == '!') { // !=
            if (next_char == '=')
                wp++;
        } else if (cur_char == '=') { // ==
            if (next_char == '=') {
                wp++;
            }
        } else if (cur_char == '|') { // ||
            if (next_char == '|') {
                wp++;
            }
        } else if (cur_char == '&') { // &&
            if (next_char == '&') {
                wp++;
            }
        }
        s3[0] = cur_char;
        s3[1] = 0;
        return cur_char;
    }

    while (1) {                                // normal object name
        cur_char = *wp;
        if (cur_char == 0) {
            wp = NULL;
            break;
        }
        if (cur_char < 0x30)
            break;
        if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
            break;
        if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
            break;
        if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
            break;
        if (a >= OBJNAME_MAX)
            break;
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < skip; i++) {
                s3[a++] = cur_char;
                wp++;
                cur_char = *wp;
            }
        }
        s3[a++] = cur_char;
        wp++;
    }
    s3[a] = 0;
    return TK_OBJ;
}

/// 戻すのは wp のみ。
///
/// s3, val, val_f, val_d などは戻されない
///
int CToken::PeekToken(void) {
    unsigned char *wp_bak = wp;
    int result = GetToken();
    wp = wp_bak;
    return result;
}

//-----------------------------------------------------------------------------

void CToken::Calc_token(void) {
    lasttoken = (char *) wp;
    ttype = GetToken();
}

void CToken::Calc_factor(CALCVAR &v) {
    CALCVAR v1;
    int id, type;
    char *ptr_dval;
    if (ttype == TK_NUM) {
        v = (CALCVAR) val;
        Calc_token();
        return;
    }
    if (ttype == TK_DNUM) {
        v = (CALCVAR) val_d;
        Calc_token();
        return;
    }
    if (ttype == TK_OBJ) {
        id = lb->Search((char *) s3);
        if (id == -1) {
            ttype = TK_CALCERROR;
            return;
        }
        type = lb->GetType(id);
        if (type != LAB_TYPE_PPVAL) {
            ttype = TK_CALCERROR;
            return;
        }
        ptr_dval = lb->GetData2(id);
        if (ptr_dval == NULL) {
            v = (CALCVAR) lb->GetOpt(id);
        } else {
            v = *(CALCVAR *) ptr_dval;
        }
        Calc_token();
        return;
    }
    if (ttype != '(') {
        ttype = TK_ERROR;
        return;
    }
    Calc_token();
    Calc_start(v1);
    if (ttype != ')') {
        ttype = TK_CALCERROR;
        return;
    }
    Calc_token();
    v = v1;
}

void CToken::Calc_unary(CALCVAR &v) {
    CALCVAR v1;
    int op;
    if (ttype == '-') {
        op = ttype;
        Calc_token();
        Calc_unary(v1);
        v1 = -v1;
    } else {
        Calc_factor(v1);
    }
    v = v1;
}

void CToken::Calc_muldiv(CALCVAR &v) {
    CALCVAR v1, v2;
    int op;
    Calc_unary(v1);
    while ((ttype == '*') || (ttype == '/') || (ttype == 0x5c)) {
        op = ttype;
        Calc_token();
        Calc_unary(v2);
        if (op == '*')
            v1 *= v2;
        else if (op == '/') {
            if ((int) v2 == 0) {
                ttype = TK_CALCERROR;
                return;
            }
            v1 /= v2;
        } else if (op == 0x5c) {
            if ((int) v2 == 0) {
                ttype = TK_CALCERROR;
                return;
            }
            v1 = fmod(v1, v2);
        }
    }
    v = v1;
}

void CToken::Calc_addsub(CALCVAR &v) {
    CALCVAR v1, v2;
    int op;
    Calc_muldiv(v1);
    while ((ttype == '+') || (ttype == '-')) {
        op = ttype;
        Calc_token();
        Calc_muldiv(v2);
        if (op == '+')
            v1 += v2;
        else if (op == '-')
            v1 -= v2;
    }
    v = v1;
}

void CToken::Calc_compare(CALCVAR &v) {
    CALCVAR v1, v2;
    int v1i = 0, v2i, op;
    Calc_addsub(v1);
    while ((ttype == '<') || (ttype == '>') || (ttype == '=')) {
        op = ttype;
        Calc_token();
        if (op == '=') {
            Calc_addsub(v2);
            v1i = v1 == v2;
            v1 = (CALCVAR) v1i;
            continue;
        }
        if (op == '<') {
            if (ttype == '=') {
                Calc_token();
                Calc_addsub(v2);
                v1i = (v1 <= v2);
                v1 = (CALCVAR) v1i;
                continue;
            }
            if (ttype == '<') {
                Calc_token();
                Calc_addsub(v2);
                v1i = (int) v1;
                v2i = (int) v2;
                v1i <<= v2i;
                v1 = (CALCVAR) v1i;
                continue;
            }
            Calc_addsub(v2);
            v1i = (v1 < v2);
            v1 = (CALCVAR) v1i;
            continue;
        }
        if (op == '>') {
            if (ttype == '=') {
                Calc_token();
                Calc_addsub(v2);
                v1i = (v1 >= v2);
                v1 = (CALCVAR) v1i;
                continue;
            }
            if (ttype == '>') {
                Calc_token();
                Calc_addsub(v2);
                v1i = (int) v1;
                v2i = (int) v2;
                v1i >>= v2i;
                v1 = (CALCVAR) v1i;
                continue;
            }
            Calc_addsub(v2);
            v1i = (v1 > v2);
            v1 = (CALCVAR) v1i;
            continue;
        }
        v1 = (CALCVAR) v1i;
    }
    v = v1;
}

void CToken::Calc_bool2(CALCVAR &v) {
    CALCVAR v1, v2;
    int v1i, v2i;
    Calc_compare(v1);
    while (ttype == '!') {
        Calc_token();
        Calc_compare(v2);
        v1i = (int) v1;
        v2i = (int) v2;
        v1i = v1i != v2i;
        v1 = (CALCVAR) v1i;
    }
    v = v1;
}

void CToken::Calc_bool(CALCVAR &v) {
    CALCVAR v1, v2;
    int op, v1i, v2i;
    Calc_bool2(v1);
    while ((ttype == '&') || (ttype == '|') || (ttype == '^')) {
        op = ttype;
        Calc_token();
        Calc_bool2(v2);
        v1i = (int) v1;
        v2i = (int) v2;
        if (op == '&')
            v1i &= v2i;
        else if (op == '|')
            v1i |= v2i;
        else if (op == '^')
            v1i ^= v2i;
        v1 = (CALCVAR) v1i;
    }
    v = v1;
}

/// entry point
///
void CToken::Calc_start(CALCVAR &v) {
    Calc_bool(v);
}

int CToken::Calc(CALCVAR &val) {
    CALCVAR v;
    Calc_token();
    Calc_start(v);
    if (ttype == TK_CALCERROR) {
        SetError((char *) "abnormal calculation");
        return -1;
    }
    if (wp == NULL) {
        val = v;
        return 0;
    }
    if (*wp == 0) {
        val = v;
        return 0;
    }
    SetError((char *) "expression syntax error");
    return -1;
}

//-----------------------------------------------------------------------------

/// 指定文字列をmembufへ展開する
///
/// opt : 0 = 行末までスキップ / 1 = "まで/2='まで
///
char *CToken::ExpandStr(char *str, int opt) {
    int a = 0;
    unsigned char *ptr = (unsigned char *) str;
    unsigned char cur_char;
    unsigned char sep = 0;

    if (opt == 1)
        sep = 0x22;
    if (opt == 2)
        sep = 0x27;
    s3[a++] = sep;

    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char == sep) {
            ptr++;
            break;
        }
        if ((cur_char < 32) && (cur_char != 9))
            break;
        s3[a++] = cur_char;
        ptr++;
        if (cur_char == 0x5c) {                    // '\'チェック
            s3[a++] = *ptr++;
        }
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < skip; i++) {
                s3[a++] = *ptr++;
            }
        }
    }
    s3[a++] = sep;
    s3[a] = 0;
    if (opt != 0) {
        if (wrtbuf != NULL)
            wrtbuf->PutData(s3, a);
    }
    return (char *) ptr;
}

/// コメントを展開する
///
/// ( ;;に続くAHT指定文字列用 )
///
char *CToken::ExpandAhtStr(char *str) {
    unsigned char *ptr = (unsigned char *) str;
    unsigned char cur_char;
    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if ((cur_char < 32) && (cur_char != 9))
            break;
        ptr++;
    }
    return (char *) ptr;
}

/// 指定文字列をmembufへ展開する
///
/// ( 複数行対応 {"〜"} )
///
char *CToken::ExpandStrEx(char *str) {
    int a = 0;
    unsigned char *vs = (unsigned char *) str;
    unsigned char cur_char;

    while (1) {
        cur_char = *vs;
        if (cur_char == 0) {
            break;
        }
        if (cur_char == 13) {
            s3[a++] = 0x5c;
            s3[a++] = 'n';
            vs++;
            if (*vs == 10) {
                vs++;
            }
            continue;
        }
        if (cur_char == 10) {
            s3[a++] = 0x5c;
            s3[a++] = 'n';
            vs++;
            continue;
        }
        if (cur_char == 0x22) {
            if (vs[1] == '}') {
                s3[a++] = 0x22;
                s3[a++] = '}';
                mulstr = LMODE_ON;
                vs += 2;
                break;
            }
            s3[a++] = 0x5c;
            s3[a++] = 0x22;
            vs++;
            continue;
        }
        s3[a++] = cur_char;
        vs++;
        if (cur_char == 0x5c) {                    // '\'チェック
            if (*vs >= 32) {
                s3[a++] = *vs;
                vs++;
            }
        }
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < skip; i++) {
                s3[a++] = *vs++;
            }
        }
    }

    s3[a] = 0;
    if (wrtbuf != NULL) {
        wrtbuf->PutData(s3, a);
    }
    return (char *) vs;
}

/// /*〜*/ コメントを展開する
///
char *CToken::ExpandStrComment(char *str, int opt) {
    int a = 0;
    unsigned char *ptr = (unsigned char *) str;
    unsigned char cur_char;

    while (1) {
        cur_char = *ptr;
        if (cur_char == 0) {
            break;
        }
        if (cur_char == '*') {
            if (ptr[1] == '/') {
                mulstr = LMODE_ON;
                ptr += 2;
                break;
            }
            ptr++;
            continue;
        }
        ptr++;
        ptr += SkipMultiByte(cur_char);    // 全角文字チェック
    }
    s3[a] = 0;
    if (opt == 0)
        if (wrtbuf != NULL)
            wrtbuf->PutData(s3, a);
    return (char *) ptr;
}

/// 16進数文字列をmembufへ展開する
///
char *CToken::ExpandHex(char *str, int *val) {
    int a = 1;
    int b;
    int num = 0;
    unsigned char *vs = (unsigned char *) str;
    unsigned char cur_char;
    s3[0] = '$';

    while (1) {
        cur_char = toupper(*vs);
        b = -1;
        if ((cur_char >= 0x30) && (cur_char <= 0x39))
            b = cur_char - 0x30;
        if ((cur_char >= 0x41) && (cur_char <= 0x46))
            b = cur_char - 55;
        if (cur_char == '_')
            b = -2;
        if (b == -1)
            break;
        if (b >= 0) {
            s3[a++] = cur_char;
            num = (num << 4) + b;
        }
        vs++;
    }

    s3[a] = 0;
    if (wrtbuf != NULL)
        wrtbuf->PutData(s3, a);
    *val = num;
    return (char *) vs;
}

/// 2進数文字列をmembufへ展開する
///
char *CToken::ExpandBin(char *str, int *val) {
    int a = 1;
    int b;
    int num = 0;
    unsigned char *vs = (unsigned char *) str;
    unsigned char cur_char;

    s3[0] = '%';

    while (1) {
        cur_char = *vs;
        b = -1;
        if ((cur_char >= 0x30) && (cur_char <= 0x31))
            b = cur_char - 0x30;
        if (cur_char == '_')
            b = -2;
        if (b == -1)
            break;
        if (b >= 0) {
            s3[a++] = cur_char;
            num = (num << 1) + b;
        }
        vs++;
    }
    s3[a] = 0;
    if (wrtbuf != NULL)
        wrtbuf->PutData(s3, a);
    return (char *) vs;
}

/// stringデータをmembufへ展開する
///
/// ppmode : 0=通常、1=プリプロセッサ時
///
char *CToken::ExpandToken(char *str, int *type, int ppmode) {
    int a, chk, id, ltype, opt;
    int flcnt;
    unsigned char *vs = (unsigned char *) str;
    unsigned char *vs_bak;
    unsigned char cur_char;
    unsigned char a2;
    unsigned char *vs_modbrk;
    char cnvstr[80];
    char fixname[256];
    char *macptr;

    if (vs == NULL) {
        *type = TK_EOF;
        return NULL;            // already end
    }

    cur_char = *vs;
    if (cur_char == 0) {                            // end
        *type = TK_EOF;
        return NULL;
    }
    if (cur_char == 10) {                            // Unix改行
        vs++;
        if (wrtbuf != NULL)
            wrtbuf->PutStr((char *) "\r\n");
        *type = TK_EOL;
        return (char *) vs;
    }
    if (cur_char == 13) {                            // 改行
        vs++;
        if (*vs == 10)
            vs++;
        if (wrtbuf != NULL)
            wrtbuf->PutStr((char *) "\r\n");
        *type = TK_EOL;
        return (char *) vs;
    }
    if (cur_char == ';') {                            // コメント
        *type = TK_VOID;
        *vs = 0;
        vs++;
        if (*vs == ';') {
            vs++;
            if (ahtmodel != NULL) {
                ahtkeyword = (char *) vs;
            }
        }
        return ExpandStr((char *) vs, 0);
    }
    if (cur_char == '/') { // Cコメント
        if (vs[1] == '/') {
            *type = TK_VOID;
            *vs = 0;
            return ExpandStr((char *) vs + 2, 0);
        }
        if (vs[1] == '*') {
            mulstr = LMODE_COMMENT;
            *type = TK_VOID;
            *vs = 0;
            return ExpandStrComment((char *) vs + 2, 0);
        }
    }
    if (cur_char == 0x22) { // "〜"
        *type = TK_STRING;
        return ExpandStr((char *) vs + 1, 1);
    }
    if (cur_char == 0x27) { // '〜'
        *type = TK_STRING;
        return ExpandStr((char *) vs + 1, 2);
    }
    if (cur_char == '{') { // {"〜"}
        if (vs[1] == 0x22) {
            if (wrtbuf != NULL)
                wrtbuf->PutStr((char *) "{\"");
            mulstr = LMODE_STR;
            *type = TK_STRING;
            return ExpandStrEx((char *) vs + 2);
        }
    }
    if (cur_char == '0') {
        a2 = vs[1];
        if (a2 == 'x') { // when hex code (0x)
            vs++;
            cur_char = '$';
        }
        if (a2 == 'b') { // when bin code (0b)
            vs++;
            cur_char = '%';
        }
    }
    if (cur_char == '$') { // when hex code ($)
        *type = TK_OBJ;
        return ExpandHex((char *) vs + 1, &a);
    }
    if (cur_char == '%') { // when bin code (%)
        *type = TK_OBJ;
        return ExpandBin((char *) vs + 1, &a);
    }
    if (cur_char < 0x30) { // space,tab
        *type = TK_CODE;
        vs++;
        if (wrtbuf != NULL)
            wrtbuf->Put((char) cur_char);
        return (char *) vs;
    }
    chk = 0;
    if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
        chk++;
    if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
        chk++;
    if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
        chk++;

    if (chk) {
        vs++;
        if (wrtbuf != NULL)
            wrtbuf->Put((char) cur_char); // 記号
        *type = cur_char;
        return (char *) vs;
    }

    if ((cur_char >= 0x30) && (cur_char <= 0x39)) { // when 0-9 numerical
        a = 0;
        flcnt = 0;
        while (1) {
            cur_char = *vs;
            if (cur_char == '.') {
                flcnt++;
                if (flcnt > 1)
                    break;
            } else {
                if ((cur_char < 0x30) || (cur_char > 0x39))
                    break;
            }
            s2[a++] = cur_char;
            vs++;
        }
        if ((cur_char == 'k') || (cur_char == 'f') || (cur_char == 'd')) {
            s2[a++] = cur_char;
            vs++;
        }
        if (cur_char == 'e') {
            s2[a++] = cur_char;
            vs++;
            cur_char = *vs;
            if ((cur_char == '-') || (cur_char == '+')) {
                s2[a++] = cur_char;
                vs++;
            }
            while (1) {
                cur_char = *vs;
                if ((cur_char < 0x30) || (cur_char > 0x39))
                    break;
                s2[a++] = cur_char;
                vs++;
            }
        }

        s2[a] = 0;
        if (wrtbuf != NULL)
            wrtbuf->PutData(s2, a);
        *type = TK_OBJ;
        return (char *) vs;
    }

    a = 0;
    vs_modbrk = NULL;

    //	 シンボル取り出し
    //
    while (1) {
        cur_char = *vs;
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < (skip + 1); i++) {
                NSLog(@"E:%s", str);
                if (a < OBJNAME_MAX) {
                    s2[a++] = cur_char;
                    vs++;
                    cur_char = *vs;
                } else {
                    vs++;
                }

            }
            continue;
        }

        chk = 0;
        if (cur_char < 0x30)
            chk++;
        if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
            chk++;
        if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
            chk++;
        if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
            chk++;
        if (chk)
            break;
        vs++;
        if (a < OBJNAME_MAX)
            s2[a++] = cur_char;
    }
    s2[a] = 0;
    if (*s2 == '@') {
        if (wrtbuf != NULL)
            wrtbuf->PutData(s2, a);
        *type = TK_CODE;
        return (char *) vs;
    }

    strcase2((char *) s2, fixname); // シンボル検索

    FixModuleName((char *) s2);
    AddModuleName(fixname);

    id = lb->SearchLocal((char *) s2, fixname);
    if (id != -1) {
        ltype = lb->GetType(id);
        switch (ltype) {
            case LAB_TYPE_PPVAL: // constマクロ展開
            {
                char *ptr_dval;
                ptr_dval = lb->GetData2(id);
                if (ptr_dval == NULL) {
                    sprintf(cnvstr, "%d", lb->GetOpt(id));
                } else {
                    sprintf(cnvstr, "%f", *(CALCVAR *) ptr_dval);
                }
                chk = ReplaceLineBuf(str, (char *) vs, cnvstr, 0, NULL);
                break;
            }
            case LAB_TYPE_PPINTMAC: // 内部マクロ
                if (ppmode) { // プリプロセッサ時はそのまま展開
                    if (wrtbuf != NULL) {
                        FixModuleName((char *) s2);
                        wrtbuf->PutStr((char *) s2);
                    }
                    *type = TK_OBJ;
                    return (char *) vs;
                }
            case LAB_TYPE_PPMAC: // マクロ展開
                vs_bak = vs;
                while (1) { // 直後のspace/tabを除去
                    cur_char = *vs_bak;
                    if ((cur_char != 32) && (cur_char != 9))
                        break;
                    vs_bak++;
                }
                opt = lb->GetOpt(id);
                if ((cur_char == '=') && (opt & PRM_MASK)) { // マクロに代入しようとした場合のエラー
                    SetError((char *) "Reserved word syntax error");
                    *type = TK_ERROR;
                    return (char *) vs;
                }
                macptr = lb->GetData(id);
                if (macptr == NULL) {
                    *cnvstr = 0;
                    macptr = cnvstr;
                }
                chk = ReplaceLineBuf(str, (char *) vs, macptr, opt, (MACDEF *) lb->GetData2(id));
                break;
            case LAB_TYPE_PPDLLFUNC: // モジュール名付き展開キーワード
                if (wrtbuf != NULL) { // AddModuleName((char*)s2);
                    if (lb->GetEternal(id)) {
                        FixModuleName((char *) s2);
                        wrtbuf->PutStr((char *) s2);
                    } else {
                        wrtbuf->PutStr(fixname);
                    }
                }
                *type = TK_OBJ;
                if (*modname == 0) {
                    lb->AddReference(id);
                } else {
                    int i;
                    i = lb->Search(GetModuleName());
                    if (lb->SearchRelation(id, i) == 0) {
                        lb->AddRelation(id, i);
                    }
                }
                return (char *) vs;
                break;
            case LAB_TYPE_COMVAR: // COMキーワードを展開
                if (wrtbuf != NULL) {
                    if (lb->GetEternal(id)) {
                        FixModuleName((char *) s2);
                        wrtbuf->PutStr((char *) s2);
                    } else {
                        wrtbuf->PutStr(fixname);
                    }
                }
                *type = TK_OBJ;
                lb->AddReference(id);
                return (char *) vs;
            case LAB_TYPE_PPMODFUNC:
            default: // 通常キーワードはそのまま展開
                if (wrtbuf != NULL) {
                    if (!lb->GetEternal(id)) { // local func
                        strcpy((char *) s2, lb->GetName(id));
                    }
                    FixModuleName((char *) s2);
                    wrtbuf->PutStr((char *) s2);
                }
                *type = TK_OBJ;
                lb->AddReference(id);
                return (char *) vs;
        }
        if (chk) {
            *type = TK_ERROR;
            return str;
        }
        *type = TK_OBJ;
        return str;
    }

//#define __vector_add_asg(vec_addr) ((typeof(*vec_addr))([cwrap _vector_add:(vector*)vec_addr vec_addr:(sizeof)(**vec_addr)]))
//#define __vector_add(vec_addr, value) (*__vector_add_asg(vec_addr) = value)

    if (wrtbuf != NULL) { // 登録されていないキーワードを展開
        if (strcmp((char *) s2, fixname)) {
            //	後ろで定義されている関数の呼び出しのために
            //	モジュール内で＠をつけていない識別子の位置を記録する
            undefined_symbol_t sym;
            sym.pos = wrtbuf->GetSize();
            sym.len_include_modname = (int) strlen(fixname);
            sym.len = (int) strlen((char *) s2);
            //undefined_symbols.push_back(sym);
            //vector_push(undefined_symbols, sym);
            //[cwrap _vector_add:(vector*)undefined_symbols type_size:(vec_type_t)sym];
            //__vector_add(undefined_symbols, sym);
            //struct undefined_symbol_t* symbol = (undefined_symbol_t*)[cwrap _vector_add:(vector*)undefined_symbols type_size:sizeof(*undefined_symbols)];
            //symbol = &sym;

            vector v = [cwrap _vector_add:(vector *) &undefined_symbols type_size:sizeof(**&undefined_symbols)];
            (*((typeof(*&undefined_symbols)) (v)) = sym);
            //(*((typeof(*&undefined_symbols))(_vector_add((vector*)&undefined_symbols, sizeof(**&undefined_symbols)))) = sym);

            //*(typeof(*vec_addr))_vector_add((vector*)vec_addr, sizeof(**vec_addr)) = value
        }
        wrtbuf->PutStr(fixname);
    }
    *type = TK_OBJ;
    return (char *) vs;
}





//#define vector_add(vec_addr, value) (*vector_add_asg(vec_addr) = value)
//*vector_add_asg(vec_addr) = value



/// strから改行までをスキップする
///
/// 行末に「\」で次行を接続
///
char *CToken::SkipLine(char *str, int *pline) {
    unsigned char *ptr = (unsigned char *) str;
    unsigned char cur_char;
    unsigned char prev_char = 0;
    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char == 13) {
            pline[0]++;
            ptr++;
            if (*ptr == 10)
                ptr++;
            if (prev_char != 0x5c)
                break;
            continue;
        }
        if (cur_char == 10) {
            pline[0]++;
            ptr++;
            if (prev_char != 0x5c)
                break;
            continue;
        }
        if ((cur_char < 32) && (cur_char != 9))
            break;
        ptr++;
        prev_char = cur_char;
    }
    return (char *) ptr;
}

/// １行分のデータをlinebufに転送
///
char *CToken::SendLineBuf(char *str) {
    char *ptr = str;
    char *w = linebuf;
    char cur_char;
    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        ptr++;
        if (cur_char == 10)
            break;
        if (cur_char == 13) {
            if (*ptr == 10)
                ptr++;
            break;
        }
        *w++ = cur_char;
    }
    *w = 0;
    return ptr;
}

#define IS_CHAR_HEAD(str, pos) \
is_sjis_char_head((unsigned char *)(str), (int)((pos) - (unsigned char *)(str)))

/// １行分のデータをlinebufに転送
///
/// 行末の'\'は継続 linesに行数を返す
///
char *CToken::SendLineBufPP(char *str, int *lines) {
    unsigned char *ptr = (unsigned char *) str;
    unsigned char *w = (unsigned char *) linebuf;
    unsigned char cur_char;
    unsigned char prev_char = 0;
    int ln = 0;
    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        ptr++;
        if (cur_char == 10) {
            if (prev_char == 0x5c && IS_CHAR_HEAD(str, ptr - 2)) {
                ln++;
                w--;
                prev_char = 0;
                continue;
            }
            break;
        }
        if (cur_char == 13) {
            if (prev_char == 0x5c && IS_CHAR_HEAD(str, ptr - 2)) {
                if (*ptr == 10)
                    ptr++;
                ln++;
                w--;
                prev_char = 0;
                continue;
            }
            if (*ptr == 10)
                ptr++;
            break;
        }
        *w++ = cur_char;
        prev_char = cur_char;
    }
    *w = 0;
    *lines = ln;
    return (char *) ptr;
}

#undef IS_CHAR_HEAD

/// "*/" で終端していない場合は NULL を返す
///
char *CToken::ExpandStrComment2(char *str) {
    int mulstr_bak = mulstr;
    mulstr = LMODE_COMMENT;
    char *ret = ExpandStrComment(str, 1);
    if (mulstr == LMODE_COMMENT) {
        ret = NULL;
    }
    mulstr = mulstr_bak;
    return ret;
}

/// linebufのキーワードを置き換え
///
/// linetmpを破壊します
/// str1 : 置き換え元キーワード先頭(linebuf内)
/// str2 : 置き換え元キーワード次ptr(linebuf内)
/// repl : 置き換えキーワード
/// macopt : マクロ添字の数
/// return : 0=ok/1=error
///
int CToken::ReplaceLineBuf(char *str1, char *str2, char *repl, int opt, MACDEF *macdef) {
    char *w;
    char *w2;
    char *p;
    char *endp;
    char *prm[32];
    char *prme[32];
    char *last;
    char *macbuf;
    char *macbuf2;
    char cur_char;
    char dummy[4];
    char mactmp[128];
    int i = 0;
    int flg = 1;
    int type;
    //int cnvfnc = 0;
    int tagid;
    int stklevel;
    int macopt = opt & PRM_MASK;
    int ctype = 0;
    int noprm;
    int kakko = 0;

    if (opt & PRM_FLAG_CTYPE)
        ctype = 1;
    *dummy = 0;
    strcpy(linetmp, str2);
    wp = (unsigned char *) linetmp;
    if ((macopt) || (ctype)) {
        p = (char *) wp;
        type = GetToken();
        if (ctype) {
            if (type != '(') {
#ifdef JPNMSG
                SetError((char *) "ctypeマクロの直後には、丸括弧でくくられた引数リストが必要です");
#else
                SetError("C-Type macro syntax error");
#endif
                return 4;
            }
            p = (char *) wp;
            type = GetToken();
        }
        if (type != TK_NONE) {
            wp = (unsigned char *) p;
            prm[i] = p;
            while (1) { // マクロパラメータを取り出す
                p = (char *) wp;
                type = GetToken();
                if (type == ';')
                    type = TK_SEPARATE;
                if (type == '}')
                    type = TK_SEPARATE;
                if (type == '/') { // Cコメント??
                    if (*wp == '/') {
                        type = TK_SEPARATE;
                    }
                    if (*wp == '*') {
                        char *start = (char *) wp - 1;
                        char *end = ExpandStrComment2(start + 2);
                        if (end == NULL) { // 範囲コメントが次の行まで続いている
                            type = TK_SEPARATE;
                        } else {
                            wp = (unsigned char *) end;
                        }
                    }
                }
                if (flg) {
                    flg = 0;
                    prm[i] = p;
                    if (type == TK_NONE) {
                        prme[i++] = p;
                        break;
                    }
                }
                if (type == TK_SEPARATE) {
                    wp = (unsigned char *) p;
                    prme[i++] = (char *) wp;
                    break;
                }
                if (wp == NULL) {
                    prme[i++] = NULL;
                    break;
                }
                if (type == ',') {
                    if (kakko == 0) { // カッコに囲まれている場合は無視する
                        prme[i] = p;
                        flg = 1;
                        i++;
                    }
                }
                if (ctype == 0) { // 通常時のカッコ処理
                    if (type == '(')
                        kakko++;
                    if (type == ')')
                        kakko--;
                } else { // Cタイプ時のカッコ処理
                    if (type == '(') {
                        kakko++;
                        ctype++;
                    }
                    if (type == ')') {
                        kakko--;
                        if (ctype == 1) {
                            wp = (unsigned char *) p;
                            prme[i++] = (char *) wp;
                            while (1) {
                                if ((*wp != 32) && (*wp != 9))
                                    break;
                                wp++;
                            }
                            *wp = 32; // ')'をspaceに
                            break;
                        }
                        ctype--;
                    }
                }
            }
        }

        if (i > macopt) {
            noprm = 1;
            if ((ctype) && (i == 1) && (macopt == 0) && (prm[0] == prme[0]))
                noprm = 0;
            if (noprm) {
#ifdef JPNMSG
                SetError((char *) "マクロの引数が多すぎます");
#else
                SetError("too many macro parameters");
#endif
                return 3;
            }
        }
        while (1) { // 省略パラメータを補完
            if (i >= macopt)
                break;
            prm[i] = dummy;
            prme[i] = dummy;
            i++;
        }
    }
    last = (char *) wp;

    tagid = 0x10000;
    w = str1;
    wp = (unsigned char *) repl;
    while (1) { // マクロ置き換え
        if (wp == NULL)
            break;
        if (w >= linetmp) {
            SetError((char *) "macro buffer overflow");
            return 4;
        }
        cur_char = *wp++;
        if (cur_char == 0)
            break;
        if (cur_char == '%') {
            if (*wp == '%') {
                *w++ = cur_char;
                wp++;
                continue;
            }
            type = GetToken();
            if (type == TK_OBJ) { // 特殊コマンドラベル処理
                macbuf = mactmp;
                *mactmp = 0;
                cur_char = tolower((int) *s3);
                switch (cur_char) {
                    case 't': // %tタグ名
                        tagid = [cwrap GetTagID:(char *) (s3 + 1)];
                        //tagid = tstack->GetTagID((char *)(s3 + 1));
                        break;
                    case 'i':
                        [cwrap GetTagUniqueName:tagid outname:mactmp];
                        [cwrap PushTag:tagid str:mactmp];
                        //tstack->GetTagUniqueName(tagid, mactmp);
                        //tstack->PushTag(tagid, mactmp);
                        if (s3[1] == '0')
                            *mactmp = 0;
                        break;
                    case 's':
                        val = (int) (s3[1] - 48);
                        val--;
                        if (!(0 <= val && val <= macopt - 1)) {
                            SetError((char *) "illegal macro parameter %s");
                            return 2;
                        }
                        w2 = mactmp;
                        p = prm[val];
                        endp = prme[val];
                        if (p == endp) { // 値省略時
                            macbuf2 = macdef->data + macdef->index[val];
                            while (1) {
                                cur_char = *macbuf2++;
                                if (cur_char == 0)
                                    break;
                                *w2++ = cur_char;
                            }
                        } else {
                            while (1) { // %numマクロ展開
                                if (p == endp)
                                    break;
                                cur_char = *p++;
                                if (cur_char == 0)
                                    break;
                                *w2++ = cur_char;
                            }
                        }
                        *w2 = 0;
                        [cwrap PushTag:tagid str:mactmp];
                        //tstack->PushTag(tagid, mactmp);
                        *mactmp = 0;
                        break;
                    case 'n':
                        [cwrap GetTagUniqueName:tagid outname:mactmp];
                        //tstack->GetTagUniqueName(tagid, mactmp);
                        break;
                    case 'p':
                        stklevel = (int) (s3[1] - 48);
                        if ((stklevel < 0) || (stklevel > 9))
                            stklevel = 0;
                        macbuf = [cwrap LookupTag:tagid level:stklevel];
                        //macbuf = tstack->LookupTag(tagid, stklevel);
                        break;
                    case 'o':
                        if (s3[1] != '0') {
                            macbuf = [cwrap PopTag:tagid];
                            //macbuf = tstack->PopTag(tagid);
                        } else {
                            [cwrap PopTag:tagid];
                            //tstack->PopTag(tagid);
                        }
                        break;
                    case 'c':
                        mactmp[0] = 0x0d;
                        mactmp[1] = 0x0a;
                        mactmp[2] = 0;
                        break;
                    default:
                        macbuf = NULL;
                        break;
                }
                if (macbuf == NULL) {
                    sprintf(mactmp, "macro syntax error [%s]", [cwrap GetTagName:tagid]);
                    //sprintf(mactmp, "macro syntax error [%s]",tstack->GetTagName(tagid));
                    SetError(mactmp);
                    return 2;
                }
                while (1) { //mactmp展開
                    cur_char = *macbuf++;
                    if (cur_char == 0)
                        break;
                    *w++ = cur_char;
                }
                if (wp != NULL) {
                    cur_char = *wp;
                    if (cur_char == ' ') // マクロ後のspace除去
                        wp++;
                }
                continue;
            }
            if (type != TK_NUM) {
                SetError((char *) "macro parameter invalid");
                return 1;
            }
            val--;
            if (!(0 <= val && val <= macopt - 1)) {
                SetError((char *) "illegal macro parameter");
                return 2;
            }
            p = prm[val];
            endp = prme[val];
            if (p == endp) { // 値省略時
                macbuf = macdef->data + macdef->index[val];
                if (*macbuf == 0) {
#ifdef JPNMSG
                    SetError((char *) "デフォルトパラメータのないマクロの引数は省略できません");
#else
                    SetError("no default parameter");
#endif
                    return 5;
                }
                while (1) {
                    cur_char = *macbuf++;
                    if (cur_char == 0)
                        break;
                    *w++ = cur_char;
                }
                continue;
            }
            while (1) { // %numマクロ展開
                if (p == endp)
                    break;
                cur_char = *p++;
                if (cur_char == 0)
                    break;
                *w++ = cur_char;
            }
            continue;
        }
        *w++ = cur_char;
    }
    *w = 0;
    if (last != NULL) {
        if (w + strlen(last) + 1 >= linetmp) {
            SetError((char *) "macro buffer overflow");
            return 4;
        }
        strcpy(w, last);
    }
    return 0;
}

ppresult_t CToken::PP_SwitchStart(int sw) {
    if (swsp == 0) {
        swflag = 1;
        swlevel = LMODE_ON;
    }
    if (swsp >= SWSTACK_MAX) {
        SetError((char *) "#if nested too deeply");
        return PPRESULT_ERROR;
    }
    swstack[swsp] = swflag; // 有効フラグ
    swstack2[swsp] = swmode; // elseモード
    swstack3[swsp] = swlevel; // ON/OFF
    swsp++;
    swmode = 0;
    if (swflag == 0)
        return PPRESULT_SUCCESS;
    if (sw == 0) {
        swlevel = LMODE_OFF;
    } else {
        swlevel = LMODE_ON;
    }
    mulstr = swlevel;
    if (mulstr == LMODE_OFF)
        swflag = 0;
    return PPRESULT_SUCCESS;
}

ppresult_t CToken::PP_SwitchEnd(void) {
    if (swsp == 0) {
        SetError((char *) "#endif without #if");
        return PPRESULT_ERROR;
    }
    swsp--;
    swflag = swstack[swsp];
    swmode = swstack2[swsp];
    swlevel = swstack3[swsp];
    if (swflag)
        mulstr = swlevel;
    return PPRESULT_SUCCESS;
}

ppresult_t CToken::PP_SwitchReverse(void) {
    if (swsp == 0) {
        SetError((char *) "#else without #if");
        return PPRESULT_ERROR;
    }
    if (swmode != 0) {
        SetError((char *) "#else after #else");
        return PPRESULT_ERROR;
    }
    if (swstack[swsp - 1] == 0)
        return PPRESULT_SUCCESS;    // 上のスタックが無効なら無視
    swmode = 1;
    if (swlevel == LMODE_ON) {
        swlevel = LMODE_OFF;
    } else {
        swlevel = LMODE_ON;
    }
    mulstr = swlevel;
    swflag ^= 1;
    return PPRESULT_SUCCESS;
}

ppresult_t CToken::PP_Include(int is_addition) {
    char *word = (char *) s3;
    char tmp_spath[HSP_MAX_PATH];
    int add_bak = 0;
    if (GetToken() != TK_STRING) {
        if (is_addition) {
            SetError((char *) "invalid addition suffix");
        } else {
            SetError((char *) "invalid include suffix");
        }
        return PPRESULT_ERROR;
    }
    incinf++;
    if (incinf > 32) {
        SetError((char *) "too many include level");
        return PPRESULT_ERROR;
    }
    strcpy(tmp_spath, search_path);
    if (is_addition)
        add_bak = SetAdditionMode(1);
    int res = ExpandFile(wrtbuf, word, word);
    if (is_addition)
        SetAdditionMode(add_bak);
    strcpy(search_path, tmp_spath);

    incinf--;
    if (res) {
        if (is_addition && res == -1)
            return PPRESULT_SUCCESS;
        return PPRESULT_ERROR;
    }

    return PPRESULT_INCLUDED;
}

/// #const解析
///
ppresult_t CToken::PP_Const(void) {
    enum ConstType {
        Indeterminate,
        Double,
        Int
    };
    ConstType valuetype = ConstType::Indeterminate;

    char *word;
    int id, res, glmode;
    char keyword[256];
    char strtmp[512];
    CALCVAR cres;
    glmode = 0;
    word = (char *) s3;
    if (GetToken() != TK_OBJ) {
        sprintf(strtmp, "invalid symbol [%s]", word);
        SetError(strtmp);
        return PPRESULT_ERROR;
    }

    strcase(word);
    if (tstrcmp(word, "global")) {        // global macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad global syntax");
            return PPRESULT_ERROR;
        }
        glmode = 1;
        strcase(word);
    }

    // 型指定キーワード
    if (tstrcmp(word, "double")) {
        valuetype = ConstType::Double;
    } else if (tstrcmp(word, "int")) {
        valuetype = ConstType::Int;
    }
    if (valuetype != ConstType::Indeterminate) {
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad #const syntax");
            return PPRESULT_ERROR;
        }
        strcase(word);
    }

    strcpy(keyword, word);
    if (glmode)
        FixModuleName(keyword);
    else
        AddModuleName(keyword);
    res = lb->Search(keyword);
    if (res != -1) {
        SetErrorSymbolOverdefined(keyword, res);
        return PPRESULT_ERROR;
    }

    if (Calc(cres))
        return PPRESULT_ERROR;

//    // AHT keyword check
//    if (ahtkeyword != NULL) {
//        if (ahtbuf != NULL) { // AHT出力時
//            AHTPROP *prop;
//            CALCVAR dbval;
//            prop = ahtmodel->GetProperty(keyword);
//            if (prop != NULL) {
//                id = lb->Regist(keyword, LAB_TYPE_PPVAL, prop->GetValueInt());
//                if (cres != floor(cres)) {
//                    dbval = prop->GetValueDouble();
//                    lb->SetData2(id, (char *)(&dbval), sizeof(CALCVAR));
//                }
//                if (glmode)
//                    lb->SetEternal(id);
//                return PPRESULT_SUCCESS;
//            }
//        } else { // AHT読み出し時
//            if (cres != floor(cres)) {
//                ahtmodel->SetPropertyDefaultDouble(keyword, (double)cres);
//            } else {
//                ahtmodel->SetPropertyDefaultInt(keyword, (int)cres);
//            }
//            if (ahtmodel->SetAHTPropertyString(keyword, ahtkeyword)) {
//                SetError((char *)"AHT parameter syntax error" );
//                return PPRESULT_ERROR;
//            }
//        }
//    }

    id = lb->Regist(keyword, LAB_TYPE_PPVAL, (int) cres);
    if (valuetype == ConstType::Double || (valuetype == ConstType::Indeterminate && cres != floor(cres))) {
        lb->SetData2(id, (char *) (&cres), sizeof(CALCVAR));
    }
    if (glmode)
        lb->SetEternal(id);
    return PPRESULT_SUCCESS;
}

/// #enum解析
///
ppresult_t CToken::PP_Enum(void) {
    char *word = (char *) s3;
    int id;
    int res;
    int glmode = 0;
    CALCVAR cres;
    char keyword[256];
    char strtmp[512];

    if (GetToken() != TK_OBJ) {
        sprintf(strtmp, "invalid symbol [%s]", word);
        SetError(strtmp);
        return PPRESULT_ERROR;
    }
    strcase(word);
    if (tstrcmp(word, "global")) { // global macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad global syntax");
            return PPRESULT_ERROR;
        }
        glmode = 1;
        strcase(word);
    }
    strcpy(keyword, word);
    if (glmode)
        FixModuleName(keyword);
    else
        AddModuleName(keyword);
    res = lb->Search(keyword);
    if (res != -1) {
        SetErrorSymbolOverdefined(keyword, res);
        return PPRESULT_ERROR;
    }
    if (GetToken() == '=') {
        if (Calc(cres))
            return PPRESULT_ERROR;
        enumgc = (int) cres;
    }
    res = enumgc++;
    id = lb->Regist(keyword, LAB_TYPE_PPVAL, res);
    if (glmode)
        lb->SetEternal(id);
    return PPRESULT_SUCCESS;
}

/// 行末までにコメントがあるか調べる
/// @return 有効文字列の先頭ポインタ
///
char *CToken::CheckValidWord(void) {
    char *res = (char *) wp;
    char *p;
    char *p2;
    unsigned char cur_char;
    int qqflg = 0;
    int qqchr = 0;

    if (res == NULL)
        return res;
    p = res;

    while (1) {
        cur_char = *p;
        if (cur_char == 0)
            break;
        if (qqflg == 0) { // コメント検索フラグ
            if (cur_char == 0x22) {
                qqflg = 1;
                qqchr = cur_char;
            }
            if (cur_char == 0x27) {
                qqflg = 1;
                qqchr = cur_char;
            }
            if (cur_char == ';') { // コメント
                *p = 0;
                break;
            }
            if (cur_char == '/') { // Cコメント
                if (p[1] == '/') {
                    *p = 0;
                    break;
                }
                if (p[1] == '*') {
                    mulstr = LMODE_COMMENT;
                    p2 = ExpandStrComment((char *) p + 2, 1);
                    while (1) {
                        if (p >= p2)
                            break;
                        *p++ = 32; // コメント部分をspaceに
                    }
                    continue;
                }
            }
        } else { // 文字列中はコメント検索せず
            if (cur_char == 0x5c) { // '\'チェック
                p++;
                cur_char = *p;
                if (cur_char >= 32)
                    p++;
                continue;
            }
            if (cur_char == qqchr)
                qqflg = 0;
        }

        p += SkipMultiByte(cur_char);           // 全角文字チェック
        p++;
    }
    return res;
}

/// #define解析
///
ppresult_t CToken::PP_Define(void) {
    char *word = (char *) s3;
    char *wdata;
    int id;
    int res;
    int type;
    int prms;
    int flg;
    int glmode = 0;
    int ctype = 0;
    char cur_char;
    MACDEF *macdef;
    int macptr;
    char *macbuf;
    char keyword[256];
    char strtmp[512];

    if (GetToken() != TK_OBJ) {
        sprintf(strtmp, "invalid symbol [%s]", word);
        SetError(strtmp);
        return PPRESULT_ERROR;
    }

    strcase(word);
    if (tstrcmp(word, "global")) {        // global macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad macro syntax");
            return PPRESULT_ERROR;
        }
        glmode = 1;
        strcase(word);
    }
    if (tstrcmp(word, "ctype")) {        // C-type macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad macro syntax");
            return PPRESULT_ERROR;
        }
        ctype = 1;
        strcase(word);
    }
    strcpy(keyword, word);
    if (glmode)
        FixModuleName(keyword);
    else
        AddModuleName(keyword);
    res = lb->Search(keyword);
    if (res != -1) {
        SetErrorSymbolOverdefined(keyword, res);
        return PPRESULT_ERROR;
    }

    // skip space,tab code
    if (wp == NULL)
        cur_char = 0;
    else {
        cur_char = *wp;
        if (cur_char != '(')
            cur_char = 0;
    }

    if (cur_char == 0) { // no parameters
        prms = 0;
        if (ctype)
            prms |= PRM_FLAG_CTYPE;
        wdata = CheckValidWord();
//        // AHT keyword check
//        if (ahtkeyword != NULL) {
//            if (ahtbuf != NULL) { // AHT出力時
//                AHTPROP *prop;
//                prop = ahtmodel->GetProperty(keyword);
//                if (prop != NULL)
//                    wdata = prop->GetOutValue();
//            } else { // AHT読み込み時
//                AHTPROP *prop;
//                prop = ahtmodel->SetPropertyDefault(keyword, wdata);
//                if (ahtmodel->SetAHTPropertyString(keyword, ahtkeyword)) {
//                    SetError((char *)"AHT parameter syntax error");
//                    return PPRESULT_ERROR;
//                }
//                if (prop->ahtmode & AHTMODE_OUTPUT_RAW) {
//                    ahtmodel->SetPropertyDefaultStr(keyword, wdata);
//                }
//            }
//        }

        id = lb->Regist(keyword, LAB_TYPE_PPMAC, prms);
        lb->SetData(id, wdata);
        if (glmode)
            lb->SetEternal(id);

        return PPRESULT_SUCCESS;
    }

    //		パラメータ定義取得
    //
    macdef = (MACDEF *) linetmp;
    macdef->data[0] = 0;
    macptr = 1;                // デフォルトマクロデータ参照オフセット
    wp++;
    prms = 0;
    flg = 0;
    while (1) {
        if (wp == NULL)
            goto bad_macro_param_expr;
        cur_char = *wp++;
        if (cur_char == ')') {
            if (flg == 0)
                goto bad_macro_param_expr;
            prms++;
            break;
        }
        switch (cur_char) {
            case 9:
            case 32:
                break;
            case ',':
                if (flg == 0)
                    goto bad_macro_param_expr;
                prms++;
                flg = 0;
                break;
            case '%':
                if (flg != 0)
                    goto bad_macro_param_expr;
                type = GetToken();
                if (type != TK_NUM)
                    goto bad_macro_param_expr;
                if (val != (prms + 1))
                    goto bad_macro_param_expr;
                flg = 1;
                macdef->index[prms] = 0;            // デフォルト(初期値なし)
                break;
            case '=':
                if (flg != 1)
                    goto bad_macro_param_expr;
                flg = 2;
                macdef->index[prms] = macptr;        // 初期値ポインタの設定
                type = GetToken();
                switch (type) {
                    case TK_NUM:
                        sprintf(word, "%d", val);
                        break;
                    case TK_DNUM:
                        strcpy(word, (char *) s3);
                        break;
                    case TK_STRING:
                        sprintf(strtmp, "\"%s\"", word);
                        strcpy(word, strtmp);
                        break;
                    case TK_OBJ:
                        break;
                    case '-':
                        type = GetToken();
                        if (type == TK_DNUM) {
                            sprintf(strtmp, "-%s", s3);
                            strcpy(word, strtmp);
                            break;
                        }
                        if (type != TK_NUM) {
                            SetError((char *) "bad default value");
                            return PPRESULT_ERROR;
                        }
                        //_itoa( val, word, 10 );
                        sprintf(word, "-%d", val);
                        break;
                    default:
                        SetError((char *) "bad default value");
                        return PPRESULT_ERROR;
                }
                macbuf = (macdef->data) + macptr;
                res = (int) strlen(word);
                strcpy(macbuf, word);
                macptr += res + 1;
                break;
            default:
                goto bad_macro_param_expr;
        }
    }

    //		skip space,tab code
    if (wp == NULL)
        cur_char = 0;
    else {
        while (1) {
            cur_char = *wp;
            if (cur_char == 0)
                break;
            if ((cur_char != 9) && (cur_char != 32))
                break;
            wp++;
        }
    }
    if (cur_char == 0) {
        SetError((char *) "macro contains no data");
        return PPRESULT_ERROR;
    }
    if (ctype)
        prms |= PRM_FLAG_CTYPE;

    //		データ定義
    id = lb->Regist(keyword, LAB_TYPE_PPMAC, prms);
    wdata = CheckValidWord();
    lb->SetData(id, wdata);
    lb->SetData2(id, (char *) macdef, macptr + sizeof(macdef->index));
    if (glmode)
        lb->SetEternal(id);

    //sprintf( keyword,"[%d]-[%s]",id,wdata );Alert( keyword );
    return PPRESULT_SUCCESS;

    bad_macro_param_expr:
    SetError((char *) "bad macro parameter expression");
    return PPRESULT_ERROR;
}

/// #defcfunc解析
///
/// mode :
/// 0 = 通常cfunc
/// 1 = modcfunc
///
ppresult_t CToken::PP_Defcfunc(int mode) {
    int id = -1;
    char *word = (char *) s3;
    char *mod = GetModuleName();
    char fixname[128];
    int glmode = 0;
    int premode = LAB_TYPE_PPMODFUNC;
    int token = GetToken();

    if (token == TK_OBJ) {
        strcase(word);
        if (tstrcmp(word, "local")) { // local option
            if (*mod == 0) {
                SetError((char *) "module name not found");
                return PPRESULT_ERROR;
            }
            glmode = 1;
            token = GetToken();
        }
        if (tstrcmp(word, "prep")) { // prepare option
            premode = LAB_TYPE_PP_PREMODFUNC;
            token = GetToken();
        }
    }

    strcase2(word, fixname);
    if (token != TK_OBJ) {
        SetError((char *) "invalid func name");
        return PPRESULT_ERROR;
    }
    token = lb->Search(fixname);
    if (token != -1) {
        if (lb->GetFlag(token) != LAB_TYPE_PP_PREMODFUNC) {
            SetErrorSymbolOverdefined(fixname, token);
            return PPRESULT_ERROR;
        }
        id = token;
    }

    if (glmode)
        AddModuleName(fixname);

    if (premode == LAB_TYPE_PP_PREMODFUNC) {
        wrtbuf->PutStrf((char *) "#defcfunc prep %s ", fixname);
    } else {
        wrtbuf->PutStrf((char *) "#defcfunc %s ", fixname);
    }

    if (id == -1) {
        id = lb->Regist(fixname, premode, 0);
        if (glmode == 0)
            lb->SetEternal(id);
        if (*mod != 0) { // モジュールラベルに依存を追加
            lb->AddRelation(mod, id);
        }
    } else {
        lb->SetFlag(id, premode);
    }

    if (mode) {
        if (mode == 1) {
            wrtbuf->PutStr((char *) "modvar ");
        } else {
            wrtbuf->PutStr((char *) "modinit ");
        }
        if (*mod == 0) {
            SetError((char *) "module name not found");
            return PPRESULT_ERROR;
        }
        wrtbuf->PutStr(mod);
        if (wp != NULL)
            wrtbuf->Put(',');
    }

    while (1) {
        token = GetToken();
        if (token == TK_OBJ) {
            wrtbuf->PutStr(word);
        }
        if (wp == NULL)
            break;
        if (token != TK_OBJ) {
            SetError((char *) "invalid func param");
            return PPRESULT_ERROR;
        }

        token = GetToken();
        if (token == TK_OBJ) {
            strcase2(word, fixname);
            AddModuleName(fixname);
            wrtbuf->Put(' ');
            wrtbuf->PutStr(fixname);
            token = GetToken();
        }
        if (wp == NULL)
            break;
        if (token != ',') {
            SetError((char *) "invalid func param");
            return PPRESULT_ERROR;
        }
        wrtbuf->Put(',');
    }

    wrtbuf->PutCR();
    return PPRESULT_WROTE_LINE;
}

/// #deffunc解析
///
/// mode:
/// 0 = 通常func
/// 1 = modfunc
/// 2 = modinit
/// 3 = modterm
///
ppresult_t CToken::PP_Deffunc(int mode) {
    int id = -1;
    char *word = (char *) s3;
    char *mod = GetModuleName();
    char fixname[128];
    int glmode = 0;
    int premode = LAB_TYPE_PPMODFUNC;
    int token;

    if (mode < 2) {
        token = GetToken();
        if (token == TK_OBJ) {
            strcase(word);
            if (tstrcmp(word, "local")) { // local option
                if (*mod == 0) {
                    SetError((char *) "module name not found");
                    return PPRESULT_ERROR;
                }
                glmode = 1;
                token = GetToken();
            }
            if (tstrcmp(word, "prep")) { // prepare option
                premode = LAB_TYPE_PP_PREMODFUNC;
                token = GetToken();
            }
        }

        strcase2(word, fixname);
        if (token != TK_OBJ) {
            SetError((char *) "invalid func name");
            return PPRESULT_ERROR;
        }
        token = lb->Search(fixname);
        if (token != -1) {
            if (lb->GetFlag(token) != LAB_TYPE_PP_PREMODFUNC) {
                SetErrorSymbolOverdefined(fixname, token);
                return PPRESULT_ERROR;
            }
            id = token;
        }

        if (glmode)
            AddModuleName(fixname);

        if (premode == LAB_TYPE_PP_PREMODFUNC) {
            wrtbuf->PutStrf((char *) "#deffunc prep %s ", fixname);
        } else {
            wrtbuf->PutStrf((char *) "#deffunc %s ", fixname);
        }

        if (id == -1) {
            id = lb->Regist(fixname, premode, 0);
            if (glmode == 0)
                lb->SetEternal(id);
            if (*mod != 0) {
                lb->AddRelation(mod, id);
            }        // モジュールラベルに依存を追加
        } else {
            lb->SetFlag(id, premode);
        }

        if (mode) {
            wrtbuf->PutStr((char *) "modvar ");
            if (*mod == 0) {
                SetError((char *) "module name not found");
                return PPRESULT_ERROR;
            }
            wrtbuf->PutStr(mod);
            if (wp != NULL)
                wrtbuf->Put(',');
        }
    } else {
        if (mode == 2) {
            wrtbuf->PutStr((char *) "#deffunc __init modinit ");
        } else {
            wrtbuf->PutStr((char *) "#deffunc __term modterm ");
        }
        if (*mod == 0) {
            SetError((char *) "module name not found");
            return PPRESULT_ERROR;
        }
        wrtbuf->PutStr(mod);
        if (wp != NULL)
            wrtbuf->Put(',');
    }

    while (1) {
        token = GetToken();
        if (token == TK_OBJ) {
            wrtbuf->PutStr(word);
            strcase(word);
            if (tstrcmp(word, "onexit")) {                            // onexitは参照済みにする
                lb->AddReference(id);
            }
        }
        if (wp == NULL)
            break;
        if (token != TK_OBJ) {
            SetError((char *) "invalid func param");
            return PPRESULT_ERROR;
        }

        token = GetToken();
        if (token == TK_OBJ) {
            strcase2(word, fixname);
            AddModuleName(fixname);
            wrtbuf->Put(' ');
            wrtbuf->PutStr(fixname);
            token = GetToken();
        }
        if (wp == NULL)
            break;
        if (token != ',') {
            SetError((char *) "invalid func param");
            return PPRESULT_ERROR;
        }
        wrtbuf->Put(',');
    }

    wrtbuf->PutCR();
    return PPRESULT_WROTE_LINE;
}

/// #struct解析
///
ppresult_t CToken::PP_Struct(void) {
    char *word = (char *) s3;
    int id;
    int res;
    int glmode = 0;
    char keyword[256];
    char tagname[256];
    char strtmp[0x4000];

    if (GetToken() != TK_OBJ) {
        sprintf(strtmp, "invalid symbol [%s]", word);
        SetError(strtmp);
        return PPRESULT_ERROR;
    }

    strcase(word);
    if (tstrcmp(word, "global")) {        // global macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad global syntax");
            return PPRESULT_ERROR;
        }
        glmode = 1;
        strcase(word);
    }

    strcpy(tagname, word);
    if (glmode)
        FixModuleName(tagname);
    else
        AddModuleName(tagname);
    res = lb->Search(tagname);
    if (res != -1) {
        SetErrorSymbolOverdefined(tagname, res);
        return PPRESULT_ERROR;
    }
    id = lb->Regist(tagname, LAB_TYPE_PPDLLFUNC, 0);
    if (glmode)
        lb->SetEternal(id);

    wrtbuf->PutStrf((char *) "#struct %s ", tagname);

    int token;
    while (1) {
        token = GetToken();
        if (wp == NULL)
            break;
        if (token != TK_OBJ) {
            SetError((char *) "invalid struct param");
            return PPRESULT_ERROR;
        }
        wrtbuf->PutStr(word);
        wrtbuf->Put(' ');

        token = GetToken();
        if (token != TK_OBJ) {
            SetError((char *) "invalid struct param");
            return PPRESULT_ERROR;
        }

        sprintf(keyword, "%s_%s", tagname, word);
        if (glmode)
            FixModuleName(keyword);
        else
            AddModuleName(keyword);
        res = lb->Search(keyword);
        if (res != -1) {
            SetErrorSymbolOverdefined(keyword, res);
            return PPRESULT_ERROR;
        }
        id = lb->Regist(keyword, LAB_TYPE_PPDLLFUNC, 0);
        if (glmode)
            lb->SetEternal(id);
        wrtbuf->PutStr(keyword);

        token = GetToken();
        if (wp == NULL)
            break;
        if (token != ',') {
            SetError((char *) "invalid struct param");
            return PPRESULT_ERROR;
        }
        wrtbuf->Put(',');
    }
    wrtbuf->PutCR();
    return PPRESULT_WROTE_LINE;
}

/// #func解析
///
ppresult_t CToken::PP_Func(char *name) {
    int id;
    int glmode;
    char *word = (char *) s3;
    int token = GetToken();

    if (token != TK_OBJ) {
        SetError((char *) "invalid func name");
        return PPRESULT_ERROR;
    }

    glmode = 0;
    strcase(word);
    if (tstrcmp(word, "global")) {        // global macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad global syntax");
            return PPRESULT_ERROR;
        }
        glmode = 1;
    }

    if (glmode)
        FixModuleName(word);
    else
        AddModuleName(word);

    token = lb->Search(word);
    if (token != -1) {
        SetErrorSymbolOverdefined(word, token);
        return PPRESULT_ERROR;
    }
    id = lb->Regist(word, LAB_TYPE_PPDLLFUNC, 0);
    if (glmode)
        lb->SetEternal(id);

    wrtbuf->PutStrf((char *) "#%s %s%s", name, word, (char *) wp);
    wrtbuf->PutCR();

    return PPRESULT_WROTE_LINE;
}

/// #cmd解析
///
ppresult_t CToken::PP_Cmd(char *name) {
    int id;
    char *word = (char *) s3;
    int token = GetToken();

    if (token != TK_OBJ) {
        SetError((char *) "invalid func name");
        return PPRESULT_ERROR;
    }
    token = lb->Search(word);
    if (token != -1) {
        SetErrorSymbolOverdefined(word, token);
        return PPRESULT_ERROR;
    }

    id = lb->Regist(word, LAB_TYPE_PPINTMAC, 0); // 内部マクロとして定義
    strcat(word, "@hsp");
    lb->SetData(id, word);
    lb->SetEternal(id);

    wrtbuf->PutStrf((char *) "#%s %s%s", name, word, (char *) wp);
    wrtbuf->PutCR();

    return PPRESULT_WROTE_LINE;
}

/// #usecom解析
///
ppresult_t CToken::PP_Usecom(void) {
    int id;
    int glmode;
    char *word = (char *) s3;
    int token = GetToken();

    if (token != TK_OBJ) {
        SetError((char *) "invalid COM symbol name");
        return PPRESULT_ERROR;
    }

    glmode = 0;
    strcase(word);
    if (tstrcmp(word, "global")) { // global macro
        if (GetToken() != TK_OBJ) {
            SetError((char *) "bad global syntax");
            return PPRESULT_ERROR;
        }
        glmode = 1;
    }

    token = lb->Search(word);
    if (token != -1) {
        SetErrorSymbolOverdefined(word, token);
        return PPRESULT_ERROR;
    }
    if (glmode)
        FixModuleName(word);
    else
        AddModuleName(word);
    id = lb->Regist(word, LAB_TYPE_COMVAR, 0);
    if (glmode)
        lb->SetEternal(id);

    wrtbuf->PutStrf((char *) "#usecom %s%s", word, (char *) wp);
    wrtbuf->PutCR();
    return PPRESULT_WROTE_LINE;
}

/// #module解析
///
ppresult_t CToken::PP_Module(void) {
    int res;
    int id;
    int fl = 0;
    char *word = (char *) s3;
    char tagname[MODNAME_MAX + 1];
    int token = GetToken();

    if ((token == TK_OBJ) || (token == TK_STRING))
        fl = 1;
    if (token == TK_NONE) {
        sprintf(word, "M%d", modgc);
        modgc++;
        fl = 1;
    }
    if (fl == 0) {
        SetError((char *) "invalid module name");
        return PPRESULT_ERROR;
    }
    if (!IsGlobalMode()) {
        SetError((char *) "not in global mode");
        return PPRESULT_ERROR;
    }
    if (CheckModuleName(word)) {
        SetError((char *) "bad module name");
        return PPRESULT_ERROR;
    }
    sprintf(tagname, "%.*s", MODNAME_MAX, word);
    res = lb->Search(tagname);
    if (res != -1) {
        SetErrorSymbolOverdefined(tagname, res);
        return PPRESULT_ERROR;
    }
    id = lb->Regist(tagname, LAB_TYPE_PPDLLFUNC, 0);
    lb->SetEternal(id);
    SetModuleName(tagname);

    wrtbuf->PutStrf((char *) "#module %s", tagname);
    wrtbuf->PutCR();
    wrtbuf->PutStrf((char *) "goto@hsp *_%s_exit", tagname);
    wrtbuf->PutCR();

    if (PeekToken() != TK_NONE) {
        wrtbuf->PutStrf((char *) "#struct %s ", tagname);
        while (1) {
            token = GetToken();
            if (token != TK_OBJ) {
                SetError((char *) "invalid module param");
                return PPRESULT_ERROR;
            }
            AddModuleName(word);
            res = lb->Search(word);
            if (res != -1) {
                SetErrorSymbolOverdefined(word, res);
                return PPRESULT_ERROR;
            }
            id = lb->Regist(word, LAB_TYPE_PPDLLFUNC, 0);
            wrtbuf->PutStr((char *) "var ");
            wrtbuf->PutStr(word);

            token = GetToken();
            if (wp == NULL)
                break;
            if (token != ',') {
                SetError((char *) "invalid module param");
                return PPRESULT_ERROR;
            }
            wrtbuf->Put(',');
        }
        wrtbuf->PutCR();
    }
    return PPRESULT_WROTE_LINES;
}

/// #global解析
///
ppresult_t CToken::PP_Global(void) {
    if (IsGlobalMode()) {
#ifdef JPNMSG
        SetError((char *) "#module と対応していない #global があります");
#else
        SetError("already in global mode");
#endif
        return PPRESULT_ERROR;
    }
    wrtbuf->PutStrf((char *) "*_%s_exit", GetModuleName());
    wrtbuf->PutCR();
    wrtbuf->PutStr((char *) "#global");
    wrtbuf->PutCR();
    SetModuleName((char *) "");
    return PPRESULT_WROTE_LINES;
}

/// #aht解析
///
ppresult_t CToken::PP_Aht(void) {
    char tmp[512];
    if (ahtmodel == NULL)
        return PPRESULT_SUCCESS;
    if (ahtbuf != NULL)
        return PPRESULT_SUCCESS; // AHT出力時は無視する

    int token = GetToken();
    if (token != TK_OBJ) {
        SetError((char *) "invalid AHT option name");
        return PPRESULT_ERROR;
    }
    strcpy2(tmp, (char *) s3, 512);

    token = GetToken();
    if ((token != TK_STRING) && (token != TK_NUM)) {
        SetError((char *) "invalid AHT option value");
        return PPRESULT_ERROR;
    }
//    ahtmodel->SetAHTOption(tmp, (char *)s3);
    return PPRESULT_SUCCESS;
}

/// #ahtout解析
///
ppresult_t CToken::PP_Ahtout(void) {
    if (ahtmodel == NULL)
        return PPRESULT_SUCCESS;
    if (ahtbuf == NULL)
        return PPRESULT_SUCCESS;
    if (wp == NULL)
        return PPRESULT_SUCCESS;
    ahtbuf->PutStr((char *) wp);
    ahtbuf->PutCR();
    return PPRESULT_SUCCESS;
}

/// #ahtmes解析
///
ppresult_t CToken::PP_Ahtmes(void) {
    int addprm = 0;

    if (ahtmodel == NULL)
        return PPRESULT_SUCCESS;
    if (ahtbuf == NULL)
        return PPRESULT_SUCCESS;
    if (wp == NULL)
        return PPRESULT_SUCCESS;

    int token;
    while (1) {
        if (wp == NULL)
            break;
        token = GetToken();
        if (token == TK_NONE)
            break;
        if ((token != TK_OBJ) && (token != TK_NUM) && (token != TK_STRING)) {
            SetError((char *) "illegal ahtmes parameter");
            return PPRESULT_ERROR;
        }
        ahtbuf->PutStr((char *) s3);
        if (wp == NULL) {
            addprm = 0;
            break;
        }

        token = GetToken();
        if (token != '+') {
            SetError((char *) "invalid ahtmes format");
            return PPRESULT_ERROR;
        }
        addprm++;
    }
    if (addprm == 0)
        ahtbuf->PutCR();
    return PPRESULT_SUCCESS;
}

/// #pack,#epack解析
///
/// mode:0=normal/1=encrypt
///
ppresult_t CToken::PP_Pack(int mode) {
    int token;
    if (packbuf != NULL) {
        token = GetToken();
        if (token != TK_STRING) {
            SetError((char *) "invalid pack name");
            return PPRESULT_ERROR;
        }
        AddPackfile((char *) s3, mode);
    }
    return PPRESULT_SUCCESS;
}

/// #packopt解析
///
ppresult_t CToken::PP_PackOpt(void) {
    int token;
    char tmp[1024];
    char optname[1024];

    if (packbuf != NULL) {
        token = GetToken();
        if (token != TK_OBJ) {
            SetError((char *) "illegal option name");
            return PPRESULT_ERROR;
        }
        strncpy(optname, (char *) s3, 128);
        token = GetToken();
        if ((token != TK_OBJ) && (token != TK_NUM) && (token != TK_STRING)) {
            SetError((char *) "illegal option parameter");
            return PPRESULT_ERROR;
        }
        sprintf(tmp, ";!%s=%s", optname, (char *) s3);
        AddPackfile(tmp, 2);
    }
    return PPRESULT_SUCCESS;
}

/// #cmpopt解析
///
ppresult_t CToken::PP_CmpOpt(void) {
    char optname[1024];
    int token = GetToken();

    if (token != TK_OBJ) {
        SetError((char *) "illegal option name");
        return PPRESULT_ERROR;
    }
    strcase2((char *) s3, optname);

    token = GetToken();
    if (token != TK_NUM) {
        SetError((char *) "illegal option parameter");
        return PPRESULT_ERROR;
    }

    token = 0;
    if (tstrcmp(optname, "ppout")) { // preprocessor out sw
        token = CMPMODE_PPOUT;
    }
    if (tstrcmp(optname, "optcode")) { // code optimization sw
        token = CMPMODE_OPTCODE;
    }
    if (tstrcmp(optname, "case")) { // case sensitive sw
        token = CMPMODE_CASE;
    }
    if (tstrcmp(optname, "optinfo")) { // optimization info sw
        token = CMPMODE_OPTINFO;
    }
    if (tstrcmp(optname, "varname")) { // VAR name out sw
        token = CMPMODE_PUTVARS;
    }
    if (tstrcmp(optname, "varinit")) { // VAR initalize check
        token = CMPMODE_VARINIT;
    }
    if (tstrcmp(optname, "optprm")) { // parameter optimization sw
        token = CMPMODE_OPTPRM;
    }
    if (tstrcmp(optname, "skipjpspc")) { // skip Japanese Space Code sw
        token = CMPMODE_SKIPJPSPC;
    }

    if (token == 0) {
        SetError((char *) "illegal option name");
        return PPRESULT_ERROR;
    }

    if (val) {
        hed_cmpmode |= token;
    } else {
        hed_cmpmode &= ~token;
    }

    return PPRESULT_SUCCESS;
}

/// #runtime解析
///
ppresult_t CToken::PP_RuntimeOpt(void) {
    char tmp[1024];
    int token = GetToken();

    if (token != TK_STRING) {
        SetError((char *) "illegal runtime name");
        return PPRESULT_ERROR;
    }
    strncpy(hed_runtime, (char *) s3, sizeof hed_runtime);
    hed_runtime[sizeof hed_runtime - 1] = '\0';

    if (packbuf != NULL) {
        sprintf(tmp, ";!runtime=%s.hrt", hed_runtime);
        AddPackfile(tmp, 2);
    }

    hed_option |= HEDINFO_RUNTIME;
    return PPRESULT_SUCCESS;
}

/// #bootopt解析
///
ppresult_t CToken::PP_BootOpt(void) {
    char optname[1024];
    int token = GetToken();
    if (token != TK_OBJ) {
        SetError((char *) "illegal option name");
        return PPRESULT_ERROR;
    }
    strcase2((char *) s3, optname);

    token = GetToken();
    if (token != TK_NUM) {
        SetError((char *) "illegal option parameter");
        return PPRESULT_ERROR;
    }

    token = 0;
    if (tstrcmp(optname, "notimer")) {            // No MMTimer sw
        token = HEDINFO_NOMMTIMER;
        hed_autoopt_timer = -1;
    }
    if (tstrcmp(optname, "nogdip")) {            // No GDI+ sw
        token = HEDINFO_NOGDIP;
    }
    if (tstrcmp(optname, "float32")) {            // float32 sw
        token = HEDINFO_FLOAT32;
    }
    if (tstrcmp(optname, "orgrnd")) {            // standard random sw
        token = HEDINFO_ORGRND;
    }

    if (token == 0) {
        SetError((char *) "illegal option name");
        return PPRESULT_ERROR;
    }

    if (val) {
        hed_option |= token;
    } else {
        hed_option &= ~token;
    }
    return PPRESULT_SUCCESS;
}

void CToken::PreprocessCommentCheck(char *str) {
    int qmode = 0;
    unsigned char *vs = (unsigned char *) str;
    unsigned char cur_char;
    while (1) {
        cur_char = *vs++;
        if (cur_char == 0)
            break;
        if (qmode == 0) {
            if ((cur_char == ';') && (*vs == ';')) {
                vs++;
                ahtkeyword = (char *) vs;
            }
        }
        if (cur_char == 0x22)
            qmode ^= 1;
        vs += SkipMultiByte(cur_char);          // 全角文字チェック
    }
}

/// プリプロセスの実行(マクロ展開なし)
///
ppresult_t CToken::PreprocessNM(char *str) {
    char *word = (char *) s3;
    int id;
    int type;
    ppresult_t res;
    char fixname[128];
    wp = (unsigned char *) str;

    if (ahtmodel != NULL) {
        PreprocessCommentCheck(str);
    }

    type = GetToken();
    if (type != TK_OBJ)
        return PPRESULT_UNKNOWN_DIRECTIVE;

    //		ソース生成コントロール
    //
    if (tstrcmp(word, "ifdef")) {        // generate control
        if (mulstr == LMODE_OFF) {
            res = PP_SwitchStart(0);
        } else {
            res = PPRESULT_ERROR;
            type = GetToken();
            if (type == TK_OBJ) {
                strcase2(word, fixname);
                AddModuleName(fixname);
                id = lb->SearchLocal(word, fixname);
                //id = lb->Search( word );
                res = PP_SwitchStart((id != -1));
            }
        }
        return res;
    }
    if (tstrcmp(word, "ifndef")) {        // generate control
        if (mulstr == LMODE_OFF) {
            res = PP_SwitchStart(0);
        } else {
            res = PPRESULT_ERROR;
            type = GetToken();
            if (type == TK_OBJ) {
                strcase2(word, fixname);
                AddModuleName(fixname);
                id = lb->SearchLocal(word, fixname);
                //id = lb->Search( word );
                res = PP_SwitchStart((id == -1));
            }
        }
        return res;
    }
    if (tstrcmp(word, "else")) {            // generate control
        return PP_SwitchReverse();
    }
    if (tstrcmp(word, "endif")) {        // generate control
        return PP_SwitchEnd();
    }

    //		これ以降は#off時に実行しません
    //
    if (mulstr == LMODE_OFF) {
        return PPRESULT_UNKNOWN_DIRECTIVE;
    }

    if (tstrcmp(word, "define")) {        // keyword define
        return PP_Define();
    }

    if (tstrcmp(word, "undef")) {        // keyword terminate
        if (GetToken() != TK_OBJ) {
            SetError((char *) "invalid symbol");
            return PPRESULT_ERROR;
        }

        strcase2(word, fixname);
        AddModuleName(fixname);
        id = lb->SearchLocal(word, fixname);

        //id = lb->Search( word );
        if (id >= 0) {
            lb->SetFlag(id, -1);
        }
        return PPRESULT_SUCCESS;
    }
    return PPRESULT_UNKNOWN_DIRECTIVE;
}

/// プリプロセスの実行
///
ppresult_t CToken::Preprocess(char *str) {
    char *word = (char *) s3;
    int a;
    ppresult_t res;
    CALCVAR cres;
    wp = (unsigned char *) str;
    int type = GetToken();

    if (type != TK_OBJ)
        return PPRESULT_SUCCESS;

    //		ソース生成コントロール
    //
    if (tstrcmp(word, "if")) {            // generate control
        if (mulstr == LMODE_OFF) {
            res = PP_SwitchStart(0);
        } else {
            res = PPRESULT_SUCCESS;
            if (Calc(cres) == 0) {
                a = (int) cres;
                res = PP_SwitchStart(a);
            } else res = PPRESULT_ERROR;
        }
        return res;
    }

    //		これ以降は#off時に実行しません
    //
    if (mulstr == LMODE_OFF) {
        return PPRESULT_SUCCESS;
    }

    //		コード生成コントロール
    //
    if (tstrcmp(word, "include")) {        // text include
        res = PP_Include(0);
        return res;
    }
    if (tstrcmp(word, "addition")) {        // text include
        res = PP_Include(1);
        return res;
    }
    if (tstrcmp(word, "const")) {        // constant define
        res = PP_Const();
        return res;
    }
    if (tstrcmp(word, "enum")) {            // constant enum define
        res = PP_Enum();
        return res;
    }
    if (tstrcmp(word, "module")) {        // module define
        res = PP_Module();
        return res;
    }
    if (tstrcmp(word, "global")) {        // module exit
        res = PP_Global();
        return res;
    }
    if (tstrcmp(word, "deffunc")) {        // module function
        res = PP_Deffunc(0);
        return res;
    }
    if (tstrcmp(word, "defcfunc")) {        // module function (1)
        res = PP_Defcfunc(0);
        return res;
    }
    if (tstrcmp(word, "modfunc")) {        // module function (2)
        res = PP_Deffunc(1);
        return res;
    }
    if (tstrcmp(word, "modcfunc")) {        // module function (2+)
        res = PP_Defcfunc(1);
        return res;
    }
    if (tstrcmp(word, "modinit")) {        // module function (3)
        res = PP_Deffunc(2);
        return res;
    }
    if (tstrcmp(word, "modterm")) {        // module function (4)
        res = PP_Deffunc(3);
        return res;
    }
    if (tstrcmp(word, "struct")) {        // struct define
        res = PP_Struct();
        return res;
    }
    if (tstrcmp(word, "func")) {            // DLL function
        res = PP_Func((char *) "func");
        return res;
    }
    if (tstrcmp(word, "cfunc")) {        // DLL function
        res = PP_Func((char *) "cfunc");
        return res;
    }
    if (tstrcmp(word, "cmd")) {            // DLL function (3.0)
        res = PP_Cmd((char *) "cmd");
        return res;
    }
    if (tstrcmp(word, "comfunc")) {        // COM Object function
        res = PP_Func((char *) "comfunc");
        return res;
    }
    if (tstrcmp(word, "aht")) {            // AHT definition
        res = PP_Aht();
        return res;
    }
    if (tstrcmp(word, "ahtout")) {        // AHT command line output
        res = PP_Ahtout();
        return res;
    }
    if (tstrcmp(word, "ahtmes")) {        // AHT command line output (mes)
        res = PP_Ahtmes();
        return res;
    }
    if (tstrcmp(word, "pack")) {            // packfile process
        res = PP_Pack(0);
        return res;
    }
    if (tstrcmp(word, "epack")) {        // packfile process
        res = PP_Pack(1);
        return res;
    }
    if (tstrcmp(word, "packopt")) {        // packfile process
        res = PP_PackOpt();
        return res;
    }
    if (tstrcmp(word, "runtime")) {        // runtime process
        res = PP_RuntimeOpt();
        return res;
    }
    if (tstrcmp(word, "bootopt")) {        // boot option process
        res = PP_BootOpt();
        return res;
    }
    if (tstrcmp(word, "cmpopt")) {        // compile option process
        res = PP_CmpOpt();
        return res;
    }
    if (tstrcmp(word, "usecom")) {        // COM definition
        res = PP_Usecom();
        return res;
    }

    //		登録キーワード以外はコンパイラに渡す
    //
    wrtbuf->Put((char) '#');
    wrtbuf->PutStr(linebuf);
    wrtbuf->PutCR();
    //wrtbuf->PutStr( (char *)s3 );
    return PPRESULT_WROTE_LINE;
}

/// マクロを展開
///
int CToken::ExpandTokens(char *vp, CMemBuf *buf, int *lineext, int is_preprocess_line) {
    *lineext = 0; // 1行->複数行にマクロ展開されたか?
    int macloop = 0; // マクロ展開無限ループチェック用カウンタ
    while (1) {
        if (mulstr == LMODE_OFF) { // １行無視
            if (wrtbuf != NULL)
                wrtbuf->PutCR(); // 行末CR/LFを追加
            break;
        }

        // {"〜"}の処理
        //
        if (mulstr == LMODE_STR) {
            wrtbuf = buf;
            vp = ExpandStrEx(vp);
            if (*vp != 0)
                continue;
        }

        // /*〜*/の処理
        //
        if (mulstr == LMODE_COMMENT) {
            vp = ExpandStrComment(vp, 0);
            if (*vp != 0)
                continue;
        }

        char *vp_bak = vp;
        int type;
        vp = ExpandToken(vp, &type, is_preprocess_line);
        if (type < 0) {
            return type;
        }
        if (type == TK_EOL) {
            (*lineext)++;
        }
        if (type == TK_EOF) {
            if (wrtbuf != NULL)
                wrtbuf->PutCR();    // 行末CR/LFを追加
            break;
        }
        if (vp_bak == vp) {
            macloop++;
            if (macloop > 999) {
                SetError((char *) "Endless macro loop");
                return -1;
            }
        }
    }
    return 0;
}

/// stringデータをmembufへ展開する
///
int CToken::ExpandLine(CMemBuf *buf, CMemBuf *src, char *refname) {
    char *p = src->GetBuffer();
    int pline = 1;
    enumgc = 0;
    mulstr = LMODE_ON;
    *errtmp = 0;
    unsigned char cur_char;

    while (1) {
        RegistExtMacro((char *) "__line__", pline); // 行番号マクロを更新
        while (1) {
            cur_char = *(unsigned char *) p;
            if (cur_char == ' ' || cur_char == '\t') {
                p++;
                continue;
            }
            break;
        }

        if (*p == 0) // 終了(EOF)
            break;
        ahtkeyword = NULL; // AHTキーワードをリセットする

        int is_preprocess_line = *p == '#' && mulstr != LMODE_STR && mulstr != LMODE_COMMENT;

        // 行データをlinebufに展開
        int mline;
        if (is_preprocess_line) {
            p = SendLineBufPP(p + 1, &mline); // 行末までを取り出す('\'継続)
            wrtbuf = NULL;
        } else {
            p = SendLineBuf(p); // 行末までを取り出す
            mline = 0;
            wrtbuf = buf;
        }

        // マクロ展開前に処理されるプリプロセッサ
        if (is_preprocess_line) {
            ppresult_t res = PreprocessNM(linebuf);
            if (res == PPRESULT_ERROR) {
                LineError(errtmp, pline, refname);
                return 1;
            }
            if (res == PPRESULT_SUCCESS) { // プリプロセッサで処理された時
                mline++;
                pline += mline;
                for (int i = 0; i < mline; i++) {
                    buf->PutCR();
                }
                continue;
            }
            assert(res == PPRESULT_UNKNOWN_DIRECTIVE);
        }

        // マクロを展開
        int lineext; // 1行->複数行にマクロ展開されたか?
        int res = ExpandTokens(linebuf, buf, &lineext, is_preprocess_line);
        if (res) {
            LineError(errtmp, pline, refname);
            return res;
        }

        // プリプロセッサ処理
        if (is_preprocess_line) {
            wrtbuf = buf;
            ppresult_t res = Preprocess(linebuf);
            if (res == PPRESULT_INCLUDED) { // include後の処理
                pline += 1 + mline;

                char *fname_literal = to_hsp_string_literal(refname);
                RegistExtMacro((char *) "__file__", fname_literal); // ファイル名マクロを更新

                wrtbuf = buf;
                wrtbuf->PutStrf((char *) "##%d %s\r\n", pline - 1, fname_literal);
                free(fname_literal);
                continue;
            }
            if (res == PPRESULT_WROTE_LINES) { // プリプロセスで行が増えた後の処理
                pline += mline;
                wrtbuf->PutStrf((char *) "##%d\r\n", pline);
                pline++;
                continue;
            }
            if (res == PPRESULT_ERROR) {
                LineError(errtmp, pline, refname);
                return 1;
            }
            pline += 1 + mline;
            if (res != PPRESULT_WROTE_LINE)
                mline++;
            for (int i = 0; i < mline; i++) {
                buf->PutCR();
            }
            assert(res == PPRESULT_SUCCESS || res == PPRESULT_WROTE_LINE);
            continue;
        }

        // マクロ展開後に行数が変わった場合の処理
        pline += 1 + mline;
        if (lineext != mline) {
            wrtbuf->PutStrf((char *) "##%d\r\n", pline);
        }
    }
    return 0;
}

/// ソースファイルをmembufへ展開する
///
int CToken::ExpandFile(CMemBuf *buf, char *fname, char *refname) {
    int res;
    char cname[HSP_MAX_PATH];
    char purename[HSP_MAX_PATH];
    char foldername[HSP_MAX_PATH];
    char refname_copy[HSP_MAX_PATH];
    CMemBuf fbuf;

    getpath(fname, purename, 8);
    getpath(fname, foldername, 32);
    if (*foldername != 0) {
        strcpy(search_path, foldername);
    }

    //-------
    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];

    //#includeのsearchパスを設定する
    NSString *ns_search_path;
    //if (global.isStartAxInResource) { //リソース内にstart.axがある場合
    //    path = [NSBundle mainBundle].resourcePath; //リソースディレクトリ
    //    path = [path stringByAppendingString:@"/"];
    //    path = [path stringByAppendingString:filename];
    //}
    //else
    if (![[global.currentPaths objectAtIndex:global.runtimeAccessNumber] isEqual:@""]) { //ソースコードのあるディレクトリ
        ns_search_path = [global.currentPaths objectAtIndex:global.runtimeAccessNumber];
    } else { //hsptmp
        ns_search_path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp"];
    }
    ns_search_path = [ns_search_path stringByAppendingString:@"/"];

    //パスに%記号が入っていたらエラーにする
    for (int n = 0; n < ns_search_path.length; n++) {
        //- (NSString*) charAt:(NSString*)str index:(int)index { //文字列の指定位置で指定された位置の文字を返す
        //    if (index>=str.length) {
        //        return @"";
        //    }
        //    if (index<0) return @"";
        //    return ;
        //}
        //printf("%hu",[ns_search_path characterAtIndex:n]);
        if ([[ns_search_path substringWithRange:NSMakeRange(n, 1)] isEqual:@"%"]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"コンパイルエラー"];
            NSString *infoText = @"ソースコードのパスに非ASCII文字が含まれています。処理を中断します。\n>> ";
            ns_search_path = [ns_search_path stringByRemovingPercentEncoding];
            infoText = [infoText stringByAppendingString:ns_search_path];
            [alert setInformativeText:infoText];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
            return 0;
        }
        //NSLog(@"%@",);
    }
    //ns_search_path = [ns_search_path stringByRemovingPercentEncoding]; //URLデコード
    //NSData *data = [ns_search_path dataUsingEncoding:NSUTF8StringEncoding];
    //NSUInteger len = [data length];
    //Byte* byteData = (Byte*)malloc(len+1);
    //memcpy(byteData,[data bytes],len);
    //byteData[len+1] = *(char *)"\0";

    const char *c_search_path = (char *) [ns_search_path UTF8String];
    int i = 0;
    for (; i < strlen(c_search_path) - 1; i++) {
        search_path[i] = c_search_path[i];
    }
    search_path[i] = *(char *) "/";
    i++;
    search_path[i] = *(char *) "\0";

    //NSString *filename =  [NSString stringWithCString:fname encoding:NSUTF8StringEncoding];
    //path = [path stringByAppendingString:filename];

    if (strcmp(common_path, "common/") == 0) {
        //#includeのcommonパスを設定する
        //NSLog(@"null");
        NSString *ns_common_path = @"";
        ns_common_path = [NSBundle mainBundle].resourcePath; //リソースディレクトリ
        ns_common_path = [ns_common_path stringByAppendingString:@"/"];
        char *c_common_path = (char *) [ns_common_path UTF8String];
        int i = 0;
        for (; i < strlen(c_common_path) - 1; i++) {
            common_path[i] = c_common_path[i];
        }
        common_path[i] = *(char *) "/";
        i++;
        common_path[i] = *(char *) "\0";
    }

    if (fbuf.PutFile(fname) < 0) {
        strcpy(cname, common_path);
        strcat(cname, purename);
        if (fbuf.PutFile(cname) < 0) {
            strcpy(cname, search_path);
            strcat(cname, purename);
            if (fbuf.PutFile(cname) < 0) {
                strcpy(cname, common_path);
                strcat(cname, search_path);
                strcat(cname, purename);
                if (fbuf.PutFile(cname) < 0) {
                    if (fileadd == 0) {
#ifdef JPNMSG
                        @autoreleasepool {
                            AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
                            global.logString = [global.logString stringByAppendingFormat:@"#スクリプトファイルが見つかりません [%s]\n", purename];
                        }
#else
                        Mesf( "#Source file not found.[%s]", purename );
#endif
                    }
                    return -1;
                }
            }
        }
    }

    fbuf.Put((char) 0);

    if (fileadd) {
        @autoreleasepool {
            AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
            global.logString = [global.logString stringByAppendingFormat:@"#Use file [%s]\n", purename];
        }
    }

    char *fname_literal = to_hsp_string_literal(refname);
    RegistExtMacro((char *) "__file__", fname_literal);            // ファイル名マクロを更新

    buf->PutStrf((char *) "##0 %s\r\n", fname_literal);
    free(fname_literal);

    strcpy2(refname_copy, refname, sizeof refname_copy);
    res = ExpandLine(buf, &fbuf, refname_copy);

    if (res == 0) {
        //		プリプロセス後チェック
        //
        res = [cwrap StackCheck:linebuf];
        //res = tstack->StackCheck(linebuf);
        if (res) {
#ifdef JPNMSG
            //Mesf( (char *)"#スタックが空になっていないマクロタグが%d個あります [%s]", res, refname_copy );
            @autoreleasepool {
                AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
                global.logString = [global.logString stringByAppendingFormat:@"#スタックが空になっていないマクロタグが%d個あります [%s]\n", res, refname_copy];
            }
#else
            Mesf( "#%d unresolved macro(s).[%s]", res, refname_copy );
#endif
            @autoreleasepool {
                AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
                global.logString = [global.logString stringByAppendingFormat:@"%s\n", linebuf];
            }
            //Mes( linebuf );
        }
    }

    if (res) {

#ifdef JPNMSG
        //Mes((char *)"#重大なエラーが検出されています");
        @autoreleasepool {
            AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
            global.logString = [global.logString stringByAppendingString:@"#重大なエラーが検出されています\n"];
        }
#else
        Mes( "#Fatal error reported." );
#endif
        return -2;
    }
    return 0;
}

/// Additionによるファイル追加モード設定(1=on/0=off)
///
int CToken::SetAdditionMode(int mode) {
    int i = fileadd;
    fileadd = mode;
    return i;
}

void CToken::SetCommonPath(char *path) {
    if (path == NULL) {
        common_path[0] = 0;
        return;
    }
    strcpy(common_path, path);
}

/// 後ろで定義された関数がある場合、それに書き換える
///
/// この関数では foo@modname を foo に書き換えるなどバッファサイズが小さくなる変更しか行わない
///
void CToken::FinishPreprocess(CMemBuf *buf) {
    int read_pos = 0;
    int write_pos = 0;
    char *p = buf->GetBuffer();

    size_t len = [cwrap vector_size:undefined_symbols];
    //size_t len = undefined_symbols.size();

    for (size_t i = 0; i < len; i++) {
        undefined_symbol_t sym = undefined_symbols[i];
        int pos = sym.pos;
        int len_include_modname = sym.len_include_modname;
        int len = sym.len;
        int id;
        memmove(p + write_pos, p + read_pos, pos - read_pos);
        write_pos += pos - read_pos;
        read_pos = pos;
        // @modname を消した名前の関数が存在したらそれに書き換え
        p[pos + len] = '\0';
        id = lb->Search(p + pos);
        if (id >= 0 && lb->GetType(id) == LAB_TYPE_PPMODFUNC) {
            memmove(p + write_pos, p + pos, len);
            write_pos += len;
            read_pos += len_include_modname;
        }
        p[pos + len] = '@';
    }
    memmove(p + write_pos, p + read_pos, buf->GetSize() - read_pos);
    buf->ReduceSize(buf->GetSize() - (read_pos - write_pos));
}

/// ラベル情報を登録
///
int CToken::LabelRegist(char **list, int mode) {
    if (mode) {
        return lb->RegistList(list, (char *) "@hsp");
    }
    return lb->RegistList(list, (char *) "");
}

/// ラベル情報を登録(マクロ)
///
int CToken::LabelRegist2(char **list) {
    return lb->RegistList2(list, (char *) "@hsp");
}

/// ラベル情報を登録(色分け用)
///
int CToken::LabelRegist3(char **list) {
    return lb->RegistList3(list);
}

/// マクロを外部から登録(path用)
///
int CToken::RegistExtMacroPath(char *keyword, char *str) {
    int id;
    int res;
    char path[1024];
    char mm[512];
    unsigned char *ptr = (unsigned char *) path;
    unsigned char *src = (unsigned char *) str;
    unsigned char cur_char;
    while (1) {
        cur_char = *src++;
        if (cur_char == 0)
            break;
        if (cur_char == 0x5c) { // '\'チェック
            *ptr++ = cur_char;
        }
        if (cur_char >= 129) { // 全角文字チェック
            if (cur_char <= 159) {
                *ptr++ = cur_char;
                cur_char = *src++;
            } else if (cur_char >= 224) {
                *ptr++ = cur_char;
                cur_char = *src++;
            }
        }
        *ptr++ = cur_char;
    }
    *ptr = 0;
    strcpy(mm, keyword);
    FixModuleName(mm);
    res = lb->Search(mm);
    if (res != -1) { // すでにある場合は上書き
        lb->SetData(res, path);
        return -1;
    }
    id = lb->Regist(mm, LAB_TYPE_PPMAC, 0); // データ定義
    lb->SetData(id, path);
    lb->SetEternal(id);
    return 0;
}

/// マクロを外部から登録
///
int CToken::RegistExtMacro(char *keyword, char *str) {
    int id;
    int res;
    char mm[512];
    strcpy(mm, keyword);
    FixModuleName(mm);
    res = lb->Search(mm);
    if (res != -1) { // すでにある場合は上書き
        lb->SetData(res, str);
        return -1;
    }
    id = lb->Regist(mm, LAB_TYPE_PPMAC, 0); // データ定義
    lb->SetData(id, str);
    lb->SetEternal(id);
    return 0;
}

/// マクロを外部から登録(数値)
///
int CToken::RegistExtMacro(char *keyword, int val) {
    int id;
    int res;
    char mm[512];
    strcpy(mm, keyword);
    FixModuleName(mm);
    res = lb->Search(mm);
    if (res != -1) { // すでにある場合は上書き
        lb->SetOpt(res, val);
        return -1;
    }
    id = lb->Regist(mm, LAB_TYPE_PPVAL, val); // データ定義
    lb->SetEternal(id);
    return 0;
}

/// 登録されているラベル情報をerrbufに展開
///
int CToken::LabelDump(CMemBuf *out, int option) {
    lb->DumpHSPLabel(linebuf, option, LINEBUF_MAX - 256);
    out->PutStr(linebuf);
    return 0;
}

/// モジュール名を設定
///
void CToken::SetModuleName(char *name) {
    if (*name == 0) {
        modname[0] = 0;
        return;
    }
    sprintf(modname, "@%.*s", MODNAME_MAX, name);
    strcase(modname + 1);
}

/// モジュール名を取得
///
char *CToken::GetModuleName(void) {
    if (*modname == 0)
        return modname;
    return modname + 1;
}

/// キーワードにモジュール名を付加(モジュール依存ラベル用)
///
void CToken::AddModuleName(char *str) {
    unsigned char cur_char;
    unsigned char *ptr = (unsigned char *) str;
    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char == '@') {
            cur_char = ptr[1];
            if (cur_char == 0)
                *ptr = 0;
            return;
        }
        if (cur_char >= 129)
            ptr++;
        ptr++;
    }
    if (*modname == 0)
        return;
    strcpy((char *) ptr, modname);
}

/// キーワードのモジュール名を正規化(モジュール非依存ラベル用)
///
void CToken::FixModuleName(char *str) {
    unsigned char cur_char;
    unsigned char *ptr = (unsigned char *) str;
    while (1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char == '@') {
            cur_char = ptr[1];
            if (cur_char == 0)
                *ptr = 0;
            return;
        }
        if (cur_char >= 129)
            ptr++;
        ptr++;
    }
}

/// モジュール内(0)か、グローバル(1)かを返す
///
int CToken::IsGlobalMode(void) {
    if (*modname == 0)
        return 1;
    return 0;
}

/// ラベルバッファサイズを得る
///
int CToken::GetLabelBufferSize(void) {
    return lb->GetSymbolSize();
}

/// 文字コード変換の初期化
///
/// size<0の場合はメモリを破棄
///
void CToken::InitSCNV(int size) {
    if (scnvbuf != NULL) {
        free(scnvbuf);
        scnvbuf = NULL;
    }
    if (size <= 0)
        return;
    scnvbuf = (char *) malloc(size);
    scnvsize = size;
}

/// 文字コード変換
///
char *CToken::ExecSCNV(char *srcbuf, int opt) {
    int size;
    if (scnvbuf == NULL)
        InitSCNV(SCNVBUF_DEFAULTSIZE);
    size = (int) strlen(srcbuf);
    switch (opt) {
        case SCNV_OPT_NONE:
            strcpy(scnvbuf, srcbuf);
            break;
        case SCNV_OPT_SJISUTF8:
            strcpy(scnvbuf, srcbuf);
            break;
        default:
            *scnvbuf = 0;
            break;
    }
    return scnvbuf;
}

/// 識別子の多重定義エラー
///
void CToken::SetErrorSymbolOverdefined(char *keyword, int label_id) {
    char strtmp[0x100];
#ifdef JPNMSG
    sprintf(strtmp, "定義済みの識別子は使用できません [%s]", keyword);
#else
    sprintf( strtmp,"symbol in use [%s]", keyword );
#endif
    SetError(strtmp);
}

/// SJISの全角1バイト目を判定する
///
/// 戻り値は以降に続くbyte数
///
int CToken::CheckByteSJIS(unsigned char c) {
    if (((c >= 0x81) && (c <= 0x9f)) || ((c >= 0xe0) && (c <= 0xfc)))
        return 1;
    return 0;
}

/// UTF8の全角1バイト目を判定する
///
/// 戻り値は以降に続くbyte数
///
int CToken::CheckByteUTF8(unsigned char c) {
    if (c <= 0x7f)
        return 0;
    if ((c >= 0xc2) && (c <= 0xdf))
        return 1;
    if ((c >= 0xe0) && (c <= 0xef))
        return 2;
    if ((c >= 0xf0) && (c <= 0xf7))
        return 3;
    if ((c >= 0xf8) && (c <= 0xfb))
        return 4;
    if ((c >= 0xfc) && (c <= 0xfd))
        return 5;
    return 0;
}

/// マルチバイトコードの2byte目以降をスキップする
///
/// 1バイト目のcharを渡すと、2byte目以降スキップするbyte数を返す
/// pp_utf8のフラグによってUTF-8とSJISを判断する
///
int CToken::SkipMultiByte(unsigned char byte) {
    if (pp_utf8)
        return CheckByteUTF8(byte);
    return CheckByteSJIS(byte);
}
