
//
// トークン解析（HSP3コード生成器）
//

#include "hsp3config.h"
#include "hsp3struct.h"
#include "label.h"
#include "membuf.h"
#include "token.h"
#include "../util/utility_errmsg.h"
#include "../util/utility.h"
#include "../util/utility_com.h"

//-------------------------------------------------------------
// ルーチン
//-------------------------------------------------------------

/// CalcCG_token
///
void CToken::CalcCG_token(void) {
    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype == TOKEN_NONE)
        ttype = val;
}

/// CalcCG_token_exprbeg
///
void CToken::CalcCG_token_exprbeg(void) {
    GetTokenCG(GETTOKEN_EXPRBEG);
    if (ttype == TOKEN_NONE)
        ttype = val;
}

/// GETTOKEN_EXPRBEG でトークンを取得し直す
///
/// GetTokenCG は 文字列リテラルや文字コードリテラルの場合、
/// cg_ptr のバッファを破壊するので常に取得し直すわけにはいかない
///
void CToken::CalcCG_token_exprbeg_redo(void) {
    if (ttype == TOKEN_NONE)
        ttype = val;
    if (ttype == '-' || ttype == '*') {
        cg_ptr = cg_ptr_bak;
        CalcCG_token_exprbeg();
    }
}

static int is_statement_end(int type) {
    return (type == TOKEN_SEPARATE) || (type == TOKEN_EOL) || (type == TOKEN_EOF);
}

/// 演算子を登録する
///
void CToken::CalcCG_regmark(int mark) {
    int op = 0;
    switch (mark) {
        case '+':
            op = CALCCODE_ADD;
            break;
        case '-':
            op = CALCCODE_SUB;
            break;
        case '*':
            op = CALCCODE_MUL;
            break;
        case '/':
            op = CALCCODE_DIV;
            break;
        case '=':
            op = CALCCODE_EQ;
            break;
        case '!':
            op = CALCCODE_NE;
            break;
        case '<':
            op = CALCCODE_LT;
            break;
        case '>':
            op = CALCCODE_GT;
            break;
        case 0x61: // '<='
            op = CALCCODE_LTEQ;
            break;
        case 0x62: // '>='
            op = CALCCODE_GTEQ;
            break;
        case '&':
            op = CALCCODE_AND;
            break;
        case '|':
            op = CALCCODE_OR;
            break;
        case '^':
            op = CALCCODE_XOR;
            break;
        case 0x5c: // '¥'
            op = CALCCODE_MOD;
            break;
        case 0x63: // '<<'
            op = CALCCODE_LR;
            break;
        case 0x64: // '>>'
            op = CALCCODE_RR;
            break;
        default:
            throw CGERROR_CALCEXP;
    }
    calccount++;
    PutCS(TOKEN_NONE, op, texflag);
}

void CToken::CalcCG_factor(void) {
    int id;
    cs_lasttype = ttype;
    switch (ttype) {
        case TOKEN_NUM:
            PutCS(TYPE_INUM, val, texflag);
            texflag = 0;
            CalcCG_token();
            calccount++;
            return;
        case TOKEN_DNUM:
            PutCS(TYPE_DNUM, val_d, texflag);
            texflag = 0;
            CalcCG_token();
            calccount++;
            return;
        case TOKEN_STRING:
            PutCS(TYPE_STRING, PutDS(cg_str), texflag);
            texflag = 0;
            CalcCG_token();
            calccount++;
            return;
        case TOKEN_LABEL:
            GenerateCodeLabel(cg_str, texflag);
            texflag = 0;
            CalcCG_token();
            calccount++;
            return;
        case TOKEN_OBJ:
            id = SetVarsFixed(cg_str, cg_defvarfix);
            if (lb->GetType(id) == TYPE_VAR) {
                if (lb->GetInitFlag(id) == LAB_INIT_NO) {
#ifdef JPNMSG
                    // Mesf( (char *)"#未初期化の変数があります(%s)", cg_str );
                    //@autoreleasepool {
                    //    AppDelegate *global =
                    //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
                    //    global.logString = [global.logString stringByAppendingFormat:@"#未初期化の変数があります(%s)\n", cg_str];
                    //}
#else
                    Mesf("#Uninitalized variable (%s).", cg_str);
#endif
                    if (hed_cmpmode & CMPMODE_VARINIT) {
                        throw CGERROR_VAR_NOINIT;
                    }
                    lb->SetInitFlag(id, LAB_INIT_DONE);
                }
            }
            GenerateCodeVAR(id, texflag);
            texflag = 0;
            if (ttype == TOKEN_NONE)
                ttype = val; // CalcCG_token()に合わせるため
            calccount++;
            return;
        case TOKEN_SEPARATE:
        case TOKEN_EOL:
        case TOKEN_EOF:
            return;
        default:
            break;
    }

    if (ttype != '(') {
        // Mesf("#Invalid%d",ttype);
        ttype = TOKEN_CALC_ERROR;
        return;
    }

    //		カッコの処理
    //
    CalcCG_token_exprbeg();
    CalcCG_start();
    if (ttype != ')') {
        ttype = TOKEN_CALC_ERROR;
        return;
    }

    CalcCG_token();
}

/// 単項演算子
///
void CToken::CalcCG_unary(void) {
    int op;
    if (ttype == '-') {
        op = ttype;
        CalcCG_token_exprbeg();
        if (is_statement_end(ttype))
            throw CGERROR_CALCEXP;
        CalcCG_unary();
        texflag = 0;
        PutCS(TYPE_INUM, -1, texflag);
        CalcCG_regmark('*');
    } else {
        CalcCG_factor();
    }
}

void CToken::CalcCG_muldiv(void) {
    int op;
    CalcCG_unary();
    while ((ttype == '*') || (ttype == '/') || (ttype == '\\')) {
        op = ttype;
        CalcCG_token_exprbeg();
        if (is_statement_end(ttype))
            throw CGERROR_CALCEXP;
        CalcCG_unary();
        CalcCG_regmark(op);
    }
}

void CToken::CalcCG_addsub(void) {
    int op;
    CalcCG_muldiv();
    while ((ttype == '+') || (ttype == '-')) {
        op = ttype;
        CalcCG_token_exprbeg();
        if (is_statement_end(ttype))
            throw CGERROR_CALCEXP;
        CalcCG_muldiv();
        CalcCG_regmark(op);
    }
}

void CToken::CalcCG_shift(void) {
    int op;
    CalcCG_addsub();
    while ((ttype == 0x63) || (ttype == 0x64)) {
        op = ttype;
        CalcCG_token_exprbeg();
        if (is_statement_end(ttype))
            throw CGERROR_CALCEXP;
        CalcCG_addsub();
        CalcCG_regmark(op);
    }
}

void CToken::CalcCG_compare(void) {
    int op;
    CalcCG_shift();
    while ((ttype == '<') || (ttype == '>') || (ttype == '=') || (ttype == '!') || (ttype == 0x61) || (ttype == 0x62)) {
        op = ttype;
        CalcCG_token_exprbeg();
        if (is_statement_end(ttype))
            throw CGERROR_CALCEXP;
        CalcCG_shift();
        CalcCG_regmark(op);
    }
}

void CToken::CalcCG_bool(void) {
    int op;
    CalcCG_compare();
    while ((ttype == '&') || (ttype == '|') || (ttype == '^')) {
        op = ttype;
        CalcCG_token_exprbeg();
        if (is_statement_end(ttype))
            throw CGERROR_CALCEXP;
        CalcCG_compare();
        CalcCG_regmark(op);
    }
}

/// entry point
void CToken::CalcCG_start(void) {
    CalcCG_bool();
}

/// パラメーターの式を評価する
///
/// 結果は逆ポーランドでコードを出力する
///
void CToken::CalcCG(int ex) {
    texflag = ex;
    cs_lastptr = cs_buf->GetSize();
    calccount = 0;
    CalcCG_token_exprbeg_redo();
    CalcCG_start();
    if (ttype == TOKEN_CALC_ERROR) {
        throw CGERROR_CALCEXP;
    }
}

//-----------------------------------------------------------------------------

/// 指定文字列をmembufへ展開する
///
/// 複数行対応 {"〜"}
///
char *CToken::PickLongStringCG(char *str) {
    char *psrc;
    char *ps;
    char *p = psrc = str;

    while (1) {
        p = PickStringCG2(p, &psrc);
        if (*psrc != 0)
            break;
        ps = GetLineCG();
        if (ps == NULL)
            throw CGERROR_MULTILINE_STR;
        psrc = ps;
        cg_orgline++;

        // 行の終端にある0を改行に置き換える
        p[0] = 13;
        p[1] = 10;
        p += 2;
    }
    if (*psrc != '}')
        throw CGERROR_MULTILINE_STR;

    if (cg_debug) {
        PutDI(254, 0, cg_orgline); // ラインだけをデバッグ情報として登録
    }

    psrc++;
    return psrc;
}

/// 指定文字列をスキップして終端コードを付加する
///
/// sep = 区切り文字
///
char *CToken::PickStringCG(char *str, int sep) {
    unsigned char *vs = (unsigned char *) str;
    unsigned char *pp = vs;
    unsigned char cur_char;

    while (1) {
        cur_char = *vs;

        if (cur_char == 0)
            break;
        if (cur_char == sep) {
            vs++;
            break;
        }
        if (cur_char == 0x5c) { // '¥'チェック
            vs++;
            cur_char = tolower(*vs);
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
        // 全角文字チェック＊
        // if (cur_char>=129) {
        //    if ((cur_char<=159)||(cur_char>=224)) {
        //        NSLog(@"A:%s",str);
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < skip; i++) {
                *pp++ = cur_char;
                vs++;
                cur_char = *vs;
            }
        }
        //        uint8 c = a1;
        //        //if (c >= 0 && c < 128) { return 1; }
        //        if (c >= 128 && c < 192) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 192 && c < 224) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 224 && c < 240) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 240 && c < 248) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 248 && c < 252) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 252 && c < 254) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 254 && c <= 255) { *pp++ = a1; vs++; a1=*vs; }
        vs++;
        *pp++ = cur_char;
    }
    *pp = 0;
    return (char *) vs;
}

/// 指定文字列をスキップして終端コードを付加する
///
/// sep = 区切り文字
///
char *CToken::PickStringCG2(char *str, char **strsrc) {
    unsigned char *vs = (unsigned char *) *strsrc;
    unsigned char *pp = (unsigned char *) str;
    unsigned char cur_char;

    while (1) {
        cur_char = *vs;

        if (cur_char == 0)
            break;
        if (cur_char == 0x22) {
            vs++;
            if (*vs == '}')
                break;
            *pp++ = cur_char;
            continue;
        }
        if (cur_char == 0x5c) { // '¥'チェック
            vs++;
            cur_char = tolower(*vs);
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
                case 0x22:
                    cur_char = 0x22;
                    break;
            }
        }
        // if (a1>=129) {					// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < skip; i++) {
                *pp++ = cur_char;
                vs++;
                cur_char = *vs;
            }
        }
        vs++;
        *pp++ = cur_char;
    }
    *pp = 0;
    *strsrc = (char *) vs;
    return (char *) pp;
}

char *CToken::GetTokenCG(int option) {
    cg_ptr_bak = cg_ptr;
    cg_ptr = GetTokenCG(cg_ptr, option);
    return cg_ptr;
}

/// 次のコード(１文字を返す)
///
/// 終端の場合は0を返す
///
int CToken::PickNextCodeCG(void) {
    unsigned char *vs = (unsigned char *) cg_ptr;
    unsigned char cur_char;

    if (vs == NULL)
        return 0;

    while (1) {
        cur_char = *vs;
        if ((cur_char != 32) && (cur_char != '\t')) { // space,tab以外か?
            break;
        }
        vs++;
    }
    return (int) cur_char;
}

