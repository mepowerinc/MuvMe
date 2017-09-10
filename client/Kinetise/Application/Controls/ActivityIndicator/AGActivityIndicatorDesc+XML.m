#import "AGActivityIndicatorDesc+XML.h"
#import "AGControlDesc+XML.h"

@implementation AGActivityIndicatorDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // src
    self.src = [AGVariable variableWithText:[node stringValueForXPath:@"@src"] ];

    return self;
}

@end
