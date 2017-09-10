#import "NSObject+Singleton.h"

@interface AGRegexCache : NSObject

    SINGLETON_INTERFACE(AGRegexCache)

- (NSRegularExpression *)regexForPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (void)clear;

@end
