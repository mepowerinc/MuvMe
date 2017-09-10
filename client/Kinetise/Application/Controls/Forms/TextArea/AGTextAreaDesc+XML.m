#import "AGTextAreaDesc+XML.h"
#import "AGEditableTextDesc+XML.h"

@implementation AGTextAreaDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // rows
    self.rows = [node integerValueForXPath:@"@rows"];

    return self;
}

@end
