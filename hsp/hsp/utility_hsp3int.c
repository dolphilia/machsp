//
//  utility_hsp3int.c
//  hsp
//
//  Created by dolphilia on 2023/07/02.
//  Copyright © 2023 dolphilia. All rights reserved.
//

#include "utility_hsp3int.h"

//----Sort Routines
bool less_int_1(DATA const *lhs, DATA const *rhs) {
    int cmp = (lhs->as.ikey - rhs->as.ikey);
    return (cmp < 0) || (cmp == 0 && lhs->info < rhs->info);
}

bool less_int_0(DATA const *lhs, DATA const *rhs) {
    int cmp = (lhs->as.ikey - rhs->as.ikey);
    return (cmp > 0) || (cmp == 0 && lhs->info < rhs->info);
}

bool less_double_1(DATA const *lhs, DATA const *rhs) {
    int cmp = (lhs->as.dkey < rhs->as.dkey ? -1 : (lhs->as.dkey > rhs->as.dkey ? 1 : 0));
    return (cmp < 0) || (cmp == 0 && lhs->info < rhs->info);
}

bool less_double_0(DATA const *lhs, DATA const *rhs) {
    int cmp = (lhs->as.dkey < rhs->as.dkey ? -1 : (lhs->as.dkey > rhs->as.dkey ? 1 : 0));
    return (cmp > 0) || (cmp == 0 && lhs->info < rhs->info);
}

bool less_str_1(DATA const *lhs, DATA const *rhs) {
    int cmp = (strcmp(lhs->as.skey, rhs->as.skey));
    return (cmp < 0) || (cmp == 0 && lhs->info < rhs->info);
}

bool less_str_0(DATA const *lhs, DATA const *rhs) {
    int cmp = (strcmp(lhs->as.skey, rhs->as.skey));
    return (cmp > 0) || (cmp == 0 && lhs->info < rhs->info);
}

int note_to_data(char *adr, DATA *data) {
    char *p = adr;
    int line = 0;
    while (*p != '\0') {
        data[line].as.skey = p;
        data[line].info = line;
        while (*p != '\0') {
            char c = *p;
            if (c == '\n' || c == '\r') {
                *p = '\0';
            }
            p++;
            if (c == '\n') break;
            if (c == '\r') {
                if (*p == '\n') p++;
                break;
            }
        }
        line++;
    }
    return line;
}

int get_note_lines(char *adr) {
    int line = 0;
    char *p = adr;
    while (*p != '\0') {
        while (*p != '\0') {
            char c = *p++;
            if (c == '\n') break;
            if (c == '\r') {
                if (*p == '\n') p++;
                break;
            }
        }
        line++;
    }
    return line;
}

size_t data_to_note_len(DATA *data, int num) {
    size_t len = 0;
    for (int i = 0; i < num; i++) {
        char *s = data[i].as.skey;
        len += strlen(s) + 2;  // strlen("¥r¥n")
    }
    return len;
}

void data_to_note(DATA *data, char *adr, int num) {
    char *p = adr;
    char *s;
    for (int i = 0; i < num; i++) {
        s = data[i].as.skey;
        strcpy(p, s);
        p += strlen(s);
        *p++ = 13;
        *p++ = 10;  // Add CR/LF
    }
    *p = 0;
}
