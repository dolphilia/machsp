//
//  MyCALayer.m
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/01.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "MyCALayer.h"

#define BUFFER_MAX_WIDTH 2500
#define BUFFER_MAX_HEIGHT 2500
#define BUFFER_HAS_ALPHA YES

@implementation MyCALayer

- (instancetype)init {
    self = [super init];
    if (self) {
        g = (AppDelegate *) [[NSApplication sharedApplication] delegate];

        samplesPerPixel = 4; //ピクセル数(3 = RGB, 4 = RGBA)

        size_t bufferCount = 24; //バッファーの数
        if (pixel_data == nil) {
            pixel_data = calloc(bufferCount, sizeof(UInt8 *));
            for (int i = 0; i < bufferCount; i++) {
                pixel_data[i] =
                        calloc((size_t) (BUFFER_MAX_WIDTH * BUFFER_MAX_HEIGHT * samplesPerPixel),
                                sizeof(UInt8));
            }
        }
        if (buf_width == nil) {
            buf_width = calloc(bufferCount, sizeof(int *));
            for (int i = 0; i < bufferCount; i++) {
                buf_width[i] = 640;
            }
        }
        if (buf_height == nil) {
            buf_height = calloc(bufferCount, sizeof(int *));
            for (int i = 0; i < bufferCount; i++) {
                buf_height[i] = 480;
            }
        }
        current_copy_width = 32;
        current_copy_height = 32;

        font_name = @"";
        font_size = 12;
        font_style = 0;

        is_redraw_just_now = YES;
        d3m = [[d3module alloc] init];
        [d3m set_winx:buf_width[buf_index]];
        [d3m set_winy:buf_height[buf_index]];

        [d3m d3setcam:500 cpy:500 cpz:500 tx:0 ty:0 tz:0];

        //設定の初期化
        [self clear_canvas:0];
        [self set_color_rgba:0 green:0 blue:0 alpha:255];
        [self redraw];

        ////タイマー
        // NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
        // arget:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        //[myTimer fire];
    }
    return self;
}

- (void)update_contents_with_cgimage:(CGImageRef)image {
    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.contents = (__bridge id _Nullable) image;
    [CATransaction commit];
}

- (void)redraw {
    @autoreleasepool {

        if (g.backing_scale_factor == 0.0) {
            return;
        }
        // g.backing_scale_factor = 2.0;
        NSBitmapImageRep *bip;
        if (g.backing_scale_factor == 2.0) {
            int width = buf_width[0];
            int height = buf_height[0];
            int h_mul = width * 2 * samplesPerPixel;

            unsigned char *retina_pixel_data = calloc(
                    (size_t) (width * 2 * height * 2 * samplesPerPixel * 4), sizeof(unsigned char));
            int i = 0;
            for (int y = 0; y < height * 2; y += 2) {
                for (int x = 0; x < width * 2 * samplesPerPixel; x += 8) {
                    memcpy(&retina_pixel_data[x + h_mul * y], &pixel_data[0][i], sizeof(unsigned char) * 4);
                    memcpy(&retina_pixel_data[x + 4 + h_mul * y], &pixel_data[0][i], sizeof(unsigned char) * 4);
                    memcpy(&retina_pixel_data[x + h_mul * (y + 1)], &pixel_data[0][i], sizeof(unsigned char) * 4);
                    memcpy(&retina_pixel_data[x + 4 + h_mul * (y + 1)], &pixel_data[0][i], sizeof(unsigned char) * 4);
                    i += 4;
                }
            }

            bip = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&retina_pixel_data pixelsWide:buf_width[buf_index] * 2 pixelsHigh:buf_height[buf_index] * 2 bitsPerSample:8 samplesPerPixel:samplesPerPixel hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:buf_width[buf_index] * 2 * samplesPerPixel bitsPerPixel:samplesPerPixel * 8];
            free(retina_pixel_data);
        } else {
            bip = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixel_data[window_id] pixelsWide:buf_width[buf_index] pixelsHigh:buf_height[buf_index] bitsPerSample:8 samplesPerPixel:samplesPerPixel hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:buf_width[buf_index] * samplesPerPixel bitsPerPixel:samplesPerPixel * 8];
        }

        [self update_contents_with_cgimage:[bip CGImage]];
    }
}

//----

- (int)get_current_point_x {
    return current_point.x;
}

- (int)get_current_point_y {
    return current_point.y;
}

- (UInt8)get_current_color_r {
    return current_color.red;
}

- (UInt8)get_current_color_g {
    return current_color.green;
}

- (UInt8)get_current_color_b {
    return current_color.blue;
}

- (UInt8)get_current_color_a {
    return current_color.alpha;
}

- (void)get_pixel_color:(int)point_x point_y:(int)point_y {
    Color color = get_pixel_color(pixel_data[buf_index], point_x, point_y, buf_width[buf_index], buf_height[buf_index]);
    [self set_color_rgba:color.red green:color.green blue:color.blue alpha:color.alpha];
}

//----

- (void)set_current_blend_mode:(int32_t)blend_mode {
    current_blend_mode = blend_mode;
}

- (void)set_current_blend_opacity:(int32_t)blend_opacity {
    current_blend_opacity = blend_opacity;
}

- (void)set_current_copy_width:(int32_t)width {
    current_copy_width = width;
}

- (void)set_current_copy_height:(int32_t)height {
    current_copy_height = height;
}

- (void)set_redraw_flag:(BOOL)flag {
    is_redraw_just_now = flag;
}

- (void)set_window_id:(int)p1 {
    window_id = p1;
}

- (void)set_current_point:(int)point_x point_y:(int)point_y {
    current_point.x = point_x;
    current_point.y = point_y;
}

- (void)set_font:(NSString *)name size:(int)size style:(int)style {
    font_name = name;
    font_size = size;
    font_style = style;
}

