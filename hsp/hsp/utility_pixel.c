//
//  PixelUtility.c
//  hsp
//
//  Created by 半澤 聡 on 2016/09/02.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#include "utility_pixel.h"

Color get_pixel_color(uint8_t *pixel_data, int32_t point_x, int32_t point_y, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    int index = point_y * canvas_size_width * 4 + point_x * 4;
    Color color;
    color.red = pixel_data[index];
    color.green = pixel_data[index + 1];
    color.blue = pixel_data[index + 2];
    color.alpha = pixel_data[index + 3];
    
    return color;
}

/// hsvによる色指定
/// h(0-191)/s(0-255)/v(0-255)
///
Color get_color_hsv(int32_t hue, int32_t saturation, int32_t brightness) {
    int h, s, v;
    Color color;
    color.red = 0;
    color.green = 0;
    color.blue = 0;
    color.alpha = 255;
    int f, i, p, q, t;
    int mv = 255 * 32;
    int mp = 255 * 16;
    // overflow check
    h = hue % 192;
    s = saturation & 255;
    v = brightness & 255;
    // hsv -> rgb 変換
    i = h / 32;
    f = h % 32;
    p = (v * (mv - s * 32) + mp) / mv;
    q = (v * (mv - s * f) + mp) / mv;
    t = (v * (mv - s * (32 - f)) + mp) / mv;
    
    switch(i) {
        case 0:
        case 1:
            color.red = q;
            color.green = v;
            color.blue = p;
            break;
        case 2:
            color.red = p;
            color.green = v;
            color.blue = t;
            break;
        case 3:
            color.red = p;
            color.green = q;
            color.blue = v;
            break;
        case 4:
            color.red = t;
            color.green = p;
            color.blue = v;
            break;
        case 5:
            color.red = v;
            color.green = p;
            color.blue = q;
            break;
        case 6:
            color.red = v;
            color.green = t;
            color.blue = p;
            break;
    }
    
    return color;
}

void clear_canvas_rgba(uint8_t *pixel_data, int32_t canvas_size_width, int32_t canvas_size_height, int32_t color_number) {
    
    if(color_number == 0) {
        memset(pixel_data, 255, sizeof(uint8_t) * canvas_size_width * canvas_size_height * 4);
    } else {
        int minx = 0;
        int miny = 0;
        int diffx = canvas_size_width;
        int diffy = canvas_size_height;
        int grayscale = 255;
        switch(color_number) {
            case 1:
                grayscale = 192;
                break;
            case 2:
                grayscale = 128;
                break;
            case 3:
                grayscale = 64;
                break;
            case 4:
                grayscale = 0;
                break;
        }
        uint8_t onepixel[4] = {grayscale, grayscale, grayscale, 255};
        uint8_t xline[diffx * 4];
        void* xlineAddr = &xline;
        void* pixeldataAddr = pixel_data;
        int xline_size = diffx * 4;
        for (int x = 0; x < diffx; x++) {
            memcpy(xlineAddr, onepixel, 4);
            xlineAddr += 4;
        }
        pixeldataAddr += minx * 4 + miny * canvas_size_width * 4;
        for (int y = 0; y < diffy; y++) {
            memcpy(pixeldataAddr, xline, xline_size);
            pixeldataAddr += canvas_size_width * 4;
        }
    }
    
}

void set_pixel_rgb(uint8_t *pixel_data, int32_t point_x, int32_t point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    if (point_x < 0 || point_y < 0 || point_x >= canvas_size_width || point_y >= canvas_size_height) {
        return;
    }
    int index = point_y * canvas_size_width * 3 + point_x * 3;
    pixel_data[index] = color_red;
    pixel_data[index + 1] = color_green;
    pixel_data[index + 2] = color_blue;
}

