
//
//	strbuf.cpp header
//
#ifndef __strbuf_h
#define __strbuf_h

#include "hsp3config.h"
#include "hsp3struct.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define STRBUF_BLOCKSIZE 64
#define STRBUF_BLOCK_DEFAULT 0x400
#define STRBUF_SEGMENT_DEFAULT 0x1000
#define STRINF_FLAG_NONE 0
#define STRINF_FLAG_USEINT 1
#define STRINF_FLAG_USEEXT 2

//	STRBUF structure
//
typedef struct strbuf_t strbuf_t;

typedef struct {
    short flag;       // 使用フラグ(0=none/other=busy)
    short exflag;     // 拡張フラグ(未使用)
    strbuf_t *intptr; // 自身のアドレス
    int size;         // 確保サイズ
    char *ptr;        // バッファポインタ
    strbuf_t *extptr; // 外部バッファポインタ(STRINF)
    void *opt;        // オプション(ユーザー定義用)
} strbuf_info_t;

typedef struct strbuf_t {
    strbuf_info_t inf;           // バッファ情報
    char data[STRBUF_BLOCKSIZE]; // 内部バッファ
} strbuf_t;

typedef struct {
    strbuf_t *mem;
    int len;
} strbuf_memory_t;

void strbuf_init(void);
void strbuf_bye(void);
char *strbuf_alloc(int size);
char *strbuf_alloc_clear(int size);
void strbuf_free(void *ptr);
char *strbuf_expand(char *ptr, int size);
strbuf_info_t *strbuf_get_strbuf_info(char *ptr);
void strbuf_copy(char **ptr, char *data, int size);
void strbuf_copy_str(char **ptr, char *str);
void strbuf_add(char **ptr, char *data, int size, int offset);
void strbuf_add_str(char **ptr, char *str);
void *strbuf_get_option(char *ptr);
void strbuf_set_option(char *ptr, void *option);
void strbuf_info(char *ptr);

#endif
