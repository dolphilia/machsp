//
//  ViewController.h
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyWebKitView.h"
#import "MyTextView.h"
#import "MyWindow.h"

@interface ViewController : NSViewController {
    IBOutlet MyWebKitView *myWebKitView;
    IBOutlet MyTextView *myTextView;
    IBOutlet MyWindow *myWindow;
}

- (IBAction)doSomething:(id)sender;

- (IBAction)onLaunchApplication:(id)sender;

- (IBAction)onTerminateApplication:(id)sender;

@end