void set_pixel_rgba(uint8_t *pixel_data, int32_t point_x, int32_t point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    if (point_x < 0 || point_y < 0 || point_x >= canvas_size_width || point_y >= canvas_size_height) {
        return;
    }
    int index = point_y * canvas_size_width * 4 + point_x * 4;
    pixel_data[index] = color_red;
    pixel_data[index + 1] = color_green;
    pixel_data[index + 2] = color_blue;
    pixel_data[index + 3] = color_alpha;
}

/// 点を打つ アルファ付き（透明度を保護する
///
void set_pixel_rgba_protect_alpha(uint8_t *pixel_data, int32_t point_x, int32_t point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height, int32_t protect_alpha) {
    
    if (point_x<0 || point_y<0 || point_x >= canvas_size_width || point_y >= canvas_size_height) {
        return;
    }
    
    Color color = get_pixel_color(pixel_data, point_x, point_y, canvas_size_width, canvas_size_height);
    
    double srcA = ((double)protect_alpha) / 255.0;
    double dstA = ((double)color.alpha) / 255.0;
    double newA = srcA + dstA - srcA * dstA;
    
    color.alpha = (uint8_t)(newA * 255 + 0.5);
    
    if(color.alpha) {
        color.red = (uint8_t)((color_red * srcA + color.red * dstA * (1 - srcA)) / newA + 0.5);
        color.green = (uint8_t)((color_green * srcA + color.green * dstA * (1 - srcA)) / newA + 0.5);
        color.blue = (uint8_t)((color_blue * srcA + color.blue * dstA * (1 - srcA)) / newA + 0.5);
    }
    
    int index = point_y * canvas_size_width * 4 + point_x * 4;
    
    pixel_data[index] = color.red;
    pixel_data[index + 1] = color.green;
    pixel_data[index + 2] = color.blue;
    pixel_data[index + 3] = color.alpha;
}

/// 改良版：点を打つ アルファ付き（透明度を保護する
///
void set_pixel_rgba_protect_alpha_fast(uint8_t *pixel_data, int32_t point_x, int32_t point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height, int32_t protect_alpha, int32_t index) {
    
    if (point_x < 0 || point_y < 0 || point_x >= canvas_size_width || point_y >= canvas_size_height) {
        return;
    }
    
    Color color = get_pixel_color(pixel_data, point_x, point_y, canvas_size_width, canvas_size_height);

    double srcA = ((double)protect_alpha) / 255.0;
    double dstA = ((double)color.alpha) / 255.0;
    double newA = srcA + dstA - srcA * dstA;

    color.alpha = (uint8_t)(newA * 255 + 0.5);

    double dstA_mul_1_minus_srcA = dstA * (1 - srcA);
    
    if(color.alpha) {
        color.red = (uint8_t)((color_red * srcA + color.red * dstA_mul_1_minus_srcA) / newA + 0.5);
        color.green = (uint8_t)((color_green * srcA + color.green * dstA_mul_1_minus_srcA) / newA + 0.5);
        color.blue = (uint8_t)((color_blue * srcA + color.blue * dstA_mul_1_minus_srcA) / newA + 0.5);
    }
    
    pixel_data[index] = color.red;
    pixel_data[index + 1] = color.green;
    pixel_data[index + 2] = color.blue;
    pixel_data[index + 3] = color.alpha;
}

