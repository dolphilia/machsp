//
//  MyCALayer.h
//
#ifndef MyCALayer_h
#define MyCALayer_h
#import "AppDelegate.h"
#import "d3module.h"
#include "debug_message.h"
#import "utility_picture.h"
#import "utility_pixel.h"
#import <Accelerate/Accelerate.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
@interface MyCALayer : CALayer {
@private
    AppDelegate* g; //"g"lobal
    int window_id;  //対応するウィンドウID
    int samplesPerPixel;
    BOOL is_redraw_just_now;
    d3module* d3m;
@public
    uint8_t** pixel_data;
    int32_t buf_index;
    int32_t* buf_width;
    int32_t* buf_height;
    Color current_color;
    _Point current_point;
    int32_t current_blend_mode;    // gmodeのp1
    int32_t current_copy_width;    // gmodeのp2 (初期値:32)
    int32_t current_copy_height;   // gmodeのp3 (初期値:32)
    int32_t current_blend_opacity; // gmodeのp4
    NSString* font_name;           //フォント関連
    int font_size;
    int font_style;
}
//
- (void)update_contents_with_cgimage:(CGImageRef)image;
- (void)redraw;
//
- (void)get_pixel_color:(int)point_x point_y:(int)point_y;
- (int)get_current_point_x;
- (int)get_current_point_y;
- (UInt8)get_current_color_r;
- (UInt8)get_current_color_g;
- (UInt8)get_current_color_b;
- (UInt8)get_current_color_a;
//
- (void)set_current_blend_mode:(int32_t)blend_mode;
- (void)set_current_blend_opacity:(int32_t)blend_opacity;
- (void)set_current_copy_width:(int32_t)width;
- (void)set_current_copy_height:(int32_t)height;
- (void)set_window_id:(int)p1;
- (void)set_redraw_flag:(BOOL)flag;
- (void)set_font:(NSString*)name size:(int)size style:(int)style;
- (void)set_color_rgba:(int)red
                 green:(int)green
                  blue:(int)blue
                 alpha:(int)alpha;
- (void)set_color_hsv:(int)hue
           saturation:(int)saturation
           brightness:(int)brightness;
- (void)set_current_point:(int)point_x point_y:(int)point_y;
//
- (void)clear_canvas:(int)color_number;
//
- (void)set_pixel_rgba:(int)point_x point_y:(int)point_y;
- (void)set_line_rgba:(int)start_point_x
        start_point_y:(int)start_point_y
          end_point_x:(int)end_point_x
          end_point_y:(int)end_point_y;
- (void)set_line_rgba_smooth:(int)start_point_x
               start_point_y:(int)start_point_y
                 end_point_x:(int)end_point_x
                 end_point_y:(int)end_point_y;
- (void)set_rect_line_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
- (void)set_rect_line_rgba_smooth:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
- (void)fill_rect_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
- (void)fill_rect_rgba_slow:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
- (void)set_circle_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
- (void)fill_circle_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
//
- (void)fillGradation:(int)pos_x
                pos_y:(int)pos_y
               size_w:(int)size_w
               size_h:(int)size_h
            direction:(int)direction
          color_red_a:(int)color_red_a
        color_green_a:(int)color_green_a
         color_blue_a:(int)color_blue_a
          color_red_b:(int)color_red_b
        color_green_b:(int)color_green_b
         color_blue_b:(int)color_blue_b;
//
- (void)gcopy:(int)index px:(int)px py:(int)py sx:(int)sx sy:(int)sy;
- (void)d3setcam:(double)x1
              y1:(double)y1
              z1:(double)z1
              x2:(double)x2
              y2:(double)y2
              z2:(double)z2;
- (void)d3pos:(double)x y:(double)y z:(double)z;
- (void)d3pset:(double)x y:(double)y z:(double)z;
- (void)d3line:(double)sx
            sy:(double)sy
            sz:(double)sz
            ex:(double)ex
            ey:(double)ey
            ez:(double)ez;
- (void)d3lineSmooth:(double)sx
                  sy:(double)sy
                  sz:(double)sz
                  ex:(double)ex
                  ey:(double)ey
                  ez:(double)ez;
- (void)d3box:(double)sx
           sy:(double)sy
           sz:(double)sz
           ex:(double)ex
           ey:(double)ey
           ez:(double)ez;
- (void)d3boxSmooth:(double)sx
                 sy:(double)sy
                 sz:(double)sz
                 ex:(double)ex
                 ey:(double)ey
                 ez:(double)ez;
- (void)mes:(NSString*)text;
- (NSSize)picload:(NSString*)filename;
- (NSSize)picload:(NSString*)filename mode:(int)mode;
//
- (void)cifilter:(int)type;
- (void)vcopy:(int)index;
- (void)scale;
- (void)rotate;
- (void)edgedetect;
- (void)sharpen;
- (void)unsharpen;
- (void)dilate;
- (void)erode;
- (void)equalization;
- (void)emboss;
- (void)verticalReflect;
- (void)horizontalReflect;
- (void)gaussianblur;
@end
#endif /* MyCALayer_h */
