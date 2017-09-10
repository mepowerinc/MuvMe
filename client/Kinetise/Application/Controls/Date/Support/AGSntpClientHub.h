#import <Foundation/Foundation.h>
#import "NSObject+Singleton.h"

@interface AGSntpClientHub : NSObject

    SINGLETON_INTERFACE(AGSntpClientHub)

@property(nonatomic, readonly) NSDate *lastSynchronization;
@property(nonatomic, assign) NSTimeInterval synchronizationInterval;
@property(nonatomic, readonly) NSTimeInterval clockOffset;

- (void)setSynchronizedClockOffset:(NSTimeInterval)clockOffset;
- (BOOL)shouldSynchronize;
- (BOOL)synchronized;

@end
