//
//  MathUtility.c
//

#include "utility_math.h"

/// ２点間の距離を求める（２次元）
///
double range2d(double x1, double y1, double x2, double y2) {
    return pow((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1), 0.5);
}

/// ２点間の距離を求める（３次元）
///
double range3d(double x1, double y1, double z1, double x2, double y2, double z2) {
    return pow((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1), 0.5);
}

unsigned long xor128() {
    static unsigned long x = 123456789, y = 362436069, z = 521288629, w = 88675123;
    unsigned long t;
    t = (x ^ (x << 11));
    x = y;
    y = z;
    z = w;
    return (w = (w ^ (w >> 19)) ^ (t ^ (t >> 8)));
}
