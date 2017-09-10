#import "AGDataFeedDesc+XML.h"
#import "AGContainerDesc+XML.h"
#import "AGFeed+XML.h"

@implementation AGDataFeedDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // feed
    AGFeed *feedDesc = [[AGFeed alloc] initWithXML:node];
    self.feed = feedDesc;
    [feedDesc release];

    return self;
}

@end
