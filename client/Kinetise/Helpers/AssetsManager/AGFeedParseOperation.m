#import "AGFeedParseOperation.h"
#import "AGFeedXMLParser.h"
#import "AGFeedJSONParser.h"
#import "AGFeedDBParser.h"

@interface AGFeedParseOperation (){
    AGFeed *feed;
    NSData *data;
}
@property(nonatomic, retain) AGFeed *feed;
@property(nonatomic, retain) NSData *data;
@end

@implementation AGFeedParseOperation

@synthesize feed;
@synthesize data;
@synthesize delegate;

- (void)dealloc {
    self.feed = nil;
    self.data = nil;
    self.delegate = nil;
    [super dealloc];
}

- (id)initWithFeed:(AGFeed *)feed_ andData:(NSData *)data_ {
    self = [super init];

    self.feed = feed_;
    self.data = data_;

    return self;
}

- (void)cancel {
    delegate = nil;
    [super cancel];
}

- (void)startSynchronous {
    [self main];
}

- (void)clearDelegatesAndCancel {
    self.delegate = nil;
    [self cancel];
}

#pragma mark - Main

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) return;

        // parse
        AGFeedParser *parser = nil;
        if (feed.format == feedFormatXML) {
            parser = [[AGFeedXMLParser alloc] init];
        } else if (feed.format == feedFormatJSON) {
            parser = [[AGFeedJSONParser alloc] init];
        } else if (feed.format == feedFormatDB) {
            parser = [[AGFeedDBParser alloc] init];
        }

        // data source
        NSError *error = nil;
        AGDSFeed *feedDataSource = [parser parseFeed:feed withData:data error:&error];
        [parser release];

        if (self.isCancelled) return;

        // delegate
        if (![NSThread isMainThread]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!error) {
                    [delegate feed:self didLoad:feedDataSource];
                } else {
                    [delegate feed:self didFail:error];
                }
            }];
        } else {
            if (!error) {
                [delegate feed:self didLoad:feedDataSource];
            } else {
                [delegate feed:self didFail:error];
            }
        }
    }
}

@end
