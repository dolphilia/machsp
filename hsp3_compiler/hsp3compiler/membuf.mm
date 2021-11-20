//@
//
//		Memory buffer class
//			onion software/onitama 2002/2
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <stdarg.h>
#import <assert.h>
#import "membuf.h"

@implementation CMemBuf : NSObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        //        空のバッファを初期化(64K)
        //
        //[self InitMemBuf:0x10000];
    }
    return self;
}
//CMemBuf::CMemBuf( int sz )
//{
//    //        指定サイズのバッファを初期化(64K)
//    //
//    InitMemBuf( sz );
//}
/**
* 箇条書き
    - aaa
    - aaa
    - aaa

* 番号付き
    1. aaa
    2. aaa
    3. aaa

* コード1
 // ほげほげ
 let hoge = Hoge()
 hoge.doSomething()


* コード2

    // ふがふが
    let fuga = Fuga()
    fuga.doSomething()


:param: 引数1
:param: 引数2
:returns: 戻り値
*/
- (void)dealloc {
    if (mem_buf != NULL) {
        free(mem_buf);
        mem_buf = NULL;
    }
    if (idxbuf != NULL) {
        free(idxbuf);
        idxbuf = NULL;
    }
}

/// バッファを初期化する
/// @param sz バッファのサイズ
-(void)InitMemBuf:(int)sz {
    //	バッファ初期化
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

//    Indexバッファ初期化
-(void)InitIndexBuf:(int)sz {
    idxflag = 1;
    idxmax = sz;
    curidx = 0;
    idxbuf = (int *)malloc(sizeof(int)*sz);
}

//    バッファ拡張チェック
//    (szサイズを書き込み可能なバッファを返す)
//        (return:もとのバッファ先頭ptr)
//
-(char*)PreparePtr:(int)sz {
    int i;
    char *p;
    if ((cur + sz) < size) {
        p = mem_buf + cur;
        cur += sz;
        return p;
    }
    //	expand buffer (VCのreallocは怖いので使わない)
    i = size;
    while(i <= (cur + sz)) {
        i += limit_size;
    }
    p = (char *)malloc(i);
    memcpy(p, mem_buf, size);
    free(mem_buf);
    size = i;
    mem_buf = p;
    p = mem_buf + cur;
    cur += sz;
    return p;
}

//    インデックスを登録
-(void)RegistIndex:(int)val {
    int *p;
    if (idxflag == 0)
        return;
    idxbuf[curidx] = val;
    curidx++;
    if (curidx >= idxmax) {
        idxmax += 256;
        p = (int *)malloc(sizeof(int)*idxmax);
        memcpy(p, idxbuf, sizeof(int)*curidx);
        free(idxbuf);
        idxbuf = p;
    }
}

-(void)Index {
    [self RegistIndex:cur];
}

-(void)Put_int:(int)data {
    char *p;
    p = [self PreparePtr:sizeof(int)];
    memcpy(p, &data, sizeof(int));
}

-(void)Put_short:(short)data {
    char *p;
    p = [self PreparePtr:sizeof(short)];
    memcpy(p, &data, sizeof(short));
}

-(void)Put_char:(char)data {
    char *p;
    p = [self PreparePtr:1];
    *p = data;
}

-(void)Put_uchar:(unsigned char)data {
    unsigned char *p;
    p = (unsigned char *)[self PreparePtr:1];
    *p = data;
}

-(void)Put_float:(float)data {
    char *p;
    p = [self PreparePtr:sizeof(float)];
    memcpy(p, &data, sizeof(float));
}

-(void)Put_double:(double)data {
    char *p;
    p = [self PreparePtr:sizeof(double)];
    memcpy(p, &data, sizeof(data));
}

-(void)PutStr:(char*)data {
    char *p;
    p = [self PreparePtr:(int)strlen(data)];
    strcpy(p, data);
}

//        ダブルクォート内専用str
//
-(void)PutStrDQ:(char*)data {
    unsigned char *src;
    unsigned char *p;
    unsigned char a1;
    unsigned char a2 = '\0';
    int fl;
    src = (unsigned char *)data;
    while(1) {
        a1 = *src;
        src++;
        if (a1 == 0)
            break;
        fl = 0;
        if (a1 == '\\') {					// ¥を¥¥に
            p = (unsigned char *)[self PreparePtr:1];
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
                a2 = *src;
                src++;
            }
            else if (a1 >= 224) {
                fl = 1;
                a2 = *src;
                src++;
            }
            if (a2 == 0)
                break;
        }
        if (fl) {
            p = (unsigned char *)[self PreparePtr:2];
            p[0] = a1;
            p[1] = a2;
            continue;
        }
        p = (unsigned char *)[self PreparePtr:1];
        *p = a1;
    }
}

