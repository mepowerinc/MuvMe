#import "NSArray+JSONPath.h"
#import "JSONPathParser.h"

@implementation NSArray (JSONPath)

-(NSArray*) nodesForJSONPath:(NSString*)path{
    JSONPathParser* parser = [[JSONPathParser alloc] initWithJSON:self andPath:path];
    NSArray* result = [parser parse];
    [parser release];
    
    return result;
}

@end
