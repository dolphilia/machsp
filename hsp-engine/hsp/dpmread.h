//	dpmread.c functions

//#import "hsp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "hsp3config.h"
#include "hsp3struct.h"
#include "supio_hsp3.h"

typedef struct MEMFILE {
    char *pt;  // target ptr
    int cur;   // current ptr
    int size;  // size
} MEMFILE;

int dpmchk(char *fname);
int dpm_chkmemf(char *fname);
FILE *dpm_open(char *fname);
void dpm_close();
int dpm_fread(void *mem, int size, FILE *stream);
int dpm_ini(char *dpmfile, long dpmofs, int chksum, int deckey);
void dpm_bye();
int dpm_read(char *fname, void *readmem, int rlen, int seekofs);
int dpm_exist(char *fname);
int dpm_filebase(char *fname);
void dpm_getinf(char *inf);
int dpm_filecopy(char *fname, char *sname);
void dpm_memfile(void *mem, int size);
char *dpm_readalloc(char *fname);
