#import "NSString+UriEncoding.h"

@implementation NSString (UriEncoding)

- (NSString *)uriString {
    NSURL *URL = [NSURL URLWithString:self];

    if (URL) return self;

    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    /*
       if( [self rangeOfString:@"%"].location!=NSNotFound ){
        return [self stringByRemovingPercentEncoding];
       }

       return self;*/
}

@end
