#import "AGSignatureDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGForm+XML.h"

@implementation AGSignatureDesc (XML)

#pragma mark - Initialization

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];

    // stroke width
    self.strokeWidth = AGSizeWithText([node stringValueForXPath:@"@strokewidth"]);

    // stroke color
    self.strokeColor = AGColorWithText([node stringValueForXPath:@"@strokecolor"]);

    // clear src
    self.clearSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@clearsrc"] ];

    // clear active src
    self.clearActiveSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@clearactivesrc"] ];

    // clear size
    self.clearSize = AGSizeWithText([node stringValueForXPath:@"@clearsize"]);

    return self;
}

@end