-(void)PutStrBlock:(char*)data {
    char *p;
    p = [self PreparePtr:(int)strlen(data) + 1];
    strcpy(p, data);
}

-(void)PutCR {
    char *p;
    p = [self PreparePtr:2];
    *p = 13;
    p++;
    *p = 10;
    p++;
}

-(void)PutData:(void*)data sz:(int)sz {
    char *p;
    p = [self PreparePtr:sz];
    memcpy(p, (char *)data, sz);
}

#if ( WIN32 || _WIN32 ) && ! __CYGWIN__
# define VSNPRINTF _vsnprintf
#else
# define VSNPRINTF vsnprintf
#endif

-(void)PutStrf:(char*)format, ... {
    va_list args;
    int c = cur;
    int space = size - cur;
    while(1) {
        char *p = [self PreparePtr:space - 1];
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

//        バッファに指定ファイルの内容を追加
//        (return:ファイルサイズ(-1=error))
//
-(int)PutFile:(char*)fname {
    char *p;
    int length;
    FILE *ff;
    ff = fopen(fname, "rb");
    if (ff == NULL)
        return -1;
    fseek(ff, 0, SEEK_END);
    length = (int)ftell(ff);			// normal file size
    fclose(ff);
    p = [self PreparePtr:length+1];
    ff = fopen(fname, "rb");
    fread(p, 1, length, ff);
    fclose(ff);
    p[length] = 0;
    strcpy(name, fname);
    return length;
}

-(void)ReduceSize:(int)new_cur {
    assert(new_cur >= 0 && new_cur <= cur);
    cur = new_cur;
}

-(void)AddIndexBuffer {
    [self InitIndexBuf:256];
}

-(void)AddIndexBuffer:(int)sz {
    [self InitIndexBuf:sz];
}

-(char*)GetBuffer {
    return mem_buf;
}

-(int)GetSize {
    return cur;
}

-(int)GetBufferSize {
    return size;
}

-(int*)GetIndexBuffer {
    return idxbuf;
}

-(void)SetIndex:(int)idx val:(int)val {
    if (idxflag == 0)
        return;
    idxbuf[idx] = val;
}

-(int)GetIndex:(int)idx {
    if (idxflag == 0)
        return -1;
    return idxbuf[idx];
}

-(int)GetIndexBufferSize {
    if (idxflag == 0 )
        return -1;
    return curidx;
}

-(int)SearchIndexValue:(int)val {
    int i;
    int j;
    if (idxflag == 0 )
        return -1;
    j = -1;
    for(i = 0; i < cur; i++) {
        if (idxbuf[i] == val)
            j = i;
    }
    return j;
}

//        バッファをファイルにセーブ
//        (return:ファイルサイズ(-1=error))
//
-(int)SaveFile:(char*)fname {
    FILE *fp;
    int flen;
    fp = fopen(fname, "wb");
    if (fp == NULL)
        return -1;
    flen = (int)fwrite(mem_buf, 1, cur, fp);
    fclose(fp);
    strcpy(name,fname);
    return flen;
}

-(char*)GetFileName {
    //		ファイル名を取得
    //
    return name;
}
@end
