//
//  Document.h
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"



@interface Document : NSDocument {
    AppDelegate* global;
    int accessNumber;
    
    NSString* title;
    NSWindowController* aController;
}


@end


