//
//  d3module.m
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
// d3moduleを改変して利用しています
// http://sprocket.babyblue.jp/html/hsp_d3m.htm
#import "d3module.h"
#import <Foundation/Foundation.h>
@implementation d3module
- (instancetype)init
{
    self = [super init];
    if (self) {
        ax = 0.0;
        ay = 0.0;
        az = 0.0;
        af = 0.0;
        bx = 0.0;
        by = 0.0;
        bz = 0.0;
        cx = 0.0;
        cy = 0.0;
        cz = 0.0;
        ex = 0.0;
        ey = 0.0;
        ez = 0.0;
        ef = 0.0;
        dx = 0.0;
        dy = 0.0;
        dz = 0.0;
        df = 0.0;
        cos0 = 0.0;
        sin0 = 0.0;
        cos1 = 0.0;
        sin1 = 0.0;
        l_cos1 = 0.0;
        LGSm00 = 0.0;
        LGSm10 = 0.0;
        LGSm20 = 0.0;
        LGSmpx = 0.0;
        LGSm01 = 0.0;
        LGSm11 = 0.0;
        LGSm21 = 0.0;
        LGSmpy = 0.0;
        LGSm02 = 0.0;
        LGSm12 = 0.0;
        LGSm22 = 0.0;
        LGSmpz = 0.0;
        GSm00 = 0.0;
        GSm10 = 0.0;
        GSmpx = 0.0;
        GSm01 = 0.0;
        GSm11 = 0.0;
        GSm21 = 0.0;
        GSmpy = 0.0;
    }
    return self;
}
- (void)set_winx:(double)x
{
    ginfo_winx = x;
    wincx = ginfo_winx / 2;
}
- (void)set_winy:(double)y
{
    ginfo_winy = y;
    wincy = ginfo_winy / 2;
}
// d3dist 距離 (ベクトル) の絶対値を求める (x, y, z)
- (double)d3dist:(double)p1 p2:(double)p2 p3:(double)p3
{
    return sqrt((p1) * (p1) + (p2) * (p2) + (p3) * (p3));
}
- (double)d3dist:(double)p1 p2:(double)p2
{
    return [self d3dist:p1 p2:p2 p3:0];
}
- (double)d3dist:(double)p1
{
    return [self d3dist:p1 p2:0 p3:0];
}
// d3rotate 平面座標回転演算 (x1, y1,  x0, y0,  va)
//出力変数 x1 y1, 入力値 x0 y0, 回転角度 va
- (double)d3rotateX:(double)x0 y0:(double)y0 va:(double)va
{
    return x0 * cos(va) - y0 * sin(va);
}
- (double)d3rotateY:(double)x0 y0:(double)y0 va:(double)va
{
    return x0 * sin(va) + y0 * cos(va);
}
// d3vrotate 任意軸周りの空間回転演算 (x1, y1, z1,  x0, y0, z0,  vx, vy, vz, va)
//出力変数 x1 y1 z1, 入力値 x0 y0 z0, 回転軸ベクトル vx vy vz, 回転角度 va
- (double)d3vrotateX:(double)x0
                  y0:(double)y0
                  z0:(double)z0
                  vx:(double)vx
                  vy:(double)vy
                  vz:(double)vz
                  va:(double)va
{
    // 回転軸の単位ベクトル化
    double r = [self d3dist:vx p2:vy p3:vz];
    ax = vx / r;
    ay = vy / r;
    az = vz / r;
    // 回転演算
    sin1 = sin(va);
    cos1 = cos(va);
    l_cos1 = 1.0 - cos1;
    return (ax * ax * l_cos1 + cos1) * x0 + (ax * ay * l_cos1 - az * sin1) * y0 +
    (az * ax * l_cos1 + ay * sin1) * z0;
}
- (double)d3vrotateY:(double)x0
                  y0:(double)y0
                  z0:(double)z0
                  vx:(double)vx
                  vy:(double)vy
                  vz:(double)vz
                  va:(double)va
{
    // 回転軸の単位ベクトル化
    double r = [self d3dist:vx p2:vy p3:vz];
    ax = vx / r;
    ay = vy / r;
    az = vz / r;
    // 回転演算
    sin1 = sin(va);
    cos1 = cos(va);
    l_cos1 = 1.0 - cos1;
    return (ax * ay * l_cos1 + az * sin1) * x0 + (ay * ay * l_cos1 + cos1) * y0 +
    (ay * az * l_cos1 - ax * sin1) * z0;
}
- (double)d3vrotateZ:(double)x0
                  y0:(double)y0
                  z0:(double)z0
                  vx:(double)vx
                  vy:(double)vy
                  vz:(double)vz
                  va:(double)va
{
    // 回転軸の単位ベクトル化
    double r = [self d3dist:vx p2:vy p3:vz];
    ax = vx / r;
    ay = vy / r;
    az = vz / r;
    // 回転演算
    sin1 = sin(va);
    cos1 = cos(va);
    l_cos1 = 1.0 - cos1;
    return (az * ax * l_cos1 - ay * sin1) * x0 +
    (ay * az * l_cos1 + ax * sin1) * y0 + (az * az * l_cos1 + cos1) * z0;
}
// d3setlocalmx ローカル座標系設定 平行移動量 + 3x3 変形マトリクス (px, py, pz,
// m00, m01, m02,  m10, m11, m12,  m20, m21, m22)
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
               LGm22:(double)LGm22
{
    // Local->Global->Screen Matrix Setup
    // 座標変換演算用マトリクス設定 (Local->Global Matrix と Global->Screen Matrix
    // を合成演算)
    LGSm00 = GSm00 * LGm00 + GSm10 * LGm01;
    LGSm10 = GSm00 * LGm10 + GSm10 * LGm11;
    LGSm20 = GSm00 * LGm20 + GSm10 * LGm21;
    LGSmpx = GSm00 * LGmpx + GSm10 * LGmpy + GSmpx;
    LGSm01 = GSm01 * LGm00 + GSm11 * LGm01 + GSm21 * LGm02;
    LGSm11 = GSm01 * LGm10 + GSm11 * LGm11 + GSm21 * LGm12;
    LGSm21 = GSm01 * LGm20 + GSm11 * LGm21 + GSm21 * LGm22;
    LGSmpy = GSm01 * LGmpx + GSm11 * LGmpy + GSm21 * LGmpz + GSmpy;
    LGSm02 = GSm02 * LGm00 + GSm12 * LGm01 + GSm22 * LGm02;
    LGSm12 = GSm02 * LGm10 + GSm12 * LGm11 + GSm22 * LGm12;
    LGSm22 = GSm02 * LGm20 + GSm12 * LGm21 + GSm22 * LGm22;
    LGSmpz = GSm02 * LGmpx + GSm12 * LGmpy + GSm22 * LGmpz + GSmpz;
}
// d3setcamx カメラ位置設定 (cx, cy, cz,  tx, ty, tz)
- (void)d3setcamx:(double)cpx
              cpy:(double)cpy
              cpz:(double)cpz
              ppx:(double)ppx
              ppy:(double)ppy
              ppz:(double)ppz
              ppv:(double)ppv
{
    //パラメータ設定
    wincx = ginfo_winx / 2;
    wincy = ginfo_winy / 2;
    //カメラ方向三角比計算
    ax = cpx - ppx;
    ay = cpy - ppy;
    az = cpz - ppz;
    double r0 = sqrt(ax * ax + ay * ay);
    double r1 = sqrt(r0 * r0 + az * az);
    if (r0 != 0.0) {
        cos0 = -ax / r0;
        sin0 = -ay / r0;
    }
    if (r1 != 0.0) {
        cos1 = r0 / r1;
        sin1 = az / r1;
    }
    // Global->Screen Matrix Setup
    //グローバル座標 → スクリーン座標 変換マトリクス
    az = ppv / (0.01 + ginfo_winy); // 視野角
    GSm00 = sin0;
    GSm10 = -cos0; // GSm20 =  0.0
    GSm01 = cos0 * cos1 * az;
    GSm11 = sin0 * cos1 * az;
    GSm21 = -sin1 * az;
    GSm02 = cos0 * sin1;
    GSm12 = sin0 * sin1;
    GSm22 = cos1;
    GSmpx = -(GSm00 * cpx + GSm10 * cpy);
    GSmpy = -(GSm01 * cpx + GSm11 * cpy + GSm21 * cpz);
    GSmpz = -(GSm02 * cpx + GSm12 * cpy + GSm22 * cpz);
    // Local->Global->Screen Matrix Setup
    // 座標変換演算用マトリクス設定 (Global->Screen Matrix で初期化)
    [self d3setlocalmx:0.0
                 LGmpy:0.0
                 LGmpz:0.0
                 LGm00:1.0
                 LGm10:0.0
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
// d3setcam カメラ位置設定 (cx, cy, cz,  tx, ty, tz, tv)
// パラメータ省略用マクロ
- (void)d3setcam:(double)cpx
             cpy:(double)cpy
             cpz:(double)cpz
              tx:(double)tx
              ty:(double)ty
              tz:(double)tz
              tv:(double)tv
{
    [self d3setcamx:cpx cpy:cpy cpz:cpz ppx:tx ppy:ty ppz:tz ppv:tv];
}
- (void)d3setcam:(double)cpx
             cpy:(double)cpy
             cpz:(double)cpz
              tx:(double)tx
              ty:(double)ty
              tz:(double)tz
{
    [self d3setcamx:cpx cpy:cpy cpz:cpz ppx:tx ppy:ty ppz:tz ppv:1.0];
}
- (void)d3setcam:(double)cpx
             cpy:(double)cpy
             cpz:(double)cpz
              tx:(double)tx
              ty:(double)ty
{
    [self d3setcamx:cpx cpy:cpy cpz:cpz ppx:tx ppy:ty ppz:0.0 ppv:1.0];
}
- (void)d3setcam:(double)cpx cpy:(double)cpy cpz:(double)cpz tx:(double)tx
{
    [self d3setcamx:cpx cpy:cpy cpz:cpz ppx:tx ppy:0.0 ppz:0.0 ppv:1.0];
}
- (void)d3setcam:(double)cpx cpy:(double)cpy cpz:(double)cpz
{
    [self d3setcamx:cpx cpy:cpy cpz:cpz ppx:0.0 ppy:0.0 ppz:0.0 ppv:1.0];
}
- (void)d3setcam:(double)cpx cpy:(double)cpy
{
    [self d3setcamx:cpx cpy:cpy cpz:0.0 ppx:0.0 ppy:0.0 ppz:0.0 ppv:1.0];
}
- (void)d3setcam:(double)cpx
{
    [self d3setcamx:cpx cpy:0.0 cpz:0.0 ppx:0.0 ppy:0.0 ppz:0.0 ppv:1.0];
}
- (void)d3setcam
{
    [self d3setcamx:0.0 cpy:0.0 cpz:0.0 ppx:0.0 ppy:0.0 ppz:0.0 ppv:1.0];
}
// d3setlocal ローカル座標系設定 (px, py, pz,  m00, m01, m02,  m10, m11, m12,
// m20, m21, m22)
//パラメータ省略用マクロ (パラメータを省略した場合、ローカル座標系 ==
//グローバル座標系となる)
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
               p12:(double)p12
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:p7
                 LGm11:p8
                 LGm21:p9
                 LGm02:p10
                 LGm12:p11
                 LGm22:p12];
}
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
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:p7
                 LGm11:p8
                 LGm21:p9
                 LGm02:p10
                 LGm12:p11
                 LGm22:1.0];
}
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
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:p7
                 LGm11:p8
                 LGm21:p9
                 LGm02:p10
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8
                p9:(double)p9
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:p7
                 LGm11:p8
                 LGm21:p9
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
                p8:(double)p8
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:p7
                 LGm11:p8
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
                p7:(double)p7
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:p7
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
                p6:(double)p6
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:p6
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1
                p2:(double)p2
                p3:(double)p3
                p4:(double)p4
                p5:(double)p5
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:p5
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1 p2:(double)p2 p3:(double)p3 p4:(double)p4
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:p4
                 LGm10:0.0
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1 p2:(double)p2 p3:(double)p3
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:p3
                 LGm00:1.0
                 LGm10:0.0
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1 p2:(double)p2
{
    [self d3setlocalmx:p1
                 LGmpy:p2
                 LGmpz:0.0
                 LGm00:1.0
                 LGm10:0.0
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal:(double)p1
{
    [self d3setlocalmx:p1
                 LGmpy:0.0
                 LGmpz:0.0
                 LGm00:1.0
                 LGm10:0.0
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
- (void)d3setlocal
{
    [self d3setlocalmx:0.0
                 LGmpy:0.0
                 LGmpz:0.0
                 LGm00:1.0
                 LGm10:0.0
                 LGm20:0.0
                 LGm01:0.0
                 LGm11:1.0
                 LGm21:0.0
                 LGm02:0.0
                 LGm12:0.0
                 LGm22:1.0];
}
// d3trans 座標変換 macro (inx, iny, inz,  oux, ouy, ouz, ouf)
- (void)d3trans:(double)inx iny:(double)iny inz:(double)inz
{
    dz = LGSm01 * inx + LGSm11 * iny + LGSm21 * inz + LGSmpy;
    df = 0.0;
    if (dz > 0.0) {
        dx = wincx + (LGSm00 * inx + LGSm10 * iny + LGSm20 * inz + LGSmpx) / dz;
        dy = wincy - (LGSm02 * inx + LGSm12 * iny + LGSm22 * inz + LGSmpz) / dz;
        if (dx / 8000 == 1.0 || dy / 8000 == 1.0) {
            df = 1.0;
        }
    }
}
- (void)d3transTypeE:(double)inx iny:(double)iny inz:(double)inz
{
    ez = LGSm01 * inx + LGSm11 * iny + LGSm21 * inz + LGSmpy;
    af = 0.0;
    if (ez > 0.0) {
        ex = wincx + (LGSm00 * inx + LGSm10 * iny + LGSm20 * inz + LGSmpx) / ez;
        ey = wincy - (LGSm02 * inx + LGSm12 * iny + LGSm22 * inz + LGSmpz) / ez;
        if (ex / 8000 == 1.0 || ey / 8000 == 1.0) {
            af = 1.0;
        }
    }
}
// d3vpos 座標変換 (x, y, z) -> dx, dy, dz, df
- (void)d3vpos:(double)v01 v02:(double)v02 v03:(double)v03
{
    // bkup last-data
    ex = dx;
    ey = dy;
    ef = df;
    [self d3trans:v01 iny:v02 inz:v03];
}
- (double)d3getposX:(double)x y:(double)y z:(double)z
{
    [self d3vpos:x v02:y v03:z];
    if (df == 1.0) {
    } else {
    }
    return dx;
}
- (double)d3getposY:(double)x y:(double)y z:(double)z
{
    [self d3vpos:x v02:y v03:z];
    if (df == 1.0) {
    } else {
    }
    return dy;
}
- (double)getdx
{
    return dx;
}
- (double)getdy
{
    return dy;
}
- (double)getdz
{
    return dz;
}
- (double)getex
{
    return ex;
}
- (double)getey
{
    return ey;
}
- (double)getez
{
    return ez;
}
@end
