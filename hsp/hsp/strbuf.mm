
//
//	HSP3 string support
//	(おおらかなメモリ管理をするバッファマネージャー)
//	(sbAllocでSTRBUF_BLOCKSIZEのバッファを確保します)
//	(あとはsbCopy,sbAddで自動的にバッファの再確保を行ないます)
//	onion software/onitama 2004/6
//
#include "strbuf.h"
#include "debug_message.h"
#include "hsp3struct_debug.h"
#include "supio_hsp3.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define REALLOC realloc
#define MALLOC malloc
#define FREE free

/*------------------------------------------------------------*/
/*
 system data
 */
/*------------------------------------------------------------*/

typedef struct
{
    STRBUF* mem;
    int len;
} SLOT;

static SLOT* mem_sb;
static int str_blockcur;
static int slot_len;
static STRBUF* freelist;

// STRINF_FLAG_NONE のとき STRINF::extptr を free list の次のポインタに使う
#define STRINF_NEXT(inf) ((inf).extptr)
#define STRBUF_NEXT(buf) STRINF_NEXT((buf)->inf)
#define GET_INTINF(buf) (&((buf)->inf.intptr->inf))

@implementation ViewController (strbuf)

/*------------------------------------------------------------*/
/*
 internal function
 */
/*------------------------------------------------------------*/

static void
BlockPtrPrepare(void)
{
    DEBUG_IN;
    STRBUF* sb;
    
    if (str_blockcur == 0) {
        mem_sb = (SLOT*)MALLOC(sizeof(SLOT));
    } else {
        mem_sb = (SLOT*)REALLOC(mem_sb, sizeof(SLOT) * (str_blockcur + 1));
    }
    
    sb = (STRBUF*)MALLOC(sizeof(STRBUF) * slot_len);
    if (sb == NULL) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPERR_OUT_OF_MEMORY];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    STRBUF* p = sb;
    STRBUF* pend = p + slot_len;
    mem_sb[str_blockcur].mem = sb;
    mem_sb[str_blockcur].len = slot_len;
    str_blockcur++;
    slot_len = (int)(slot_len * 1.8);
    
    while (p < pend) {
        p->inf.intptr = p;
        p->inf.flag = STRINF_FLAG_NONE;
        STRBUF_NEXT(p) = freelist;
        freelist = p;
        p++;
    }
    DEBUG_OUT;
}

static STRBUF*
BlockEntry(void)
{
    DEBUG_IN;
    //		空きエントリーブロックを探す
    //
    if (freelist == NULL) {
        BlockPtrPrepare();
    }
    STRBUF* buf = freelist;
    freelist = STRBUF_NEXT(freelist);
    DEBUG_OUT;
    return buf;
}

static char*
BlockAlloc(int size)
{
    DEBUG_IN;
    int* p;
    STRBUF* st;
    STRBUF* st2;
    STRINF* inf;
    st = BlockEntry();
    inf = &(st->inf);
    if (size <= STRBUF_BLOCKSIZE) {
        inf->flag = STRINF_FLAG_USEINT;
        inf->size = STRBUF_BLOCKSIZE;
        p = (int*)st->data;
        inf->ptr = (char*)p;
    } else {
        inf->flag = STRINF_FLAG_USEEXT;
        inf->size = size;
        st2 = (STRBUF*)MALLOC(size + sizeof(STRINF));
        p = (int*)(st2->data);
        inf->extptr = st2;
        inf->ptr = (char*)p;
        st2->inf = *inf;
    }
    *p = 0;
    // return inf->ptr;
    DEBUG_OUT;
    return (char*)p;
}

static void
FreeExtPtr(STRINF* inf)
{
    DEBUG_IN;
    if (inf->flag == STRINF_FLAG_USEEXT) {
        FREE(inf->extptr);
    }
    DEBUG_OUT;
}

static void
BlockFree(STRINF* inf)
{
    DEBUG_IN;
    FreeExtPtr(inf);
    STRINF_NEXT(*inf) = freelist;
    freelist = (STRBUF*)inf;
    inf->flag = STRINF_FLAG_NONE;
    DEBUG_OUT;
}

static char*
BlockRealloc(STRBUF* st, int size)
{
    DEBUG_IN;
    char* p;
    STRINF* inf;
    STRBUF* newst;
    inf = GET_INTINF(st);
    if (size <= inf->size)
        return inf->ptr;
    
    newst = (STRBUF*)MALLOC(size + sizeof(STRINF));
    p = newst->data;
    memcpy(p, inf->ptr, inf->size);
    FreeExtPtr(inf);
    inf->size = size;
    inf->flag = STRINF_FLAG_USEEXT;
    inf->ptr = p;
    inf->extptr = newst;
    
    newst->inf = *inf;
    DEBUG_OUT;
    return p;
}

