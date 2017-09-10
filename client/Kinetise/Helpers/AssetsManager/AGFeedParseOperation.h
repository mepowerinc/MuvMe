#import <Foundation/Foundation.h>
#import "AGFeed.h"
#import "AGDSFeed.h"

@protocol AGFeedParseOperationDelegate;

@interface AGFeedParseOperation : NSOperation {
    id<AGFeedParseOperationDelegate> delegate;
}

@property(nonatomic, assign) id<AGFeedParseOperationDelegate> delegate;

- (id)initWithFeed:(AGFeed *)feed andData:(NSData *)data;
- (void)startSynchronous;
- (void)clearDelegatesAndCancel;

@end

@protocol AGFeedParseOperationDelegate<NSObject>
- (void)feed:(AGFeedParseOperation *)operation didLoad:(AGDSFeed *)feedDataSource;
- (void)feed:(AGFeedParseOperation *)operation didFail:(NSError *)error;
@end