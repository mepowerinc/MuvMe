#import <Foundation/Foundation.h>

@interface AGRegexExtractor : NSObject

+ (NSString *)processTagsWithString:(NSString *)text andRules:(NSArray *)rules;
+ (NSString *)processTagsWithString:(NSString *)text andRegexName:(NSString *)regexName;

@end
