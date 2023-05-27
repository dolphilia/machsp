//
//  MyComboBox.m
//  hsed
//
//  Created by dolphilia on 2016/04/08.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyComboBox.h"

@implementation MyComboBox

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self selectItemAtIndex:0]; // First item is at index 0
    }
    return self;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
}

- (void)comboBoxSelectionIsChanging:(NSNotification *)notification {
}

- (void)comboBoxWillDismiss:(NSNotification *)notification {
}

- (void)comboBoxWillPopUp:(NSNotification *)notification {
}

@end