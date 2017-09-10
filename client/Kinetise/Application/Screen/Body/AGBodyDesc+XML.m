#import "AGBodyDesc+XML.h"
#import "AGFeedClientProtocol.h"
#import "AGContainerDesc.h"
#import "AGDataFeedHorizontalDesc.h"
#import "AGDataFeedThumbnailsDesc.h"
#import "AGDataFeedVerticalDesc.h"
#import "AGSectionDesc+XML.h"

@implementation AGBodyDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    return self;
}

@end
