//
//  utility_com.h
//  hsedle
//
//  Created by dolphilia on 2022/05/16.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#ifndef utility_com_h
#define utility_com_h

#include <stdio.h>

typedef struct _COM_GUID {
    int Data1; // 4バイト
    short Data2; // 2バイト
    short Data3; // 2バイト
    char Data4[8]; // 1バイト×8
} COM_GUID;

int ConvertIID(COM_GUID *guid, char *name);

#endif /* utility_com_h */
