#import "NSObject+Singleton.h"
#import <Reachability/Reachability.h>

@interface AGReachability : NSObject

SINGLETON_INTERFACE(AGReachability)

@property(nonatomic, readonly) Reachability *reachability;

@end
