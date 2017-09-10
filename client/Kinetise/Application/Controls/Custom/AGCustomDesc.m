#import "AGCustomDesc.h"

@implementation AGCustomDesc

#pragma mark - Initialization

- (void)dealloc {
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGCustomDesc *obj = [super copyWithZone:zone];
    
    return obj;
}

@end
