#import "AGPopupDesc.h"

@implementation AGPopupDesc

@synthesize controlDesc;

#pragma mark - Initialization

- (void)dealloc {
    self.controlDesc = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [controlDesc executeVariables];
}

#pragma mark - Update

- (void)update {
    [super update];
    
    [controlDesc update];
}

#pragma mark - State

- (void)resetState {
    [controlDesc resetState];
}

@end