/// stringデータのタイプと内容を返す
///
/// 次のptrを返す
/// ttypeにタイプを、val,val_d,cg_strに内容を書き込みます
///
char *CToken::GetTokenCG(char *str, int option) {
    unsigned char *vs = (unsigned char *) str;
    unsigned char cur_char;
    unsigned char next_char;
    int a, b, chk, labmode;

    if (vs == NULL) {
        ttype = TOKEN_EOF;
        return NULL; // already end
    }

    while (1) {
        cur_char = *vs;
        if ((cur_char != 32) && (cur_char != '\t')) { // space,tab以外か?
            break;
        }
        vs++;
    }

    if (cur_char == 0) { // end
        ttype = TOKEN_EOL;
        return (char *) vs;
        // return GetLineCG();
    }

    if (cur_char < 0x20) { // 無効なコード
        ttype = TOKEN_ERROR;
        throw CGERROR_UNKNOWN;
    }

    if (cur_char == 0x22) { // "〜"
        vs++;
        ttype = TOKEN_STRING;
        cg_str = (char *) vs;
        return PickStringCG((char *) vs, 0x22);
    }

    if (cur_char == '{') { // {"〜"}
        if (vs[1] == 0x22) {
            vs += 2;
            if (*vs == 0) {
                vs = (unsigned char *) GetLineCG();
                cg_orgline++;
            }
            ttype = TOKEN_STRING;
            cg_str = (char *) vs;
            return PickLongStringCG((char *) vs);
        }
    }

    if (cur_char == 0x27) { // '〜'
        char *p;
        vs++;
        cg_str = (char *) vs;
        p = PickStringCG((char *) vs, 0x27);
        ttype = TOKEN_NUM;
        val = ((unsigned char *) cg_str)[0];
        return p;
    }

    if ((cur_char == ':') || (cur_char == '{') || (cur_char == '}')) { // multi statement
        cg_str = (char *) s2;
        ttype = TOKEN_SEPARATE;
        cg_str[0] = cur_char;
        cg_str[1] = 0;
        return (char *) vs + 1;
    }

    if (cur_char == '0') {
        next_char = tolower(vs[1]);
        if (next_char == 'x') {
            vs++;
            cur_char = '$';
        } // when hex code (0x)
        if (next_char == 'b') {
            vs++;
            cur_char = '%';
        } // when bin code (0b)
    }

    if (cur_char == '$') { // when hex code ($)
        vs++;
        val = 0;
        cg_str = (char *) s2;
        a = 0;
        while (1) {
            cur_char = toupper(*vs);
            b = -1;
            if (cur_char == 0)
                break;
            if ((cur_char >= 0x30) && (cur_char <= 0x39))
                b = cur_char - 0x30;
            if ((cur_char >= 0x41) && (cur_char <= 0x46))
                b = cur_char - 55;
            if (cur_char == '_')
                b = -2;
            if (b == -1)
                break;
            if (b >= 0) {
                cg_str[a++] = (char) cur_char;
                val = (val << 4) + b;
            }
            vs++;
        }
        cg_str[a] = 0;
        ttype = TOKEN_NUM;
        return (char *) vs;
    }

    if (cur_char == '%') { // when bin code (%)
        vs++;
        val = 0;
        cg_str = (char *) s2;
        a = 0;
        while (1) {
            cur_char = *vs;
            b = -1;
            if (cur_char == 0)
                break;
            if ((cur_char >= 0x30) && (cur_char <= 0x31))
                b = cur_char - 0x30;
            if (cur_char == '_')
                b = -2;
            if (b == -1)
                break;
            if (b >= 0) {
                cg_str[a++] = (char) cur_char;
                val = (val << 1) + b;
            }
            vs++;
        }
        cg_str[a] = 0;
        ttype = TOKEN_NUM;
        return (char *) vs;
    }

    chk = 0;
    labmode = 0;
    if (cur_char < 0x30)
        chk++;
    if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
        chk++;
    if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
        chk++;
    if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
        chk++;

    if (option & (GETTOKEN_EXPRBEG | GETTOKEN_LABEL)) {
        if (cur_char == '*') { // ラベル
            next_char = vs[1];
            b = 0;
            if (next_char < 0x30)
                b++;
            if ((next_char >= 0x30) && (next_char <= 0x3f))
                b++;
            if ((next_char >= 0x5b) && (next_char <= 0x5e))
                b++;
            if ((next_char >= 0x7b) && (next_char <= 0x7f))
                b++;
            if (b == 0) {
                chk = 0;
                labmode = 1;
                vs++;
                cur_char = *vs;
            }
        }
    }

    int is_negative_number = 0;
    if (option & GETTOKEN_EXPRBEG && cur_char == '-') {
        is_negative_number = isdigit(vs[1]);
    }

    if (is_negative_number || isdigit(cur_char)) { // when 0-9 numerical
        a = 0;
        chk = 0;
        if (is_negative_number) {
            vs++;
        }
        while (1) {
            cur_char = *vs;
            if (option & GETTOKEN_NOFLOAT) {
                if ((cur_char < 0x30) || (cur_char > 0x39))
                    break;
            } else {
                if (cur_char == '.') {
                    chk++;
                    if (chk > 1) {
                        ttype = TOKEN_ERROR;
                        throw CGERROR_FLOATEXP;
                        return (char *) vs;
                    }
                } else {
                    if ((cur_char < 0x30) || (cur_char > 0x39))
                        break;
                }
            }
            s2[a++] = cur_char;
            vs++;
        }
        if ((cur_char == 'f') || (cur_char == 'd')) {
            chk = 1;
            vs++;
        }
        if (cur_char == 'e') { // 指数部を取り込む
            chk = 1;
            s2[a++] = 'e';
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

        switch (chk) {
            case 1:
                val_d = atof((char *) s2);
                if (is_negative_number) {
                    val_d = -val_d;
                }
                ttype = TOKEN_DNUM;
                break;
            default:
                val = atoi_allow_overflow((char *) s2);
                if (is_negative_number) {
                    val = -val;
                }
                ttype = TOKEN_NUM;
                break;
        }
        return (char *) vs;
    }

    if (chk) { // 記号
        vs++;
        next_char = *vs;
        switch (cur_char) {
            case '-':
                if (next_char == '>') {
                    vs++;
                    cur_char = 0x65;
                } // '->'
                break;
            case '!':
                if (next_char == '=')
                    vs++;
                break;
            case '<':
                if (next_char == '<') {
                    vs++;
                    cur_char = 0x63;
                } // '<<'
                if (next_char == '=') {
                    vs++;
                    cur_char = 0x61;
                } // '<='
                break;
            case '>':
                if (next_char == '>') {
                    vs++;
                    cur_char = 0x64;
                } // '>>'
                if (next_char == '=') {
                    vs++;
                    cur_char = 0x62;
                } // '>='
                break;
            case '=':
                if (next_char == '=') {
                    vs++;
                } // '=='
                break;
            case '|':
                if (next_char == '|') {
                    vs++;
                } // '||'
                break;
            case '&':
                if (next_char == '&') {
                    vs++;
                } // '&&'
                break;
        }
        ttype = TOKEN_NONE;
        val = (int) cur_char;
        return (char *) vs;
    }

    a = 0;
    while (1) { // シンボル取り出し
        cur_char = *vs;
        // if (a1>=129) {
        //全角文字チェック＊
        //    if ((a1<=159)||(a1>=224)) {
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < (skip + 1); i++) {
                //NSLog(@"B:%s", str);
                if (a < OBJNAME_MAX) {
                    s2[a++] = cur_char;
                    vs++;
                    cur_char = *vs;
                    // s2[a++] = a1; vs++;
                } else {
                    // vs+=2;
                    vs++;
                }
                // continue;
            }
            continue;
        }

        //        uint8 c = a1;
        //        //if (c >= 0 && c < 128) { return 1; }
        //        if (c >= 128 && c < 192) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 192 && c < 224) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 224 && c < 240) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 240 && c < 248) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 248 && c < 252) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 252 && c < 254) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 254 && c <= 255) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }

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

    //		シンボル
    //
    if (labmode) {
        ttype = TOKEN_LABEL;
    } else {
        ttype = TOKEN_OBJ;
    }
    cg_str = (char *) s2;
    return (char *) vs;
}