- (void)set_color_rgba:(int)red green:(int)green blue:(int)blue alpha:(int)alpha {
    current_color.red = red;
    current_color.green = green;
    current_color.blue = blue;
    current_color.alpha = alpha;
}

- (void)set_color_hsv:(int)hue saturation:(int)saturation brightness:(int)brightness {
    Color color = get_color_hsv(hue, saturation, brightness);
    [self set_color_rgba:color.red green:color.green blue:color.blue alpha:255];
}

- (void)clear_canvas:(int)color_number {
    clear_canvas_rgba(pixel_data[buf_index], buf_width[buf_index], buf_height[buf_index], color_number);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)set_pixel_rgba:(int)point_x point_y:(int)point_y {
    set_pixel_rgba(pixel_data[buf_index], point_x, point_y, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)set_line_rgba:(int)start_point_x start_point_y:(int)start_point_y end_point_x:(int)end_point_x end_point_y:(int)end_point_y {
    set_line_rgba(pixel_data[buf_index], start_point_x, start_point_y, end_point_x, end_point_y, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)set_line_rgba_smooth:(int)start_point_x start_point_y:(int)start_point_y end_point_x:(int)end_point_x end_point_y:(int)end_point_y {
    set_line_rgba_smooth_i(pixel_data[buf_index], start_point_x, start_point_y, end_point_x, end_point_y, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

//-(void)set_line_rgba_smooth_b:(int)start_point_x
//start_point_y:(int)start_point_y end_point_x:(int)end_point_x
//end_point_y:(int)end_point_y
//{
//    //NSBezierPathを使った直線描画
//    @autoreleasepool {
//        //プレーンデータからNSImageを生成
//        unsigned char *plane = malloc(sizeof(unsigned char) *
//        buf_width[buf_index] * buf_height[buf_index] * 4);
//        memcpy(plane,pixel_data[buf_index],sizeof(unsigned char) *
//        buf_width[buf_index] * buf_height[buf_index] * 4);
//        NSBitmapImageRep* _bipPlane = [[NSBitmapImageRep alloc]
//        initWithBitmapDataPlanes:&plane pixelsWide:buf_width[buf_index]
//        pixelsHigh:buf_height[buf_index] bitsPerSample:8
//        samplesPerPixel:samplesPerPixel hasAlpha:YES isPlanar:NO
//        colorSpaceName:NSDeviceRGBColorSpace
//        bytesPerRow:buf_width[buf_index]*samplesPerPixel
//        bitsPerPixel:samplesPerPixel*8];
//        free(plane);
//        NSImage* img = [[NSImage alloc] init];
//        [img addRepresentation:_bipPlane];
//
//        //NSImageに読み込んだ画像を描画する
//        int
//        width=MAX(start_point_x,end_point_x)-MIN(start_point_x,end_point_x);
//        int
//        height=MAX(start_point_y,end_point_y)-MIN(start_point_y,end_point_y);
//        int posx=MIN(start_point_x,end_point_x);
//        int posy=MIN(start_point_y,end_point_y);
//        if(start_point_x==end_point_x) {
//            posx=start_point_x;
//            width=1; //太さの最小値
//        }
//        if(start_point_y==end_point_y) {
//            posy=start_point_y;
//            height=1; //太さの最小値
//        }
//
//        [img lockFocus];
//        [NSColor colorWithCalibratedRed:((float)current_color.red)/255.0
//        green:((float)current_color.green)/255.0
//        blue:((float)current_color.blue)/255.0
//        alpha:((float)current_color.alpha)/255.0];
//        [NSBezierPath setDefaultLineWidth:1];
//        [NSBezierPath
//        strokeLineFromPoint:NSMakePoint(start_point_x,buf_height[buf_index]-start_point_y)
//        toPoint:NSMakePoint(end_point_x,buf_height[buf_index]-end_point_y)];
//        [img unlockFocus];
//
//        //描画した画像からプレーンデータを生成する
//        NSBitmapImageRep* _bip = [[NSBitmapImageRep alloc] initWithData:[img
//        TIFFRepresentation]];
//        NSUInteger p[4];
//        int i=0;
//        i=posx*4+posy*buf_width[buf_index]*4;
//        for (int y=0; y<height; y++) {
//            for (int x=0; x<width; x++) {
//                [_bip getPixel:p atX:x+posx y:y+posy];
//                pixel_data[buf_index][i] = p[0];
//                pixel_data[buf_index][i+1] = p[1];
//                pixel_data[buf_index][i+2] = p[2];
//                pixel_data[buf_index][i+3] = p[3];
//                i+=4;
//            }
//            i+=buf_width[buf_index]*4-width*4;
//        }
//        if (is_redraw_just_now && buf_index==0) {
//            [self redraw];
//        }
//    }
//}

- (void)set_rect_line_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    [self set_line_rgba:x1 start_point_y:y1 end_point_x:x1 end_point_y:y2];
    [self set_line_rgba:x1 start_point_y:y2 end_point_x:x2 end_point_y:y2];
    [self set_line_rgba:x2 start_point_y:y2 end_point_x:x2 end_point_y:y1];
    [self set_line_rgba:x2 start_point_y:y1 end_point_x:x1 end_point_y:y1];
}

- (void)set_rect_line_rgba_smooth:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    [self set_line_rgba_smooth:x1 start_point_y:y1 end_point_x:x1 end_point_y:y2];
    [self set_line_rgba_smooth:x1 start_point_y:y2 end_point_x:x2 end_point_y:y2];
    [self set_line_rgba_smooth:x2 start_point_y:y2 end_point_x:x2 end_point_y:y1];
    [self set_line_rgba_smooth:x2 start_point_y:y1 end_point_x:x1 end_point_y:y1];
}

- (void)fill_rect_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    fill_rect_rgba(pixel_data[buf_index], x1, y1, x2, y2, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)fill_rect_rgba_slow:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    fill_rect_rgba_slow(pixel_data[buf_index], x1, y1, x2, y2, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)set_circle_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    set_circle_rgba(pixel_data[buf_index], x1, y1, x2, y2, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)fill_circle_rgba:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    fill_circle_rgba(pixel_data[buf_index], x1, y1, x2, y2, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index]);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)set_circle_rgba_smooth:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    //    int r=80;
    //    double a=1.0;
    //    double b=2.0;
    //    int x = (int)( (double)r / sqrt( (double)a ) );
    //    int y = 0;
    //    double d = sqrt( (double)a ) * (double)r;
    //    int F = (int)( -2.0 * d ) +     a + 2 * b;
    //    int H = (int)( -4.0 * d ) + 2 * a     + b;
    //
    //    while ( x >= 0 ) {
    //        [self psetNotRedraw:x1 + x y:y1 + y ];
    //        [self psetNotRedraw:x1 - x y:y1 + y ];
    //        [self psetNotRedraw:x1 + x y:y1 - y ];
    //        [self psetNotRedraw:x1 - x y:y1 - y ];
    //        if ( F >= 0 ) {
    //            --x;
    //            F -= 4 * a * x;
    //            H -= 4 * a * x - 2 * a;
    //        }
    //        if ( H < 0 ) {
    //            ++y;
    //            F += 4 * b * y + 2 * b;
    //            H += 4 * b * y;
    //        }
    //    }
}

