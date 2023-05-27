//
//  MySyntaxPopUpButton.m
//  hsed
//
//  Created by dolphilia on 2016/04/08.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySyntaxPopUpButton.h"

@implementation MySyntaxPopUpButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        if (global.selectedSyntaxString == nil) {
            global.selectedSyntaxString = [self title];
        }
        [self setAction:@selector(mySelector:)];
        [self setTarget:self];
    }
    return self;
}

- (IBAction)mySelector:(id)sender {
    global.selectedSyntaxString = [(NSPopUpButton *) sender titleOfSelectedItem];
}

@end