//
//  string_utility.c
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#include "utility_string.h"
bool isEqualString(char *s1, char *s2) {
    if(strcmp(s1,s2) == 0) {
        return true;
    }
    else {
        return false;
    }
}
