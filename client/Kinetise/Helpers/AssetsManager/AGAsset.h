#import "AGUnits.h"

typedef NS_OPTIONS (NSInteger, AGAssetResponseOption){
    AGAssetResponseNone = 0,
    AGAssetResponseCacheData = 1 << 1,
    AGAssetResponseSilentRequest = 1 << 2,
};

@protocol AGAssetDelegate;

@interface AGAsset : NSObject {
    NSString *uri;
    NSString *httpMethod;
    NSDictionary *httpQueryParams;
    NSDictionary *httpHeaderParams;
    NSData *httpBody;
    AGCachePolicy cachePolicy;
    CGFloat cacheInterval;
    id<AGAssetDelegate> delegate;
    AGAssetType assetType;
    AGAssetDataType assetDataType;
    BOOL isCachedData;
    BOOL isSilentRequest;
    NSURLRequest *originalRequest;
    NSURLSessionDataTask *sessionDataTask;
}

@property(nonatomic, copy) NSString *uri;
@property(nonatomic, copy) NSString *httpMethod;
@property(nonatomic, retain) NSDictionary *httpQueryParams;
@property(nonatomic, retain) NSDictionary *httpHeaderParams;
@property(nonatomic, retain) NSData *httpBody;
@property(nonatomic, assign) AGCachePolicy cachePolicy;
@property(nonatomic, assign) CGFloat cacheInterval;
@property(nonatomic, assign) id<AGAssetDelegate> delegate;

@property(nonatomic, readonly) AGAssetType assetType;
@property(nonatomic, readonly) BOOL isCachedData;
@property(nonatomic, readonly) BOOL isSilentRequest;

- (id)initWithUri:(NSString *)uri;
- (void)execute;
- (void)clearDelegatesAndCancel;
- (void)cancel;
- (void)processCachedResponse:(NSCachedURLResponse *)cachedResponse;
- (void)processHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data andError:(NSError *)error;
- (void)processData:(NSData *)data asynchronous:(BOOL)async;
- (void)finishProcessingData;

@end

@protocol AGAssetDelegate<NSObject>
- (void)assetWillLoad:(AGAsset *)asset;
- (void)asset:(AGAsset *)asset didLoad:(id)object;
- (void)asset:(AGAsset *)asset didFail:(NSError *)error;
@optional
- (void)assetWillLoadSilent:(AGAsset *)asset;
@end
