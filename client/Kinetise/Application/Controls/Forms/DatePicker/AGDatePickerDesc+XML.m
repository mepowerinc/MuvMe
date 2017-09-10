#import "AGDatePickerDesc+XML.h"
#import "AGPickerDesc+XML.h"

@implementation AGDatePickerDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // mode
    self.mode = AGDatePickerModeWithText([node stringValueForXPath:@"@mode"]);

    // min date
    self.minDate = [AGVariable variableWithText:[node stringValueForXPath:@"@mindate"] ];

    // max date
    self.maxDate = [AGVariable variableWithText:[node stringValueForXPath:@"@maxdate"] ];

    // date format
    self.dateFormat = [node stringValueForXPath:@"@dateformat"];

    // watermark
    self.watermark = [AGVariable variableWithText:[node stringValueForXPath:@"@watermark"] ];

    return self;
}

@end
