#import "AGGalleryDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGFeed+XML.h"

@implementation AGGalleryDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // feed
    AGFeed *feedDesc = [[AGFeed alloc] initWithXML:node];
    self.feed = feedDesc;
    [feedDesc release];

    return self;
}

@end
