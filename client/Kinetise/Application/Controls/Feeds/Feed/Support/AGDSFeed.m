#import "AGDSFeed.h"

@implementation AGDSFeed

@synthesize items;
@synthesize itemIndex;
@synthesize pagination;

- (void)dealloc {
    self.items = nil;
    self.pagination = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.items = [NSMutableArray array];
    itemIndex = NSNotFound;

    return self;
}

#pragma mark - Serialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    items = [[decoder decodeObjectForKey:@"items"] retain];
    itemIndex = [decoder decodeIntegerForKey:@"itemIndex"];
    self.pagination = [decoder decodeObjectForKey:@"pagination"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:items forKey:@"items"];
    [encoder encodeInteger:itemIndex forKey:@"itemIndex"];
    [encoder encodeObject:pagination forKey:@"pagination"];
}

@end
