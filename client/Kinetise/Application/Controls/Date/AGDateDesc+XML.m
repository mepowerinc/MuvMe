#import "AGDateDesc+XML.h"
#import "AGTextDesc+XML.h"

@implementation AGDateDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // date format
    self.dateFormat = [node stringValueForXPath:@"@dateformat"];

    // ticking
    self.ticking = [node booleanValueForXPath:@"@ticking"];

    // date src
    self.dateSrc = AGDateSourceWithText([node stringValueForXPath:@"@datesrc"]);

    // timezone
    self.timezone = AGDateTimezoneWithText([node stringValueForXPath:@"@timezone"]);

    return self;
}

@end
