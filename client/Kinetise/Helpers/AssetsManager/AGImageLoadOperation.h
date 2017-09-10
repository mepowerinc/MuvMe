#import <Foundation/Foundation.h>

@protocol AGImageLoadOperationDelegate;

@interface AGImageLoadOperation : NSOperation {
    id<AGImageLoadOperationDelegate> delegate;
}

@property(nonatomic, assign) id<AGImageLoadOperationDelegate> delegate;

- (id)initWithData:(NSData *)data andPrefferedSize:(NSInteger)prefferedImageSize;
- (void)startSynchronous;
- (void)clearDelegatesAndCancel;

@end

@protocol AGImageLoadOperationDelegate<NSObject>
- (void)loadImage:(AGImageLoadOperation *)operation didLoad:(UIImage *)image;
- (void)loadImage:(AGImageLoadOperation *)operation didFail:(NSError *)error;
@end