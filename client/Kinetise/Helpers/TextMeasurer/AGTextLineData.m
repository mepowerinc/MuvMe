#import "AGTextLineData.h"

@implementation AGTextLineData

@synthesize startIndex;
@synthesize length;
@synthesize width;

#pragma mark - Equal

- (BOOL)isEqualToTextLineData:(AGTextLineData *)object {
    if (startIndex != object.startIndex) return NO;
    if (length != object.length) return NO;
    if (width != object.width) return NO;

    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToTextLineData:object];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGTextLineData *obj = [[[self class] allocWithZone:zone] init];

    obj.startIndex = startIndex;
    obj.length = length;
    obj.width = width;

    return obj;
}

@end