/// stringデータのシンボル内容を返す
///
char *CToken::GetSymbolCG(char *str) {
    unsigned char *vs = (unsigned char *) str;
    unsigned char cur_char;
    int a, chk, labmode;

    if (vs == NULL)
        return NULL; // already end

    while (1) {
        cur_char = *vs;
        if ((cur_char != 32) && (cur_char != '\t')) { // space,tab以外か?
            break;
        }
        vs++;
    }

    if (cur_char < 0x20) { // 無効なコード
        return NULL;
    }

    chk = 0;
    labmode = 0;
    if (cur_char < 0x30)
        chk++;
    if ((cur_char >= 0x3a) && (cur_char <= 0x3f))
        chk++;
    if ((cur_char >= 0x5b) && (cur_char <= 0x5e))
        chk++;
    if ((cur_char >= 0x7b) && (cur_char <= 0x7f))
        chk++;

    if (chk) { // 記号
        return NULL;
    }

    a = 0;
    while (1) { // シンボル取り出し
        cur_char = *vs;
        // if (a1>=129) {				// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        int skip = SkipMultiByte(cur_char); // 全角文字チェック
        if (skip) {
            for (int i = 0; i < (skip + 1); i++) {
                if (a < OBJNAME_MAX) {
                    s2[a++] = cur_char;
                    vs++;
                    cur_char = *vs;
                    // s2[a++] = a1; vs++;
                } else {
                    // vs+=2;
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
    return (char *) s2;
}

//-----------------------------------------------------------------------------

/// HSP3Codeを展開する(パラメーター)
///
void CToken::GenerateCodePRM(void) {
    int ex = 0;
    while (1) {
        if (ttype == TOKEN_NONE) {
            if (val == ',') { // 先頭が','の場合は省略
                if (ex & EXFLG_2)
                    PutCS(TYPE_MARK, '?', EXFLG_2);
                GetTokenCG(GETTOKEN_DEFAULT);
                ex |= EXFLG_2;
                continue;
            }
        }

        CalcCG(ex); // 式の評価
        // Mesf( "#count %d", calccount );

        if (hed_cmpmode & CMPMODE_OPTPRM) {
            if (calccount == 1) { // パラメーターが単一項目の時
                switch (cs_lasttype) {
                    case TOKEN_NUM:
                    case TOKEN_DNUM:
                    case TOKEN_STRING: {
                        unsigned short *cstmp;
                        cstmp = (unsigned short *) (cs_buf->GetBuffer() + cs_lastptr);
                        *cstmp |= EXFLG_0; // 単一項目フラグを立てる
                        break;
                    }
                    default:
                        break;
                }
            }
        }

        if (ttype >= TOKEN_SEPARATE)
            break;
        if (ttype != ',') {
            // NSLog(@"%d",ttype);
            //
            //エラー箇所
            throw CGERROR_CALCEXP;
        }
        GetTokenCG(GETTOKEN_DEFAULT);
        ex |= EXFLG_2;

        if (ttype >= TOKEN_SEPARATE) {
            PutCS(TYPE_MARK, '?', EXFLG_2);
            break;
        }
    }
}

/// HSP3Codeを展開する(カッコ内のパラメーター)
///
/// 戻り値 : exflg
///
int CToken::GenerateCodePRMF(void) {
    int ex = 0;
    while (1) {
        if (ttype == TOKEN_NONE) {
            if (val == ')') { // ')'の場合は終了
                return ex;
            }
            if (val == ',') { // 先頭が','の場合は省略
                if (ex & EXFLG_2)
                    PutCS(TYPE_MARK, '?', EXFLG_2);
                GetTokenCG(GETTOKEN_DEFAULT);
                ex |= EXFLG_2;
                continue;
            }
        }

        CalcCG(ex);

        if (ttype >= TOKEN_SEPARATE)
            throw CGERROR_PRMEND;

        if (ttype == ')')
            break;
        if (ttype != ',') {
            throw CGERROR_CALCEXP;
        }
        GetTokenCG(GETTOKEN_DEFAULT);
        ex |= EXFLG_2;
    }
    return 0;
}

/// HSP3Codeを展開する('.'から始まる配列内のパラメーター)
///
void CToken::GenerateCodePRMF2(void) {
    int t;
    int id;
    int ex = 0;
    int tmp;
    while (1) {
        if (ttype >= TOKEN_SEPARATE)
            break;

        // Mesf( "(type:%d val:%d) line:%d", ttype, val, cg_orgline );

        switch (ttype) {
            case TOKEN_NONE:
                if (val == '(') {
                    GetTokenCG(GETTOKEN_DEFAULT);
                    CalcCG(ex);
                    if (ttype != ')')
                        throw CGERROR_CALCEXP;
                } else {
                    throw CGERROR_ARRAYEXP;
                }
                GetTokenCG(GETTOKEN_NOFLOAT);
                break;
            case TOKEN_NUM:
                PutCS(TYPE_INUM, val, ex);
                GetTokenCG(GETTOKEN_NOFLOAT);
                break;
            case TOKEN_OBJ:
                id = SetVarsFixed(cg_str, cg_defvarfix);
                t = lb->GetType(id);
                if ((t == TYPE_XLABEL) || (t == TYPE_LABEL))
                    throw CGERROR_LABELNAME;
                PutCSSymbol(id, ex);
                GetTokenCG(GETTOKEN_DEFAULT);

                if (ttype == TOKEN_NONE) {
                    if (val == '(') { // '(' 配列指定
                        GetTokenCG(GETTOKEN_DEFAULT);
                        PutCS(TYPE_MARK, '(', 0);
                        tmp = GenerateCodePRMF();
                        if (tmp)
                            PutCS(TYPE_MARK, '?', EXFLG_2);
                        PutCS(TYPE_MARK, ')', 0);
                        GetTokenCG(GETTOKEN_DEFAULT);
                    }
                }

                // GenerateCodeVAR( id, ex );
                break;
            default:
                throw CGERROR_ARRAYEXP;
        }

        if (ttype >= TOKEN_SEPARATE)
            return;
        if (ttype != TOKEN_NONE && ttype != '.')
            throw CGERROR_ARRAYEXP;
        if (val != '.')
            return;

        GetTokenCG(GETTOKEN_NOFLOAT);
        ex |= EXFLG_2;
    }
}

/// HSP3Codeを展開する('<'から始まる構造体参照元のパラメーター)
///
void CToken::GenerateCodePRMF3(void) {
    int id;
    int ex = 0;
    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_BAD_STRUCT_SOURCE;

    id = SetVarsFixed(cg_str, cg_defvarfix);
    GenerateCodeVAR(id, ex);

    if (ttype != TOKEN_NONE)
        throw CGERROR_PP_BAD_STRUCT_SOURCE;
    if (val != ']')
        throw CGERROR_PP_BAD_STRUCT_SOURCE;
    GetTokenCG(GETTOKEN_DEFAULT);
}

/// HSP3Codeを展開する(構造体/配列指定パラメーター)
///
int CToken::GenerateCodePRMF4(int t) {
    //	int t,id;
    int ex = 0;
    int tmp;

    if (ttype == TOKEN_NONE) {
        if (val == '.') {
            GetTokenCG(GETTOKEN_NOFLOAT);
            /*
             if ( ttype == TK_OBJ ) {
             id = lb->Search( cg_str );
             if ( id < 0 ) throw CGERROR_PP_BAD_STRUCT;
             t = lb->GetType(id);
             if ( t == TYPE_STRUCT ) {
             PutCS( t, lb->GetOpt(id), ex );
             GetTokenCG( GETTOKEN_DEFAULT );
             return GenerateCodePRMF4();
             }
             }
             */
            PutCS(TYPE_MARK, '(', 0); // '.' 配列指定
            GenerateCodePRMF2();
            PutCS(TYPE_MARK, ')', 0);
            return 1;
        }
        if (val == '(') { // '(' 配列指定
            GetTokenCG(GETTOKEN_DEFAULT);
            PutCS(TYPE_MARK, '(', 0);
            tmp = GenerateCodePRMF();
            if (tmp)
                PutCS(TYPE_MARK, '?', EXFLG_2);
            PutCS(TYPE_MARK, ')', 0);
            GetTokenCG(GETTOKEN_DEFAULT);
            return 1;
        }
        if (t == TYPE_STRUCT) {
            if (val == '[') { // '[' ソース指定
                PutCS(TYPE_MARK, '[', 0);
                GenerateCodePRMF3();
                return 0;
            }
        }
    }
    return 0;
}

/// HSP3Codeを展開する(->に続くメソッド名)
///
void CToken::GenerateCodeMethod(void) {
    int id;
    int ex = 0;

    if (ttype >= TOKEN_SEPARATE)
        throw CGERROR_SYNTAX;
    switch (ttype) {
        case TOKEN_NUM:
            PutCS(TYPE_INUM, val, ex);
            GetTokenCG(GETTOKEN_DEFAULT);
            break;
        case TOKEN_STRING:
            PutCS(TYPE_STRING, PutDS(cg_str), ex);
            GetTokenCG(GETTOKEN_DEFAULT);
            break;
        case TOKEN_OBJ:
            id = SetVarsFixed(cg_str, cg_defvarfix);
            GenerateCodeVAR(id, ex);
            break;
        default:
            throw CGERROR_SYNTAX;
    }

    ex |= EXFLG_2;
    while (1) {
        if (ttype == TOKEN_NONE) {
            if (val == ',') { // 先頭が','の場合は省略
                if (ex & EXFLG_2)
                    PutCS(TYPE_MARK, '?', EXFLG_2);
                GetTokenCG(GETTOKEN_DEFAULT);
                ex |= EXFLG_2;
                continue;
            }
        }

        CalcCG(ex); // 式の評価

        if (ttype >= TOKEN_SEPARATE)
            break;
        if (ttype != ',') {
            throw CGERROR_CALCEXP;
        }
        GetTokenCG(GETTOKEN_DEFAULT);
        ex |= EXFLG_2;
    }
}

#if 0
//        HSP3Codeを展開する(パラメーター)
//        (ソースの順番通りに展開する/実験用)
//
void CToken::GenerateCodePRMN(void) {
    int i,t,ex;
    ex = 0;
    while(1) {
        if (ttype >= TK_SEPARATE)
            break;
        switch(ttype) {
            case TK_NONE:
                if (val == ',') {
                    if ( ex & EXFLG_2 )
                        PutCS( TYPE_MARK, '?', ex );
                    ex |= EXFLG_2;
                } else {
                    PutCS( TYPE_MARK, val, ex );
                    ex = 0;
                }
                break;
            case TK_NUM:
                PutCS( TYPE_INUM, val, ex );
                ex = 0;
                break;
            case TK_STRING:
                PutCS( TYPE_STRING, PutDS( cg_str ), ex );
                ex = 0;
                break;
            case TK_DNUM:
                PutCS( TYPE_DNUM, val_d, ex );
                ex = 0;
                break;
            case TK_OBJ:
                i = lb->Search( cg_str );
                if ( i < 0 ) {
                    lb->Regist( cg_str, TYPE_VAR, cg_valcnt );
                    PutCS( TYPE_VAR, cg_valcnt, ex );
                    cg_valcnt++;
                } else {
                    t = lb->GetType( i );
                    if ( t == TYPE_XLABEL ) t = TYPE_LABEL;
                    PutCS( t, lb->GetOpt(i), ex );
                }
                ex = 0;
                break;
            case TK_LABEL:
                GenerateCodeLabel( cg_str, ex );
                ex = 0;
                break;
            default:
                throw CGERROR_SYNTAX;
        }
        
        GetTokenCG( GETTOKEN_DEFAULT );
    }
}
#endif

/// HSP3Codeを展開する(ラベル)
///
void CToken::GenerateCodeLabel(char *keyname, int ex) {
    int id, t, i;
    char lname[128];
    char *name = keyname;

    if (*name == '@') {
        switch (tolower(name[1])) {
            case 'f':
                i = cg_locallabel;
                break;
            case 'b':
                i = cg_locallabel - 1;
                break;
            default:
                throw CGERROR_LABELNAME;
        }
        sprintf(lname, "@l%d", i); // local label
        name = lname;
    }

    id = lb->Search(name);
    if (id < 0) { // 仮のラベル
        i = PutOT(-1);
        id = lb->Regist(name, TYPE_XLABEL, i);
    } else {
        t = lb->GetType(id);
        if ((t != TYPE_XLABEL) && (t != TYPE_LABEL))
            throw CGERROR_LABELEXIST;
    }
    PutCS(TYPE_LABEL, lb->GetOpt(id), ex);
}

/// HSP3Codeを展開する(変数ほか)
///
/// idはlabel ID
///
void CToken::GenerateCodeVAR(int id, int ex) {
    int t = lb->GetType(id);
    if ((t == TYPE_XLABEL) || (t == TYPE_LABEL))
        throw CGERROR_LABELNAME;

    PutCSSymbol(id, ex);
    GetTokenCG(GETTOKEN_DEFAULT);

    if (t == TYPE_SYSVAR)
        return;
    GenerateCodePRMF4(t); // 構造体/配列のチェック
}

/// set 'if'&'else' command additional code
///
/// mode/ 0=if 1=else
///
void CToken::CheckCMDIF_Set(int mode) {
    if (iflev >= CG_IFLEV_MAX)
        throw CGERROR_IF_OVERFLOW;

    iftype[iflev] = mode;
    ifptr[iflev] = GetCS();

    cs_buf->Put((short) 0);

    ifmode[iflev] = GetCS();
    ifscope[iflev] = CG_IFCHECK_LINE;
    ifterm[iflev] = 0;
    iflev++;
    // sprintf(tmp,"#IF BEGIN [L=%d(%d)]¥n",cline,iflev);
    // prt(tmp);
}

/// finish 'if'&'else' command
///
/// mode/ 0=if 1=else
///
void CToken::CheckCMDIF_Fin(int mode) {
    int a;
    short *p;
    if (iflev == 0)
        return;
    finag:
    iflev--;

    a = GetCS() - ifmode[iflev];
    if (mode) { // when 'else'
        a++;
    }

    if (ifterm[iflev] == 0) {
        ifterm[iflev] = 1;
        p = (short *) cs_buf->GetBuffer();
        p[ifptr[iflev]] = (short) a;
    }

    // sprintf(tmp,"#IF FINISH [L=%d(%d)] [skip%d]¥n",cline,iflev,a);
    // prt(tmp);

    // Mesf( "lev%d : %d: line%d", iflev, ifscope[iflev], cg_orgline );

    if (mode == 0) {
        if (iflev) {
            if (ifscope[iflev - 1] == CG_IFCHECK_LINE)
                goto finag;
        }
    }
}

/// 内蔵命令生成時チェック
///
void CToken::CheckInternalIF(int opt) {
    if (opt) { // 'else'+offset
        if (iflev == 0)
            throw CGERROR_ELSE_WO_IF;
        CheckCMDIF_Fin(1);
        CheckCMDIF_Set(1);
        return;
    }
    CheckCMDIF_Set(0); // normal if
}

/// 命令生成時チェック(命令+命令セット)
///
void CToken::CheckInternalListenerCMD(int opt) {
    int i, t, o;
    if (ttype != TOKEN_OBJ)
        return;
    i = lb->Search(cg_str);
    if (i < 0)
        return;
    t = lb->GetType(i);
    o = lb->GetOpt(i);
    if (t != TYPE_PROGCMD)
        return;
    if (o == 0x001) { // gosub
        PutCS(t, o & 0xffff, 0);
    }
    GetTokenCG(GETTOKEN_DEFAULT);
}

/// 内蔵プログラム命令生成時チェック
///
void CToken::CheckInternalProgCMD(int opt, int orgcs) {
    int i;
    switch (opt) {
        case 0x03: // repeat break
        case 0x06: // repeat continue
            if (replev == 0) {
                if (opt == 0x03)
                    throw CGERROR_BREAK_WO_REPEAT;
                throw CGERROR_CONT_WO_REPEAT;
            }
            i = repend[replev];
            if (i == -1) {
                i = PutOT(-1);
                repend[replev] = i;
            }
            PutCS(TOKEN_LABEL, i, 0);
            break;
        case 0x04: // repeat start
        case 0x0b: // (foreach)
            if (replev == CG_REPLEV_MAX)
                throw CGERROR_REPEAT_OVERFLOW;
            replev++;
            i = repend[replev];
            if (i == -1) {
                i = PutOT(-1);
                repend[replev] = i;
            }
            PutCS(TOKEN_LABEL, i, 0);
            if (opt == 0x0b) {
                PutCS(TYPE_PROGCMD, 0x0c, EXFLG_1);
                PutCS(TOKEN_LABEL, i, 0);
            }
            break;
        case 0x05: // repeat end
            if (replev == 0)
                throw CGERROR_LOOP_WO_REPEAT;
            i = repend[replev];
            if (i != -1) {
                SetOT(i, GetCS());
                repend[replev] = -1;
            }
            replev--;
            break;
        case 0x11: // stop
            i = PutOT(orgcs);
            PutCS(TYPE_PROGCMD, 0, EXFLG_1);
            PutCS(TYPE_LABEL, i, 0);
            break;
        case 0x19: // on
            GetTokenCG(GETTOKEN_DEFAULT);
            CalcCG(0); // 式の評価
            if (ttype != TOKEN_OBJ)
                throw CGERROR_SYNTAX;
            i = lb->Search(cg_str);
            if (i < 0)
                throw CGERROR_SYNTAX;
            PutCS(lb->GetType(i), lb->GetOpt(i), EXFLG_2);
            break;

        case 0x08: // await
            //	await命令の出現をカウントする(HEDINFO_NOMMTIMER自動設定のため)
            if (hed_autoopt_timer >= 0)
                hed_autoopt_timer++;
            break;

        case 0x09: // dim
        case 0x0a: // sdim
        case 0x0d: // dimtype
        case 0x0e: // dup
        case 0x0f: // dupptr
            GetTokenCG(GETTOKEN_DEFAULT);
            if (ttype == TOKEN_OBJ) {
                i = SetVarsFixed(cg_str, cg_defvarfix);
                //	変数の初期化フラグをセットする
                lb->SetInitFlag(i, LAB_INIT_DONE);
                // Mesf( "#initflag set [%s]", cg_str );
            }
            cg_ptr = cg_ptr_bak;
            break;
    }
}

/// HSP3Codeを展開する(コマンド)
///
/// idはlabel ID
///
void CToken::GenerateCodeCMD(int id) {
    int t = lb->GetType(id);
    int opt = lb->GetOpt(id);
    int orgcs = GetCS();

    PutCSSymbol(id, EXFLG_1);
    if (t == TYPE_PROGCMD)
        CheckInternalProgCMD(opt, orgcs);
    if (t == TYPE_CMPCMD)
        CheckInternalIF(opt);
    GetTokenCG(GETTOKEN_DEFAULT);

    if (opt & 0x10000)
        CheckInternalListenerCMD(opt);

    GenerateCodePRM();
    cg_lastcmd = CG_LASTCMD_CMD;
    cg_lasttype = t;
    cg_lastval = opt;
}

/// HSP3Codeを展開する(代入)
///
/// idはlabel ID
///
void CToken::GenerateCodeLET(int id) {
    int op;
    int t = lb->GetType(id);
    int mcall;

    if ((t == TYPE_XLABEL) || (t == TYPE_LABEL))
        throw CGERROR_LABELNAME;

    mcall = 0;
    GetTokenCG(GETTOKEN_DEFAULT);

    if ((ttype == TOKEN_NONE) && (val == 0x65)) { // ->が続いているか?
        PutCS(TYPE_PROGCMD, 0x1a, EXFLG_1); // 'mcall'コマンドに置き換える
        PutCS(t, lb->GetOpt(id), 0);        // 変数パラメーター
        GetTokenCG(GETTOKEN_DEFAULT);
        GenerateCodeMethod(); // パラメーター展開
        return;
    }

    PutCS(t, lb->GetOpt(id), EXFLG_1); // 通常の変数代入
    GenerateCodePRMF4(t);              // 構造体/配列のチェック

    if (ttype != TOKEN_NONE) {
        throw CGERROR_SYNTAX;
    }

    op = val;
    // PutCS( TK_NONE, op, 0 );
    texflag = 0;
    CalcCG_regmark(op);

    cg_lastcmd = CG_LASTCMD_LET;
    cg_lastval = op;

    GetTokenCG(GETTOKEN_DEFAULT);

    switch (op) {
        case '+': // '++'
        case '-': // '--'
            if (ttype >= TOKEN_SEPARATE)
                return;
            if (ttype == TOKEN_NONE) {
                if (val == op) {
                    GetTokenCG(GETTOKEN_DEFAULT);
                    if (ttype >= TOKEN_SEPARATE)
                        return;
                    throw CGERROR_SYNTAX;
                }
            }
            break;
        case '=': // 変数=prm
            GenerateCodePRM();
            return;
        default:
            break;
    }

    if ((ttype == TOKEN_NONE) && (val == '=')) {
        GetTokenCG(GETTOKEN_DEFAULT);
    }
    GenerateCodePRM();
}

/// HSP3Codeを展開する(regcmd)
///
void CToken::GenerateCodePP_regcmd(void) {
    char cmd[1024];
    char cmd2[1024];
    cg_pptype = cg_typecnt;
    cmd[0] = 0;

    GetTokenCG(GETTOKEN_DEFAULT);
    switch (ttype) {
        case TOKEN_STRING:
            strcpy(cmd, cg_str);
            GetTokenCG(GETTOKEN_DEFAULT);
            if (ttype != TOKEN_NONE)
                throw CGERROR_PP_NO_REGCMD;
            if (val != ',')
                throw CGERROR_PP_NO_REGCMD;
            GetTokenCG(GETTOKEN_DEFAULT);
            if (ttype != TOKEN_STRING)
                throw CGERROR_PP_NO_REGCMD;
            strcpy(cmd2, cg_str);

            GetTokenCG(GETTOKEN_DEFAULT);
            if (ttype == TOKEN_NONE) {
                if (val != ',')
                    throw CGERROR_PP_NO_REGCMD;
                GetTokenCG(GETTOKEN_DEFAULT);
                if (ttype != TOKEN_NUM)
                    throw CGERROR_PP_NO_REGCMD;
                cg_varhpi += val;
            }

            PutHPI(HPIDAT_FLAG_TYPEFUNC, 0, cmd2, cmd);
            cg_typecnt++;
            break;
        case TOKEN_NUM:
            PutHPI(HPIDAT_FLAG_SELFFUNC, 0, (char *) "", (char *) "");
            cg_pptype = val;
            break;
        default:
            throw CGERROR_PP_NO_REGCMD;
    }
    // Mesf( "#regcmd [%d][%s]",cg_pptype, cmd );
}

/// HSP3Codeを展開する(cmd)
///
void CToken::GenerateCodePP_cmd(void) {
    int id;
    char cmd[1024];
    if (cg_pptype < 0)
        throw CGERROR_PP_NO_REGCMD;
    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_NO_REGCMD;
    strcpy(cmd, cg_str);

    // if ( ttype != TK_NONE ) throw CGERROR_PP_NO_REGCMD;
    // if ( val != ',' ) throw CGERROR_PP_NO_REGCMD;
    // GetTokenCG( GETTOKEN_DEFAULT );

    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_NUM)
        throw CGERROR_PP_NO_REGCMD;
    id = val;

    lb->Regist(cmd, cg_pptype, id, cg_orgfile, cg_orgline);
    // Mesf( "#%x:%d [%s]",cg_pptype, id, cmd );
}

/// HSP3Codeを展開する(uselib)
///
void CToken::GenerateCodePP_uselib(void) {
    GetTokenCG(GETTOKEN_DEFAULT);
    cg_libname[0] = 0;
    if (ttype == TOKEN_STRING) {
        strncpy(cg_libname, cg_str, 1023);
    } else if (ttype < TOKEN_VOID) {
        throw CGERROR_PP_NAMEREQUIRED;
    }
    cg_libmode = CG_LIBMODE_DLLNEW;
}

/// HSP3Codeを展開する(usecom)
///
void CToken::GenerateCodePP_usecom(void) {
    int i, prmid;
    char libname[1024];
    char clsname[128];
    char iidname[128];

    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ) {
        throw CGERROR_PP_NAMEREQUIRED;
    }
    strncpy(libname, cg_str, 1023);

    i = lb->Search(libname);
    if (i >= 0) {
        CG_MesLabelDefinition(i);
        throw CGERROR_PP_ALREADY_USE_PARAM;
    }

    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_STRING)
        throw CGERROR_PP_BAD_IMPORT_IID;
    strncpy(iidname, cg_str, 127);

    *clsname = 0;
    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype < TOKEN_EOL) {
        if (ttype != TOKEN_STRING)
            throw CGERROR_PP_BAD_IMPORT_IID;
        strncpy(clsname, cg_str, 127);
    }

    cg_libindex = PutLIB(LIBDAT_FLAG_COMOBJ, iidname);
    if (cg_libindex < 0)
        throw CGERROR_PP_BAD_IMPORT_IID;

    SetLIBIID(cg_libindex, clsname);
    cg_libmode = CG_LIBMODE_COM;

    PutStructStart();
    prmid = PutStructEndDll((char *) "*", cg_libindex, STRUCTPRM_SUBID_COMOBJ, -1);
    lb->Regist(libname, TYPE_DLLCTRL, prmid | TYPE_OFFSET_COMOBJ, cg_orgfile,
            cg_orgline);

    // Mesf( "#usecom %s [%s][%s]",libname,clsname,iidname );
}

