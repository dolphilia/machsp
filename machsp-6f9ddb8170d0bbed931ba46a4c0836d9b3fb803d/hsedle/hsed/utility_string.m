//
//  utility_string.m
//  hsedle
//
//  Created by dolphilia on 2022/04/22.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utility_string.h"

@implementation utility_string

//--- 文字列操作のためのユーティリティ

//文字列の指定位置で指定された位置の文字を返す
+(NSString*)charAt:(NSString*)str index:(int)index {
    if (index>=str.length) {
        return @"";
    }
    if (index<0) return @"";
    return [str substringWithRange:NSMakeRange(index, 1)];
}

//文字列の部分文字列を返す
+(NSString*)substr:(NSString*)str index:(int)index length:(int)length {
    if (index>=str.length || index+length>=str.length) {
        return @"";
    }
    if (index<0) return @"";
    return [str substringWithRange:NSMakeRange(index, length)];
}

+(int)indexOf:(NSString*)str searchStr:(NSString*)searchStr {
    if (str.length < searchStr.length) {
        return -1;
    }
    return (int)[str rangeOfString:searchStr].location;
}

+(int)indexOf:(NSString*)str searchStr:(NSString*)searchStr location:(int)location {
    if (str.length < location+searchStr.length) {
        return -1;
    }
    return (int)[str rangeOfString:searchStr options:0 range:NSMakeRange(location, str.length-location)].location;
}

+(BOOL)isSpaceCharacter:(NSString*)str {
    if ( [str isEqual:@" "] || [str isEqual:@"\t"] || [str isEqual:@"\f"] || [str isEqual:@"\n"] || [str isEqual:@"\r"] || [str isEqual:@"\v"]) {
        return YES;
    } else {
        return NO;
    }
}

+(BOOL)isOperatorCharacter:(NSString*)str {
    if ( [str isEqual:@"+"] || [str isEqual:@"-"] || [str isEqual:@"*"] || [str isEqual:@"/"] || [str isEqual:@"\\"] || [str isEqual:@"="] || [str isEqual:@"&"] || [str isEqual:@"|"] || [str isEqual:@"^"] || [str isEqual:@"<"] || [str isEqual:@">"] || [str isEqual:@"!"]) {
        return YES;
    } else {
        return NO;
    }
}

+(NSString*)replace:(NSString*)str searchStr:(NSString*)searchStr replaceStr:(NSString*)replaceStr {
    return [str stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];
}

+(NSString*)preg_replace:(NSString*)str patternStr:(NSString*)patternStr replaceStr:(NSString*)replaceStr {
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:patternStr options:0 error:&error];
    NSString *new_str = [regexp stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:replaceStr];
    return new_str;
}

+(NSString*)preg_replace_lines:(NSString *)str patternStr:(NSString *)patternStr replaceStr:(NSString *)replaceStr {
    __block NSString* tmpstr = @"";
    __block NSString* t = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        t = line;
        if ([self preg_match:line patternStr:patternStr]) {
            t = [self preg_replace:line patternStr:patternStr replaceStr:replaceStr];
        }
        tmpstr = [tmpstr stringByAppendingString:t];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    return tmpstr;
}

+(BOOL)preg_match:(NSString*)str patternStr:(NSString*)patternStr {
    BOOL ret = NO;
    NSError* error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternStr options:0 error:&error];
    NSArray * matches = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if ([matches isEqual:nil]) {
    } else {
        if (matches.count > 0) {
            ret = YES;
        }
    }
    return ret;
}

+(NSString*)trim:(NSString*)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+(NSString*)append:(NSString*)str append:(NSString*)append {
    return [str stringByAppendingString:append];
}

//すべての行をtrimする
+(NSString*)trimAllLines:(NSString*)str {
    __block NSString* tmpstr = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        tmpstr = [tmpstr stringByAppendingString:[self trim:line]];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    return tmpstr;
}
//すべての行から空行を取り除く
+(NSString*)deleteBlankLineAllLines:(NSString*)str {
    __block NSString* tmpstr = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if ([line isEqual:@""]){}
        else {
            tmpstr = [tmpstr stringByAppendingString:line];
            tmpstr = [tmpstr stringByAppendingString:@"\n"];
        }
    }];
    return tmpstr;
}

@end
