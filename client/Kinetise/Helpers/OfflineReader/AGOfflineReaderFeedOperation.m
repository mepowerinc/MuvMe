#import "AGOfflineReaderFeedOperation.h"
#import "GDataXMLNode+XPath.h"
#import "NSString+HTML.h"

@implementation AGOfflineReaderFeedOperation

#pragma mark - Initialization

- (id)initWithJSON:(NSDictionary *)json_ {
    self = [super initWithJSON:json_];

    // priority
    self.queuePriority = NSOperationQueuePriorityHigh;

    return self;
}

#pragma mark - Lifecycle

- (void)processRequest:(NSURLRequest *)request withResponse:(NSHTTPURLResponse *)response data:(NSData *)data andError:(NSError *)error {
    if (response.statusCode >= 200 && response.statusCode < 400) {
        [self parseFeed:data];
    } else {
        [self onFail:error];
    }
}

- (void)parseFeed:(NSData *)data {

}

@end
