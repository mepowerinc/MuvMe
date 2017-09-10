#import "UIApplication+Launch.h"

@implementation UIApplication (Launch)

- (BOOL)isFirstLaunch {
    BOOL launchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"launched_before"];

    if (!launchedBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"launched_before"];
    }

    return !launchedBefore;
}

@end
