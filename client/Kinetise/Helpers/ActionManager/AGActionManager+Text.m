#import "AGActionManager+Text.h"
#import "AGApplication.h"
#import "AGRegexExtractor.h"
#import "NSString+Base64.h"
#import "NSString+URL.h"
#import "NSString+SHA.h"
#import "NSString+MD5.h"

@implementation AGActionManager (Text)

- (NSString *)merge:(id)sender :(id)object :(NSArray *)strings {
    return [strings componentsJoinedByString:@""];
}

- (NSString *)regex:(id)sender :(id)object :(NSString *)string :(NSString *)regexName {
    NSString *value = [AGRegexExtractor processTagsWithString:string andRegexName:regexName];
    if (!value) value = @"";

    return value;
}

- (NSString *)encode:(id)sender :(id)object :(NSString *)algorithm :(NSString *)input {
    NSString *value = @"";
    algorithm = [algorithm lowercaseString];

    if ([algorithm isEqualToString:@"base64"]) {
        value = [input base64EncodedString];
    } else if ([algorithm isEqualToString:@"md5"]) {
        value = [input md5];
    } else if ([algorithm isEqualToString:@"sha1"]) {
        value = [input sha1];
    } else if ([algorithm isEqualToString:@"url"]) {
        value = [input URLEncodedString];
    } else {
        NSLog(@"Unknown encoding algorithm");
    }

    return value;
}

- (NSString *)decode:(id)sender :(id)object :(NSString *)algorithm :(NSString *)input {
    NSString *value = @"";
    algorithm = [algorithm lowercaseString];

    if ([algorithm isEqualToString:@"base64"]) {
        value = [input base64DecodedString];
    } else if ([algorithm isEqualToString:@"url"]) {
        value = [input URLDecodedString];
    } else {
        NSLog(@"Unknown decoding algorithm");
    }

    return value;
}

- (void)increaseTextMultiplier:(id)sender :(id)object :(NSString *)stepString {
    CGFloat step = [stepString floatValue];
    AGAPPLICATION.textMultiplier = MIN(AGAPPLICATION.textMultiplier+step, AGAPPLICATION.descriptor.maxTextMultiplier);
}

- (void)decreaseTextMultiplier:(id)sender :(id)object :(NSString *)stepString {
    CGFloat step = [stepString floatValue];
    AGAPPLICATION.textMultiplier = MAX(AGAPPLICATION.textMultiplier-step, AGAPPLICATION.descriptor.minTextMultiplier);
}

@end
