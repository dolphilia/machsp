//
//  utility.c
//  hsp3compiler
//
//  Created by dolphilia on 2021/11/20.
//

#include "utility.h"

char *mem_ini(int size) {
    return (char *)calloc(size, 1);
}

void mem_bye(void *ptr) {
    free(ptr);
}

int mem_load(const char *file_name, void *mem, int mem_size) {
    FILE *fp;
    int file_size;
    fp = fopen(file_name, "rb");
    if (fp == NULL) //ファイルが存在しない場合
        return -1;
    file_size = (int)fread(mem, 1, mem_size, fp);
    fclose(fp);
    return file_size;
}

/// Description
///
/// @param fname <#fname description#>
/// @param mem <#mem description#>
/// @param msize <#msize description#>
/// @param seekofs <#seekofs description#>
///
int mem_save(const char *fname, const void *mem, int msize, int seekofs) {
    FILE *fp;
    int size;
    if (seekofs < 0) {
        fp = fopen(fname, "wb");
    }
    else {
        fp = fopen(fname, "r+b");
    }
    if (fp == NULL)
        return -1;
    if (seekofs >= 0 )
        fseek(fp, seekofs, SEEK_SET);
    size = (int)fwrite(mem, 1, msize, fp);
    fclose(fp);
    return size;
}

char *mem_alloc(void *base, int newsize, int oldsize) {
    char *p;
    if (base == NULL) {
        p = (char *)calloc( newsize, 1 );
        return p;
    }
    if (newsize <= oldsize)
        return (char *)base;
    p = (char*)calloc( newsize, 1 );
    memcpy(p, base, oldsize);
    free(base);
    return p;
}

