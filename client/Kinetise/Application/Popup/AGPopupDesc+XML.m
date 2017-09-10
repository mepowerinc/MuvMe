#import "AGPopupDesc+XML.h"
#import "AGDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGParser.h"

@implementation AGPopupDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // control
    GDataXMLNode *childNode = node.children[0];
    Class childClass = [AGParser classWithName:childNode.name];
    if (childClass) {
        AGControlDesc *childDesc = [[childClass alloc] initWithXML:childNode];
        self.controlDesc = childDesc;
        [childDesc release];
    }

    return self;
}

@end
