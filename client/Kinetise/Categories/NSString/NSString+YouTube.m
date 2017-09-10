#import "NSString+YouTube.h"

@implementation NSString (YouTube)

- (NSString *)stringByExtractingYouTubeVideoId {
    NSString *regexString = @"^(?:http(?:s)?://)?(?:www\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)/))([^\?&\"'>]+)";
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (match && match.numberOfRanges == 2) {
        NSRange videoIdRange = [match rangeAtIndex:1];
        NSString *videoId = [self substringWithRange:videoIdRange];
        
        return videoId;
    }
    
    return nil;
}

@end
