//
//  PixelUtility.h
//  hsp
//
//  Created by 半澤 聡 on 2016/09/02.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef PixelUtility_h
#define PixelUtility_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "debug_message.h"

typedef struct {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t alpha;
} Color;

typedef struct {
    uint32_t x;
    uint32_t y;
} _Point;

Color get_pixel_color(uint8_t *pixel_data,
                      int32_t point_x, int32_t point_y,
                      int32_t canvas_size_width, int32_t canvas_size_height);

Color get_color_hsv(int32_t hue, int32_t saturation, int32_t brightness);

void clear_canvas_rgba(uint8_t *pixel_data,
                       int32_t canvas_size_width, int32_t canvas_size_height,
                       int32_t color_number);

void set_pixel_rgb(uint8_t *pixel_data,
                   int32_t point_x, int32_t point_y,
                   uint8_t color_red, uint8_t color_green, uint8_t color_blue,
                   int32_t canvas_size_width, int32_t canvas_size_height);

void set_pixel_rgba(uint8_t *pixel_data,
                    int32_t point_x, int32_t point_y,
                    uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                    int32_t canvas_size_width, int32_t canvas_size_height);

void set_pixel_rgba_protect_alpha(uint8_t *pixel_data,
                                  int32_t point_x, int32_t point_y,
                                  uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                                  int32_t canvas_size_width, int32_t canvas_size_height,
                                  int32_t protect_alpha);

void set_pixel_rgba_protect_alpha_fast(uint8_t *pixel_data,
                                       int32_t point_x, int32_t point_y,
                                       uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                                       int32_t canvas_size_width, int32_t canvas_size_height,
                                       int32_t protect_alpha,
                                       int32_t index);

void set_line_rgb(uint8_t *pixel_data,
                  int32_t start_point_x, int32_t start_point_y,
                  int32_t end_point_x, int32_t end_point_y,
                  uint8_t color_red, uint8_t color_green, uint8_t color_blue,
                  int32_t canvas_size_width, int32_t canvas_size_height);

void set_line_rgba(uint8_t *pixel_data,
                   int32_t start_point_x, int32_t start_point_y,
                   int32_t end_point_x, int32_t end_point_y,
                   uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                   int32_t canvas_size_width, int32_t canvas_size_height);

void fill_circle_rgba_smooth(uint8_t *pixel_data,
                             double point_x, double point_y,
                             uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                             int32_t canvas_size_width, int32_t canvas_size_height,
                             double radius);

void set_line_rgba_smooth(uint8_t *pixel_data,
                          double start_point_x, double start_point_y,
                          double end_point_x, double end_point_y,
                          uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                          int32_t canvas_size_width, int32_t canvas_size_height,
                          double radius,
                          double interval);

void set_line_rgba_smooth_i(uint8_t *pixel_data,
                            int32_t start_point_x, int32_t start_point_y,
                            int32_t end_point_x, int32_t end_point_y,
                            uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                            int32_t canvas_size_width, int32_t canvas_size_height);

void fill_rect_rgba(uint8_t *pixel_data,
                    int32_t start_point_x, int32_t start_point_y,
                    int32_t end_point_x, int32_t end_point_y,
                    uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                    int32_t canvas_size_width, int32_t canvas_size_height);

void fill_rect_rgba_slow(uint8_t *pixel_data,
                         int32_t start_point_x, int32_t start_point_y,
                         int32_t end_point_x, int32_t end_point_y,
                         uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                         int32_t canvas_size_width, int32_t canvas_size_height);

void set_circle_rgba(uint8_t *pixel_data,
                     int32_t start_point_x, int32_t start_point_y,
                     int32_t end_point_x, int32_t end_point_y,
                     uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                     int32_t canvas_size_width, int32_t canvas_size_height);

void fill_circle_rgba(uint8_t *pixel_data,
                      int32_t start_point_x, int32_t start_point_y,
                      int32_t end_point_x, int32_t end_point_y,
                      uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                      int32_t canvas_size_width, int32_t canvas_size_height);

void copy_pixel_data(uint8_t *pixel_data_dest,
                     uint8_t *pixel_data_source,
                     int32_t current_point_x, int32_t current_point_y,
                     int32_t copy_point_x, int32_t copy_point_y,
                     int32_t copy_size_width, int32_t copy_size_height,
                     int32_t copy_defalut_size_width, int32_t copy_default_size_height,
                     uint8_t color_red, uint8_t color_green, uint8_t color_blue, uint8_t color_alpha,
                     int32_t canvas_dest_size_width, int32_t canvas_dest_size_height,
                     int32_t canvas_source_size_width, int32_t canvas_source_size_height,
                     int8_t blend_mode,
                     int8_t blend_opacity);

#endif /* PixelUtility_h */
