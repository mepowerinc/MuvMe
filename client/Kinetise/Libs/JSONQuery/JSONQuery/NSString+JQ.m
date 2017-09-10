#import "NSString+JQ.h"
#import "JQParse.h"

@implementation NSString (JQ)

- (NSString*)jq:(NSString*)jq_program withOptions:(JV_OPTIONS)flags {
    const char* data = [self UTF8String];
    const size_t data_length = strlen(data);
    __block NSString* outputStr = nil;
    
    JQParse([jq_program UTF8String], data, data_length, flags, ^(const char* output, const NSUInteger length){
        if( !output ){
            return;
        }
        
        outputStr = [[NSString alloc] initWithUTF8String:output];
    });
    
    return outputStr;
}

- (NSString*)jq:(NSString*)jq_program {
    return [self jq:jq_program withOptions:0];
}

@end
