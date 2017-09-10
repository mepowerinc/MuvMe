#import <Foundation/Foundation.h>

@interface NSData (HTTP)

+ (NSData *)dataWithHTTPForm:(NSDictionary *)parameters;

@end
