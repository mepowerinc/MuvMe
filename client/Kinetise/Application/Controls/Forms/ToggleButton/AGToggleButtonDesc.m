#import "AGToggleButtonDesc.h"
#import "AGActionManager.h"
#import "AGSynchronizer.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"

@implementation AGToggleButtonDesc

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    // synchronizer
    NSNumber *localValue = [AGSYNCHRONIZER getRequestValue:form.formId.value];
    if (localValue) {
        NSDate *feedTS = [NSDate distantPast];
        NSDate *localTS = [NSDate distantFuture];

        id<AGFeedClientProtocol> feedClient = [AGAPPLICATION getControlFeedParent:self];
        if (feedClient) {
            feedTS = feedClient.feed.dateTS;
        } else {
            AGFeed *context = AGAPPLICATION.currentContext;
            if ([context isKindOfClass:[AGFeed class]]) {
                feedTS = context.dateTS;
            }
        }

        localTS = [AGSYNCHRONIZER getRequestTimestamp:form.formId.value];

        if ([feedTS compare:localTS] == NSOrderedDescending) {
            [AGSYNCHRONIZER removeRequest:form.formId.value];
        } else {
            form.value = localValue;
        }
    }
}

@end
