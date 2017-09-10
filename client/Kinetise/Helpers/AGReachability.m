#import "AGReachability.h"

@interface AGReachability (){
    Reachability *reachability;
}
@end

@implementation AGReachability

SINGLETON_IMPLEMENTATION(AGReachability)

@synthesize reachability;

#pragma mark - Initialization

- (void)dealloc {
    [reachability release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // reachability
    reachability = [[Reachability reachabilityForInternetConnection] retain];
    [reachability startNotifier];

    return self;
}

@end
