#import <Foundation/Foundation.h>

@interface NSCharacterSet (HTML)

+ (NSCharacterSet *)htmlAttributeNameCharacterSet;

@end

@interface NSString (HTML)

- (NSString *)stringByExtractingPlainTextFromHTML;
- (NSString *)stringByExtractingIMGFromHTML;
- (NSString *)stringByExtractingURLFromHTML;
- (NSString *)stringByExtractingFacebookURLFromHTML;

@end
