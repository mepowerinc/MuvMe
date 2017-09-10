#import "AGAnalytics.h"
#import "AGReachability.h"
#import "AGApplication.h"
#import "NSString+Base64.h"

#define KEY_ANALYTICS_DISABALE @"analitics_disabled"

@implementation AGAnalytics

SINGLETON_IMPLEMENTATION(AGAnalytics)

#pragma mark - Initialization

- (id)init {
    self = [super init];

    // GA
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 30;

    // app tracker
    appTracker = [[GAI sharedInstance] trackerWithTrackingId:ANALYTICS_APP_TRACKING_ID];

    return self;
}

#pragma mark - Tracking

- (void)trackApplicationStart:(NSString *)applicationName {
    [appTracker set:kGAIAppName value:applicationName];
    [appTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackGoToScreen:(NSString *)screenName {
    AGApplicationDesc *appDesc = AGAPPLICATION.descriptor;
    screenName = [NSString stringWithFormat:@"%@/%@", appDesc.name, screenName];
    
    [appTracker set:kGAIScreenName value:screenName];
    [appTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end
