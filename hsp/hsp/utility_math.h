//
//  MathUtility.h
//  hsp
//
//  Created by 半澤 聡 on 2016/09/06.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef MathUtility_h
#define MathUtility_h

#include <stdio.h>
#include <math.h>
#include "debug_message.h"

double range2d(double x1, double y1, double x2, double y2);
double range3d(double x1, double y1, double z1, double x2, double y2, double z2);
unsigned long xor128();

#endif /* MathUtility_h */
