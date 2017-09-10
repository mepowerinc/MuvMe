#import "AGFeedRequiredField.h"

@implementation AGFeedRequiredField

@synthesize field;
@synthesize match;
@synthesize regexName;
@synthesize allowEmpty;

- (void)dealloc {
    self.field = nil;
    self.match = nil;
    self.regexName = nil;
    [super dealloc];
}

@end
