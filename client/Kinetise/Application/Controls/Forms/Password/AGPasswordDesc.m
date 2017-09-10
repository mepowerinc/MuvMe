#import "AGPasswordDesc.h"

@implementation AGPasswordDesc

@synthesize encryptionType;

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGPasswordDesc *obj = [super copyWithZone:zone];

    obj.encryptionType = encryptionType;

    return obj;
}

@end
