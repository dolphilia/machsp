//
//  utility_stack.c
//  hsedle
//
//  Created by dolphilia on 2022/05/16.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#include "utility_stack.h"

static TAGINF mem_tag[TAGSTK_TAGMAX];    // Tag info
static TAGDATA mem_buf[TAGSTK_MAX];    // Main Buffer
static char tagerr[8];                // Tag Error String
static int tagent;                    // Tag Entry
static int lastidx;                // Current last index
static int gcount;                    // Global Counter

void stack_init(void) {
    for(int i = 0; i < TAGSTK_TAGMAX; i++) {
        mem_tag[i].name[0] = 0;
        mem_tag[i].uid = 0;
    }
    for(int i = 0; i < TAGSTK_MAX; i++) {
        mem_buf[i].data[0] = 0;
        mem_buf[i].tagid = -1;
    }
    tagent = 0;
    lastidx = 0;
    gcount = 0;
    strcpy(tagerr, "%err%");
}

int StrCmp(char *str1, char *str2) {
    int i = 0;
    while(1) {
        if (str1[i] != str2[i])
            return 0;
        if (str1[i] == 0)
            break;
        i++;
    }
    return -1;
}

/// タグを検索
///
int SearchTagID(char *tag) {
    if (tagent == 0 )
        return -1;
    for(int i = 0; i < tagent; i++) {
        if (StrCmp(mem_tag[i].name, tag))
            return i;
    }
    return -1;
}

/// タグを登録
///
int RegistTagID(char *tag) {
    int i, len;
    if (tagent >= TAGSTK_TAGMAX)
        return -1;
    i = tagent;
    tagent++;
    len = (int)strlen(tag);
    if (len >= TAGSTK_TAGSIZE)
        tag[TAGSTK_TAGSIZE - 1] = 0;
    strcpy(mem_tag[i].name, tag);
    return i;
}

/// タグIDに対応したユニーク名を取得
///
void GetTagUniqueName(int tagid, char *outname) {
    TAGINF *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX)) {
        sprintf(outname, "TagErr%04x", gcount++);
    } else {
        t = &mem_tag[tagid];
        sprintf(outname, "_%s_%04x", t->name, t->uid++);
    }
}

/// タグ名->タグID に変換する
///
int GetTagID(char *tag) {
    int tag_id = SearchTagID(tag);
    if (tag_id < 0) {
        tag_id = RegistTagID(tag);
    }
    return tag_id;
}

/// タグID->タグ名 に変換する
///
char *GetTagName(int tagid) {
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX ))
        return tagerr;
    return mem_tag[tagid].name;
}

/// すべてのスタックが解決されているかをチェック
///
/// @return 0=OK/1>=NG (resにエラースタックを含むタグ一覧)
///
int StackCheck(char *res) {
    int i, n;
    TAGDATA *t;
    strcpy(res, "\t");
    for(i = 0; i < TAGSTK_TAGMAX; i++) {
        mem_tag[i].check = 0;
    }
    if (lastidx < 1)
        return 0;
    i = lastidx;
    while(1) {
        i--;
        if (i < 0)
            break;
        t = &mem_buf[i];
        if (t->tagid >= 0 )
            mem_tag[t->tagid].check = -1;
    }
    n = 0;
    for(i = 0; i < TAGSTK_TAGMAX; i++) {
        if (mem_tag[i].check) {
            if (n)
                strcat(res, ", ");
            strcat(res, mem_tag[i].name);
            n++;
        }
    }
    return n;
}

/// タグID,strをスタックに入れる
///
int PushTag(int tagid, char *str) {
    int i, len;
    TAGDATA *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return -1;
    if (lastidx >= TAGSTK_MAX)
        return -1;
    i = lastidx;
    lastidx++;
    t = &mem_buf[i];
    t->tagid = tagid;
    len = (int)strlen(str);
    if (len >= TAGSTK_SIZE)
        str[TAGSTK_SIZE - 1] = 0;
    strcpy(t->data, str);
    return i;
}

/// タグIDに対応したスタックstrを取り出す
///
char *PopTag(int tagid) {
    int i;
    TAGDATA *t;
    char *p;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return NULL;
    if (lastidx < 1)
        return NULL;
    i = lastidx;
    while(1) {                            // ÉXÉ^ÉbÉNÇíHÇÈ
        i--;
        if (i < 0)
            return NULL;
        t = &mem_buf[i];
        if (t->tagid == tagid)
            break;
    }
    p = t->data;
    t->tagid = -1;
    i = lastidx - 1;
    while(1) {
        if (i < 0)
            break;
        if (mem_buf[i].tagid != -1)
            break;
        lastidx = i;
        i--;
    }
    return p;
}

/// タグIDに対応したスタックstrを取り出す(POPしない)
/// (level=スタック段数0,1,2…)
///
char *LookupTag(int tagid, int level) {
    int i, lv;
    TAGDATA *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return NULL;
    if (lastidx < 1)
        return NULL;
    lv = level;
    i = lastidx;
    while(1) { // スタックを辿る
        i--;
        if (i < 0)
            return NULL;
        t = &mem_buf[i];
        if (t->tagid == tagid) {
            if (lv == 0)
                break;
            lv--;
        }
    }
    return t->data;
}
