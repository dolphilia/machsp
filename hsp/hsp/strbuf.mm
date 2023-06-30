
//
//	HSP3文字列サポート
//
//	(おおらかなメモリ管理をするバッファマネージャー)
//	(sbAllocでSTRBUF_BLOCKSIZEのバッファを確保します)
//	(あとはsbCopy,sbAddで自動的にバッファの再確保を行ないます)
//	onion software/onitama 2004/6
//

#include "strbuf.h"

#define REALLOC realloc
#define MALLOC malloc
#define FREE free

//------------------------------------------------------------
// system data
//------------------------------------------------------------

typedef struct {
    STRBUF *mem;
    int len;
} SLOT;

static SLOT *mem_sb;
static int str_blockcur;
static int slot_len;
static strbuf_t *freelist;

// STRINF_FLAG_NONE のとき STRINF::extptr を free list の次のポインタに使う
#define STRINF_NEXT(inf) ((inf).extptr)
#define STRBUF_NEXT(buf) STRINF_NEXT((buf)->inf)
#define GET_INTINF(buf) (&((buf)->inf.intptr->inf))

//------------------------------------------------------------
// internal function
//------------------------------------------------------------

static void BlockPtrPrepare(void) {
    if (str_blockcur == 0) {
        mem_sb = (SLOT *) MALLOC(sizeof(SLOT));
    } else {
        mem_sb = (SLOT *) REALLOC(mem_sb, sizeof(SLOT) * (str_blockcur + 1));
    }

    STRBUF *sb = (STRBUF *) MALLOC(sizeof(STRBUF) * slot_len);
    if (sb == NULL) {
        fprintf(stderr, "Error: %d\n", HSPERR_OUT_OF_MEMORY);
        exit(EXIT_FAILURE);
    }

    STRBUF *p = sb;
    STRBUF *pend = p + slot_len;

    mem_sb[str_blockcur].mem = sb;
    mem_sb[str_blockcur].len = slot_len;
    str_blockcur++;
    slot_len = (int) (slot_len * 1.8);

    while (p < pend) {
        p->inf.intptr = p;
        p->inf.flag = STRINF_FLAG_NONE;
        STRBUF_NEXT(p) = freelist;
        freelist = p;
        p++;
    }
}

/// 空きエントリーブロックを探す
///
static STRBUF *BlockEntry(void) {
    if (freelist == NULL) {
        BlockPtrPrepare();
    }
    STRBUF *buf = freelist;
    freelist = STRBUF_NEXT(freelist);
    return buf;
}

static char *BlockAlloc(int size) {
    int *p;
    STRBUF *st = BlockEntry();
    STRBUF *st2;
    strbuf_info_t *inf = &(st->inf);
    if (size <= STRBUF_BLOCKSIZE) {
        inf->flag = STRINF_FLAG_USEINT;
        inf->size = STRBUF_BLOCKSIZE;
        p = (int *) st->data;
        inf->ptr = (char *) p;
    } else {
        inf->flag = STRINF_FLAG_USEEXT;
        inf->size = size;
        st2 = (STRBUF *) MALLOC(size + sizeof(strbuf_info_t));
        p = (int *) (st2->data);
        inf->extptr = st2;
        inf->ptr = (char *) p;
        st2->inf = *inf;
    }
    *p = 0;
    // return inf->ptr;
    return (char *) p;
}

static void FreeExtPtr(strbuf_info_t *inf) {
    if (inf->flag == STRINF_FLAG_USEEXT) {
        FREE(inf->extptr);
    }
}

static void BlockFree(strbuf_info_t *inf) {
    FreeExtPtr(inf);
    STRINF_NEXT(*inf) = freelist;
    freelist = (STRBUF *) inf;
    inf->flag = STRINF_FLAG_NONE;
}

static char *BlockRealloc(STRBUF *st, int size) {
    strbuf_info_t *inf = GET_INTINF(st);

    if (size <= inf->size)
        return inf->ptr;
    STRBUF *newst = (STRBUF *) MALLOC(size + sizeof(strbuf_info_t));
    char *p = newst->data;

    memcpy(p, inf->ptr, inf->size);
    FreeExtPtr(inf);
    inf->size = size;
    inf->flag = STRINF_FLAG_USEEXT;
    inf->ptr = p;
    inf->extptr = newst;
    newst->inf = *inf;
    return p;
}

