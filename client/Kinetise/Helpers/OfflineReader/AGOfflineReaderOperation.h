#import <Foundation/Foundation.h>

@protocol AGOfflineReaderOperationDelegate;

@interface AGOfflineReaderOperation : NSOperation {
    NSURLRequest *urlRequest;
    NSDictionary *json;
    id<AGOfflineReaderOperationDelegate> delegate;
}

@property(nonatomic, assign) id<AGOfflineReaderOperationDelegate> delegate;

+ (instancetype)operationWithJSON:(NSDictionary *)json;
- (instancetype)initWithJSON:(NSDictionary *)json;
- (void)onSuccess:(NSArray *)operations;
- (void)onFail:(NSError *)error;

@end

@protocol AGOfflineReaderOperationDelegate<NSObject>
@optional
- (void)offlineReaderOperation:(AGOfflineReaderOperation *)operation didEndWithOperations:(NSArray *)operations andError:(NSError *)error;
@end