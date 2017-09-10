#import "AGChartDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGFeed+XML.h"

@implementation AGChartDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // feed
    AGFeed *feedDesc = [[AGFeed alloc] initWithXML:node];
    self.feed = feedDesc;
    [feedDesc release];

    // type
    self.type = AGChartTypeWithText([node stringValueForXPath:@"@type"]);

    // label
    self.label = [node stringValueForXPath:@"@label"];

    // colors
    NSData *jsonData = [[node stringValueForXPath:@"@colors"] dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        for (NSString *hexColor in jsonArray) {
            [self.colors addObject:hexColor ];
        }
    }

    // data sets
    jsonData = [[node stringValueForXPath:@"@dataset"] dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        for (NSDictionary *jsonDictionary in jsonArray) {
            [self.dataset addObject:jsonDictionary ];
        }
    }

    return self;
}

@end
