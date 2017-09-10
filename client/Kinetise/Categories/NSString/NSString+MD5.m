#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)md5 {
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }

    return output;
}

- (BOOL)isMd5 {
    BOOL isXDigit = YES;

    for (NSInteger i = 0; i < self.length; i++) {
        unichar character = [self characterAtIndex:i];
        if (!isxdigit(character)) isXDigit = NO;
    }

    return self.length == 32 && isXDigit;
}

@end