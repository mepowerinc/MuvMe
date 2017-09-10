#import "UIDevice+Jailbroken.h"

@implementation UIDevice (Jailbroken)

- (BOOL)isJailbroken {
#if !TARGET_IPHONE_SIMULATOR
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]) {
        return YES;
    }

    NSError *error;
    [@"test" writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];

    if (error == nil) {
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]) {
        return YES;
    }
#endif
    return NO;
}

@end
