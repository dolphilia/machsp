//
//  utility_hsp3int.h
//  hsp
//
//  Created by dolphilia on 2023/07/02.
//  Copyright © 2023 dolphilia. All rights reserved.
//

#ifndef utility_hsp3int_h
#define utility_hsp3int_h

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include "hsp3struct.h"

int note_to_data(char *adr, DATA *data);
int get_note_lines(char *adr);
size_t data_to_note_len(DATA *data, int num);
void data_to_note(DATA *data, char *adr, int num);

#endif /* utility_hsp3int_h */
