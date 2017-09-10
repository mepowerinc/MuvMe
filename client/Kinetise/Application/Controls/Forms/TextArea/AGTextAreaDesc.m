#import "AGTextAreaDesc.h"

@implementation AGTextAreaDesc

@synthesize rows;

- (id)init {
    self = [super init];

    // defaults
    rows = 1;

    return self;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGTextAreaDesc *obj = [super copyWithZone:zone];

    obj.rows = rows;

    return obj;
}

@end
