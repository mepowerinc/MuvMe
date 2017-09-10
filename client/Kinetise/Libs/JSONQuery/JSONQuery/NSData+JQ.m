#import "NSData+JQ.h"
#import "JQParse.h"

@implementation NSData (JQ)

- (NSData *)jq:(NSString*)jq_program withOptions:(JV_OPTIONS)flags {
    __block NSData* outputData = nil;
    
    JQParse([jq_program UTF8String], [self bytes], [self length], flags, ^(const char* output, const NSUInteger length){
        if( !output ){
            return;
        }
        outputData = [NSData dataWithBytes:output length:length];
    });
    
    return outputData;
}

- (NSData *)jq:(NSString*)jq_program {
    return [self jq:jq_program withOptions:0];
}

@end
