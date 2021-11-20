//
//  utility.h
//  hsp3compiler
//
//  Created by dolphilia on 2021/11/20.
//

#ifndef utility_h
#define utility_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *mem_ini( int size );
void mem_bye( void *ptr );
char *mem_alloc( void *base, int newsize, int oldsize );
int mem_load( const char *fname, void *mem, int msize );
int mem_save( const char *fname, const void *mem, int msize, int seekofs );

#endif /* utility_h */
