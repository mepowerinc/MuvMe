#import "AGAlertWindow.h"
#import "AGAlertViewController.h"

@implementation AGAlertWindow

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.rootViewController = [[[AGAlertViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    self.windowLevel = UIWindowLevelAlert + 1;

    return self;
}

@end
