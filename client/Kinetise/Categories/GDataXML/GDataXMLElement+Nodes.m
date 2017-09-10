#import "GDataXMLElement+Nodes.h"

@implementation GDataXMLElement (Nodes)

- (GDataXMLElement *)elementForName:(NSString *)name {
    NSArray *elements = [self elementsForName:name];
    if (elements.count) return elements[0];
    return nil;
}

- (NSString *)stringValueForName:(NSString *)name {
    return [[self elementForName:name] stringValue];
}

- (NSInteger)integerValueForName:(NSString *)name {
    return [[[self elementForName:name] stringValue] integerValue];
}

- (CGFloat)floatValueForName:(NSString *)name {
    return [[[self elementForName:name] stringValue] floatValue];
}

- (NSInteger)countElementsForName:(NSString *)name {
    return [self elementsForName:name].count;
}

- (BOOL)hasElementForName:(NSString *)name {
    return [self elementsForName:name].count > 0;
}

@end