/// HSP3Codeを展開する(func)
///
void CToken::GenerateCodePP_func(int deftype) {
    int warn, i, t, subid, otflag;
    int ref;
    char fbase[1024];
    char fname[1024];

    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    strncpy(fbase, cg_str, 1023);

    ref = -1;
    if ((hed_cmpmode & CMPMODE_OPTCODE) &&
            (tmp_lb != NULL)) { // プリプロセス情報から最適化を行なう
        i = tmp_lb->Search(fbase);
        if (i >= 0) {
            ref = tmp_lb->GetReference(i);
            // Mesf( "#func %s [use%d]", fbase, ref );
        }
    }

    warn = 0;
    otflag = deftype;
    GetTokenCG(GETTOKEN_DEFAULT);

    if (ttype == TOKEN_OBJ) {
        if (strcmp(cg_str, "onexit") == 0) {
            otflag |= STRUCTDAT_OT_CLEANUP;
            GetTokenCG(GETTOKEN_DEFAULT);
        }
    }

    if (ref == 0 && (otflag & STRUCTDAT_OT_CLEANUP) == 0) {
        if (hed_cmpmode & CMPMODE_OPTINFO) {
#ifdef JPNMSG
            //@autoreleasepool {
            //    AppDelegate *global =
            //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
            //    global.logString = [global.logString
            //            stringByAppendingFormat:
            //                    @"#未使用の外部DLL関数の登録を削除しました %s\n", fbase];
            //}
            // Mesf( (char *)"#未使用の外部DLL関数の登録を削除しました %s", fbase );
#else
            Mesf("#Delete func %s", fbase);
#endif
        }
        return;
    }

    if (cg_libmode == CG_LIBMODE_DLLNEW) { // 初回はDLL名を登録する
        cg_libindex = PutLIB(LIBDAT_FLAG_DLL, cg_libname);
        cg_libmode = CG_LIBMODE_DLL;
    }
    if (cg_libmode != CG_LIBMODE_DLL)
        throw CGERROR_PP_NO_USELIB;

    switch (ttype) {
        case TOKEN_OBJ:
            sprintf(fname, "_%s@16", cg_str);
            warn = 1;
            break;
        case TOKEN_STRING:
            strncpy(fname, cg_str, 1023);
            break;
        case TOKEN_NONE:
            if (val == '*')
                break;
            throw CGERROR_PP_BAD_IMPORT_NAME;
        default:
            throw CGERROR_PP_BAD_IMPORT_NAME;
    }
    GetTokenCG(GETTOKEN_DEFAULT);

    PutStructStart();
    if (ttype == TOKEN_NUM) {
        int p1, p2, p3, p4, c1;
        warn = 1;
        p1 = p2 = p3 = p4 = MPTYPE_INUM;
        c1 = val & 3;
        if (c1 == 1)
            p1 = MPTYPE_PVARPTR;
        if (c1 == 2)
            p1 = MPTYPE_PBMSCR;
        if (c1 == 3) {
            if ((val & 0x80) == 0)
                throw CGERROR_PP_INCOMPATIBLE_IMPORT;
            p1 = MPTYPE_PPVAL;
        }
        if (val & 4)
            p2 = MPTYPE_LOCALSTRING;
        if (val & 0x10)
            p4 = MPTYPE_PTR_REFSTR;
        if (val & 0x20)
            p4 = MPTYPE_PTR_DPMINFO;
        if (val & 0x100)
            otflag |= STRUCTDAT_OT_CLEANUP;
        if (val & 0x200) {
            if ((val & 3) != 2)
                throw CGERROR_PP_INCOMPATIBLE_IMPORT;
            p1 = MPTYPE_PTR_EXINFO;
            p2 = p3 = MPTYPE_NULLPTR;
            if ((val & 0x30) == 0)
                p4 = MPTYPE_NULLPTR;
        }
        //		if ( val & 0x220 ) throw CGERROR_PP_INCOMPATIBLE_IMPORT;

        //		Mesf("#oldfunc %d,%d,%d,%d",p1,p2,p3,p4);

        PutStructParam(p1, STRUCTPRM_SUBID_STID);
        PutStructParam(p2, STRUCTPRM_SUBID_STID);
        PutStructParam(p3, STRUCTPRM_SUBID_STID);
        PutStructParam(p4, STRUCTPRM_SUBID_STID);

    } else {
        while (1) {
            if (ttype >= TOKEN_EOL)
                break;
            if (ttype != TOKEN_OBJ)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            t = GetParameterFuncTypeCG(cg_str);
            if (t == MPTYPE_NONE)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            PutStructParam(t, STRUCTPRM_SUBID_STID);
            GetTokenCG(GETTOKEN_DEFAULT);

            if (ttype >= TOKEN_EOL)
                break;
            if (ttype != TOKEN_NONE)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            if (val != ',')
                throw CGERROR_PP_WRONG_PARAM_NAME;
            GetTokenCG(GETTOKEN_DEFAULT);
        }
    }

    i = lb->Search(fbase);
    if (i >= 0) {
        CG_MesLabelDefinition(i);
        throw CGERROR_PP_ALREADY_USE_FUNCNAME;
    }
    subid = STRUCTPRM_SUBID_DLL;
    if (warn) {
        subid = STRUCTPRM_SUBID_OLDDLL;
        // Mesf( "Warning:Old func expression [%s]", fbase );
    }
    i = PutStructEndDll(fname, cg_libindex, subid, otflag);
    lb->Regist(fbase, TYPE_DLLFUNC, i, cg_orgfile, cg_orgline);

    // Mesf( "#func [%s][%s][%d]",fbase, fname, i );
}

/// HSP3Codeを展開する(comfunc)
///
void CToken::GenerateCodePP_comfunc(void) {
    int i, t, subid, imp_index;
    char fbase[1024];

    if (cg_libmode != CG_LIBMODE_COM)
        throw CGERROR_PP_NO_USECOM;

    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    strncpy(fbase, cg_str, 1023);

    GetTokenCG(GETTOKEN_DEFAULT);

    if (ttype != TOKEN_NUM) {
        throw CGERROR_PP_BAD_IMPORT_INDEX;
    }
    imp_index = val;

    GetTokenCG(GETTOKEN_DEFAULT);

    PutStructStart();
    PutStructParam(MPTYPE_IOBJECTVAR, STRUCTPRM_SUBID_STID);

    while (1) {
        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        t = GetParameterFuncTypeCG(cg_str);
        if (t == MPTYPE_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        PutStructParam(t, STRUCTPRM_SUBID_STID);
        GetTokenCG(GETTOKEN_DEFAULT);

        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
        GetTokenCG(GETTOKEN_DEFAULT);
    }

    i = lb->Search(fbase);
    if (i >= 0) {
        CG_MesLabelDefinition(i);
        throw CGERROR_PP_ALREADY_USE_TAGNAME;
    }
    subid = STRUCTPRM_SUBID_COMOBJ;
    i = PutStructEndDll((char *) "*", cg_libindex, subid, imp_index);
    lb->Regist(fbase, TYPE_DLLCTRL, i | TYPE_OFFSET_COMOBJ, cg_orgfile,
            cg_orgline);

    // Mesf( "#comfunc [%s][%d][%d]",fbase, imp_index, i );
}

/// パラメーター名を認識する(deffunc)
///
int CToken::GetParameterTypeCG(char *name) {
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "var"))
        return MPTYPE_SINGLEVAR;
    if (!strcmp(cg_str, "val")) {
#ifdef JPNMSG
        //@autoreleasepool {
        //    AppDelegate *global =
        //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
        //    global.logString = [global.logString stringByAppendingFormat:@"警告:古いdeffunc表記があります 行%d.[%s]\n", cg_orgline, name];
        //}
        // Mesf( (char *)"警告:古いdeffunc表記があります 行%d.[%s]", cg_orgline, name );
#else
        Mesf("Warning:Old deffunc expression at %d.[%s]", cg_orgline, name);
#endif
        return MPTYPE_SINGLEVAR;
    }
    if (!strcmp(cg_str, "str"))
        return MPTYPE_LOCALSTRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    if (!strcmp(cg_str, "label"))
        return MPTYPE_LABEL;
    if (!strcmp(cg_str, "local"))
        return MPTYPE_LOCALVAR;
    if (!strcmp(cg_str, "array"))
        return MPTYPE_ARRAYVAR;
    if (!strcmp(cg_str, "modvar"))
        return MPTYPE_MODULEVAR;
    if (!strcmp(cg_str, "modinit"))
        return MPTYPE_IMODULEVAR;
    if (!strcmp(cg_str, "modterm"))
        return MPTYPE_TMODULEVAR;

    return MPTYPE_NONE;
}

/// パラメーター名を認識する(struct)
///
int CToken::GetParameterStructTypeCG(char *name) {
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "var"))
        return MPTYPE_LOCALVAR;
    if (!strcmp(cg_str, "str"))
        return MPTYPE_LOCALSTRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    if (!strcmp(cg_str, "label"))
        return MPTYPE_LABEL;
    if (!strcmp(cg_str, "float"))
        return MPTYPE_FLOAT;
    return MPTYPE_NONE;
}

