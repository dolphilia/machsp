
//
//		Memory buffer class
//			onion software/onitama 2002/2
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>
#include "membuf.h"

//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------

/// バッファ初期化
///
void CMemBuf::InitMemBuf(int sz) {
    size = sz;
    if (size < 0x1000) {
        size = 0x1000;
    } else if (size < 0x4000) {
        size = 0x4000;
    } else {
        size = 0x10000;
    }
    limit_size = size;
    mem_buf = (char *)malloc(limit_size);
    mem_buf[0] = 0;
    name[0] = 0;
    cur = 0;
    //	Indexバッファ初期化
    idxflag = 0;
    idxmax = -1;
    curidx = 0;
    idxbuf = NULL;
}

/// Indexバッファ初期化
///
void CMemBuf::InitIndexBuf(int sz) {
    idxflag = 1;
    idxmax = sz;
    curidx = 0;
    idxbuf = (int *)malloc(sizeof(int)*sz);
}

/// バッファ拡張チェック
///
/// szサイズを書き込み可能なバッファを返す
///
/// @return もとのバッファ先頭ptr
///
char *CMemBuf::PreparePtr(int sz) {
    int i;
    char *p;
    if ((cur+sz) < size) {
        p = mem_buf + cur;
        cur += sz;
        return p;
    }
    //	expand buffer (VCのreallocは怖いので使わない)
    i = size;
    while(i <= (cur + sz))
        i += limit_size;
    p = (char *)malloc(i);
    memcpy(p, mem_buf, size);
    free(mem_buf);
    size = i;
    mem_buf = p;
    p = mem_buf + cur;
    cur += sz;
    return p;
}

/// インデックスを登録
///
void CMemBuf::RegistIndex(int val) {
    int *p;
    if (idxflag == 0)
        return;
    idxbuf[curidx++] = val;
    if (curidx >= idxmax) {
        idxmax += 256;
        p = (int *)malloc(sizeof(int)*idxmax);
        memcpy(p, idxbuf, sizeof(int)*curidx);
        free(idxbuf);
        idxbuf = p;
    }
}

void CMemBuf::Index(void) {
    RegistIndex(cur);
}

void CMemBuf::Put(int data) {
    char *p = PreparePtr(sizeof(int));
    memcpy(p, &data, sizeof(int));
}

void CMemBuf::Put(short data) {
    char *p = PreparePtr(sizeof(short));
    memcpy(p, &data, sizeof(short));
}

void CMemBuf::Put(char data) {
    char *p = PreparePtr(1);
    *p = data;
}

void CMemBuf::Put(unsigned char data) {
    unsigned char *p = (unsigned char *)PreparePtr(1);
    *p = data;
}

void CMemBuf::Put(float data) {
    char *p = PreparePtr(sizeof(float));
    memcpy(p, &data, sizeof(float));
}

void CMemBuf::Put(double data) {
    char *p = PreparePtr(sizeof(double));
    memcpy(p, &data, sizeof(data));
}

void CMemBuf::PutStr(char *data) {
    char *p = PreparePtr((int)strlen(data));
    strcpy(p, data);
}

/// ダブルクォート内専用str
///
void CMemBuf::PutStrDQ(char *data) {
    unsigned char *src = (unsigned char *)data;
    unsigned char *p;
    unsigned char a1;
    unsigned char a2 = '\0';
    int fl;
    while(1) {
        a1 = *src++;
        if (a1 == 0)
            break;
        fl = 0;
        if (a1 == '\\') {					// ¥を¥¥に
            p = (unsigned char *)PreparePtr(1);
            *p = a1;
        }
        if (a1 == 13) {					// CRを¥nに
            fl = 1;
            a2 = 10;
            if (*src == 10)
                src++;
        }
        if (a1 >= 129) {						// 全角文字チェック
            if (a1 <= 159) {
                fl = 1;
                a2 = *src++;
            }
            else if (a1 >= 224) {
                fl = 1;
                a2 = *src++;
            }
            if (a2 == 0)
                break;
        }
        if (fl) {
            p = (unsigned char *)PreparePtr(2);
            p[0] = a1;
            p[1] = a2;
            continue;
        }
        p = (unsigned char *)PreparePtr(1);
        *p = a1;
    }
}

