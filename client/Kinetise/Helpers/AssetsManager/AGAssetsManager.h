#import "NSObject+Singleton.h"
#import "AGUnits.h"

@interface AGAssetsManager : NSObject

    SINGLETON_INTERFACE(AGAssetsManager)

@property(nonatomic, readonly) NSOperationQueue *feedProcessingQueue;
@property(nonatomic, readonly) NSOperationQueue *imageProcessingQueue;

- (NSURLSessionDataTask *)dataTask:(AGAssetDataType)type silent:(BOOL)silent request:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionBlock;

@end
