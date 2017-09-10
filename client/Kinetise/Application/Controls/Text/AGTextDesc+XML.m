#import "AGTextDesc+XML.h"
#import "AGTextStyle+XML.h"
#import "AGControlDesc+XML.h"

@implementation AGTextDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    NSString *xmlValue;
    
    // text style
    self.textStyle = [[[AGTextStyle alloc] initWithXML:node] autorelease];
    
    // max characters
    xmlValue = [node stringValueForXPath:@"@maxcharacters"];
    if (![xmlValue isEqualToString:AG_NONE]) {
        self.maxCharacters = [xmlValue integerValue];
    } else {
        self.maxCharacters = 0;
    }
    
    // max lines
    xmlValue = [node stringValueForXPath:@"@maxlines"];
    if (![xmlValue isEqualToString:AG_NONE]) {
        self.maxLines = [xmlValue integerValue];
    } else {
        self.maxLines = 0;
    }
    
    // text
    if ([node hasNodeForXPath:@"@text"]) {
        self.text = [AGVariable variableWithText:[node stringValueForXPath:@"@text"] ];
    } else {
        self.text = [AGVariable variableWithText:[node stringValue] ];
    }
    
    return self;
}

@end
