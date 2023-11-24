//
//  utility_stack.h
//  hsedle
//
//  Created by dolphilia on 2022/05/16.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#ifndef utility_stack_h
#define utility_stack_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAGSTK_MAX 256
#define TAGSTK_SIZE 124
#define TAGSTK_TAGMAX 256
#define TAGSTK_TAGSIZE 56

/// tag info storage
///
typedef struct TAGINF {
    char name[TAGSTK_TAGSIZE];    // tag name
    int check;                    // resolve check flag
    int uid;                    // unique ID
} TAGINF;

/// tag data storage
/// 
typedef struct TAGDATA {
    int tagid;                    // tag ID
    char data[TAGSTK_SIZE];        // data
} TAGDATA;

void stack_init(void);
int GetTagID(char *tag);
char *GetTagName(int tagid);
int PushTag(int tagid, char *str);
char *PopTag(int tagid);
char *LookupTag(int tagid, int level);
void GetTagUniqueName(int tagid, char *outname);
int StackCheck(char *res);

//int StrCmp( char *str1, char *str2 );
//int SearchTagID( char *tag );
//int RegistTagID( char *tag );

#endif /* utility_stack_h */
