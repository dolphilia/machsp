//
//  LineNumberRulerView.h
//  globalvaltest
//
//  Created by dolphilia on 2016/01/29.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef LineNumberRulerView_h
#define LineNumberRulerView_h

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface LineNumberRulerView : NSRulerView {
    NSFont* myFont;
}
- (instancetype)init:(NSTextView *)textView;

@end


#endif /* LineNumberRulerView_h */
