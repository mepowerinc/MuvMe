#import "AGCompoundButtonDesc+XML.h"
#import "AGButtonDesc+XML.h"
#import "AGTextStyle+XML.h"
#import "AGForm+XML.h"

@implementation AGCompoundButtonDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];
    
    // check width
    self.checkWidth = AGSizeWithText([node stringValueForXPath:@"@checkwidth"]);
    
    // check height
    self.checkHeight = AGSizeWithText([node stringValueForXPath:@"@checkheight"]);
    
    // inner space
    self.innerSpace = AGSizeWithText([node stringValueForXPath:@"@innerspace"]);
    
    // check valign
    self.checkValign = AGValignWithText([node stringValueForXPath:@"@checkvalign"]);
    
    // check src
    self.activeSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@checksrc"] ];
    
    return self;
}

@end
