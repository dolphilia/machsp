//
//  utility_string.h
//  hsedle
//
//  Created by dolphilia on 2022/04/22.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#ifndef utility_string_h
#define utility_string_h

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface objc_utility_string : NSObject {
}

+(NSString*)charAt:(NSString*)str index:(int)index;
+(NSString*)substr:(NSString*)str index:(int)index length:(int)length;
+(int)indexOf:(NSString*)str searchStr:(NSString*)searchStr;
+(int)indexOf:(NSString*)str searchStr:(NSString*)searchStr location:(int)location;
+(BOOL)isSpaceCharacter:(NSString*)str;
+(BOOL)isOperatorCharacter:(NSString*)str;
+(NSString*)preg_replace_lines:(NSString *)str patternStr:(NSString *)patternStr replaceStr:(NSString *)replaceStr;
+(NSString*)replace:(NSString*)str searchStr:(NSString*)searchStr replaceStr:(NSString*)replaceStr;
+(NSString*)preg_replace:(NSString*)str patternStr:(NSString*)patternStr replaceStr:(NSString*)replaceStr;
+(BOOL)preg_match:(NSString*)str patternStr:(NSString*)patternStr;
+(NSString*)trim:(NSString*)str;
+(NSString*)append:(NSString*)str append:(NSString*)append;
+(NSString*)trimAllLines:(NSString*)str;
+(NSString*)deleteBlankLineAllLines:(NSString*)str;

@end



#endif /* utility_string_h */
