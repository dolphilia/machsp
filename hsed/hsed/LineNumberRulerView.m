//
//  LineNumberRulerView.m
//  globalvaltest
//
//  Created by dolphilia on 2016/01/29.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

//
//  LineNumberRulerView.swift
//  LineNumber
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "LineNumberRulerView.h"

@implementation LineNumberRulerView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}
- (instancetype)init:(NSTextView *)textView {
    self = [super initWithScrollView:textView.enclosingScrollView orientation:NSVerticalRuler];
    myFont = textView.font ? [NSFont systemFontOfSize:[NSFont smallSystemFontSize]] : [NSFont systemFontOfSize:[NSFont smallSystemFontSize]] ;
    self.clientView = textView;
    self.ruleThickness = 40;
    [self setNeedsDisplay:YES];
    return self;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    //行番号の矩形領域を描画する
    NSBezierPath* rectangle = [NSBezierPath bezierPathWithRect:CGRectMake(0,0,40,self.frame.size.height) ];
    [[NSColor colorWithCalibratedRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0] setFill]; // stroke 色の設定
    [rectangle fill];
    NSBezierPath* number_line = [NSBezierPath bezierPathWithRect:CGRectMake(39,0,1,self.frame.size.height)];
    [[NSColor colorWithCalibratedRed:87.0/255.0 green:87.0/255.0 blue:87.0/255.0 alpha:1.0] setFill]; // stroke 色の設定
    [number_line fill];

    NSTextView* textView = (NSTextView*)self.clientView;
    NSLayoutManager* layoutManager = textView.layoutManager;
    if (textView != nil && layoutManager != nil) {
        NSPoint relativePoint = [self convertPoint:NSZeroPoint fromView:textView];
        NSDictionary* lineNumberAttributes = @{NSFontAttributeName:textView.font, NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0]};
        NSRange visibleGlyphRange = [layoutManager glyphRangeForBoundingRect:textView.visibleRect inTextContainer:textView.textContainer];
        NSUInteger firstVisibleGlyphCharacterIndex = [layoutManager characterIndexForGlyphAtIndex:visibleGlyphRange.location];
        NSError *error = nil;
        NSRegularExpression* newLineRegex = [NSRegularExpression regularExpressionWithPattern:@"\n" options:0 error:&error];
        if (error != nil) {
            return;
        }
        NSUInteger lineNumber = [newLineRegex numberOfMatchesInString:textView.string options:0 range:NSMakeRange(0, firstVisibleGlyphCharacterIndex)]+1;
        
        NSUInteger glyphIndexForStringLine = visibleGlyphRange.location;

        // 各行を精査
        while (glyphIndexForStringLine < NSMaxRange(visibleGlyphRange)) {
            NSRange characterRangeForStringLine = [textView.string lineRangeForRange:NSMakeRange( [layoutManager characterIndexForGlyphAtIndex:glyphIndexForStringLine], 0 )
                                                     ];
            // 現在行のrange
            NSRange glyphRangeForStringLine = [layoutManager glyphRangeForCharacterRange:characterRangeForStringLine actualCharacterRange: nil];
            NSUInteger glyphIndexForGlyphLine = glyphIndexForStringLine;
            NSUInteger glyphLineCount = 0;
            
            while ( glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) ) {
                NSRange effectiveRange = NSMakeRange(0, 0);
                NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndexForGlyphLine effectiveRange: &effectiveRange withoutAdditionalLayout: true];
                
                if (glyphLineCount > 0) {
                    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:@"-" attributes:lineNumberAttributes];
                    CGFloat x = 35 - attString.size.width;
                    CGFloat y = CGRectGetMinY(lineRect);
                    [attString drawAtPoint:NSMakePoint(x, relativePoint.y + y)];
                } else {
                    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)lineNumber] attributes:lineNumberAttributes];
                    CGFloat x = 35 - attString.size.width;
                    CGFloat y = CGRectGetMinY(lineRect);
                    [attString drawAtPoint:NSMakePoint(x, relativePoint.y + y)];
                }
                
                // 次の行に
                glyphLineCount++;
                glyphIndexForGlyphLine = NSMaxRange(effectiveRange);
            }
            
            glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine);
            lineNumber++;
        }
        
        if ([layoutManager extraLineFragmentTextContainer] != nil) {
            NSAttributedString* attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)lineNumber] attributes:lineNumberAttributes];
            CGFloat x = 35 - attString.size.width;
            CGFloat y = CGRectGetMinY(layoutManager.extraLineFragmentRect);
            [attString drawAtPoint:NSMakePoint(x, relativePoint.y + y)];
        }
    }
}

@end