void CMemBuf::PutStrBlock(char *data) {
    char *p = PreparePtr((int)strlen(data) + 1);
    strcpy(p, data);
}

void CMemBuf::PutCR(void) {
    char *p = PreparePtr(2);
    *p++ = 13;
    *p++ = 10;
}

void CMemBuf::PutData(void *data, int sz) {
    char *p = PreparePtr(sz);
    memcpy(p, (char *)data, sz);
}

#if ( WIN32 || _WIN32 ) && ! __CYGWIN__
# define VSNPRINTF _vsnprintf
#else
# define VSNPRINTF vsnprintf
#endif

void CMemBuf::PutStrf(char *format, ...) {
    va_list args;
    int c = cur;
    int space = size - cur;
    while(1) {
        char *p = PreparePtr(space - 1);
        cur = c;
        space = size - cur;
        int n;
        va_start(args, format);
        n = VSNPRINTF(p, space, format, args);
        va_end(args);
        if (0 <= n && n < space) {
            cur += n;
            return;
        }
        if (0 <= n) {
            space = n + 1;
        } else {
            space *= 2;
        }
    }
}

/// バッファに指定ファイルの内容を追加
///
/// @return ファイルサイズ(-1=error))
///
int CMemBuf::PutFile(char *fname) {
    char *p;
    int length;
    FILE *ff = fopen(fname, "rb");
    if (ff == NULL)
        return -1;
    fseek(ff, 0, SEEK_END);
    length = (int)ftell(ff);			// normal file size
    fclose(ff);
    
    p = PreparePtr(length + 1);
    ff = fopen(fname, "rb");
    fread(p, 1, length, ff);
    fclose(ff);
    p[length] = 0;
    
    strcpy(name, fname);
    return length;
}

void CMemBuf::ReduceSize(int new_cur) {
    assert(new_cur >= 0 && new_cur <= cur);
    cur = new_cur;
}

//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------

/// 空のバッファを初期化(64K)
///
CMemBuf::CMemBuf(void) {
    InitMemBuf(0x10000);
}

/// 指定サイズのバッファを初期化(64K)
///
CMemBuf::CMemBuf(int sz) {
    InitMemBuf(sz);
}

CMemBuf::~CMemBuf(void) {
    if (mem_buf != NULL) {
        free(mem_buf);
        mem_buf = NULL;
    }
    if (idxbuf != NULL) {
        free(idxbuf);
        idxbuf = NULL;
    }
}

void CMemBuf::AddIndexBuffer(void) {
    InitIndexBuf(256);
}

void CMemBuf::AddIndexBuffer(int sz) {
    InitIndexBuf(sz);
}

char *CMemBuf::GetBuffer(void) {
    return mem_buf;
}

int CMemBuf::GetBufferSize(void) {
    return size;
}

int *CMemBuf::GetIndexBuffer(void) {
    return idxbuf;
}

void CMemBuf::SetIndex(int idx, int val) {
    if (idxflag == 0)
        return;
    idxbuf[idx] = val;
}

int CMemBuf::GetIndex(int idx) {
    if (idxflag == 0)
        return -1;
    return idxbuf[idx];
}

int CMemBuf::GetIndexBufferSize(void) {
    if (idxflag == 0)
        return -1;
    return curidx;
}

int CMemBuf::SearchIndexValue(int val) {
    int j;
    if (idxflag == 0)
        return -1;
    j = -1;
    for(int i = 0; i < cur; i++) {
        if (idxbuf[i] == val)
            j = i;
    }
    return j;
}

/// バッファをファイルにセーブ
///
/// @return:ファイルサイズ(-1=error))
///
int CMemBuf::SaveFile(char *fname) {
    FILE *fp = fopen(fname, "wb");
    int flen;
    if (fp == NULL)
        return -1;
    flen = (int)fwrite(mem_buf, 1, cur, fp);
    fclose(fp);
    strcpy(name, fname);
    return flen;
}

/// ファイル名を取得
///
char *CMemBuf::GetFileName(void) {
    return name;
}
