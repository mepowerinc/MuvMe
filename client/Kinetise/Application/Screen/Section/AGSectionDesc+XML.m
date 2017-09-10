#import "AGSectionDesc+XML.h"
#import "AGDesc+XML.h"
#import "AGControlDesc.h"
#import "AGParser.h"

@implementation AGSectionDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // children
    NSArray *childrenNodes = node.children;
    for (GDataXMLNode *childNode in childrenNodes) {
        Class childClass = [AGParser classWithName:childNode.name];
        if (childClass) {
            AGControlDesc *childDesc = [[childClass alloc] initWithXML:childNode];
            childDesc.section = self;
            [children addObject:childDesc];
            [childDesc release];
        } else {
            NSLog(@"Unrecognized control in xml");
        }
    }

    return self;
}

@end
