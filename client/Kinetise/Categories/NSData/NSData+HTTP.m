#import "NSData+HTTP.h"
#import "NSString+URL.h"

@implementation NSData (HTTP)

+ (NSData *)dataWithHTTPForm:(NSDictionary *)parameters {
    NSMutableString *postBody = [NSMutableString string];

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
        if (postBody.length) {
            [postBody appendString:@"&"];
        }
        [postBody appendString:[key URLEncodedString] ];
        [postBody appendString:@"="];
        [postBody appendString:[value URLEncodedString] ];
    }];

    return [postBody dataUsingEncoding:NSUTF8StringEncoding];
}

@end