- (void)fill_circle_rgba_smooth:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 {
    //単純な楕円塗りつぶし
    //    int ix,iy,x,y,r;
    //    r = 80;
    //    for(iy = 0; iy < 200; iy++)
    //    {
    //        for(ix = 0; ix < 200; ix++)
    //        {
    //            x = ix - 100;
    //            y = iy - 100;
    //            y /= 0.5;
    //
    //            if(x * x + y * y < r * r)
    //                [self psetNotRedraw:ix y:iy];
    //        }
    //    }
}

//

- (void)d3setcam:(double)x1 y1:(double)y1 z1:(double)z1 x2:(double)x2 y2:(double)y2 z2:(double)z2 {
    [d3m d3setcam:x1 cpy:y1 cpz:z1 tx:x2 ty:y2 tz:z2];
}

- (void)d3pos:(double)x y:(double)y z:(double)z {
    int px = (int) [d3m d3getposX:x y:y z:z];
    int py = (int) [d3m d3getposY:x y:y z:z];
    [self set_current_point:px point_y:py];
}

- (void)d3pset:(double)x y:(double)y z:(double)z {
    int px = (int) [d3m d3getposX:x y:y z:z];
    int py = (int) [d3m d3getposY:x y:y z:z];
    [self set_pixel_rgba:px point_y:py];
}

- (void)d3line:(double)sx sy:(double)sy sz:(double)sz ex:(double)ex ey:(double)ey ez:(double)ez {
    int x1 = (int) [d3m d3getposX:sx y:sy z:sz];
    int y1 = (int) [d3m d3getposY:sx y:sy z:sz];
    int x2 = (int) [d3m d3getposX:ex y:ey z:ez];
    int y2 = (int) [d3m d3getposY:ex y:ey z:ez];
    [self set_line_rgba:x1 start_point_y:y1 end_point_x:x2 end_point_y:y2];
}

- (void)d3lineSmooth:(double)sx sy:(double)sy sz:(double)sz ex:(double)ex ey:(double)ey ez:(double)ez {
    int x1 = (int) [d3m d3getposX:sx y:sy z:sz];
    int y1 = (int) [d3m d3getposY:sx y:sy z:sz];
    int x2 = (int) [d3m d3getposX:ex y:ey z:ez];
    int y2 = (int) [d3m d3getposY:ex y:ey z:ez];
    [self set_line_rgba_smooth:x1 start_point_y:y1 end_point_x:x2 end_point_y:y2];
}

- (void)d3box:(double)sx sy:(double)sy sz:(double)sz ex:(double)ex ey:(double)ey ez:(double)ez {
    [self d3line:sx sy:sy sz:sz ex:sx ey:sy ez:ez];
    [self d3line:sx sy:sy sz:ez ex:sx ey:ey ez:ez];
    [self d3line:sx sy:ey sz:ez ex:sx ey:ey ez:sz];
    [self d3line:sx sy:ey sz:sz ex:sx ey:sy ez:sz];
    [self d3line:ex sy:sy sz:sz ex:ex ey:ey ez:sz];
    [self d3line:ex sy:ey sz:sz ex:ex ey:ey ez:ez];
    [self d3line:ex sy:ey sz:ez ex:ex ey:sy ez:ez];
    [self d3line:ex sy:sy sz:ez ex:ex ey:sy ez:sz];
    [self d3line:sx sy:sy sz:sz ex:ex ey:sy ez:sz];
    [self d3line:sx sy:sy sz:ez ex:ex ey:sy ez:ez];
    [self d3line:sx sy:ey sz:ez ex:ex ey:ey ez:ez];
    [self d3line:sx sy:ey sz:sz ex:ex ey:ey ez:sz];
}

