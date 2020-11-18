//
//  PictureUtility.h
//
#ifndef PictureUtility_h
#define PictureUtility_h
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include "stb_image.h"
#include "stb_image_write.h"
typedef struct{
    int32_t width;
    int32_t height;
} _Size;
_Size load_image_init_canvas(char const *file_name,
                            uint8_t *pixel_data);
_Size load_image(char const *file_ename,
                uint8_t *pixel_data,
                int32_t point_x, int32_t point_y,
                int32_t canvas_size_width, int32_t canvas_size_height);
#endif /* PictureUtility_h */