/// パラメーター名を認識する(func)
///
int CToken::GetParameterFuncTypeCG(char *name) {
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "var"))
        return MPTYPE_PVARPTR;
    if (!strcmp(cg_str, "str"))
        return MPTYPE_LOCALSTRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    //	if ( !strcmp( cg_str,"label" ) ) return MPTYPE_LABEL;
    if (!strcmp(cg_str, "float"))
        return MPTYPE_FLOAT;
    if (!strcmp(cg_str, "pval"))
        return MPTYPE_PPVAL;
    if (!strcmp(cg_str, "bmscr"))
        return MPTYPE_PBMSCR;

    if (!strcmp(cg_str, "comobj"))
        return MPTYPE_IOBJECTVAR;
    if (!strcmp(cg_str, "wstr"))
        return MPTYPE_LOCALWSTR;

    if (!strcmp(cg_str, "sptr"))
        return MPTYPE_FLEXSPTR;
    if (!strcmp(cg_str, "wptr"))
        return MPTYPE_FLEXWPTR;

    if (!strcmp(cg_str, "prefstr"))
        return MPTYPE_PTR_REFSTR;
    if (!strcmp(cg_str, "pexinfo"))
        return MPTYPE_PTR_EXINFO;
    if (!strcmp(cg_str, "nullptr"))
        return MPTYPE_NULLPTR;

    //	if ( !strcmp( cg_str,"hwnd" ) ) return MPTYPE_PTR_HWND;
    //	if ( !strcmp( cg_str,"hdc" ) ) return MPTYPE_PTR_HDC;
    //	if ( !strcmp( cg_str,"hinst" ) ) return MPTYPE_PTR_HINST;

    return MPTYPE_NONE;
}

/// 戻り値のパラメーター名を認識する(defcfunc)
///
int CToken::GetParameterResTypeCG(char *name) {
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "str"))
        return MPTYPE_STRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    if (!strcmp(cg_str, "label"))
        return MPTYPE_LABEL;
    if (!strcmp(cg_str, "float"))
        return MPTYPE_FLOAT;
    return MPTYPE_NONE;
}

#define GET_FI_SIZE() ((int)(fi_buf->GetSize() / sizeof(STRUCTDAT)))
#define GET_FI(n) (((STRUCTDAT*)fi_buf->GetBuffer()) + (n))
#define STRUCTDAT_INDEX_DUMMY ((short)0x8000)

/// HSP3Codeを展開する(deffunc / defcfunc)
///
void CToken::GenerateCodePP_deffunc0(int is_command) {
    int i, t, ot, prmid, subid;
    int index;
    int funcflag;
    int regflag;
    int prep = 0;
    char funcname[1024];
    STRUCTPRM *prm;
    STRUCTDAT *st;

    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;

    if (is_command && !strcmp(cg_str, "prep")) { // プロトタイプ宣言
        prep = 1;
        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype != TOKEN_OBJ)
            throw CGERROR_PP_NAMEREQUIRED;
    }

    strncpy(funcname, cg_str, 1023);

    for (i = 0; i < cg_localcur; i++) {
        lb->SetFlag(cg_localstruct[i], -1); // 以前に指定されたパラメーター名を削除する
    }
    cg_localcur = 0;
    funcflag = 0;
    regflag = 1;

    index = -1;
    int label_id = lb->Search(funcname);
    if (label_id >= 0) {
        if (lb->GetType(label_id) != TYPE_MODCMD) {
            CG_MesLabelDefinition(label_id);
            throw CGERROR_PP_ALREADY_USE_FUNC;
        }
        index = lb->GetOpt(label_id);
        if (index >= 0 && GET_FI(index)->index != STRUCTDAT_INDEX_DUMMY) {
            CG_MesLabelDefinition(label_id);
            throw CGERROR_PP_ALREADY_USE_FUNC;
        }
    }

    PutStructStart();
    while (1) {
        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;

        if (is_command && !strcmp(cg_str, "onexit")) {
            funcflag |= STRUCTDAT_FUNCFLAG_CLEANUP;
            break;
        }

        t = GetParameterTypeCG(cg_str);
        if (t == MPTYPE_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if ((t == MPTYPE_MODULEVAR) || (t == MPTYPE_IMODULEVAR) ||
                (t == MPTYPE_TMODULEVAR)) {
            //	モジュール名指定
            GetTokenCG(GETTOKEN_DEFAULT);
            if (ttype != TOKEN_OBJ)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            i = lb->Search(cg_str);
            if (i < 0)
                throw CGERROR_PP_BAD_STRUCT;
            if (lb->GetType(i) != TYPE_STRUCT)
                throw CGERROR_PP_BAD_STRUCT;
            prm = (STRUCTPRM *) mi_buf->GetBuffer();
            subid = prm[lb->GetOpt(i)].subid;
            // Mesf( "%s:struct%d",cg_str,subid );
            if (t == MPTYPE_IMODULEVAR) {
                if (prm[lb->GetOpt(i)].offset != -1)
                    throw CGERROR_PP_MODINIT_USED;
                prm[lb->GetOpt(i)].offset = GET_FI_SIZE();
                regflag = 0;
            }
            if (t == MPTYPE_TMODULEVAR) {
                st = (STRUCTDAT *) fi_buf->GetBuffer();
                if (st[subid].otindex != 0)
                    throw CGERROR_PP_MODTERM_USED;
                st[subid].otindex = GET_FI_SIZE();
                regflag = 0;
            }
            prmid = PutStructParam(t, subid);
            GetTokenCG(GETTOKEN_DEFAULT);

        } else {
            prmid = PutStructParam(t, STRUCTPRM_SUBID_STACK);
            // Mesf( "%d:type%d",prmid,t );

            GetTokenCG(GETTOKEN_DEFAULT);
            if (ttype == TOKEN_OBJ) {
                //	引数のエイリアス
                i = lb->Search(cg_str);
                if (i >= 0) {
                    CG_MesLabelDefinition(i);
                    throw CGERROR_PP_ALREADY_USE_PARAM;
                }
                i = lb->Regist(cg_str, TYPE_STRUCT, prmid, cg_orgfile, cg_orgline);
                cg_localstruct[cg_localcur++] = i;
                GetTokenCG(GETTOKEN_DEFAULT);
            }
        }

        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
    }

    ot = PutOT(GetCS());
    if (index == -1) {
        index = GET_FI_SIZE();
        fi_buf->PreparePtr(sizeof(STRUCTDAT));
        if (regflag) {
            lb->Regist(funcname, TYPE_MODCMD, index, cg_orgfile, cg_orgline);
        }
    }
    if (label_id >= 0) {
        lb->SetOpt(label_id, index);
    }
    int dat_index = is_command ? STRUCTDAT_INDEX_FUNC : STRUCTDAT_INDEX_CFUNC;
    PutStructEnd(index, funcname, dat_index, ot, funcflag);
}

void CToken::GenerateCodePP_deffunc(void) {
    GenerateCodePP_deffunc0(1);
}

void CToken::GenerateCodePP_defcfunc(void) {
    GenerateCodePP_deffunc0(0);
}

/// HSP3Codeを展開する(module)
///
void CToken::GenerateCodePP_module(void) {
    int i, ref;
    char *modname;
    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    modname = cg_str;

    if ((hed_cmpmode & CMPMODE_OPTCODE) &&
            (tmp_lb != NULL)) { // プリプロセス情報から最適化を行なう
        i = tmp_lb->Search(modname);
        if (i >= 0) {
            ref = tmp_lb->GetReference(i);
            if (ref == 0) {
                cg_flag = CG_FLAG_DISABLE;
                if (hed_cmpmode & CMPMODE_OPTINFO) {
#ifdef JPNMSG
                    // Mesf( (char *)"#未使用のモジュールを削除しました %s", modname );
                    //@autoreleasepool {
                    //    AppDelegate *global =
                    //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
                    //    global.logString = [global.logString
                    //            stringByAppendingFormat:@"#未使用のモジュールを削除しました %s\n",
                    //                                    modname];
                    //}
#else
                    Mesf("#Delete module %s", modname);
#endif
                }
                return;
            }
        }
    }
}

/// HSP3Codeを展開する(struct)
///
void CToken::GenerateCodePP_struct(void) {
    int i, t, prmid;
    char funcname[1024];
    GetTokenCG(GETTOKEN_DEFAULT);
    if (ttype != TOKEN_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    strncpy(funcname, cg_str, 1023);
    i = lb->Search(funcname);
    if (i >= 0) {
        CG_MesLabelDefinition(i);
        throw CGERROR_PP_ALREADY_USE_PARAM;
    }

    PutStructStart();
    prmid = PutStructParamTag(); // modinit用のTAG
    lb->Regist(funcname, TYPE_STRUCT, prmid, cg_orgfile, cg_orgline);
    // Mesf( "%d:%s",prmid, funcname );

    while (1) {
        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        t = GetParameterStructTypeCG(cg_str);
        if (t == MPTYPE_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        prmid = PutStructParam(t, STRUCTPRM_SUBID_STID);
        // Mesf( "%d:type%d",prmid,t );

        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype != TOKEN_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;

        i = lb->Search(cg_str);
        if (i >= 0) {
            CG_MesLabelDefinition(i);
            throw CGERROR_PP_ALREADY_USE_PARAM;
        }
        lb->Regist(cg_str, TYPE_STRUCT, prmid, cg_orgfile, cg_orgline);

        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
    }
    PutStructEnd(funcname, STRUCTDAT_INDEX_STRUCT, 0, 0);
}

/// HSP3Codeを展開する(defint,defdouble,defnone)
///
void CToken::GenerateCodePP_defvars(int fixedvalue) {
    int id;
    int prms = 0;

    while (1) {
        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_OBJ)
            throw CGERROR_WRONG_VARIABLE;
        id = SetVarsFixed(cg_str, fixedvalue);
        if (lb->GetType(id) != TYPE_VAR) {
            throw CGERROR_WRONG_VARIABLE;
        }
        prms++;
        // Mesf( "name:%s(%d) fixed:%d", cg_str, id, fixedvalue );

        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype >= TOKEN_EOL)
            break;
        if (ttype != TOKEN_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
    }

    if (prms == 0) {
        cg_defvarfix = fixedvalue;
    }
}

/// 変数の固定型を設定する
///
int CToken::SetVarsFixed(char *varname, int fixedvalue) {
    int id = lb->Search(varname);
    if (id < 0) {
        id = lb->Regist(varname, TYPE_VAR, cg_valcnt, cg_orgfile, cg_orgline);
        cg_valcnt++;
    }
    lb->SetForceType(id, fixedvalue);
    return id;
}

/// HSP3Codeを展開する(プリプロセスコマンド)
///
void CToken::GenerateCodePP(char *buf) {
    GetTokenCG(GETTOKEN_DEFAULT); // 最初の'#'を読み飛ばし
    GetTokenCG(GETTOKEN_DEFAULT);

    if (ttype == TOKEN_NONE) { // プリプロセッサから渡される行情報
        if (val != '#')
            throw CGERROR_UNKNOWN;
        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype != TOKEN_NUM)
            throw CGERROR_UNKNOWN;
        cg_orgline = val;
        GetTokenCG(GETTOKEN_DEFAULT);
        if (ttype == TOKEN_STRING) {
            strcpy(cg_orgfile, cg_str);
            if (cg_debug) {
                int i = PutDSBuf(cg_str);
                PutDI(254, i, cg_orgline); // ファイル名をデバッグ情報として登録
            }
        } else {
            if (cg_debug) {
                PutDI(254, 0, cg_orgline); // ラインだけをデバッグ情報として登録
            }
        }
        // Mesf( "#%d [%s]",cg_orgline, cg_str );
        return;
    }

    if (ttype != TOKEN_OBJ) { // その他はエラー
        throw CGERROR_PP_SYNTAX;
    }

    if (!strcmp(cg_str, "global")) {
        cg_flag = CG_FLAG_ENABLE;
        return;
    }

    if (cg_flag != CG_FLAG_ENABLE) { // 最適化による出力抑制
        return;
    }

    if (!strcmp(cg_str, "regcmd")) {
        GenerateCodePP_regcmd();
        return;
    }
    if (!strcmp(cg_str, "cmd")) {
        GenerateCodePP_cmd();
        return;
    }
    if (!strcmp(cg_str, "uselib")) {
        GenerateCodePP_uselib();
        return;
    }
    if (!strcmp(cg_str, "func")) {
        GenerateCodePP_func(STRUCTDAT_OT_STATEMENT | STRUCTDAT_OT_FUNCTION);
        return;
    }
    if (!strcmp(cg_str, "cfunc")) {
        GenerateCodePP_func(STRUCTDAT_OT_FUNCTION);
        return;
    }
    if (!strcmp(cg_str, "deffunc")) {
        GenerateCodePP_deffunc();
        return;
    }
    if (!strcmp(cg_str, "defcfunc")) {
        GenerateCodePP_defcfunc();
        return;
    }
    if (!strcmp(cg_str, "module")) {
        GenerateCodePP_module();
        return;
    }
    if (!strcmp(cg_str, "struct")) {
        GenerateCodePP_struct();
        return;
    }
    if (!strcmp(cg_str, "usecom")) {
        GenerateCodePP_usecom();
        return;
    }
    if (!strcmp(cg_str, "comfunc")) {
        GenerateCodePP_comfunc();
        return;
    }
    if (!strcmp(cg_str, "defint")) {
        GenerateCodePP_defvars(LAB_TYPEFIX_INT);
        return;
    }
    if (!strcmp(cg_str, "defdouble")) {
        GenerateCodePP_defvars(LAB_TYPEFIX_DOUBLE);
        return;
    }
    if (!strcmp(cg_str, "defnone")) {
        GenerateCodePP_defvars(LAB_TYPEFIX_NONE);
        return;
    }
}