- (void)d3boxSmooth:(double)sx sy:(double)sy sz:(double)sz ex:(double)ex ey:(double)ey ez:(double)ez {
    [self d3lineSmooth:sx sy:sy sz:sz ex:sx ey:sy ez:ez];
    [self d3lineSmooth:sx sy:sy sz:ez ex:sx ey:ey ez:ez];
    [self d3lineSmooth:sx sy:ey sz:ez ex:sx ey:ey ez:sz];
    [self d3lineSmooth:sx sy:ey sz:sz ex:sx ey:sy ez:sz];
    [self d3lineSmooth:ex sy:sy sz:sz ex:ex ey:ey ez:sz];
    [self d3lineSmooth:ex sy:ey sz:sz ex:ex ey:ey ez:ez];
    [self d3lineSmooth:ex sy:ey sz:ez ex:ex ey:sy ez:ez];
    [self d3lineSmooth:ex sy:sy sz:ez ex:ex ey:sy ez:sz];
    [self d3lineSmooth:sx sy:sy sz:sz ex:ex ey:sy ez:sz];
    [self d3lineSmooth:sx sy:sy sz:ez ex:ex ey:sy ez:ez];
    [self d3lineSmooth:sx sy:ey sz:ez ex:ex ey:ey ez:ez];
    [self d3lineSmooth:sx sy:ey sz:sz ex:ex ey:ey ez:sz];
}

