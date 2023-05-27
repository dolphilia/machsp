//
//  MyFontSizePopUpButton.m
//  hsed
//
//  Created by 半澤 聡 on 2016/06/29.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyFontSizePopUpButton.h"

@implementation MyFontSizePopUpButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        if (global.selectedFontSizeString == nil) {
            global.selectedFontSizeString = [self title];
        }
        [self setAction:@selector(mySelector:)];
        [self setTarget:self];
    }
    return self;
}

- (IBAction)mySelector:(id)sender {
    global.selectedFontSizeString = [(NSPopUpButton *) sender titleOfSelectedItem];
}

@end