#import "AGRegexCache.h"

@interface AGRegexCache (){
    NSMutableDictionary *cache;
}
@end

@implementation AGRegexCache

SINGLETON_IMPLEMENTATION(AGRegexCache)

- (void)dealloc {
    [cache release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    cache = [[NSMutableDictionary alloc] init];

    return self;
}

- (NSRegularExpression *)regexForPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSString *key = [self keyForPattern:pattern options:options];

    NSRegularExpression *regex = cache[key];

    if (!regex) {
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
    }

    return regex;
}

- (void)clear {
    [cache removeAllObjects];
}

- (NSString *)keyForPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    return [pattern stringByAppendingString:[@(options)stringValue]];
}

@end