void BlockInfo(strbuf_info_t *inf) {
    STRBUF *newst;
    if (inf->flag == STRINF_FLAG_USEEXT) {
        newst = (STRBUF *) inf->extptr;
    }
}

//------------------------------------------------------------
// interface
//------------------------------------------------------------

void strbuf_init(void) {
    str_blockcur = 0;
    freelist = NULL;
    slot_len = STRBUF_BLOCK_DEFAULT;
    BlockPtrPrepare();
}

void strbuf_bye(void) {
    for (int i = 0; i < str_blockcur; i++) {
        STRBUF *mem = mem_sb[i].mem;
        STRBUF *p = mem;
        STRBUF *pend = p + mem_sb[i].len;
        while (p < pend) {
            FreeExtPtr(&p->inf);
            p++;
        }
        FREE(mem);
    }
    FREE(mem_sb);
}

strbuf_info_t *strbuf_get_strbuf_info(char *ptr) {
    return (strbuf_info_t *) (ptr - sizeof(strbuf_info_t));
}

char *strbuf_alloc(int size) {
    int sz = size;
    if (size < STRBUF_BLOCKSIZE)
        sz = STRBUF_BLOCKSIZE;
    return BlockAlloc(sz);
}

char *strbuf_alloc_clear(int size) {
    char *p = strbuf_alloc(size);
    memset(p, 0, size);
    return p;
}

void strbuf_free(void *ptr) {
    char *p = (char *) ptr;
    STRBUF *st = (STRBUF *) (p - sizeof(strbuf_info_t));
    strbuf_info_t *inf = GET_INTINF(st);
    if (p != (inf->ptr)) {
        return;
    }
    BlockFree(inf);
}

char *strbuf_expand(char *ptr, int size) {
    STRBUF *st = (STRBUF *) (ptr - sizeof(strbuf_info_t));
    return BlockRealloc(st, size);
}

void strbuf_copy(char **pptr, char *data, int size) {
    char *ptr = *pptr;
    STRBUF *st = (STRBUF *) (ptr - sizeof(strbuf_info_t));
    int sz = st->inf.size;
    char *p = st->inf.ptr;
    if (size > sz) {
        p = BlockRealloc(st, size);
        *pptr = p;
    }
    memcpy(p, data, size);
}

/// mode:0=normal/1=string
///        
void strbuf_add(char **pptr, char *data, int size, int mode) {
    char *ptr = *pptr;
    STRBUF *st = (STRBUF *) (ptr - sizeof(strbuf_info_t));
    char *p = st->inf.ptr;
    int sz;

    if (mode) {
        sz = (int) strlen(p); // 文字列データ
    } else {
        sz = st->inf.size; // 通常データ
    }

    int newsize = sz + size;
    if (newsize > (st->inf.size)) {
        newsize = (newsize + 0xfff) & 0xfffff000; // 8K単位で確保
        // alert_format( "#Alloc%d",newsize );
        p = BlockRealloc(st, newsize);
        *pptr = p;
    }
    memcpy(p + sz, data, size);
}

void strbuf_copy_str(char **ptr, char *str) {
    strbuf_copy(ptr, str, (int) strlen(str) + 1);
}

void strbuf_add_str(char **ptr, char *str) {
    strbuf_add(ptr, str, (int) strlen(str) + 1, 1);
}

void *strbuf_get_option(char *ptr) {
    STRBUF *st = (STRBUF *) (ptr - sizeof(strbuf_info_t));
    return st->inf.opt;
}

void strbuf_set_option(char *ptr, void *option) {
    STRBUF *st = (STRBUF *) (ptr - sizeof(strbuf_info_t));
    strbuf_info_t *inf;
    st->inf.opt = option;
    inf = GET_INTINF(st);
    inf->opt = option;
}

//@end

/*
 void strbuf_info( char *ptr )
 {
 strbuf_t *st;
 st = (strbuf_t *)( ptr - sizeof(STRINF) );
 alert_format( "size:%d (%x)",st->inf.size, st->inf.ptr );
 }
 */
