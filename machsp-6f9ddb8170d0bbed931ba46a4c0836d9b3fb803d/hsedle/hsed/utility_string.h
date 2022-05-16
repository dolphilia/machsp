//
//  utility_string.h
//  hsedle
//
//  Created by dolphilia on 2022/05/14.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#ifndef utility_string_h
#define utility_string_h

#include <string.h>

void Select(char *str);
int GetSize(void);
int GetMaxLine(void);
int GetLine(char *nres, int line);
int GetLine2(char *nres, int line, int max);
int PutLine(char *nstr, int line, int ovr);
char *GetLineDirect(int line);
void ResumeLineDirect(void);
int nnget( char *nbase, int line );

#endif /* utility_string_h */
