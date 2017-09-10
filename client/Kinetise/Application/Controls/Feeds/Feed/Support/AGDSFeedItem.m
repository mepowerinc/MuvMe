#import "AGDSFeedItem.h"

@implementation AGDSFeedItem

@synthesize values;
@synthesize alterApiContext;
@synthesize guid;
@synthesize itemTemplateIndex;

- (void)dealloc {
    self.alterApiContext = nil;
    self.guid = nil;
    [values release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    values = [[NSMutableDictionary alloc] init];

    return self;
}

#pragma mark - Serialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    values = [[decoder decodeObjectForKey:@"values"] retain];
    self.alterApiContext = [decoder decodeObjectForKey:@"alterApiContext"];
    self.guid = [decoder decodeObjectForKey:@"guid"];
    itemTemplateIndex = [[decoder decodeObjectForKey:@"itemTemplateIndex"] integerValue];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:values forKey:@"values"];
    [encoder encodeObject:alterApiContext forKey:@"alterApiContext"];
    [encoder encodeObject:guid forKey:@"guid"];
    [encoder encodeObject:@(itemTemplateIndex) forKey:@"itemTemplateIndex"];
}

@end
