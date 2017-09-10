#import "AGPasswordDesc+XML.h"
#import "AGEditableTextDesc+XML.h"

@implementation AGPasswordDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // encryption type
    self.encryptionType = AGEncryptionTypeWithText([node stringValueForXPath:@"@encryptiontype"]);

    return self;
}

@end