/// 文字列(１行単位)からHSP3Codeを展開する
///
/// エラー発生時は例外が発生します
///
int CToken::GenerateCodeSub(void) {
    int i, t;
    //	char tmp[512];

    cg_errline = line;
    cg_lastcmd = CG_LASTCMD_NONE;

    if (cg_ptr == NULL)
        return TOKEN_EOF;

    if (*cg_ptr == '#') {
        GenerateCodePP(cg_ptr);
        return TOKEN_EOL;
    }

    if (cg_flag != CG_FLAG_ENABLE)
        return TOKEN_EOL; // 最適化による出力抑制

    //	while(1) {
    //		if ( cg_ptr!=NULL ) Mes( cg_ptr );
    GetTokenCG(GETTOKEN_LABEL);
    if (ttype >= TOKEN_SEPARATE)
        return ttype;

    switch (ttype) {
        //		case TK_NONE:
        //			sprintf( tmp,"#cod:%d",val );
        //			Mes( tmp );
        //			break;
        //		case TK_NUM:
        //			sprintf( tmp,"#num:%d",val );
        //			Mes( tmp );
        //			break;
        //		case TK_STRING:
        //			sprintf( tmp,"#str:%s",cg_str );
        //			Mes( tmp );
        //			break;
        //		case TK_DNUM:
        //			sprintf( tmp,"#dbl:%f",val_d );
        //			Mes( tmp );
        //			break;
        case TOKEN_OBJ:
            cg_lastcmd = CG_LASTCMD_LET;
            i = lb->Search(cg_str);
            if (i < 0) {
                // Mesf( "[%s][%d]",cg_str, cg_valcnt );
                i = SetVarsFixed(cg_str, cg_defvarfix);
                lb->SetInitFlag(i, LAB_INIT_DONE); //	変数の初期化フラグをセットする
                GenerateCodeLET(i);
            } else {
                t = lb->GetType(i);
                switch (t) {
                    case TYPE_VAR:
                    case TYPE_STRUCT:
                        GenerateCodeLET(i);
                        break;
                    case TYPE_LABEL:
                    case TYPE_XLABEL:
                        throw CGERROR_LABELNAME;
                        break;
                    default:
                        GenerateCodeCMD(i);
                        break;
                }
            }
            //			sprintf( tmp,"#obj:%s (%d)",cg_str,i );
            //			Mes( tmp );
            break;
        case TOKEN_LABEL:
            // Mesf( "#lab:%s",cg_str );
            if (*cg_str == '@') {
                sprintf(cg_str, "@l%d", cg_locallabel); // local label
                cg_locallabel++;
            }

            i = lb->Search(cg_str);
            if (i >= 0) {
                LABOBJ *lab;
                lab = lb->GetLabel(i);
                if (lab->type != TYPE_XLABEL)
                    throw CGERROR_LABELEXIST;
                SetOT(lb->GetOpt(i), GetCS());
                lab->type = TYPE_LABEL;
            } else {
                i = lb->Regist(cg_str, TYPE_LABEL, ot_buf->GetSize() / sizeof(int));
                PutOT(GetCS());
            }
            GetTokenCG(GETTOKEN_DEFAULT);
            break;
        default:
            throw CGERROR_SYNTAX;
    }
    //	}

    if (ttype < TOKEN_SEPARATE)
        throw CGERROR_SYNTAX;
    return ttype;
}

/// vs_wpから１行を取得する
///
char *CToken::GetLineCG(void) {
    char *pp;
    unsigned char *p = cg_wp;
    unsigned char a1;

    if (p == NULL)
        return NULL;

    pp = (char *) p;
    a1 = *p;
    if (a1 == 0) {
        cg_wp = NULL;
        return NULL;
    }
    while (1) {
        a1 = *p;
        // 全角文字チェック＊
        // if (a1>=129) {
        //    if ((a1<=159)||(a1>=224)) {
        //        NSLog(@"C:%s",cg_wp);
        //        p++;
        //        if ( *p >= 32 ) { p++; continue; }
        //    }
        //}
        int skip = SkipMultiByte(a1); // 全角文字チェック
        if (skip) {
            p += skip + 1;
            continue;
        }
        //        uint8 c = a1;
        //        //if (c >= 0 && c < 128) { return 1; }
        //        if (c >= 128 && c < 192) { p++; if ( *p >= 32 ) { p++; continue; }
        //        }
        //        if (c >= 192 && c < 224) { p++; if ( *p >= 32 ) { p++; continue; }
        //        }
        //        if (c >= 224 && c < 240) { p++;p++; if ( *p >= 32 ) { p++;
        //        continue; } }
        //        if (c >= 240 && c < 248) { p++;p++;p++; if ( *p >= 32 ) { p++;
        //        continue; } }
        //        if (c >= 248 && c < 252) { p++;p++;p++;p++; if ( *p >= 32 ) { p++;
        //        continue; } }
        //        if (c >= 252 && c < 254) { p++;p++;p++;p++;p++; if ( *p >= 32 ) {
        //        p++; continue; } }
        //        if (c >= 254 && c <= 255) { p++;p++;p++;p++;p++;  if ( *p >= 32 )
        //        { p++; continue; } }
        //
        if (a1 == 0)
            break;
        if (a1 == 13) {
            *p = 0;
            p++;
            line++;
            if (*p == 10) {
                *p = 0;
                p++;
            }
            break;
        }
        if (a1 == 10) {
            *p = 0;
            p++;
            line++;
            break;
        }
        p++;
    }
    cg_wp = p;
    return pp;
}

/// プロック単位でHSP3Codeを展開する
///
/// エラー発生時は例外が発生します
///
int CToken::GenerateCodeBlock(void) {
    int id;
    int ff;
    char a1;
    char *p;
    int res = GenerateCodeSub();

    if (res == TOKEN_EOF)
        return res;
    if (res == TOKEN_EOL) {
        cg_ptr = GetLineCG();
        if (iflev) {
            if (ifscope[iflev - 1] == CG_IFCHECK_LINE)
                CheckCMDIF_Fin(0); // 'if' jump support
        }
        if (cg_debug)
            PutDI();
        cg_orgline++;
    }
    if (res == TOKEN_SEPARATE) {
        a1 = cg_str[0];
        if (a1 == '{') { // when '{'
            if (iflev == 0)
                throw CGERROR_BLOCKEXP;
            if (ifscope[iflev - 1] == CG_IFCHECK_SCOPE)
                throw CGERROR_BLOCKEXP;
            ifscope[iflev - 1] = CG_IFCHECK_SCOPE;
        } else if (a1 == '}') { // when '}'
            if (iflev == 0)
                throw CGERROR_BLOCKEXP;
            if (ifscope[iflev - 1] != CG_IFCHECK_SCOPE)
                throw CGERROR_BLOCKEXP;

            ff = 0;
            p = GetTokenCG(cg_ptr, GETTOKEN_DEFAULT);

            if (ttype == TOKEN_EOL) { // 次行のコマンドがelseかどうか調べる
                if (cg_wp != NULL) {
                    p = GetSymbolCG((char *) cg_wp);
                    if (p != NULL) {
                        id = lb->Search(p);
                        if (id >= 0) {
                            if ((lb->GetType(id) == TYPE_CMPCMD) && (lb->GetOpt(id) == 1)) {
                                ff = 1;
                            }
                        }
                    }
                }
            } else if (ttype == TOKEN_OBJ) { // 次のコマンドがelseかどうか調べる
                id = lb->Search(cg_str);
                if (id >= 0) {
                    if ((lb->GetType(id) == TYPE_CMPCMD) && (lb->GetOpt(id) == 1)) {
                        // ifscope[iflev-1] = CG_IFCHECK_LINE;					// line
                        // scope
                        // on
                        ff = 1;
                    }
                }
            }
            if (ff == 0)
                CheckCMDIF_Fin(0);
        }
    }
    return res;
}

/// プリプロセス時のラベル情報から関数を定義
///
void CToken::RegisterFuncLabels(void) {
    if (tmp_lb == NULL)
        return;
    int len = tmp_lb->GetCount();
    for (int i = 0; i < len; i++) {
        if (tmp_lb->GetType(i) == LAB_TYPE_PPMODFUNC && tmp_lb->GetFlag(i) >= 0) {
            char *name = tmp_lb->GetName(i);
            if (lb->Search(name) >= 0) {
                throw CGERROR_PP_ALREADY_USE_FUNC;
            }
            LABOBJ *lab = tmp_lb->GetLabel(i);
            int id = lb->Regist(name, TYPE_MODCMD, -1, lab->def_file, lab->def_line);
            lb->SetData2(id, (char *) &i, sizeof i);
        }
    }
}

/// ソースをHSP3Codeに展開する
///
/// ソースのバッファを書き換えるので注意
///
int CToken::GenerateCodeMain(CMemBuf *buf) {
    int a;
    line = 0;
    cg_flag = CG_FLAG_ENABLE;
    cg_valcnt = 0;
    cg_typecnt = HSP3_TYPE_USER;
    cg_pptype = -1;
    cg_iflev = 0;
    cg_wp = (unsigned char *) buf->GetBuffer();
    cg_ptr = GetLineCG();
    cg_orgfile[0] = 0;
    cg_libindex = -1;
    cg_libmode = CG_LIBMODE_NONE;
    cg_lastcs = 0;
    cg_localcur = 0;
    cg_locallabel = 0;
    cg_varhpi = 0;
    cg_defvarfix = LAB_TYPEFIX_NONE;

    iflev = 0;
    replev = 0;

    for (a = 0; a < CG_REPLEV_MAX; a++) {
        repend[a] = -1;
    }

    try {
        RegisterFuncLabels();

        while (1) {
            if (GenerateCodeBlock() == TOKEN_EOF)
                break;
        }

        cg_errline = -1; // エラーの行番号は該当なし

        //		コンパイル後の後始末チェック
        if (replev != 0)
            throw CGERROR_LOOP_NOTFOUND;

        //		ラベル未処理チェック
        int errend;
        errend = 0;
        for (a = 0; a < lb->GetCount(); a++) {
            if (lb->GetType(a) == TYPE_XLABEL) {
#ifdef JPNMSG
                // Mesf( (char *)"#ラベルの定義が存在しません [%s]", lb->GetName(a) );
                //@autoreleasepool {
                //    AppDelegate *global =
                //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
                //    global.logString = [global.logString
                //            stringByAppendingFormat:@"#ラベルの定義が存在しません [%s]\n",
                //                                    lb->GetName(a)];
                //}
#else
                Mesf("#Label definition not found [%s]", lb->GetName(a));
#endif

                errend++;
            }
        }

        //		関数未処理チェック
        for (a = 0; a < GET_FI_SIZE(); a++) {
            if (GET_FI(a)->index == STRUCTDAT_INDEX_DUMMY) {
#ifdef JPNMSG
                // Mesf( (char *)"#関数が定義されていません [%s]",
                // lb->GetName(GET_FI(a)->otindex) );
                //@autoreleasepool {
                //    AppDelegate *global =
                //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
                //    global.logString = [global.logString
                //            stringByAppendingFormat:@"#関数が定義されていません [%s]\n",
                //                                    lb->GetName(GET_FI(a)->otindex)];
                //}
#else
                Mesf("#Function not found [%s]", lb->GetName(GET_FI(a)->otindex));
#endif

                errend++;
            }
        }

        //      ブレース対応チェック
        if (iflev > 0) {
#ifdef JPNMSG
            // Mesf( (char *)"#波括弧が閉じられていません" );
            //@autoreleasepool {
            //    AppDelegate *global =
            //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
            //    global.logString = [global.logString
            //            stringByAppendingString:@"#波括弧が閉じられていません\n"];
            //}
#else
            Mesf("#Missing closing braces");
#endif
            errend++;
        }

        if (errend)
            throw CGERROR_FATAL;
    } catch (CGERROR code) {
        return (int) code;
    }

    return 0;
}

/// Register command code
///
/// HSP ver3.3以降用
/// type=0-0xfff ( -1 to debug line info
/// val=16,32bit length supported
///
void CToken::PutCS(int type, int value, int exflg) {
    unsigned int v = (unsigned int) value;
    int a = (type & CSTYPE) | exflg;
    if (v < 0x10000) { // when 16bit encode
        cs_buf->Put((short) (a));
        cs_buf->Put((short) (v));
    } else { // when 32bit encode
        cs_buf->Put((short) (0x8000 | a));
        cs_buf->Put((int) value);
    }
}

/// Register command code (double)
///
void CToken::PutCS(int type, double value, int exflg) {
    PutCS(type, PutDS(value), exflg);
}

/// まだ定義されていない関数の呼び出しがあったら仮登録する
///
void CToken::PutCSSymbol(int label_id, int exflag) {
    int type = lb->GetType(label_id);
    int value = lb->GetOpt(label_id);
    if (type == TYPE_MODCMD && value == -1) {
        int id = *(int *) lb->GetData2(label_id);
        tmp_lb->AddReference(id);

        STRUCTDAT st = {STRUCTDAT_INDEX_DUMMY};
        st.otindex = label_id;
        value = GET_FI_SIZE();
        fi_buf->PutData(&st, sizeof(STRUCTDAT));
        lb->SetOpt(label_id, value);
    }
    if (exflag & EXFLG_1 && type != TYPE_VAR && type != TYPE_STRUCT) {
        value &= 0xffff;
    }
    PutCS(type, value, exflag);
}

/// 現在のコードセグメントのインデックスを取得する
///
int CToken::GetCS(void) {
    return (cs_buf->GetSize()) >> 1;
}

/// データセグメントにdoubleを登録する
///
int CToken::PutDS(double value) {
    int i = ds_buf->GetSize();

#ifdef HSP_DS_POOL
    if (CG_optCode()) {
        int i_cache =
        double_literal_table.insert(std::make_pair(value, i)).first->second; /// @warning cpp
        if (i != i_cache) {
            if (CG_optInfo()) {
                Mesf("#実数リテラルプール %f", value);
            }
            return i_cache;
        }
    }
#endif

    ds_buf->Put(value);
    return i;
}

/// データセグメント（スクリプト文字列）に文字列を登録する。
///
int CToken::PutDS(char *str) {
    return PutDSStr(str, cg_utf8out != 0);
}

/// データセグメントに文字列を登録する（直接）
///
int CToken::PutDSBuf(char *str) {
    return PutDSStr(str, false);
}