- (void)fillGradation:(int)pos_x pos_y:(int)pos_y size_w:(int)size_w size_h:(int)size_h direction:(int)direction color_red_a:(int)color_red_a color_green_a:(int)color_green_a color_blue_a:(int)color_blue_a color_red_b:(int)color_red_b color_green_b:(int)color_green_b color_blue_b:(int)color_blue_b {
    unsigned char *plane_pixeldata = malloc(sizeof(unsigned char) * buf_width[buf_index] * buf_height[buf_index] * samplesPerPixel);
    memcpy(plane_pixeldata, pixel_data[window_id], sizeof(unsigned char) * buf_width[buf_index] * buf_height[buf_index] * samplesPerPixel);

    CGContextRef context = CGBitmapContextCreate(plane_pixeldata, buf_width[buf_index], buf_height[buf_index], 8, buf_width[buf_index] * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    CGContextSaveGState(context);

    NSRect rect = NSMakeRect(0, 0, buf_width[buf_index], buf_height[buf_index]);
    CGContextAddRect(context, rect);

    CGFloat ra = ((float) color_red_a) / 255.0;
    CGFloat ga = ((float) color_green_a) / 255.0;
    CGFloat ba = ((float) color_blue_a) / 255.0;
    CGFloat rb = ((float) color_red_b) / 255.0;
    CGFloat gb = ((float) color_green_b) / 255.0;
    CGFloat bb = ((float) color_blue_b) / 255.0;

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
            rb, gb, bb, 1.0f, ra, ga, ba, 1.0f // R, G, B, Alpha
    };
    CGFloat locations[] = {0.0f, 1.0f};

    size_t count = sizeof(components) / (sizeof(CGFloat) * 4);

    // CGRect frame = self.bounds;
    CGPoint startPoint = rect.origin;
    CGPoint endPoint = rect.origin;
    if (direction == 0) { //横方向
        endPoint.x = rect.origin.x + rect.size.width;
    } else {
        endPoint.y = rect.origin.y + rect.size.height;
    }

    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);

    CGContextDrawLinearGradient(context, gradientRef, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);

    // 画像出力
    unsigned char *bitmap = CGBitmapContextGetData(context);
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, bitmap, buf_width[buf_index] * buf_height[buf_index] * 4, bufferFree);
    CGImageRef result =
            CGImageCreate(buf_width[buf_index], buf_height[buf_index], 8, 32, buf_width[buf_index] * 4, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo) kCGImageAlphaLast, dataProviderRef, NULL, 0, kCGRenderingIntentDefault);
    NSImage *image = [[NSImage alloc] initWithCGImage:result size:NSMakeSize(buf_width[buf_index], buf_height[buf_index])]; //[ initWithCGImage:result]
    NSBitmapImageRep *bip = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];

    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRestoreGState(context);
    CFRelease(dataProviderRef);
    CGImageRelease(result);

    NSUInteger color_now[samplesPerPixel];

    int i = 0;
    int height = buf_height[buf_index];
    int width = buf_width[buf_index];

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            [bip getPixel:color_now atX:x y:y];
            pixel_data[buf_index][i] = color_now[0];
            pixel_data[buf_index][i + 1] = color_now[1];
            pixel_data[buf_index][i + 2] = color_now[2];
            pixel_data[buf_index][i + 3] = color_now[3];
            i += samplesPerPixel;
        }
    }

    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)gcopy:(int)index px:(int)px py:(int)py sx:(int)sx sy:(int)sy {
    copy_pixel_data(pixel_data[buf_index], pixel_data[index], current_point.x, current_point.y, px, py, sx, sy, current_copy_width, current_copy_height, current_color.red, current_color.green, current_color.blue, current_color.alpha, buf_width[buf_index], buf_height[buf_index], buf_width[index], buf_height[index], current_blend_mode, current_blend_opacity);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)mes:(NSString *)text {
    @autoreleasepool {
        // NSImageに文字を描画
        NSString *str = text;
        CGFloat scale = 1.0;
        BOOL is_font_smooth = NO;

        if (font_style & 16) { //アンチエイリアシングありの時だけRetina対応をする
            is_font_smooth = YES;
            scale = g.backing_scale_factor;
        }

        NSFont *font;
        CFStringRef ct_font_name; // = CFStringCreateWithCString(NULL, "Helvetica",
        // kCFStringEncodingMacRoman);
        CTFontRef ct_font;        // = CTFontCreateWithName(font_name, 12.0, NULL);

        if ([font_name isEqual:@""]) { //フォント名が未指定だったら
            font = [NSFont fontWithName:@"Helvetica" size:((float) font_size) / scale];
            ct_font_name =
                    CFStringCreateWithCString(NULL, "Osaka", kCFStringEncodingUTF8);
            ct_font =
                    CTFontCreateWithName(ct_font_name, ((float) font_size) / scale, NULL);
        } else {
            font = [NSFont fontWithName:font_name size:((float) font_size) / scale];
            ct_font_name = CFStringCreateWithCString(NULL, [font_name UTF8String],
                    kCFStringEncodingUTF8);
            ct_font =
                    CTFontCreateWithName(ct_font_name, ((float) font_size) / scale, NULL);
        }

        CGSize strSize = [str sizeWithAttributes:@{
                NSForegroundColorAttributeName: [NSColor whiteColor],
                NSFontAttributeName: font
        }]; //現在の属性からサイズを取得する
        int h = 0;
        int w = 0;

        if (scale > 1.0) { // Retina環境
            h = (int) strSize.height * scale;
            w = (int) strSize.width * scale + 20;
        } else { //非Retina環境
            h = (int) strSize.height;
            w = (int) strSize.width + 10;
        }

        NSImage *img = [[NSImage alloc]
                initWithSize:NSMakeSize((int) strSize.width + 10, (int) strSize.height)];

        //プレーンデータからNSImageを生成
        unsigned char *plane = malloc(sizeof(unsigned char) * buf_width[buf_index] *
                buf_height[buf_index] * samplesPerPixel);
        memcpy(plane, pixel_data[buf_index],
                sizeof(unsigned char) * buf_width[buf_index] *
                        buf_height[buf_index] * samplesPerPixel);
        NSBitmapImageRep *bip = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:&plane
                              pixelsWide:buf_width[buf_index]
                              pixelsHigh:buf_height[buf_index]
                           bitsPerSample:8
                         samplesPerPixel:samplesPerPixel
                                hasAlpha:YES
                                isPlanar:NO
                          colorSpaceName:NSDeviceRGBColorSpace
                             bytesPerRow:buf_width[buf_index] * samplesPerPixel
                            bitsPerPixel:samplesPerPixel * 8];
        free(plane);

        NSColor *color =
                [NSColor colorWithCalibratedRed:((float) current_color.red) / 255.0
                                          green:((float) current_color.green) / 255.0
                                           blue:((float) current_color.blue) / 255.0
                                          alpha:1.0];

        // NSMutableDictionary* font_styleAttributes;

        if (is_font_smooth) { //アンチエリアシングあり
            NSDictionary *stringAttributes;
            if (font_style & 4 && font_style & 8) { //下線＋打ち消し線
                stringAttributes = @{
                        NSForegroundColorAttributeName: color,
                        NSFontAttributeName: font,
                        NSUnderlineStyleAttributeName:
                        [NSNumber numberWithInteger:NSUnderlineStyleSingle],
                        NSStrikethroughStyleAttributeName:
                        [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                };
            } else if (font_style & 8) { //打ち消し線
                stringAttributes = @{
                        NSForegroundColorAttributeName: color,
                        NSFontAttributeName: font,
                        NSStrikethroughStyleAttributeName:
                        [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                };
            } else if (font_style & 4) { //下線
                stringAttributes = @{
                        NSForegroundColorAttributeName: color,
                        NSFontAttributeName: font,
                        NSUnderlineStyleAttributeName:
                        [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                };
            } else { //標準スタイル
                stringAttributes = @{
                        NSForegroundColorAttributeName: color,
                        NSFontAttributeName: font
                };
            }
            [img lockFocus];
            [bip drawInRect:NSMakeRect(0, 0, w, h)
                   fromRect:NSMakeRect(current_point.x,
                           buf_height[buf_index] - current_point.y - h,
                           w, h)
                  operation:NSCompositeSourceOver
                   fraction:1.0f
             respectFlipped:NO
                      hints:@{}];
            [str drawAtPoint:NSMakePoint(0, 0) withAttributes:stringAttributes];
            [img unlockFocus];
            bip = [[NSBitmapImageRep alloc] initWithData:[img TIFFRepresentation]];
        } else { //アンチエリアシングなし
            unsigned char *plane_text_image =
                    malloc(sizeof(unsigned char) * img.size.width * img.size.height *
                            samplesPerPixel);
            memset(plane_text_image, 0, sizeof(unsigned char) * img.size.width *
                    img.size.height * samplesPerPixel);

            CGContextRef context = CGBitmapContextCreate(
                    plane_text_image, img.size.width, img.size.height, 8,
                    img.size.width * 4, CGColorSpaceCreateDeviceRGB(),
                    kCGImageAlphaPremultipliedLast);
            CGContextSaveGState(context);

            CGColorRef fontColor = [color CGColor];

            // Paragraph
            //- kCTTextAlignmentLeft
            //- kCTTextAlignmentCenter
            //- kCTTextAlignmentRight
            //- kCTTextAlignmentNatural
            CTTextAlignment alignment = kCTTextAlignmentLeft;

            CTParagraphStyleSetting settings[] = {
                    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
            };

            CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(
                    settings, sizeof(settings) / sizeof(settings[0]));

            CFTypeRef underline_style;
            if (font_style & 4) {
                underline_style = (__bridge CFTypeRef) (@(kCTUnderlineStyleSingle));
            } else {
                underline_style = (__bridge CFTypeRef) (@(kCTUnderlineStyleNone));
            }

            CFStringRef keys[] = {kCTFontAttributeName,
                    kCTParagraphStyleAttributeName,
                    kCTForegroundColorAttributeName,
                    kCTUnderlineStyleAttributeName};
            CFTypeRef values[] = {ct_font, paragraphStyle, fontColor,
                    underline_style};

            //メモリ解放必要
            CFDictionaryRef font_attributes = CFDictionaryCreate(
                    kCFAllocatorDefault, (const void **) &keys, (const void **) &values,
                    sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks,
                    &kCFTypeDictionaryValueCallBacks);
            int x = 0;
            int y = 3;

            CFStringRef string = CFStringCreateWithCString(NULL, [str UTF8String],
                    kCFStringEncodingUTF8);
            CFAttributedStringRef attr_string =
                    CFAttributedStringCreate(NULL, string, font_attributes);
            CTLineRef line = CTLineCreateWithAttributedString(attr_string);
            CGContextSetTextPosition(context, x, y);
            CGContextSetAllowsAntialiasing(context, NO);
            CGContextSetShouldAntialias(context, NO);
            CGContextSetShouldSmoothFonts(context, NO);

            CTLineDraw(line, context);

            unsigned char *bitmap = CGBitmapContextGetData(context);

            // 画像出力
            CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(
                    NULL, bitmap, img.size.width * img.size.height * 4, bufferFree);
            CGImageRef result = CGImageCreate(
                    img.size.width, img.size.height, 8, 32, img.size.width * 4,
                    CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo) kCGImageAlphaLast,
                    dataProviderRef, NULL, 0, kCGRenderingIntentDefault);
            NSImage *image = [[NSImage alloc] initWithCGImage:result size:img.size];
            bip = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];

            // 解放処理
            CFRelease(dataProviderRef);
            CGImageRelease(result);

            CFRelease(underline_style);
            CFRelease(paragraphStyle);
            CFRelease(line);
            CFBridgingRelease(attr_string);
            CFBridgingRelease(string);
            CFBridgingRelease(font_attributes);
            CGContextRelease(context);
            free(plane_text_image);
        }

        //描画した画像からプレーンデータを生成する
        NSUInteger color_now[samplesPerPixel];
        NSUInteger color_compare[samplesPerPixel];
        color_compare[0] = current_color.red;
        color_compare[1] = current_color.green;
        color_compare[2] = current_color.blue;
        color_compare[3] = current_color.alpha;

        int i = 0;
        int height = h; //(int)strSize.height;
        int width = w;  //(int)strSize.width + 10;
        while (1) {
            if (width + current_point.x >= 641) {
                width--;
            } else if (width < 1) {
                break;
            } else {
                break;
            }
        }
        i = current_point.x * samplesPerPixel +
                current_point.y * buf_width[buf_index] * samplesPerPixel;

        if (font_style & 16) {
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    [bip getPixel:color_now atX:x y:y];
                    pixel_data[buf_index][i] = color_now[0];
                    pixel_data[buf_index][i + 1] = color_now[1];
                    pixel_data[buf_index][i + 2] = color_now[2];
                    pixel_data[buf_index][i + 3] = color_now[3];

                    i += samplesPerPixel;
                }
                i += buf_width[buf_index] * samplesPerPixel - width * samplesPerPixel;
            }
        } else {
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    [bip getPixel:color_now atX:x y:y];
                    if (color_now[0] == color_compare[0] &&
                            color_now[1] == color_compare[1] &&
                            color_now[2] == color_compare[2] &&
                            color_now[3] == color_compare[3]) {
                        pixel_data[buf_index][i] = color_now[0];
                        pixel_data[buf_index][i + 1] = color_now[1];
                        pixel_data[buf_index][i + 2] = color_now[2];
                        pixel_data[buf_index][i + 3] = color_now[3];
                    }

                    i += samplesPerPixel;
                }
                i += buf_width[buf_index] * samplesPerPixel - width * samplesPerPixel;
            }
        }

        CFRelease(ct_font_name);
        CFRelease(ct_font);

        current_point.y += h;

        if (is_redraw_just_now && buf_index == 0) {
            [self redraw];
        }
    }
}

