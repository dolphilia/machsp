//
// notepadオブジェクト関連ルーチン
//

#include <string.h>
#include "strnote.h"

///
CStrNote::CStrNote() {
    base = NULL;
    nulltmp[0] = 0;
}

///
CStrNote::~CStrNote() {
}

///
void CStrNote::Select(char *str) {
    base = str;
}

///
int CStrNote::GetSize(void) {
    return (int)strlen(base);
}

/// nngetの解説
///
/// @param nbase
/// @param line
/// @return
///
int CStrNote::nnget(char *nbase, int line) {
    char cur_char;
    lastcr = 0;
    nn = nbase;
    if (line < 0) {
        if ((int)strlen(nbase) == 0)
            return 0;
        nn += (int)strlen(nbase);
        cur_char = *(nn - 1);
        if ((cur_char == 10) || (cur_char == 13))
            lastcr++;
        return 0;
    }
    if (line) {
        int i = 0;
        while(1) {
            cur_char = *nn;
            if (cur_char == 0)
                return 1;
            nn++;
            if (cur_char == 10) {
                i++;
                if (i == line)
                    break;
            }
            if (cur_char == 13) {
                if (*nn == 10)
                    nn++;
                i++;
                if (i == line)
                    break;
            }
        }
    }
    lastcr++;
    return 0;
}

/// ノートから指定行を取得する
///
/// @param nres: 格納する文字列
/// @param line: 行番号
///
/// @return 0 = ok / 1 = no line
///
int CStrNote::GetLine(char *str, int line) {
    char *ptr = str;
    if (nnget(base, line))
        return 1;
    if (*nn == 0)
        return 1;
    char cur_char; //現在の文字
    while(1) {
        cur_char = *nn++;
        if ((cur_char == 0) || (cur_char == 13))
            break;
        if (cur_char == 10)
            break;
        *ptr++ = cur_char;
    }
    *ptr = 0;
    return 0;
}

/// ノートから指定行を取得する
///
/// @param str: 格納するための文字列
/// @param line: 行番号
/// @param max: 最大値
///
/// @return 0 = ok / 1 = no line
///
int CStrNote::GetLine(char *str, int line, int max) {
    char cur_char; //現在の文字
    char *ptr = str;
    if (nnget(base, line))
        return 1;
    if (*nn == 0)
        return 1;
    for(int i = 0; i < max; i++) {
        cur_char = *nn++;
        if ((cur_char == 0) || (cur_char == 13))
            break;
        if (cur_char == 10)
            break;
        *ptr++ = cur_char;
    }
    *ptr = 0;
    return 0;
}

/// ノートから指定行を取得する
///
/// @param line
///
/// @return
///
char *CStrNote::GetLineDirect(int line) {
    char cur_char;
    if (nnget(base, line))
        nn = nulltmp;
    lastnn = nn;
    while(1) {
        cur_char = *lastnn;
        if ((cur_char == 0) || (cur_char == 13))
            break;
        if (cur_char == 10)
            break;
        lastnn++;
    }
    lastcode = cur_char;
    *lastnn = 0;
    return nn;
}

/// 最後のGetLineDirect関数をレジュームする
///
void CStrNote::ResumeLineDirect(void) {
    *lastnn = lastcode;
}

/// GetMaxLineの解説
///
int CStrNote::GetMaxLine(void) {
    int a = 1;
    int b = 0;
    char cur_char;
    nn = base;
    while(1) {
        cur_char = *nn++;
        if (cur_char == 0)
            break;
        if ((cur_char == 13) || (cur_char == 10)) {
            a++;
            b = 0;
        }
        else
            b++;
    }
    if (b == 0)
        a--;
    return a;
}

/// 指定した行をノートに書き込む
///
/// @return 0 = ok / 1 = no line
///
int CStrNote::PutLine(char *nstr2, int line, int ovr) {
    int a = 0, ln, la, lw;
    char cur_char;
    char *ptr;
    char *p1;
    char *p2;
    char *nstr;
    if (nnget(base, line))
        return 1;
    if (lastcr == 0) {
        if (nn != base) {
            strcat(base, "¥r¥n");
            nn+=2;
        }
    }
    nstr = nstr2;
    if (nstr == NULL) {
        nstr = (char *)"";
    }
    ptr = nstr;
    if (nstr2 != NULL)
        strcat(nstr, "¥r¥n");
    ln = (int)strlen(nstr);			// base new str + cr/lf
    la = (int)strlen(base);
    lw = la - (int)(nn - base) + 1;
    //
    if (ovr) {						// when overwrite mode
        p1 = nn;
        a = 0;
        while(1) {
            cur_char = *p1++;
            if (cur_char == 0)
                break;
            a++;
            if ((cur_char == 13) || (cur_char == 10)) {
                break;
            }
        }
        ln = ln - a;
        lw = lw - a;
        if (lw < 1)
            lw = 1;
    }
    if (ln >= 0) {
        p1 = base + la + ln;
        p2 = base + la;
        for(a = 0; a < lw; a++) {
            *p1-- = *p2--;
        }
    }
    else {
        p1 = nn + a + ln;
        p2 = nn + a;
        for(a = 0; a < lw; a++) {
            *p1++ = *p2++;
        }
    }
    while(1) {
        cur_char = *ptr++;
        if (cur_char == 0)
            break;
        *nn++ = cur_char;
    }
    return 0;
}
