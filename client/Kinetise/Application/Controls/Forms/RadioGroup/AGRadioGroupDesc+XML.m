#import "AGRadioGroupDesc+XML.h"
#import "AGContainerDesc+XML.h"
#import "AGForm+XML.h"

@implementation AGRadioGroupDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];

    return self;
}

@end
