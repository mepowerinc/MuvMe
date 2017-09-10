#import <Foundation/Foundation.h>

@interface NSDictionary (JSONPath)

-(NSArray*) nodesForJSONPath:(NSString*)path;

@end
