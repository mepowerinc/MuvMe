#import "AGActivityIndicatorDesc.h"
#import "AGActionManager.h"

@implementation AGActivityIndicatorDesc

@synthesize src;

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
    AGActivityIndicatorDesc *obj = [super copyWithZone:zone];

    obj.src = [[src copy] autorelease];

    return obj;
}

@end
