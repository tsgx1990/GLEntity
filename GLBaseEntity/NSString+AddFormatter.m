//
//  NSString+AddFormatter.m
//  StringSeperateDemo
//
//  Created by guanglong on 16/2/16.
//  Copyright © 2016年 syswin. All rights reserved.
//

#import "NSString+AddFormatter.h"

@implementation NSString (AddFormatter)

+ (NSString *)emptyStringWithFormat:(NSString *)format, ...
{
    va_list argPtr;
    va_start(argPtr, format);
    NSMutableString* mFormattedString = [self handleFormatString:format argumentsList:argPtr emptyString:@""];
    va_end(argPtr);
    
    return mFormattedString;
}

+ (NSString *)emptyString:(NSString *)emptyString withFormat:(NSString *)format, ...
{
    va_list argPtr;
    va_start(argPtr, format);
    NSMutableString* mFormattedString = [self handleFormatString:format argumentsList:argPtr emptyString:emptyString];
    va_end(argPtr);
    
    return mFormattedString;
}

+ (NSMutableString *)handleFormatString:(NSString *)formatString argumentsList:(va_list)args emptyString:(NSString *)emptyString
{
    NSMutableString* stringContainer = [NSMutableString stringWithCapacity:formatString.length];
    
    NSUInteger length = [formatString length];
    unichar last = '\0';
    for (NSUInteger i = 0; i < length; ++i) {
        id arg = nil;
        unichar current = [formatString characterAtIndex:i];
        unichar add = current;
        if (last == '%') {
            switch (current) {
                case '@':
                    arg = va_arg(args, id);
                    break;
                case 'c':
                    // warning: second argument to 'va_arg' is of promotable type 'char'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                    arg = [NSString stringWithFormat:@"%c", va_arg(args, int)];
                    break;
                case 's':
                    arg = [NSString stringWithUTF8String:va_arg(args, char*)];
                    break;
                case 'd':
                case 'D':
                case 'i':
                    arg = [NSNumber numberWithInt:va_arg(args, int)];
                    break;
                case 'u':
                case 'U':
                    arg = [NSNumber numberWithUnsignedInt:va_arg(args, unsigned int)];
                    break;
                case 'h':
                    i++;
                    if (i < length && [formatString characterAtIndex:i] == 'i') {
                        //  warning: second argument to 'va_arg' is of promotable type 'short'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                        arg = [NSNumber numberWithShort:(short)(va_arg(args, int))];
                    }
                    else if (i < length && [formatString characterAtIndex:i] == 'u') {
                        // warning: second argument to 'va_arg' is of promotable type 'unsigned short'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                        arg = [NSNumber numberWithUnsignedShort:(unsigned short)(va_arg(args, uint))];
                    }
                    else {
                        i--;
                    }
                    break;
                case 'q':
                    i++;
                    if (i < length && [formatString characterAtIndex:i] == 'i') {
                        arg = [NSNumber numberWithLongLong:va_arg(args, long long)];
                    }
                    else if (i < length && [formatString characterAtIndex:i] == 'u') {
                        arg = [NSNumber numberWithUnsignedLongLong:va_arg(args, unsigned long long)];
                    }
                    else {
                        i--;
                    }
                    break;
                case 'f':
                    arg = [NSNumber numberWithDouble:va_arg(args, double)];
                    break;
                case 'g':
                    // warning: second argument to 'va_arg' is of promotable type 'float'; this va_arg has undefined behavior because arguments will be promoted to 'double'
                    arg = [NSNumber numberWithFloat:(float)(va_arg(args, double))];
                    break;
                case 'l':
                    i++;
                    if (i < length) {
                        unichar next = [formatString characterAtIndex:i];
                        if (next == 'l') {
                            i++;
                            if (i < length && [formatString characterAtIndex:i] == 'd') {
                                //%lld
                                arg = [NSNumber numberWithLongLong:va_arg(args, long long)];
                            }
                            else if (i < length && [formatString characterAtIndex:i] == 'u') {
                                //%llu
                                arg = [NSNumber numberWithUnsignedLongLong:va_arg(args, unsigned long long)];
                            }
                            else {
                                i--;
                            }
                        }
                        else if (next == 'd') {
                            //%ld
                            arg = [NSNumber numberWithLong:va_arg(args, long)];
                        }
                        else if (next == 'u') {
                            //%lu
                            arg = [NSNumber numberWithUnsignedLong:va_arg(args, unsigned long)];
                        }
                        else {
                            i--;
                        }
                    }
                    else {
                        i--;
                    }
                    break;
                default:
                    // something else that we can't interpret. just pass it on through like normal
                    break;
            }
        }
        else if (current == '%') {
            // percent sign; skip this character
            add = '\0';
        }
        
        if (arg != nil) {
            [stringContainer appendFormat:@"%@", arg];
        }
        else if (add == (unichar)'@' && last == (unichar) '%') {
            [stringContainer appendFormat:@"%@", emptyString];
        }
        else if (add != '\0') {
            [stringContainer appendFormat:@"%C", add];
        }
        last = current;
    }
    return stringContainer;
}

@end