/// データセグメントに文字列を登録する（キャッシュ）
///
int CToken::PutDSStr(char *str, bool converts_to_utf8) {
    char *p;

    // output as UTF8 format
    if (converts_to_utf8) {
        p = ExecSCNV(str, SCNV_OPT_SJISUTF8);
    } else {
        p = str;
    }

    int i = ds_buf->GetSize();

#ifdef HSP_DS_POOL
    if (CG_optCode()) {
        int i_cache = string_literal_table.insert(std::make_pair(std::string(p), i)) /// @warning cpp
        .first->second;
        if (i != i_cache) {
            if (CG_optInfo()) {
                char* literal_str = to_hsp_string_literal(str);
                Mesf("#文字列プール %s", literal_str);
                free(literal_str);
            }
            return i_cache;
        }
    }
#endif

    if (converts_to_utf8) {
        ds_buf->PutData(p, (int) (strlen(p) + 1));
    } else {
        ds_buf->PutStr(p);
        ds_buf->Put((char) 0);
    }
    return i;
}

/// データセグメントに文字列を登録する（直接）
///
int CToken::PutDSBuf(char *str, int size) {
    int i = ds_buf->GetSize();
    ds_buf->PutData(str, size);
    return i;
}

/// 一時的なオブジェクトを登録する
///
int CToken::PutOT(int value) {
    int i = ot_buf->GetSize() / sizeof(int);
    ot_buf->Put(value);
    return i;
}

/// 一時的なオブジェクトを修正する
///
void CToken::SetOT(int id, int value) {
    int *p = (int *) (ot_buf->GetBuffer());
    p[id] = value;
}

/// デバッグコードレジスタ
///
/// mem_di formats :
/// 0-250           = offset to old mcs
/// 252,x(16)       = big offset
/// 253,x(24),y(16) = used val (x=mds ptr.)
/// 254,x(24),y(16) = new filename accepted (x=mds ptr.)
/// 255             = end of debug data
///
void CToken::PutDI(void) {
    int ofs = (int) (GetCS() - cg_lastcs);
    if (ofs <= 250) {
        di_buf->Put((unsigned char) ofs);
    } else {
        di_buf->Put((unsigned char) 252);
        di_buf->Put((unsigned char) (ofs));
        di_buf->Put((unsigned char) (ofs >> 8));
    }
    cg_lastcs = GetCS();
}

/// 特殊デバッグコードレジスタ
///
/// in : -1=end of code
/// 254=(a=file ds ptr./subid=line num.)
///
void CToken::PutDI(int dbg_code, int a, int subid) {
    if (dbg_code < 0) {
        di_buf->Put((unsigned char) 255);
        di_buf->Put((unsigned char) 255);
    } else {
        di_buf->Put((unsigned char) dbg_code);
        di_buf->Put((unsigned char) (a));
        di_buf->Put((unsigned char) (a >> 8));
        di_buf->Put((unsigned char) (a >> 16));
        di_buf->Put((unsigned char) (subid));
        di_buf->Put((unsigned char) (subid >> 8));
    }
}

/// 変数用デバッグ情報レジスタ
///
void CToken::PutDIVars(void) {
    int a, i, id;
    LABOBJ *lab;
    char vtmpname[256];
    char *p;

    id = 0;
    strcpy(vtmpname, "I_");

    for (a = 0; a < lb->GetNumEntry(); a++) {
        lab = lb->GetLabel(a);
        if (lab->type == TOKEN_OBJ) {
            switch (lab->typefix) {
                case LAB_TYPEFIX_INT:
                    vtmpname[0] = 'I';
                    p = vtmpname;
                    strcpy(p + 2, lab->name);
                    break;
                case LAB_TYPEFIX_DOUBLE:
                    vtmpname[0] = 'D';
                    p = vtmpname;
                    strcpy(p + 2, lab->name);
                    break;
                case LAB_TYPEFIX_NONE:
                default:
                    p = lab->name;
                    break;
            }
            i = PutDSBuf(p);
            PutDI(253, i, lab->opt);
        }
    }
}

/// ラベル名の情報を出力する
///
void CToken::PutDILabels(void) {
    int num = ot_buf->GetSize() / sizeof(int);
    int *table = new int[num];
    for (int i = 0; i < num; i++)
        table[i] = -1;
    for (int i = 0; i < lb->GetNumEntry(); i++) {
        if (lb->GetType(i) == TYPE_LABEL) {
            int id = lb->GetOpt(i);
            table[id] = i;
        }
    }
    di_buf->Put((unsigned char) 255);
    for (int i = 0; i < num; i++) {
        if (table[i] == -1)
            continue;
        char *name = lb->GetName(table[i]);
        int dsPos = PutDSBuf(name);
        PutDI(251, dsPos, i);
    }
    delete[] table;
}

/// 引数名の情報を出力する
///
void CToken::PutDIParams(void) {
    di_buf->Put((unsigned char) 255);
    for (int i = 0; i < lb->GetNumEntry(); i++) {
        if (lb->GetType(i) == TYPE_STRUCT) {
            int id = lb->GetOpt(i);
            if (id < 0)
            continue;
            char *name = lb->GetName(i);
            int dsPos = PutDSBuf(name);
            PutDI(251, dsPos, id);
        }
    }
}

char *CToken::GetDS(int ptr) {
    int i;
    char *p;
    i = ds_buf->GetSize();
    if (ptr >= i)
        return NULL;
    p = ds_buf->GetBuffer();
    p += ptr;
    return p;
}

int CToken::PutLIB(int flag, char *name) {
    int a, i = -1, p;
    LIBDAT lib;
    LIBDAT *l;
    p = li_buf->GetSize() / sizeof(LIBDAT);
    l = (LIBDAT *) li_buf->GetBuffer();

    if (flag == LIBDAT_FLAG_DLL) {
        if (*name != 0) {
            for (a = 0; a < p; a++) {
                if (l->flag == flag) {
                    if (strcmp(GetDS(l->nameidx), name) == 0) {
                        return a;
                    }
                }
                l++;
            }
            i = PutDSBuf(name);
        } else {
            i = -1;
        }
    }
    if (flag == LIBDAT_FLAG_COMOBJ) {
        COM_GUID guid;
        if (ConvertIID(&guid, name))
            return -1;
        i = PutDSBuf((char *) &guid, sizeof(COM_GUID));
    }

    lib.flag = flag;
    lib.nameidx = i;
    lib.hlib = NULL;
    lib.clsid = -1;
    li_buf->PutData(&lib, sizeof(LIBDAT));
    // Mesf( "LIB#%d:%s",flag,name );

    return p;
}

void CToken::SetLIBIID(int id, char *clsid) {
    LIBDAT *l;
    l = (LIBDAT *) li_buf->GetBuffer();
    l += id;
    if (*clsid == 0) {
        l->clsid = -1;
    } else {
        l->clsid = PutDSBuf(clsid);
    }
}

int CToken::PutStructParam(short mptype, int extype) {
    int i = mi_buf->GetSize() / sizeof(STRUCTPRM);
    STRUCTPRM prm;

    prm.mptype = mptype;
    if (extype == STRUCTPRM_SUBID_STID) {
        prm.subid = (short) GET_FI_SIZE();
    } else {
        prm.subid = extype;
    }
    prm.offset = cg_stsize;

    int size = 0;
    switch (mptype) {
        case MPTYPE_INUM:
        case MPTYPE_STRUCT:
            size = sizeof(int);
            break;
        case MPTYPE_LOCALVAR:
            size = sizeof(PVal);
            break;
        case MPTYPE_DNUM:
            size = sizeof(double);
            break;
        case MPTYPE_FLOAT:
            size = sizeof(float);
            break;
        case MPTYPE_LOCALSTRING:
        case MPTYPE_STRING:
        case MPTYPE_LABEL:
        case MPTYPE_PPVAL:
        case MPTYPE_PBMSCR:
        case MPTYPE_PVARPTR:
        case MPTYPE_IOBJECTVAR:
        case MPTYPE_LOCALWSTR:
        case MPTYPE_FLEXSPTR:
        case MPTYPE_FLEXWPTR:
        case MPTYPE_PTR_REFSTR:
        case MPTYPE_PTR_EXINFO:
        case MPTYPE_PTR_DPMINFO:
        case MPTYPE_NULLPTR:
            size = sizeof(char *);
            break;
        case MPTYPE_SINGLEVAR:
        case MPTYPE_ARRAYVAR:
            size = sizeof(MPVarData);
            break;
        case MPTYPE_MODULEVAR:
        case MPTYPE_IMODULEVAR:
        case MPTYPE_TMODULEVAR:
            size = sizeof(MPModVarData);
            break;
        default:
            return i;
    }
    cg_stsize += size;
    cg_stnum++;
    mi_buf->PutData(&prm, sizeof(STRUCTPRM));
    return i;
}

int CToken::PutStructParamTag(void) {
    int i = mi_buf->GetSize() / sizeof(STRUCTPRM);
    STRUCTPRM prm;

    prm.mptype = MPTYPE_STRUCTTAG;
    prm.subid = (short) GET_FI_SIZE();
    prm.offset = -1;

    cg_stnum++;
    mi_buf->PutData(&prm, sizeof(STRUCTPRM));
    return i;
}

void CToken::PutStructStart(void) {
    cg_stnum = 0;
    cg_stsize = 0;
    cg_stptr = mi_buf->GetSize() / sizeof(STRUCTPRM);
}

/// STRUCTDATを登録する(モジュール用)
///
int CToken::PutStructEnd(int i, char *name, int libindex, int otindex, int funcflag) {
    STRUCTDAT st;
    st.index = libindex;
    st.nameidx = PutDSBuf(name);
    st.subid = i;
    st.prmindex = cg_stptr;
    st.prmmax = cg_stnum;
    st.funcflag = funcflag;
    st.size = cg_stsize;
    if (otindex < 0) {
        st.otindex = 0;
        st.subid = otindex;
    } else {
        st.otindex = otindex;
    }
    *GET_FI(i) = st;
    // Mesf( "#%d : %s(LIB%d) prm%d size%d ot%d", i, name, libindex, cg_stnum,
    // cg_stsize, otindex );
    return i;
}

int CToken::PutStructEnd(char *name, int libindex, int otindex, int funcflag) {
    int i = GET_FI_SIZE();
    fi_buf->PreparePtr(sizeof(STRUCTDAT));
    return PutStructEnd(i, name, libindex, otindex, funcflag);
}

/// STRUCTDATを登録する(DLL用)
///
int CToken::PutStructEndDll(char *name, int libindex, int subid, int otindex) {
    int i;
    STRUCTDAT st;
    i = GET_FI_SIZE();
    st.index = libindex;
    if (name[0] == '*') {
        st.nameidx = -1;
    } else {
        st.nameidx = PutDSBuf(name);
    }
    st.subid = subid;
    st.prmindex = cg_stptr;
    st.prmmax = cg_stnum;
    st.proc = NULL;
    st.size = cg_stsize;
    st.otindex = otindex;
    fi_buf->PutData(&st, sizeof(STRUCTDAT));
    // Mesf( "#%d : %s(LIB%d) prm%d size%d ot%d", i, name, libindex, cg_stnum,
    // cg_stsize, otindex );
    return i;
}

void CToken::PutHPI(short flag, short option, char *libname, char *funcname) {
    HPIDAT hpi;
    hpi.flag = flag;
    hpi.option = option;
    hpi.libname = PutDSBuf(libname);
    hpi.funcname = PutDSBuf(funcname);
    hpi.libptr = NULL;
    hpi_buf->PutData(&hpi, sizeof(HPIDAT));
}

int CToken::GenerateCode(char *fname, char *oname, int mode) {
    CMemBuf srcbuf;
    if (srcbuf.PutFile(fname) < 0) {
        // Mes( (char *)"#No file." );
        //@autoreleasepool {
        //    AppDelegate *global =
        //            (AppDelegate *) [[NSApplication sharedApplication] delegate];
        //    global.logString =
        //            [global.logString stringByAppendingString:@"#No file.\n"];
        //}
        return -1;
    }
    return GenerateCode(&srcbuf, oname, mode);
}

