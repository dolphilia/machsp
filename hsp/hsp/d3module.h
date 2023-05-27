//
//  d3module.h
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
// d3moduleを改変して利用しています
// http://sprocket.babyblue.jp/html/hsp_d3m.htm

#ifndef d3module_h
#define d3module_h

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#include "debug_message.h"
#import <math.h>

@interface d3module : NSObject {
    //
    double ginfo_winx;
    double ginfo_winy;
    //
    double wincx;
    double wincy;
    //
    double ax;
    double ay;
    double az;
    double af;
    double bx;
    double by;
    double bz;
    double cx;
    double cy;
    double cz;
    //
    double ex;
    double ey;
    double ez;
    double ef;
    //
    double dx;
    double dy;
    double dz;
    double df;
    //
    double cos0;
    double sin0;
    double cos1;
    double sin1;
    double l_cos1;
    //
    double LGSm00;
    double LGSm10;
    double LGSm20;
    double LGSmpx;
    double LGSm01;
    double LGSm11;
    double LGSm21;
    double LGSmpy;
    double LGSm02;
    double LGSm12;
    double LGSm22;
    double LGSmpz;
    double GSm00;
    double GSm10;
    double GSmpx;
    double GSm01;
    double GSm11;
    double GSm21;
    double GSmpy;
    double GSm02;
    double GSm12;
    double GSm22;
    double GSmpz;
}
- (void)set_winx:(double)x;

- (void)set_winy:(double)y;

- (double)getdx;

- (double)getdy;

- (double)getdz;

- (double)getex;

- (double)getey;

- (double)getez;

- (double)d3dist:(double)p1 p2:(double)p2 p3:(double)p3;

- (double)d3dist:(double)p1 p2:(double)p2;

- (double)d3dist:(double)p1;

- (double)d3rotateX:(double)x0 y0:(double)y0 va:(double)va; // getX
- (double)d3rotateY:(double)x0 y0:(double)y0 va:(double)va; // getY

- (double)d3vrotateX:(double)x0
                  y0:(double)y0
                  z0:(double)z0
                  vx:(double)vx
                  vy:(double)vy
                  vz:(double)vz
                  va:(double)va; // getX
- (double)d3vrotateY:(double)x0
                  y0:(double)y0
                  z0:(double)z0
                  vx:(double)vx
                  vy:(double)vy
                  vz:(double)vz
                  va:(double)va; // getY
- (double)d3vrotateZ:(double)x0
                  y0:(double)y0
                  z0:(double)z0
                  vx:(double)vx
                  vy:(double)vy
                  vz:(double)vz
                  va:(double)va; // getZ

- (void)d3setlocalmx:(double)LGmpx
               LGmpy:(double)LGmpy
               LGmpz:(double)LGmpz
               LGm00:(double)LGm00
               LGm10:(double)LGm10
               LGm20:(double)LGm20
               LGm01:(double)LGm01
               LGm11:(double)LGm11
               LGm21:(double)LGm21
               LGm02:(double)LGm02
               LGm12:(double)LGm12
               LGm22:(double)LGm22;

- (void)d3setcamx:(double)cpx
              cpy:(double)cpy
              cpz:(double)cpz
              ppx:(double)ppx
              ppy:(double)ppy
              ppz:(double)ppz
              ppv:(double)ppv;

- (void)d3setcam:(double)cpx
             cpy:(double)cpy
             cpz:(double)cpz
              tx:(double)tx
              ty:(double)ty
              tz:(double)tz
              tv:(double)tv;

- (void)d3setcam:(double)cpx
             cpy:(double)cpy
             cpz:(double)cpz
              tx:(double)tx
              ty:(double)ty
              tz:(double)tz;

- (void)d3setcam:(double)cpx
             cpy:(double)cpy
             cpz:(double)cpz
              tx:(double)tx
              ty:(double)ty;

- (void)d3setcam:(double)cpx cpy:(double)cpy cpz:(double)cpz tx:(double)tx;

- (void)d3setcam:(double)cpx cpy:(double)cpy cpz:(double)cpz;

- (void)d3setcam:(double)cpx cpy:(double)cpy;

- (void)d3setcam:(double)cpx;

- (void)d3setcam;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8
                p9:(double)p9
               p10:(double)p10
               p11:(double)p11
               p12:(double)p12;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8
                p9:(double)p9
               p10:(double)p10
               p11:(double)p11;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8
                p9:(double)p9
               p10:(double)p10;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8
                p9:(double)p9;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6;

- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5;

- (void)d3setlocal:(double)p1 p2:(double)p2 p3:(double)p3 p4:(double)p4;

- (void)d3setlocal:(double)p1 p2:(double)p2 p3:(double)p3;

- (void)d3setlocal:(double)p1 p2:(double)p2;

- (void)d3setlocal:(double)p1;

- (void)d3setlocal;

- (void)d3trans:(double)inx iny:(double)iny inz:(double)inz;      // dx,dy,dz,ef
- (void)d3transTypeE:(double)inx iny:(double)iny inz:(double)inz; // ex,ey,ez,ef

- (void)d3vpos:(double)v01 v02:(double)v02 v03:(double)v03;

- (double)d3getposX:(double)x y:(double)y z:(double)z;

- (double)d3getposY:(double)x y:(double)y z:(double)z;

@end

#endif /* d3module_h */
