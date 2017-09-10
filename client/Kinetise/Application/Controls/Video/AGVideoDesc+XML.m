#import "AGVideoDesc+XML.h"
#import "AGControlDesc+XML.h"

@implementation AGVideoDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // src
    self.src = [AGVariable variableWithText:[node stringValueForXPath:@"@src"] ];

    // autoplay
    autoplay = [node booleanValueForXPath:@"@autoplay"];

    return self;
}

@end