/// ファイルをHSP3Codeに展開する
/// mode            Debug code (0=off 1=on)
///
int CToken::GenerateCode(CMemBuf *srcbuf, char *oname, int mode) {
    int i, orgcs, res;
    int adjsize;
    CMemBuf optbuf; // オプション文字列用バッファ
    CMemBuf bakbuf; // プリプロセッサソース保存用バッファ

    cs_buf = new CMemBuf;
    ds_buf = new CMemBuf;
    ot_buf = new CMemBuf;
    di_buf = new CMemBuf;
    li_buf = new CMemBuf;
    fi_buf = new CMemBuf;
    mi_buf = new CMemBuf;
    fi2_buf = new CMemBuf;
    hpi_buf = new CMemBuf;

    bakbuf.PutStr(srcbuf->GetBuffer()); // プリプロセッサソースを保存する

    cg_debug = mode & COMP_MODE_DEBUG;
    cg_utf8out = mode & COMP_MODE_UTF8;

    if (pp_utf8)
        cg_utf8out = 0; // ソースコードがUTF-8の場合は変換は必要ない

    cg_putvars = hed_cmpmode & CMPMODE_PUTVARS;
    res = GenerateCodeMain(srcbuf);
    if (res) {
        //		エラー終了
        char tmp[512];
        //CStrNote note;
        CMemBuf srctmp;
        // Mesf( (char *)"%s(%d) : error %d : %s (%d行目)", cg_orgfile, cg_orgline,
        // res, cg_geterror((CGERROR)res), cg_orgline );

        char *err[] = {
                (char *) "",                                               // 0
                (char *) "解釈できない文字コードです",                     // 1
                (char *) "文法が間違っています",                           // 2
                (char *) "小数の記述が間違っています",                     // 3
                (char *) "パラメーター式の記述が無効です",                 // 4
                (char *) "カッコが閉じられていません",                     // 5
                (char *) "配列の書式が間違っています",                     // 6
                (char *) "ラベル名はすでに使われています",                 // 7
                (char *) "ラベル名は指定できません",                       // 8
                (char *) "repeatのネストが深すぎます",                     // 9
                (char *) "repeatループ外でbreakが使用されました",          // 10
                (char *) "repeatループ外でcontinueが使用されました",       // 11
                (char *) "repeatループでないのにloopが使用されました",     // 12
                (char *) "repeatループが閉じられていません",               // 13
                (char *) "elseの前にifが見当たりません",                   // 14
                (char *) "{が閉じられていません",                          // 15
                (char *) "if命令以外で{〜}が使われています",               // 16
                (char *) "else命令の位置が不正です",                       // 17
                (char *) "if命令の階層が深すぎます",                       // 18
                (char *) "致命的なエラーです",                             // 19
                (char *) "プリプロセッサ命令が解釈できません",             // 20
                (char *) "コマンド登録中のエラーです",                     // 21
                (char *) "プリプロセッサは文字列のみ受け付けます",         // 22
                (char *) "パラメーター引数の指定が間違っています",         // 23
                (char *) "ライブラリ名が指定されていません",               // 24
                (char *) "命令として定義できない名前です",                 // 25
                (char *) "パラメーター引数名は使用されています",           // 26
                (char *) "モジュール変数の参照元が無効です",               // 27
                (char *) "モジュール変数の指定が無効です",                 // 28
                (char *) "外部関数のインポート名が無効です",               // 29
                (char *) "拡張命令の名前はすでに使用されています",         // 30
                (char *) "互換性のない拡張命令タイプを使用しています",     // 31
                (char *) "コンストラクタは既に登録されています",           // 32
                (char *) "デストラクタは既に登録されています",             // 33
                (char *) "複数行文字列の終端ではありません",               // 34
                (char *) "タグ名はすでに使用されています",                 // 35
                (char *) "インターフェース名が指定されていません",         // 36
                (char *) "インポートするインデックスが指定されていません", // 37
                (char *) "インポートするIID名が指定されていません",        // 38
                (char *) "未初期化変数を使用しようとしました",             // 39
                (char *) "指定できない変数名です",                         // 40
                (char *) "*"
        };

//        @autoreleasepool {
//            NSString *nsstr_error_message =
//                    [NSString stringWithCString:err[(int) res]
//                                       encoding:NSUTF8StringEncoding];
//            // NSLog(@"%@",nsstr_error_message);
//
//            AppDelegate *global =
//                    (AppDelegate *) [[NSApplication sharedApplication] delegate];
//            global.logString = [global.logString
//                    stringByAppendingFormat:@"%s(%d) : error %d : %@ (%d行目)\n",
//                                            cg_orgfile, cg_orgline, res,
//                                            nsstr_error_message, cg_orgline];
//
//            if (cg_errline > 0) {
//
//                [cwrap Select:bakbuf.GetBuffer()];
//                [cwrap GetLine2:tmp line:cg_errline - 1 max:510];
//                //note.Select(bakbuf.GetBuffer());
//                //note.GetLine(tmp, cg_errline - 1, 510);
//
//                global.logString =
//                        [global.logString stringByAppendingFormat:@"--> %s\n", tmp];
//
//                NSAlert *alert = [[NSAlert alloc] init];
//                [alert setMessageText:@"コンパイルエラー"];
//                [alert
//                        setInformativeText:
//                                [NSString stringWithFormat:@"error %d : %@ (%d行目)\n--> %s\n", res,
//                                                           nsstr_error_message, cg_orgline, tmp]];
//                [alert addButtonWithTitle:@"OK"];
//                [alert runModal];
//            } else {
//                NSAlert *alert = [[NSAlert alloc] init];
//                [alert setMessageText:@"コンパイルエラー"];
//                [alert
//                        setInformativeText:[NSString
//                                stringWithFormat:@"error %d : %@ (%d行目)\n",
//                                                 res, nsstr_error_message,
//                                                 cg_orgline]];
//                [alert addButtonWithTitle:@"OK"];
//                [alert runModal];
//            }
//
//            global.isError = YES;
//        }

    } else {
        //		正常終了
        CMemBuf axbuf;
        HSPHED hsphed;
        int sz_hed, sz_opt, cs_size, ds_size, ot_size, di_size;
        int li_size, fi_size, mi_size, fi2_size, hpi_size;

        orgcs = GetCS();
        PutCS(TYPE_PROGCMD, 0x11, EXFLG_1); // 終了コードを最後に入れる
        i = PutOT(orgcs);
        PutCS(TYPE_PROGCMD, 0, EXFLG_1);
        PutCS(TYPE_LABEL, i, 0);

        if (cg_debug) {
            PutDI();
        }
        if ((cg_debug) || (cg_putvars)) {
            PutDIVars();
        }
        if (cg_debug) {
            PutDILabels();
            PutDIParams();
        }
        PutDI(-1, 0, 0); // デバッグ情報終端

        sz_hed = sizeof(HSPHED);
        memset(&hsphed, 0, sz_hed);
        hsphed.bootoption = 0;
        hsphed.runtime = 0;

        if (hed_option & HEDINFO_RUNTIME) {
            optbuf.PutStr(hed_runtime);
        }
        sz_opt = optbuf.GetSize();
        if (sz_opt) {
            while (1) {
                adjsize = (sz_opt + 15) & 0xfff0;
                if (adjsize == sz_opt)
                    break;
                optbuf.Put((char) 0);
                sz_opt = optbuf.GetSize();
            }
            hsphed.bootoption |= HSPHED_BOOTOPT_RUNTIME;
            hsphed.runtime = sz_hed;
            sz_hed += sz_opt;
        }

        //		デバッグウインドゥ表示
        if (mode & COMP_MODE_DEBUGWIN)
            hsphed.bootoption |= HSPHED_BOOTOPT_DEBUGWIN;
        //		起動オプションの設定
        if (hed_autoopt_timer >= 0) {
            // awaitが使用されていない場合はマルチメディアタイマーを無効にする(自動設定)
            if (hed_autoopt_timer == 0)
                hsphed.bootoption |= HSPHED_BOOTOPT_NOMMTIMER;
        } else {
            // 設定されたオプションに従ってマルチメディアタイマーを無効にする
            if (hed_option & HEDINFO_NOMMTIMER)
                hsphed.bootoption |= HSPHED_BOOTOPT_NOMMTIMER;
        }

        if (hed_option & HEDINFO_NOGDIP)
            hsphed.bootoption |= HSPHED_BOOTOPT_NOGDIP; // GDI+による描画を無効にする
        if (hed_option & HEDINFO_FLOAT32)
            hsphed.bootoption |=
                    HSPHED_BOOTOPT_FLOAT32; // 実数を32bit floatとして処理する
        if (hed_option & HEDINFO_ORGRND)
            hsphed.bootoption |= HSPHED_BOOTOPT_ORGRND; // 標準の乱数発生を使用する

        cs_size = cs_buf->GetSize();
        ds_size = ds_buf->GetSize();
        ot_size = ot_buf->GetSize();
        di_size = di_buf->GetSize();

        li_size = li_buf->GetSize();
        fi_size = fi_buf->GetSize();
        mi_size = mi_buf->GetSize();
        fi2_size = fi2_buf->GetSize();
        hpi_size = hpi_buf->GetSize();

        hsphed.h1 = 'H';
        hsphed.h2 = 'S';
        hsphed.h3 = 'P';
        hsphed.h4 = '3';
        hsphed.version = 0x0350;    // version3.5
        hsphed.max_val = cg_valcnt; // max count of VAL Object
        hsphed.allsize = sz_hed + cs_size + ds_size + ot_size + di_size;
        hsphed.allsize += li_size + fi_size + mi_size + fi2_size + hpi_size;

        hsphed.pt_cs = sz_hed;                    // ptr to Code Segment
        hsphed.max_cs = cs_size;                  // size of CS
        hsphed.pt_ds = sz_hed + cs_size;          // ptr to Data Segment
        hsphed.max_ds = ds_size;                  // size of DS
        hsphed.pt_ot = hsphed.pt_ds + ds_size;    // ptr to Object Temp
        hsphed.max_ot = ot_size;                  // size of OT
        hsphed.pt_dinfo = hsphed.pt_ot + ot_size; // ptr to Debug Info
        hsphed.max_dinfo = di_size;               // size of DI

        hsphed.pt_linfo = hsphed.pt_dinfo + di_size; // ptr to Debug Info
        hsphed.max_linfo = li_size;                  // size of LINFO

        hsphed.pt_finfo = hsphed.pt_linfo + li_size; // ptr to Debug Info
        hsphed.max_finfo = fi_size;                  // size of FINFO

        hsphed.pt_minfo = hsphed.pt_finfo + fi_size; // ptr to Debug Info
        hsphed.max_minfo = mi_size;                  // size of MINFO

        hsphed.pt_finfo2 = hsphed.pt_minfo + mi_size; // ptr to Debug Info
        hsphed.max_finfo2 = fi2_size;                 // size of FINFO2

        hsphed.pt_hpidat = hsphed.pt_finfo2 + fi2_size; // ptr to Debug Info
        hsphed.max_hpi = hpi_size;                      // size of HPIDAT
        hsphed.max_varhpi = cg_varhpi;                  // Num of Vartype Plugins

        hsphed.pt_sr = sizeof(HSPHED); // ptr to Option Segment
        hsphed.max_sr = sz_opt;        // size of Option Segment
        hsphed.opt1 = 0;
        hsphed.opt2 = 0;

        axbuf.PutData(&hsphed, sizeof(HSPHED));
        if (sz_opt)
            axbuf.PutData(optbuf.GetBuffer(), sz_opt);

        if (cs_size)
            axbuf.PutData(cs_buf->GetBuffer(), cs_size);
        if (ds_size)
            axbuf.PutData(ds_buf->GetBuffer(), ds_size);
        if (ot_size)
            axbuf.PutData(ot_buf->GetBuffer(), ot_size);
        if (di_size)
            axbuf.PutData(di_buf->GetBuffer(), di_size);

        if (li_size)
            axbuf.PutData(li_buf->GetBuffer(), li_size);
        if (fi_size)
            axbuf.PutData(fi_buf->GetBuffer(), fi_size);
        if (mi_size)
            axbuf.PutData(mi_buf->GetBuffer(), mi_size);
        if (fi2_size)
            axbuf.PutData(fi2_buf->GetBuffer(), fi2_size);
        if (hpi_size)
            axbuf.PutData(hpi_buf->GetBuffer(), hpi_size);

        res = axbuf.SaveFile(oname);
        if (res < 0) {
#ifdef JPNMSG
            // Mes( (char *)"#出力ファイルを書き込めません" );
//            @autoreleasepool {
//                AppDelegate *global =
//                        (AppDelegate *) [[NSApplication sharedApplication] delegate];
//                global.logString = [global.logString
//                        stringByAppendingString:@"#出力ファイルを書き込めません\n"];
//            }
#else
            Mes("#Can't write output file.");
#endif
        } else {
            int n_mod, n_hpi;
            n_hpi = hpi_buf->GetSize() / sizeof(HPIDAT);
            n_mod = fi_buf->GetSize() / sizeof(STRUCTDAT);

//            @autoreleasepool {
//                AppDelegate *global =
//                        (AppDelegate *) [[NSApplication sharedApplication] delegate];
//                global.logString = [global.logString
//                        stringByAppendingFormat:
//                                @"# Code size (%d) String data size (%d) param size (%d)\n",
//                                cs_size, ds_size, mi_buf->GetSize()];
//                global.logString = [global.logString
//                        stringByAppendingFormat:@"# Vars (%d) Labels (%d) Modules (%d) "
//                                                @"Libs (%d) Plugins (%d)\n",
//                                                cg_valcnt, ot_size >> 2, n_mod, li_size,
//                                                n_hpi];
//                global.logString = [global.logString
//                        stringByAppendingFormat:@"# No error detected. (total %d bytes)\n",
//                                                hsphed.allsize];
//                global.logString = [global.logString stringByAppendingString:@"\n"];
//            }

            // Mesf( (char *)"#Code size (%d) String data size (%d) param size
            // (%d)",cs_size,ds_size,mi_buf->GetSize() );
            // Mesf( (char *)"#Vars (%d) Labels (%d) Modules (%d) Libs (%d) Plugins
            // (%d)",cg_valcnt,ot_size>>2,n_mod,li_size,n_hpi );
            // Mesf( (char *)"#No error detected. (total %d bytes)",hsphed.allsize );
            res = 0;
        }
    }

    delete hpi_buf;
    delete fi2_buf;
    delete mi_buf;
    delete fi_buf;
    delete li_buf;

    delete di_buf;
    delete ot_buf;
    delete ds_buf;
    delete cs_buf;

    return res;
}

void CToken::CG_MesLabelDefinition(int label_id) {
    if (!cg_debug)
        return;

    LABOBJ *const labobj = lb->GetLabel(label_id);
    if (labobj->def_file) {
#ifdef JPNMSG
        // Mesf((char *)"#識別子「%s」の定義位置: line %d in [%s]",
        // lb->GetName(label_id), labobj->def_line, labobj->def_file);
//        @autoreleasepool {
//            AppDelegate *global =
//                    (AppDelegate *) [[NSApplication sharedApplication] delegate];
//            global.logString = [global.logString
//                    stringByAppendingFormat:@"#識別子「%s」の定義位置: line %d in [%s]\n",
//                                            lb->GetName(label_id), labobj->def_line,
//                                            labobj->def_file];
//        }
#else
        Mesf("#Identifier '%s' has already defined in line %d in [%s]",
             lb->GetName(label_id), labobj->def_line, labobj->def_file);
#endif
    }
}
