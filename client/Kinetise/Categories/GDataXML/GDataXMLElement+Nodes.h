#import <GDataXMLParser/GDataXMLNode.h>

@interface GDataXMLElement (Nodes)
- (GDataXMLElement *)elementForName:(NSString *)name;
- (NSString *)stringValueForName:(NSString *)name;
- (NSInteger)integerValueForName:(NSString *)name;
- (CGFloat)floatValueForName:(NSString *)name;
- (NSInteger)countElementsForName:(NSString *)name;
- (BOOL)hasElementForName:(NSString *)name;
@end
