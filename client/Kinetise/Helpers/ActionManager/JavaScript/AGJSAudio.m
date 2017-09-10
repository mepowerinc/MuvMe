#import "AGJSAudio.h"
#import "AGActionManager+External.h"

@implementation AGJSAudio

- (void)play:(NSDictionary *)request :(NSNumber *)volume :(NSNumber *)loop {
    [AGACTIONMANAGER playSound:nil :nil :request[@"url"] :[volume stringValue] :[loop stringValue]];
}

- (void)stop {
    [AGACTIONMANAGER stopAllSounds:nil :nil];
}

@end
