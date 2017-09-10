#import "AGRadioButtonDesc+XML.h"
#import "AGCompoundButtonDesc+XML.h"

@implementation AGRadioButtonDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // value
    self.value = [node stringValueForXPath:@"@value"];

    return self;
}

@end
