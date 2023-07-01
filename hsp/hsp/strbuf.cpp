//
//	文字列バッファマネージャー
//

#include "strbuf.h"

static strbuf_memory_t *mem_sb;
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

static void prepare_block_ptr(void) {
    if (str_blockcur == 0) {
        mem_sb = (strbuf_memory_t *) malloc(sizeof(strbuf_memory_t));
    } else {
        mem_sb = (strbuf_memory_t *) realloc(mem_sb, sizeof(strbuf_memory_t) * (str_blockcur + 1));
    }

    strbuf_t *sb = (strbuf_t *) malloc(sizeof(strbuf_t) * slot_len);
    if (sb == NULL) {
        fprintf(stderr, "Error: %d\n", HSPERR_OUT_OF_MEMORY);
        exit(EXIT_FAILURE);
    }

    strbuf_t *p = sb;
    strbuf_t *pend = p + slot_len;

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

// 空きエントリーブロックを探す
static strbuf_t *search_entry_block(void) {
    if (freelist == NULL) {
        prepare_block_ptr();
    }
    strbuf_t *buf = freelist;
    freelist = STRBUF_NEXT(freelist);
    return buf;
}

static char *alloc_block(int size) {
    int *p;
    strbuf_t *st = search_entry_block();
    strbuf_t *st2;
    strbuf_info_t *inf = &(st->inf);
    if (size <= STRBUF_BLOCKSIZE) {
        inf->flag = STRINF_FLAG_USEINT;
        inf->size = STRBUF_BLOCKSIZE;
        p = (int *) st->data;
        inf->ptr = (char *) p;
    } else {
        inf->flag = STRINF_FLAG_USEEXT;
        inf->size = size;
        st2 = (strbuf_t *) malloc(size + sizeof(strbuf_info_t));
        p = (int *) (st2->data);
        inf->extptr = st2;
        inf->ptr = (char *) p;
        st2->inf = *inf;
    }
    *p = 0;
    return (char *) p;
}

static void free_ext_ptr(strbuf_info_t *inf) {
    if (inf->flag == STRINF_FLAG_USEEXT) {
        free(inf->extptr);
    }
}

static void free_block(strbuf_info_t *inf) {
    free_ext_ptr(inf);
    STRINF_NEXT(*inf) = freelist;
    freelist = (strbuf_t *) inf;
    inf->flag = STRINF_FLAG_NONE;
}

static char *realloc_block(strbuf_t *st, int size) {
    strbuf_info_t *inf = GET_INTINF(st);

    if (size <= inf->size)
        return inf->ptr;
    strbuf_t *newst = (strbuf_t *) malloc(size + sizeof(strbuf_info_t));
    char *p = newst->data;

    memcpy(p, inf->ptr, inf->size);
    free_ext_ptr(inf);
    inf->size = size;
    inf->flag = STRINF_FLAG_USEEXT;
    inf->ptr = p;
    inf->extptr = newst;
    newst->inf = *inf;
    return p;
}

void block_info(strbuf_info_t *inf) {
    strbuf_t *newst;
    if (inf->flag == STRINF_FLAG_USEEXT) {
        newst = (strbuf_t *) inf->extptr;
    }
}

//------------------------------------------------------------
// interface
//------------------------------------------------------------

void strbuf_init(void) {
    str_blockcur = 0;
    freelist = NULL;
    slot_len = STRBUF_BLOCK_DEFAULT;
    prepare_block_ptr();
}

void strbuf_bye(void) {
    for (int i = 0; i < str_blockcur; i++) {
        strbuf_t *mem = mem_sb[i].mem;
        strbuf_t *p = mem;
        strbuf_t *pend = p + mem_sb[i].len;
        while (p < pend) {
            free_ext_ptr(&p->inf);
            p++;
        }
        free(mem);
    }
    free(mem_sb);
}

strbuf_info_t *strbuf_get_strbuf_info(char *ptr) {
    return (strbuf_info_t *) (ptr - sizeof(strbuf_info_t));
}

char *strbuf_alloc(int size) {
    int sz = size;
    if (size < STRBUF_BLOCKSIZE)
        sz = STRBUF_BLOCKSIZE;
    return alloc_block(sz);
}

char *strbuf_alloc_clear(int size) {
    char *p = strbuf_alloc(size);
    memset(p, 0, size);
    return p;
}

void strbuf_free(void *ptr) {
    char *p = (char *) ptr;
    strbuf_t *st = (strbuf_t *) (p - sizeof(strbuf_info_t));
    strbuf_info_t *inf = GET_INTINF(st);
    if (p != (inf->ptr)) {
        return;
    }
    free_block(inf);
}

char *strbuf_expand(char *ptr, int size) {
    strbuf_t *st = (strbuf_t *) (ptr - sizeof(strbuf_info_t));
    return realloc_block(st, size);
}

void strbuf_copy(char **pptr, char *data, int size) {
    char *ptr = *pptr;
    strbuf_t *st = (strbuf_t *) (ptr - sizeof(strbuf_info_t));
    int sz = st->inf.size;
    char *p = st->inf.ptr;
    if (size > sz) {
        p = realloc_block(st, size);
        *pptr = p;
    }
    memcpy(p, data, size);
}

// mode:0=normal/1=string
void strbuf_add(char **pptr, char *data, int size, int mode) {
    char *ptr = *pptr;
    strbuf_t *st = (strbuf_t *) (ptr - sizeof(strbuf_info_t));
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
        p = realloc_block(st, newsize);
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
    strbuf_t *st = (strbuf_t *) (ptr - sizeof(strbuf_info_t));
    return st->inf.opt;
}

void strbuf_set_option(char *ptr, void *option) {
    strbuf_t *st = (strbuf_t *) (ptr - sizeof(strbuf_info_t));
    strbuf_info_t *inf;
    st->inf.opt = option;
    inf = GET_INTINF(st);
    inf->opt = option;
}
