#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "NSObject+Singleton.h"

@interface AGAnalytics : NSObject {
    id<GAITracker> appTracker;
}

SINGLETON_INTERFACE(AGAnalytics)

- (void)trackApplicationStart:(NSString *)applicationName;
- (void)trackGoToScreen:(NSString *)screenName;

@end