static void bufferFree(void *info, const void *data, size_t size) {
    // free((unsigned char *)data);
}

- (NSSize)picload:(NSString *)filename {
    return [self picload:filename mode:0];
}

- (NSSize)picload:(NSString *)filename mode:(int)mode {
    NSSize pictureSize;
    NSString *path;
    if (g.is_startax_in_resource) { //リソース内にstart.axがある場合
        path = [NSBundle mainBundle].resourcePath; //リソースディレクトリ
        path = [path stringByAppendingString:@"/"];
        path = [path stringByAppendingString:filename];
    } else if (![g.current_script_path isEqual:@""]) { //ソースコードのあるディレクトリ
        path = g.current_script_path;
    } else { // hsptmp
        path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp"];
    }
    path = [path stringByAppendingString:@"/"];
    path = [path stringByAppendingString:filename];

    _Size image_size;
    if (mode == 0) {
        //画像サイズに合わせて画面をリサイズ
        image_size = load_image_init_canvas([path UTF8String], pixel_data[buf_index]);
        buf_width[buf_index] = image_size.width;
        buf_height[buf_index] = image_size.height;
    } else {
        //画面をリサイズせず読み込み
        image_size = load_image([path UTF8String], pixel_data[buf_index], current_point.x, current_point.y, buf_width[buf_index], buf_height[buf_index]);
    }
    pictureSize.width = image_size.width;
    pictureSize.height = image_size.height;

    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
    return pictureSize;
}

//-------------------------------------->> フィルター