void
BlockInfo(STRINF* inf)
{
    DEBUG_IN;
    STRBUF* newst;
    if (inf->flag == STRINF_FLAG_USEEXT) {
        newst = (STRBUF*)inf->extptr;
    }
    DEBUG_OUT;
}

/*------------------------------------------------------------*/
/*
 interface
 */
/*------------------------------------------------------------*/

void
sbInit(void)
{
    DEBUG_IN;
    str_blockcur = 0;
    freelist = NULL;
    slot_len = STRBUF_BLOCK_DEFAULT;
    BlockPtrPrepare();
    DEBUG_OUT;
}

void
sbBye(void)
{
    DEBUG_IN;
    int i;
    for (i = 0; i < str_blockcur; i++) {
        STRBUF* mem = mem_sb[i].mem;
        STRBUF* p = mem;
        STRBUF* pend = p + mem_sb[i].len;
        while (p < pend) {
            FreeExtPtr(&p->inf);
            p++;
        }
        FREE(mem);
    }
    FREE(mem_sb);
    DEBUG_OUT;
}

STRINF*
sbGetSTRINF(char* ptr)
{
    DEBUG_IN;
    DEBUG_OUT;
    return (STRINF*)(ptr - sizeof(STRINF));
}

char*
sbAlloc(int size)
{
    DEBUG_IN;
    int sz;
    sz = size;
    if (size < STRBUF_BLOCKSIZE)
        sz = STRBUF_BLOCKSIZE;
    DEBUG_OUT;
    return BlockAlloc(sz);
}

char*
sbAllocClear(int size)
{
    DEBUG_IN;
    char* p;
    p = sbAlloc(size);
    memset(p, 0, size);
    DEBUG_OUT;
    return p;
}

void
sbFree(void* ptr)
{
    DEBUG_IN;
    char* p;
    STRBUF* st;
    STRINF* inf;
    p = (char*)ptr;
    st = (STRBUF*)(p - sizeof(STRINF));
    inf = GET_INTINF(st);
    if (p != (inf->ptr)) {
        DEBUG_OUT;
        return;
    }
    BlockFree(inf);
    DEBUG_OUT;
}

char*
sbExpand(char* ptr, int size)
{
    DEBUG_IN;
    STRBUF* st;
    st = (STRBUF*)(ptr - sizeof(STRINF));
    DEBUG_OUT;
    return BlockRealloc(st, size);
}

void
sbCopy(char** pptr, char* data, int size)
{
    DEBUG_IN;
    int sz;
    char* ptr;
    char* p;
    STRBUF* st;
    ptr = *pptr;
    st = (STRBUF*)(ptr - sizeof(STRINF));
    sz = st->inf.size;
    p = st->inf.ptr;
    if (size > sz) {
        p = BlockRealloc(st, size);
        *pptr = p;
    }
    memcpy(p, data, size);
    DEBUG_OUT;
}

void
sbAdd(char** pptr, char* data, int size, int mode)
{
    DEBUG_IN;
    //		mode:0=normal/1=string
    int sz, newsize;
    STRBUF* st;
    char* ptr;
    char* p;
    ptr = *pptr;
    st = (STRBUF*)(ptr - sizeof(STRINF));
    p = st->inf.ptr;
    if (mode) {
        sz = (int)strlen(p); // 文字列データ
    } else {
        sz = st->inf.size; // 通常データ
    }
    newsize = sz + size;
    if (newsize > (st->inf.size)) {
        newsize = (newsize + 0xfff) & 0xfffff000; // 8K単位で確保
        // Alertf( "#Alloc%d",newsize );
        p = BlockRealloc(st, newsize);
        *pptr = p;
    }
    memcpy(p + sz, data, size);
    DEBUG_OUT;
}

void
sbStrCopy(char** ptr, char* str)
{
    DEBUG_IN;
    sbCopy(ptr, str, (int)strlen(str) + 1);
    DEBUG_OUT;
}

void
sbStrAdd(char** ptr, char* str)
{
    DEBUG_IN;
    sbAdd(ptr, str, (int)strlen(str) + 1, 1);
    DEBUG_OUT;
}

void*
sbGetOption(char* ptr)
{
    DEBUG_IN;
    STRBUF* st;
    st = (STRBUF*)(ptr - sizeof(STRINF));
    DEBUG_OUT;
    return st->inf.opt;
}

void
sbSetOption(char* ptr, void* option)
{
    DEBUG_IN;
    STRBUF* st;
    STRINF* inf;
    st = (STRBUF*)(ptr - sizeof(STRINF));
    st->inf.opt = option;
    inf = GET_INTINF(st);
    inf->opt = option;
    DEBUG_OUT;
}

@end

/*
 void sbInfo( char *ptr )
 {
 STRBUF *st;
 st = (STRBUF *)( ptr - sizeof(STRINF) );
 Alertf( "size:%d (%x)",st->inf.size, st->inf.ptr );
 }
 */

//@end
