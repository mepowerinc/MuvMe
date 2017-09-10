#import "AGCustomButtonDesc+XML.h"
#import "AGControlDesc+XML.h"

@implementation AGCustomButtonDesc (XML)

#pragma mark - Initialization

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // Initialize based on XML representation
    self.text = [node stringValueForXPath:@"@text"];
    
    return self;
}

@end