- (void)vcopy:(int)index {
    //    CGAffineTransform t = CGAffineTransformMakeTranslation(200, 200);
    //    NSLog(@"%f",at.a);
    //    NSLog(@"%f",at.b);
    //    NSLog(@"%f",at.c);
    //    NSLog(@"%f",at.d);
    //    NSLog(@"%f",at.tx);
    //    NSLog(@"%f",at.ty);

    //    vImage_AffineTransform affine_transform = {1.0,0.0,0.0,1.0,200.0,0.0};
    //    Pixel_8888 bgColor = {0, 0, 0, 255};
    //
    //    vImage_Buffer source = {pixel_data[index], buf_height[index],
    //    buf_width[index], buf_width[index]*4};
    //    vImage_Buffer dest = {pixel_data[buf_index], buf_height[buf_index],
    //    buf_width[buf_index], buf_width[buf_index]*4};
    //
    //    vImageAffineWarp_ARGB8888(&source, &dest, NULL, &affine_transform,
    //    bgColor, kvImageHighQualityResampling);
    //
    //    affine_transform.tx = 0;
    //    vImageAffineWarp_ARGB8888(&source, &dest, NULL, &affine_transform,
    //    bgColor, kvImageHighQualityResampling);

    //    vImageScale_ARGB8888(&source, &dest, NULL,
    //    kvImageHighQualityResampling);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// 拡大縮小する：倍率はdestのサイズで変わる
///
- (void)scale {
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImage_Buffer dest = {pixel_data[buf_index], 120, 160, buf_width[buf_index] * 4};
    vImageScale_ARGB8888(&source, &dest, NULL, kvImageHighQualityResampling);
}

/// 回転する
///
- (void)rotate {
    float radians = 2.0;
    Pixel_8888 bgColor = {0, 0, 0, 0};
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageRotate_ARGB8888(&source, &source, NULL, radians, bgColor, kvImageBackgroundColorFill);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// エッジ検出
- (void)edgedetect {
    static int16_t edgedetect_kernel[9] = {-1, -1, -1, -1, 8, -1, -1, -1, -1};
    Pixel_8888 bgColor = {0, 0, 0, 0};
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageConvolve_ARGB8888(&source, &source, NULL, 0, 0, edgedetect_kernel, 3, 3, 1, bgColor, kvImageCopyInPlace);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// 先鋭化
///
- (void)sharpen {
    static int16_t sharpen_kernel[9] = {-1, -1, -1, -1, 9, -1, -1, -1, -1};
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageConvolve_ARGB8888(&source, &source, NULL, 0, 0, sharpen_kernel, 3, 3, 1, NULL, kvImageCopyInPlace);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)unsharpen {
    static int16_t unsharpen_kernel[9] = {-1, -1, -1, -1, 17, -1, -1, -1, -1};
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageConvolve_ARGB8888(&source, &source, NULL, 0, 0, unsharpen_kernel, 3, 3, 9, NULL, kvImageCopyInPlace);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// 膨張
///
- (void)dilate {
    static unsigned char morphological_kernel[9] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1,
    };
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageDilate_ARGB8888(&source, &source, 0, 0, morphological_kernel, 3, 3, kvImageCopyInPlace);
    vImageErode_ARGB8888(&source, &source, 0, 0, morphological_kernel, 3, 3, kvImageCopyInPlace);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// 収縮
///
- (void)erode {
    static unsigned char morphological_kernel[9] = {
            1, 1, 1, 1, 1, 1, 1, 1, 1,
    };
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageErode_ARGB8888(&source, &source, 0, 0, morphological_kernel, 3, 3, kvImageCopyInPlace);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// ヒストグラム均一化
///
- (void)equalization {
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageEqualization_ARGB8888(&source, &source, kvImageNoFlags);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)emboss {
    //エンボス
    static int16_t emboss_kernel[9] = {-2, 0, 0, 0, 1, 0, 0, 0, 2};
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageConvolve_ARGB8888(&source, &source, NULL, 0, 0, emboss_kernel, 3, 3, 1, NULL, kvImageCopyInPlace);
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// 上下反転する
///
- (void)verticalReflect {
    //直接出力する方法
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageVerticalReflect_ARGB8888(&source, &source, kvImageNoFlags);

    //別な方法
    // vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index],
    // buf_width[buf_index], buf_width[buf_index]*4};
    // const size_t destSize = sizeof(UInt8) * buf_width[buf_index] *
    // buf_height[buf_index] * 4 * 2;
    // void *destData = malloc(destSize);
    // vImage_Buffer dest = {destData, buf_height[buf_index],
    // buf_width[buf_index], buf_width[buf_index]*4};
    // vImageVerticalReflect_ARGB8888(&source, &dest, kvImageNoFlags);
    // memcpy(pixel_data[buf_index],destData,sizeof(UInt8) * buf_width[buf_index]
    // * buf_height[buf_index] * 4);
    // free(destData);

    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// 左右反転する
///
- (void)horizontalReflect {
    //直接出力する方法
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageHorizontalReflect_ARGB8888(&source, &source, kvImageNoFlags);

    //別な方法
    // vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index],
    // buf_width[buf_index], buf_width[buf_index]*4};
    // const size_t destSize = sizeof(UInt8) * buf_width[buf_index] *
    // buf_height[buf_index] * 4 * 2;
    // void *destData = malloc(destSize);
    // vImage_Buffer dest = {destData, buf_height[buf_index],
    // buf_width[buf_index], buf_width[buf_index]*4};
    // vImageHorizontalReflect_ARGB8888(&source, &dest, kvImageNoFlags);
    // memcpy(pixel_data[buf_index],destData,sizeof(UInt8) * buf_width[buf_index]
    // * buf_height[buf_index] * 4);
    // free(destData);

    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

/// ぼかし
///
- (void)gaussianblur {
    // 2次元のガウス関数を求める
    double x, y;
    double s = 5;
    double w = s * 4;
    double h;
    double btm;
    int frq;
    int n = 10; //この値がフィルタの強度になる
    int i, j;
    int m;
    int16_t gaussKernel[100000]; //多めに確保
    int counter = 0;
    h = w / n;
    m = 2 * n - 1;
    btm = -(w - h);
    for (i = 0; i < m; i++) {
        for (j = 0; j < m; j++) {
            x = btm + h * j;
            y = btm + h * i;
            frq = (int) (exp(-(x * x + y * y) / (2 * s * s)) * 100);
            gaussKernel[counter] = frq;
            counter++;
        }
    }
    int divisor = 0;
    for (int i = 0; i < m * m; i++) {
        divisor += gaussKernel[i];
    }
    //直接出力する方法
    vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index], buf_width[buf_index], buf_width[buf_index] * 4};
    vImageConvolve_ARGB8888(&source, &source, NULL, 0, 0, gaussKernel, m, m,
            divisor, NULL, kvImageBackgroundColorFill);

    //別な方法
    // vImage_Buffer source = {pixel_data[buf_index], buf_height[buf_index],
    // buf_width[buf_index], buf_width[buf_index]*4};
    // const size_t destSize = sizeof(UInt8) * buf_width[buf_index] *
    // buf_height[buf_index] * 4 * 2;
    // void *destData = malloc(destSize);
    // vImage_Buffer dest = {destData, buf_height[buf_index],
    // buf_width[buf_index], buf_width[buf_index]*4};
    // vImageConvolve_ARGB8888(&source,&dest,NULL,0,0,gauss,m,m,divisor,NULL,kvImageBackgroundColorFill);
    // memcpy(pixel_data[buf_index],destData,sizeof(UInt8) * buf_width[buf_index]
    // * buf_height[buf_index] * 4);
    // free(destData);

    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

- (void)cifilter:(int)type {
    //プレーンデータからNSImageを生成
    unsigned char *plane = malloc(sizeof(unsigned char) * buf_width[buf_index] * buf_height[buf_index] * 4 * 2);
    memcpy(plane, pixel_data[buf_index], sizeof(unsigned char) * buf_width[buf_index] * buf_height[buf_index] * 4);
    NSBitmapImageRep *bip = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&plane pixelsWide:buf_width[buf_index] pixelsHigh:buf_height[buf_index] bitsPerSample:8 samplesPerPixel:samplesPerPixel hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:buf_width[buf_index] * samplesPerPixel bitsPerPixel:samplesPerPixel * 8];

    free(plane);

    CIImage *ciImage = [[CIImage alloc] initWithCGImage:bip.CGImage]; // NSBitmapImageRepをCIImageに変換

    CIFilter *filter;
    /*
    switch (type) {
        case 0: //グレースケール
            filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, ciImage, @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75], @"inputIntensity", [NSNumber numberWithFloat:1.0], nil];
            break;
        case 1: // セピア
            filter =
            [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, ciImage, @"inputIntensity",
            [NSNumber numberWithFloat:0.8], nil];
            break;
        case 2: // 色の反転
            filter = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 3: // 偽色
            filter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:kCIInputImageKey, ciImage, @"inputColor0", [CIColor colorWithRed:0.44 green:0.5 blue:0.2 alpha:1], @"inputColor1", [CIColor colorWithRed:1 green:0.92 blue:0.50 alpha:1], nil];
            break;
        case 4: // 色調節フィルタ
            filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, @"inputSaturation", [NSNumber numberWithFloat:1.0], @"inputBrightness", [NSNumber numberWithFloat:0.5], @"inputContrast", [NSNumber numberWithFloat:3.0], nil];
            break;
        case 5: // トーンカーブ
            filter = [CIFilter filterWithName:@"CIToneCurve" keysAndValues:kCIInputImageKey, ciImage, @"inputPoint0", [CIVector vectorWithX:0.0 Y:0.0], @"inputPoint1", [CIVector vectorWithX:0.25 Y:0.1], @"inputPoint2", [CIVector vectorWithX:0.5 Y:0.5], @"inputPoint3", [CIVector vectorWithX:0.75 Y:0.9], @"inputPoint4", [CIVector vectorWithX:1 Y:1], nil];
            break;
        case 6: // 色相調整
            filter = [CIFilter filterWithName:@"CIHueAdjust" keysAndValues:kCIInputImageKey, ciImage, @"inputAngle",
            [NSNumber numberWithFloat:3.14], nil];
            break;
        case 7: // ビネット効果（トイカメラ風）
            filter = [CIFilter filterWithName:@"CIVignette" keysAndValues:kCIInputImageKey, ciImage, @"inputRadius", [NSNumber numberWithFloat:200.0f], @"inputIntensity", [NSNumber numberWithFloat:2.0f], nil];
            break;
        case 8: // アルファをマスク
            filter = [CIFilter filterWithName:@"CIMaskToAlpha" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 9: // モザイク
            filter = [CIFilter filterWithName:@"CIPixellate" keysAndValues:kCIInputImageKey, ciImage, @"inputCenter", [CIVector vectorWithX:250.0 Y:250.0], @"inputScale", [NSNumber numberWithFloat:20.0], nil];
            break;
        case 10: // 写真効果1
            filter = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 11: // 写真効果2
            filter = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 12: //写真効果3
            filter = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 13: //写真効果4
            filter = [CIFilter filterWithName:@"CIPhotoEffectMono" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 14: //写真効果5
            filter = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 15: //写真効果6
            filter = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 16: //写真効果7
            filter = [CIFilter filterWithName:@"CIPhotoEffectTonal" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        case 17: //写真効果8
            filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, ciImage, nil];
            break;
        default:
            break;
    }*/

    // フィルタ後の画像を取得
    //ciImage = filter.outputImage;

    //描画した画像からプレーンデータを生成する
    bip = [[NSBitmapImageRep alloc] initWithCIImage:ciImage]; // CIImageからNSBitmapImageRepを生成する
    NSUInteger p[4];
    int i = 0;
    int height = (int) bip.size.height;
    int width = (int) bip.size.width;
    // i=current_point.x*4+current_point.y*buf_width[buf_index]*4;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            [bip getPixel:p atX:x y:y];
            pixel_data[buf_index][i] = p[0];
            pixel_data[buf_index][i + 1] = p[1];
            pixel_data[buf_index][i + 2] = p[2];
            i += 4;
        }
        i += buf_width[buf_index] * 4 - width * 4;
    }
    if (is_redraw_just_now && buf_index == 0) {
        [self redraw];
    }
}

@end