void set_line_rgb(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    //let
    int deltax = abs(end_point_x - start_point_x);
    int deltay = abs(end_point_y - start_point_y);
    int xstep = (end_point_x > start_point_x) ? 1 : -1;
    int ystep = (end_point_y > start_point_y) ? 1 : -1;
    
    //var
    int x = start_point_x;
    int y = start_point_y;
    int error;
    
    if (deltax >= deltay) {
        error = 2 * deltay - deltax;
        for (int i = 0; i <= deltax; ++i) {
            if (x < 0 || x > canvas_size_width || y < 0 || y > canvas_size_height) { //描画範囲を超える場合
            } else {
                set_pixel_rgb(pixel_data, x, y, color_red, color_green, color_blue, canvas_size_width, canvas_size_height);
            }
            x += xstep;
            error += 2 * deltay;
            if (error >= 0) {
                y += ystep;
                error -= 2 * deltax;
            }
        }
    }
    else {
        error = 2 * deltax - deltay;
        for (int i = 0; i <= deltay; ++i) {
            if (x < 0 || x > canvas_size_width || y < 0 || y > canvas_size_height) {
            } else {
                set_pixel_rgb(pixel_data, x, y, color_red, color_green, color_blue, canvas_size_width, canvas_size_height);
            }
            y += ystep;
            error += 2 * deltax;
            if (error >= 0) {
                x += xstep;
                error -= 2 * deltay;
            }
        }
    }
}

