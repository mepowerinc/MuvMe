#import "AGPhotoDesc+XML.h"
#import "AGButtonDesc+XML.h"
#import "AGForm+XML.h"

@implementation AGPhotoDesc (XML)

#pragma mark - Initialization

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];

    return self;
}

@end
