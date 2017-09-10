#import <GDataXMLParser/GDataXMLNode.h>

@interface GDataXMLNode (XPath)

- (NSArray *)nodesForXPath:(NSString *)path;
- (GDataXMLNode *)nodeForXPath:(NSString *)path;
- (BOOL)booleanValueForXPath:(NSString *)path;
- (NSString *)stringValueForXPath:(NSString *)path;
- (NSString *)stringValueForXPath:(NSString *)path namespaces:(NSDictionary *)namespaces;
- (NSInteger)integerValueForXPath:(NSString *)path;
- (CGFloat)floatValueForXPath:(NSString *)path;
- (double)doubleValueForXPath:(NSString *)path;
- (NSInteger)countNodesForXPath:(NSString *)path;
- (BOOL)hasNodeForXPath:(NSString *)path;

@end