void set_line_rgba(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    //let
    int deltax = abs(end_point_x - start_point_x);
    int deltay = abs(end_point_y - start_point_y);
    int xstep = (end_point_x > start_point_x) ? 1 : -1;
    int ystep = (end_point_y > start_point_y) ? 1 : -1;
    
    //var
    int x = start_point_x;
    int y = start_point_y;
    int error;
    
    if (deltax >= deltay) {
        error = 2 * deltay - deltax;
        for (int i = 0; i <= deltax; ++i) {
            if (x < 0 || x > canvas_size_width || y < 0 || y > canvas_size_height) { //描画範囲を超える場合
            } else {
                set_pixel_rgba(pixel_data, x, y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
            }
            x += xstep;
            error += 2 * deltay;
            if (error >= 0) {
                y += ystep;
                error -= 2 * deltax;
            }
        }
    }
    else {
        error = 2 * deltax - deltay;
        for (int i = 0; i <= deltay; ++i) {
            if (x < 0 || x > canvas_size_width || y < 0 || y > canvas_size_height) {
            } else {
                set_pixel_rgba(pixel_data, x, y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
            }
            y += ystep;
            error += 2 * deltax;
            if (error >= 0) {
                x += xstep;
                error -= 2 * deltay;
            }
        }
    }
}

/// アンチエイリアシング付き円塗りつぶし
///
void fill_circle_rgba_smooth(uint8_t *pixel_data, double point_x, double point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height, double radius) {
    
    int nx1, ny1, nx2, ny2, ix, iy, jx, jy, count;
    double xx, yy, rr;
    uint8_t protect_alpha;
    
    // 描画先の範囲
    nx1 = (int)floor(point_x - radius);
    ny1 = (int)floor(point_y - radius);
    nx2 = (int)floor(point_x + radius);
    ny2 = (int)floor(point_y + radius);
    
    //描画先ループ
    rr = radius * radius;
    for(iy = ny1; iy <= ny2; iy++) {
        for(ix = nx1; ix <= nx2; ix++) {
            //オーバーサンプリング
            count = 0;
            for(jy = 0; jy < 8; jy++) {
                yy = iy - point_y + jy * (1.0 / 8);
                for(jx = 0; jx < 8; jx++) {
                    xx = ix - point_x + jx * (1.0 / 8);
                    if(xx * xx + yy * yy < rr) {
                        count++;
                    }
                }
            }
            protect_alpha = color_alpha * count >> 6;
            
            set_pixel_rgba_protect_alpha(pixel_data, ix, iy, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height, protect_alpha);
        }
    }
}

void set_line_rgba_smooth(uint8_t *pixel_data, double start_point_x, double start_point_y, double end_point_x, double end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height, double radius, double interval) {
    
    double dx, dy, len, t, t_interval, x, y, dtmp;
    double line_interval = interval;
    double line_last_t = 0;
    //線の長さ
    dx = end_point_x - start_point_x;
    dy = end_point_y - start_point_y;
    len = sqrt(dx * dx + dy * dy);
    if(len == 0) return;
    //線形補間
    t_interval = line_interval / len;
    t = line_last_t / len;
    while(t < 1.0) {
        x = start_point_x + dx * t;
        y = start_point_y + dy * t;
        fill_circle_rgba_smooth(pixel_data, x, y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height, radius);
        //次の位置
        dtmp = radius * t_interval;
        if(dtmp < 0.0001) dtmp = 0.0001;
        t += dtmp;
    }
    
}

void set_line_rgba_smooth_i(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    //アンチエイリアシング直線描画
    set_line_rgba_smooth(pixel_data, (double)start_point_x, (double)start_point_y, (double)end_point_x, (double)end_point_y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height, 0.5, 1.0);
}

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

void fill_rect_rgba_slow(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    //普通に描画する方法：若干遅い
    int minx = MIN(start_point_x,end_point_x);
    int miny = MIN(start_point_y,end_point_y);
    int diffx = MAX(start_point_x,end_point_x) - MIN(start_point_x,end_point_x) + 1;
    int diffy = MAX(start_point_y,end_point_y) - MIN(start_point_y,end_point_y) + 1;
    for (int y = 0; y < diffy; y++) {
        for (int x = 0; x < diffx; x++) {
            set_pixel_rgba(pixel_data, minx+x, miny+y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
        }
    }
}

void fill_rect_rgba(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    int minx = MIN(start_point_x,end_point_x);
    int miny = MIN(start_point_y,end_point_y);
    int diffx = MAX(start_point_y,end_point_x) - MIN(start_point_x,end_point_x) + 1;
    int diffy = MAX(start_point_y,end_point_y) - MIN(start_point_y,end_point_y) + 1;
    
    //クリップ
    if (minx > canvas_size_width) {
        return;
    } else if (minx < 0) {
        minx = 0;
    }
    
    if (miny > canvas_size_height) {
        return;
    } else if (miny < 0) {
        miny = 0;
    }
    
    if ((minx + diffx) < 0) {
        return;
    } else if ((minx + diffx) > canvas_size_width) {
        diffx = canvas_size_width - minx;
    }
    
    if ((miny + diffy) < 0) {
        return;
    } else if ((miny + diffy) > canvas_size_height) {
        diffy = canvas_size_height - miny;
    }
    
    uint8_t onepixel[4] = {color_red, color_green, color_blue, color_alpha};
    uint8_t xline[diffx * 4];
    void* xlineAddr = &xline;
    void* pixeldataAddr = pixel_data;
    int xline_size = diffx * 4;
    for (int x = 0; x < diffx; x++) {
        memcpy(xlineAddr, onepixel, 4);
        xlineAddr += 4;
        //別な方法：ほんの少し遅い
        //xline[3*x]=current_color.red;
        //xline[3*x+1]=current_color.green;
        //xline[3*x+2]=current_color.blue;
    }
    pixeldataAddr += minx*4 + miny*canvas_size_width*4;
    for (int y = 0; y < diffy; y++) {
        memcpy(pixeldataAddr, xline, xline_size);
        pixeldataAddr += canvas_size_width * 4;
    }
}

void set_circle_rgba(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    if(start_point_x>=end_point_x || start_point_y>=end_point_y) {
        return;
    }
    
    double ix1 = start_point_x;
    double iy1 = start_point_y;
    double ix2 = end_point_x;
    double iy2 = end_point_y;
    
    //幅の半径を求める
    double widthRadius = (ix2 - ix1) / 2.0;
    double heightRadius = (iy2 - iy1) / 2.0;//widthRadius / ratioHeight;
    
    //幅と高さの比率を求める
    double ratioWidth = 1.0;
    double ratioHeight = (ix2 - ix1) / (iy2 - iy1);//1.0;
    double ratioHeightSquare = ratioHeight *= ratioHeight;
    
    //中心点を求める
    int centerPointX = (int)(ix1 + widthRadius);
    int centerPointY = (int)(iy1 + heightRadius);
    
    int x = (int)(widthRadius / sqrt(ratioWidth));
    int y = 0;
    double d = sqrt(ratioWidth) * widthRadius;
    int F = (int)(-2.0 * d) + ratioWidth + 2 * ratioHeightSquare;
    int H = (int)(-4.0 * d) + 2 * ratioWidth + ratioHeightSquare;
    
    while (x >= 0) {
        set_pixel_rgba(pixel_data, centerPointX + x, centerPointY + y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
        set_pixel_rgba(pixel_data, centerPointX - x, centerPointY + y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
        set_pixel_rgba(pixel_data, centerPointX + x, centerPointY - y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
        set_pixel_rgba(pixel_data, centerPointX - x, centerPointY - y, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
        if (F >= 0) {
            --x;
            F -= 4 * ratioWidth * x;
            H -= 4 * ratioWidth * x - 2 * ratioWidth;
        }
        if (H < 0) {
            ++y;
            F += 4 * ratioHeightSquare * y + 2 * ratioHeightSquare;
            H += 4 * ratioHeightSquare * y;
        }
    }
}

void fill_circle_rgba(uint8_t *pixel_data, int32_t start_point_x, int32_t start_point_y, int32_t end_point_x, int32_t end_point_y, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    if(start_point_x>=end_point_x || start_point_y>=end_point_y) {
        return;
    }
    
    double _x1 = start_point_x;
    double _y1 = start_point_y;
    double _x2 = end_point_x;
    double _y2 = end_point_y;
    
    //幅の半径を求める
    double widthRadius = (_x2 - _x1) / 2.0;
    double heightRadius = (_y2 - _y1) / 2.0;//widthRadius / ratioHeight;
    double x, y;
    double ratioHeightReverse = (_y2 - _y1) / (_x2 - _x1);
    
    for(int iy = start_point_y; iy < end_point_y+heightRadius; iy++) {
        for(int ix = start_point_x; ix < end_point_x+widthRadius; ix++) {
            x = ix - start_point_x - widthRadius;
            y = iy - start_point_y - heightRadius;
            y /= ratioHeightReverse;
            if(x * x + y * y < widthRadius * widthRadius) {
                set_pixel_rgba(pixel_data, ix, iy, color_red, color_green, color_blue, color_alpha, canvas_size_width, canvas_size_height);
            }
        }
    }
}

void copy_pixel_data(uint8_t *pixel_data_dest, uint8_t *pixel_data_source, int32_t current_point_x, int32_t current_point_y, int32_t copy_point_x, int32_t copy_point_y, int32_t copy_size_width, int32_t copy_size_height, int32_t copy_default_size_width, int32_t copy_default_size_height, uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha, int32_t canvas_dest_size_width, int32_t canvas_dest_size_height, int32_t canvas_source_size_width, int32_t canvas_source_size_height, int8_t blend_mode, int8_t blend_opacity) {
    
    int cx = current_point_x; //カレントポジション
    int cy = current_point_y;
    
    if (cx >= canvas_dest_size_width || cy >= canvas_dest_size_height) {
        return;
    }
    
    int w = copy_size_width;
    int h = copy_size_height;
    if (w == -1) {
        w = copy_default_size_width;
    }
    if (h == -1) {
        h = copy_default_size_height;
    }
    
    if (copy_point_x >= canvas_source_size_width || copy_point_y >= canvas_source_size_height) {
        return;
    }
    
    if (copy_point_x + w > canvas_source_size_width) {
        w = canvas_source_size_width - copy_point_x;
    }
    if (copy_point_y + h > canvas_source_size_height) {
        h = canvas_source_size_height - copy_point_y;
    }
    
    //コピー元とコピー先のサイズが同じだったら
    if (cx == 0 && cy == 0 && copy_point_x == 0 && copy_point_y == 0 && canvas_dest_size_width == canvas_source_size_width && canvas_dest_size_height == canvas_source_size_height && w == canvas_source_size_width && h == canvas_source_size_height && blend_mode == 0) {
        memcpy(pixel_data_dest, pixel_data_source, sizeof(uint8_t) * canvas_dest_size_width * canvas_dest_size_height * 4);
        return;
    }
    
    if (copy_point_x > 0 && w == canvas_source_size_width) {
        w = w - copy_point_x;
    }
    if (copy_point_y > 0 && h == canvas_source_size_height) {
        h = h - copy_point_y;
    }

    if (canvas_dest_size_width < w + cx) {
        w = w - (w + cx - canvas_dest_size_width);
        if (copy_point_x > 0) {
            w = w - copy_point_x;
        }
    }
    if (canvas_dest_size_height < h + cy) {
        h = h - (h + cy - canvas_dest_size_height);
        if (copy_point_y > 0) {
            h = h - copy_point_x;
        }
    }
    
    if (cx < 0 || cy < 0) {
        return;
    }
    
    if (w <= 0 || h <= 0) {
        return;
    }
    
    switch(blend_mode) {
        case 0: //通常コピー
        case 1:
        {
            for (int y = 0; y < h; y++) {
                memcpy(&pixel_data_dest[cx * 4 + (y + cy) * canvas_dest_size_width * 4], &pixel_data_source[copy_point_x * 4 + y * canvas_source_size_width * 4], sizeof(unsigned char) * w * 4);
            }
            break;
        }
        case 2: //透明色付きコピー
        {
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    if(pixel_data_source[((x + copy_point_x) * 4) + y * canvas_dest_size_width * 4] != 0 && pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_dest_size_width * 4] != 0 && pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_dest_size_width * 4] != 0) {
                        pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4] = pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                        pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4] = pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                        pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4] = pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                        pixel_data_dest[((x + cx) * 4 + 3) + (y + cy) * canvas_dest_size_width * 4] = pixel_data_source[((x + copy_point_x) * 4 + 3) + y * canvas_source_size_width * 4];
                    }
                }
            }
            break;
        }
        case 3://半透明コピー
        {
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    double sr = (double)pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                    double sg = (double)pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                    double sb = (double)pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                    double sa = (double)blend_opacity;
                    double dr = (double)pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4];
                    double dg = (double)pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4];
                    double db = (double)pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4];
                    
                    dr = ((dr * (255.0 - sa)) + (sr * sa)) / 255.0;
                    dg = ((dg * (255.0 - sa)) + (sg * sa)) / 255.0;
                    db = ((db * (255.0 - sa)) + (sb * sa)) / 255.0;
                    
                    pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4] = (int)dr;
                    pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4] = (int)dg;
                    pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4] = (int)db;
                    pixel_data_dest[((x + cx) * 4 + 3) + (y + cy) * canvas_dest_size_width * 4] = 255;
                }
            }
            break;
        }
        case 4://透明色付き半透明コピー
        {
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    if(pixel_data_source[((x + copy_point_x) * 4) + y * canvas_dest_size_width * 4] != 0 && pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_dest_size_width * 4] != 0 && pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_dest_size_width * 4] != 0) {
                        double sr = (double)pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                        double sg = (double)pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                        double sb = (double)pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                        double sa = (double)blend_opacity;
                        double dr = (double)pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4];
                        double dg = (double)pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4];
                        double db = (double)pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4];
                        
                        dr = ((dr * (255.0 - sa)) + (sr * sa)) / 255.0;
                        dg = ((dg * (255.0 - sa)) + (sg * sa)) / 255.0;
                        db = ((db * (255.0 - sa)) + (sb * sa)) / 255.0;
                        
                        pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4] = (int)dr;
                        pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4] = (int)dg;
                        pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4] = (int)db;
                        pixel_data_dest[((x + cx) * 4 + 3) + (y + cy) * canvas_dest_size_width * 4] = 255;
                    }
                }
            }
            break;
        }
        case 5://加算合成
        {
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    int sr = pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                    int sg = pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                    int sb = pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                    int dr = pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4];
                    int dg = pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4];
                    int db = pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4];
                    
                    dr = dr + sr;
                    dg = dg + sg;
                    db = db + sb;
                    if(dr > 255)
                        dr = 255;
                    if(dg > 255)
                        dg = 255;
                    if(db > 255)
                        db = 255;
                    
                    pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4] = dr;
                    pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4] = dg;
                    pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4] = db;
                    pixel_data_dest[((x + cx) * 4 + 3) + (y + cy) * canvas_dest_size_width * 4] = 255;
                }
            }
            break;
        }
        case 6://減算合成
        {
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    int sr = pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                    int sg = pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                    int sb = pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                    int dr = pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4];
                    int dg = pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4];
                    int db = pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4];
                    
                    dr = dr - sr;
                    dg = dg - sg;
                    db = db - sb;
                    if(dr < 0)
                        dr = 0;
                    if(dg < 0)
                        dg = 0;
                    if(db < 0)
                        db = 0;
                    
                    pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4] = dr;
                    pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4] = dg;
                    pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4] = db;
                    pixel_data_dest[((x + cx) * 4 + 3) + (y + cy) * canvas_dest_size_width * 4] = 255;
                }
            }
            break;
        }
        case 7: //ピクセルアルファブレンドコピー
        {
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    double sr = (double)pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                    double sg = (double)pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                    double sb = (double)pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                    double sa_r = (double)pixel_data_source[((x + copy_point_x + w) * 4) + y * canvas_source_size_width * 4];
                    double sa_g = (double)pixel_data_source[((x + copy_point_x + w) * 4 + 1) + y * canvas_source_size_width * 4];
                    double sa_b = (double)pixel_data_source[((x + copy_point_x + w) * 4 + 2) + y * canvas_source_size_width * 4];
                    double sa = (sa_r + sa_g + sa_b) / 3.0;
                    double dr = (double)pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4];
                    double dg = (double)pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4];
                    double db = (double)pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4];
                    
                    dr = ((dr * (255.0 - sa)) + (sr * sa)) / 255.0;
                    dg = ((dg * (255.0 - sa)) + (sg * sa)) / 255.0;
                    db = ((db * (255.0 - sa)) + (sb * sa)) / 255.0;
                    
                    pixel_data_dest[((x + cx) * 4) + (y + cy) * canvas_dest_size_width * 4] = (int)dr;
                    pixel_data_dest[((x + cx) * 4 + 1) + (y + cy) * canvas_dest_size_width * 4] = (int)dg;
                    pixel_data_dest[((x + cx) * 4 + 2) + (y + cy) * canvas_dest_size_width * 4] = (int)db;
                    pixel_data_dest[((x + cx) * 4 + 3) + (y + cy) * canvas_dest_size_width * 4] = 255;
                }
            }
            break;
        }
        case 8: //透明色保護コピー
        {
            Color color;
            int set_pixel_index;
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    color.red = pixel_data_source[((x + copy_point_x) * 4) + y * canvas_source_size_width * 4];
                    color.green = pixel_data_source[((x + copy_point_x) * 4 + 1) + y * canvas_source_size_width * 4];
                    color.blue = pixel_data_source[((x + copy_point_x) * 4 + 2) + y * canvas_source_size_width * 4];
                    set_pixel_index = (cy + y) * canvas_dest_size_width * 4 + (cx + x) * 4;
                    set_pixel_rgba_protect_alpha_fast(pixel_data_dest, x + cx, y + cy, color.red, color.green, color.blue, color.alpha, canvas_dest_size_width, canvas_dest_size_height, pixel_data_source[((x + copy_point_x) * 4 + 3) + y * canvas_dest_size_width * 4], set_pixel_index);
                }
            }
            break;
        }
    }
}
