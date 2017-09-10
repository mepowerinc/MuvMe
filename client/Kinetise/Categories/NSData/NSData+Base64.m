#import "NSData+Base64.h"

@implementation NSData (Base64)

- (NSString *)base64EncodedString {
    return [self base64EncodedStringWithOptions:0];
}

@end
