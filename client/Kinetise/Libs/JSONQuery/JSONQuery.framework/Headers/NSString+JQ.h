#import "JQParse.h"

@interface NSString (JQ)

- (NSString *)jq:(NSString*)jq_program withOptions:(JV_OPTIONS)flags;
- (NSString *)jq:(NSString*)jq_program;

@end
