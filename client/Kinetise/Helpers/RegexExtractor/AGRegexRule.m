#import "AGRegexRule.h"

@implementation AGRegexRule

@synthesize tag;
@synthesize returnMatch;
@synthesize replaceWith;

- (void)dealloc {
    self.tag = nil;
    self.replaceWith = nil;
    [super dealloc];
}

@end
