#import <Foundation/Foundation.h>

@interface AGScriptParser : NSObject

- (id)initWithString:(NSString *)string;
- (id)parseUsingBlock:(id (^)(id target, NSString *method, NSArray *attributes))block;

@end