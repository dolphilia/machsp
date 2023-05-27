//
//  MyColorThemePopUpButton.m
//  hsed
//
//  Created by dolphilia on 2016/04/16.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyColorThemePopUpButton.h"

@implementation MyColorThemePopUpButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        if (global.selectedColorThemeString == nil) {
            global.selectedColorThemeString = [self title];
        }
        [self setAction:@selector(mySelector:)];
        [self setTarget:self];
    }
    return self;
}

- (IBAction)mySelector:(id)sender {
    global.selectedColorThemeString = [(NSPopUpButton *) sender titleOfSelectedItem];
}

@end