#import "AGWebBrowserDesc+XML.h"
#import "AGControlDesc+XML.h"

@implementation AGWebBrowserDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // src
    self.src = [AGVariable variableWithText:[node stringValueForXPath:@"@source"] ];

    // use external browser
    self.useExternalBrowser = [node booleanValueForXPath:@"@gotoexternalbrowser"];

    return self;
}

@end
