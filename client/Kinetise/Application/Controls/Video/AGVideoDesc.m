#import "AGVideoDesc.h"
#import "AGActionManager.h"

@implementation AGVideoDesc

@synthesize src;
@synthesize autoplay;

- (void)dealloc {
    self.src = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
    [AGACTIONMANAGER executeVariable:src withSender:self];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGVideoDesc *obj = [super copyWithZone:zone];

    obj.src = [[src copy] autorelease];
    obj.autoplay = autoplay;

    return obj;
}

@end
