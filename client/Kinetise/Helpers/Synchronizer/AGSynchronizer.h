#import "NSObject+Singleton.h"
#import "AGSynchronizerRequest.h"

#define AGSYNCHRONIZER [AGSynchronizer sharedInstance]

@interface AGSynchronizer : NSObject

    SINGLETON_INTERFACE(AGSynchronizer)

- (void)addRequest:(AGSynchronizerRequest *)request;
- (id)getRequestValue:(NSString *)key;
- (NSDate *)getRequestTimestamp:(NSString *)key;
- (void)removeRequest:(NSString *)key;

@end
