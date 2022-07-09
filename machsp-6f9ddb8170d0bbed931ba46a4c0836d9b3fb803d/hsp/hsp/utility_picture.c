//
//  PictureUtility.c
//  hsp
//
//  Created by 半澤 聡 on 2016/09/04.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#include "utility_picture.h"

_Size load_image_init_canvas(char const *file_name, uint8_t *pixel_data) {
    
    _Size image_size;
    uint8_t *image_pixels;
    int image_width;
    int image_height;
    int image_bpp;//色数 3 or 4
    
    image_pixels = stbi_load(file_name, &image_width, &image_height, &image_bpp, 0);
    image_size.width = image_width;
    image_size.height = image_height;
    
    if(image_bpp == 4) {
        memcpy(pixel_data, image_pixels, image_width * image_height * image_bpp * sizeof(unsigned char));
    } else {
        int i = 0;
        for(int j = 0;j<image_width * image_height * image_bpp; j += 3) {
            memcpy(&pixel_data[i], &image_pixels[j], 3);
            pixel_data[i+3] = 255;
            i += 4;
        }
    }
    
    free(image_pixels);
    return image_size;
}

_Size load_image(char const *file_name, uint8_t *pixel_data, int32_t point_x, int32_t point_y, int32_t canvas_size_width, int32_t canvas_size_height) {
    
    _Size image_size;
    uint8_t *image_pixels;
    int image_width;
    int image_height;
    int image_bpp;//色数 3 or 4
    
    image_pixels = stbi_load(file_name, &image_width, &image_height, &image_bpp, 0);
    image_size.width = image_width;
    image_size.height = image_height;
    
    int i = point_x * 4 + point_y * canvas_size_width * 4;
    int j = 0;
    int posx_now = point_x;
    
    for (int y = 0; y < image_height; y++) {
        if(canvas_size_height <= y + point_y) {
            break;
        }
        posx_now = point_x;
        for (int x = 0; x < image_width; x++) {
            if(canvas_size_width <= x+point_x || posx_now < 0) {
                j += image_bpp;
                i += 4;
                posx_now++;
                continue;
            }
            if(image_bpp == 4) {
                memcpy(&pixel_data[i], &image_pixels[j], 4);
            } else {
                memcpy(&pixel_data[i], &image_pixels[j], 3);
                pixel_data[i+3] = 255;
            }
            j += image_bpp;
            i += 4;
            posx_now++;
        }
        i += canvas_size_width * 4 - image_width * 4;
    }
    
    free(image_pixels);
    return image_size;
}
