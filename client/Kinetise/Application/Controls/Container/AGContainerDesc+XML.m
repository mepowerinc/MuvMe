#import "AGContainerDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGParser.h"

@implementation AGContainerDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // layout
    // set by container type

    // inner border
    self.innerBorder = AGSizeWithText([node stringValueForXPath:@"@innerborder"]);

    // vertical scroll
    self.hasVerticalScroll = [node booleanValueForXPath:@"@scrollvertical"];

    // horizontal scroll
    self.hasHorizontalScroll = [node booleanValueForXPath:@"@scrollhorizontal"];

    // inner align
    self.innerAlign = AGAlignWithText([node stringValueForXPath:@"@inneralign"]);

    // inner valign
    self.innerVAlign = AGValignWithText([node stringValueForXPath:@"@innervalign"]);

    // children
    NSArray *childrenNodes = node.children;
    for (GDataXMLNode *childNode in childrenNodes) {
        Class childClass = [AGParser classWithName:childNode.name];
        if (childClass) {
            AGControlDesc *childDesc = [[childClass alloc] initWithXML:childNode];
            [self addChild:childDesc];
            [childDesc release];
        }
    }

    // columns
    if (self.containerLayout == layoutGrid) {
        self.columns = [node integerValueForXPath:@"@columns"];
    }

    // invert children
    self.invertChildren = [node booleanValueForXPath:@"@invertchildren"];

    // children separator color
    self.childrenSeparatorColor = AGColorWithText([node stringValueForXPath:@"@childrenseparatorcolor"]);

    return self;
}

@end
