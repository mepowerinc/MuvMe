#import "GDataXMLNode+XPath.h"

@implementation GDataXMLNode (XPath)

- (NSArray *)nodesForXPath:(NSString *)path {
    NSArray *nodes = [self nodesForXPath:path error:nil];
    return nodes;
}

- (GDataXMLNode *)nodeForXPath:(NSString *)path {
    NSArray *nodes = [self nodesForXPath:path];
    if (nodes.count) return nodes[0];
    NSLog(@"GDataXMLNode (XPath): Exception - missing XPath:%@", path);
    return nil;
}

- (GDataXMLNode *)nodeForXPath:(NSString *)path namespaces:(NSDictionary *)namespaces {
    NSArray *nodes = [self nodesForXPath:path namespaces:namespaces error:nil];
    if (nodes.count) return nodes[0];
    NSLog(@"GDataXMLNode (XPath): Exception - missing XPath:%@", path);
    return nil;
}

- (BOOL)booleanValueForXPath:(NSString *)path {
    NSString *stringValue = [[[self nodeForXPath:path] stringValue] lowercaseString];
    if ([stringValue hasPrefix:@"y"] || [stringValue hasPrefix:@"t"]) {
        return YES;
    }
    return NO;
}

- (NSString *)stringValueForXPath:(NSString *)path {
    return [[self nodeForXPath:path] stringValue];
}

- (NSString *)stringValueForXPath:(NSString *)path namespaces:(NSDictionary *)namespaces {
    return [[self nodeForXPath:path namespaces:namespaces] stringValue];
}

- (NSInteger)integerValueForXPath:(NSString *)path {
    return [[[self nodeForXPath:path] stringValue] integerValue];
}

- (CGFloat)floatValueForXPath:(NSString *)path {
    return [[[self nodeForXPath:path] stringValue] floatValue];
}

- (double)doubleValueForXPath:(NSString *)path {
    return [[[self nodeForXPath:path] stringValue] doubleValue];
}

- (NSInteger)countNodesForXPath:(NSString *)path {
    return [self nodesForXPath:path].count;
}

- (BOOL)hasNodeForXPath:(NSString *)path {
    return [self nodesForXPath:path].count > 0;
}

@end
