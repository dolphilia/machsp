
//
//	supio.cpp 関数 (linux)
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include "hsp3config.h"
#include "hsp3struct.h"
#include "strbuf.h"

char *mem_ini(int size);
void mem_bye(void *ptr);
int mem_save(char *fname, void *mem, int msize, int seekofs);
void strcase(char *str);
int strcpy2(char *str1, char *str2);
int strcat2(char *str1, char *str2);
char *strstr2(char *target, char *src);
char *strchr2(char *target, char code);
void get_path(char *stmp, char *outbuf, int p2);
int make_dir(char *name);
int change_dir(char *name);
int delete_file(char *name);
int dirlist(char *fname, char **target, int p3);
int get_time(int index);
void str_split_init(void);
int str_split_get_ptr(void);
int str_split_get(char *srcstr, char *dststr, char splitchr, int len);
int get_limit(int num, int min, int max);
void cut_last_char(char *p, char code);
char *strsp_cmds(char *srcstr);
int htoi(char *str); //
int check_security(char *name);
char *strchr3(char *target, int code, int sw, char **findptr);
void trim_code(char *p, int code);
void trim_code_left(char *p, int code);
void trim_code_right(char *p, int code);
void alert(char *mes);
void alert_val(char *mes, int val);
void alert_format(char *format, ...); //
