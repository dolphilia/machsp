//
//  Document.h
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
