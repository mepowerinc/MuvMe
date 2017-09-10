#import "AGJSDevice.h"
#import "AGActionManager+Actions.h"

@implementation AGJSDevice

- (NSString *)uuid {
    return [AGACTIONMANAGER getDeviceToken:nil :nil];
}

@end
