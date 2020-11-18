//
//	strbuf.cpp header
//
#ifndef __strbuf_h
#define __strbuf_h
#include "hsp3config.h"
#define STRBUF_BLOCKSIZE 64
#define STRBUF_BLOCK_DEFAULT 0x400
#define STRBUF_SEGMENT_DEFAULT 0x1000
#define STRINF_FLAG_NONE 0
#define STRINF_FLAG_USEINT 1
#define STRINF_FLAG_USEEXT 2
//	STRBUF structure
//
typedef struct STRBUF STRBUF;
typedef struct
{
    //	String Data structure
    //
    short flag;     // 使用フラグ(0=none/other=busy)
    short exflag;   // 拡張フラグ(未使用)
    STRBUF* intptr; // 自身のアドレス
    int size;       // 確保サイズ
    char* ptr;      // バッファポインタ
    STRBUF* extptr; // 外部バッファポインタ(STRINF)
    void* opt;      // オプション(ユーザー定義用)
} STRINF;
struct STRBUF
{
    //	String Data structure
    //
    STRINF inf;                  // バッファ情報
    char data[STRBUF_BLOCKSIZE]; // 内部バッファ
};
#import "ViewController.h"
#import <Foundation/Foundation.h>
@interface
ViewController (strbuf) {
}
-(void)sbInit;
-(void)sbBye;
-(char*)sbAlloc:(int)size;
-(char*)sbAllocClear:(int)size;
-(void)sbFree:(void*)ptr;
-(char*)sbExpand:(char*)ptr size:(int)size;
-(STRINF*)sbGetSTRINF:(char*)ptr;
-(void)sbCopy:(char**)ptr data:(char*)data size:(int)size;
-(void)sbStrCopy:(char**)ptr str:(char*)str;
-(void)sbAdd:(char**)ptr data:(char*)data size:(int)size mode:(int)mode;
-(void)sbStrAdd:(char**)ptr str:(char*)str;
-(void*)sbGetOption:(char*)ptr;
-(void)sbSetOption:(char*)ptr option:(void*)option;
//-(void)sbInfo:(char*)ptr;
@end
#endif
