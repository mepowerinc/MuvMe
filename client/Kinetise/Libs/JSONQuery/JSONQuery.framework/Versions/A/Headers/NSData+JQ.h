#import "JQParse.h"

@interface NSData (JQ)

- (NSData *)jq:(NSString*)jq_program withOptions:(JV_OPTIONS)flags;
- (NSData *)jq:(NSString*)jq_program;

@end
