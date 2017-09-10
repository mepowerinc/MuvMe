#import "AGFeedRequiredField+JSON.h"
#import "NSObject+Nil.h"

@implementation AGFeedRequiredField (JSON)

- (id)initWithJSON:(NSDictionary *)json {
    self = [self init];

    // field
    self.field = json[@"field"];

    // match
    self.match = json[@"match"];

    // regex name
    self.regexName = json[@"regexname"];

    // allow empty
    self.allowEmpty = [json[@"allowempty"] boolValue];

    return self;
}

@end
