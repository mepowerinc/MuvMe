#import "AGToastItem.h"

@implementation AGToastItem

@synthesize message;
@synthesize duration;
@synthesize priority;
@synthesize color;

- (void)dealloc {
    self.message = nil;
    self.color = nil;
    [super dealloc];
}

#pragma mark - NSCompare

- (BOOL)isEqualToItem:(AGToastItem *)object {
    return [object.message isEqualToString:self.message];
}

- (BOOL)isEqual:(AGToastItem *)object {
    if (self == object) return YES;

    if (![object isKindOfClass:[AGToastItem class]]) {
        return NO;
    }

    return [self isEqualToItem:object];
}

- (NSUInteger)hash {
    return [message hash];
}

@end
