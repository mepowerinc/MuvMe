#import "AGDSDropDownItem.h"

@implementation AGDSDropDownItem

@synthesize title;
@synthesize value;

- (void)dealloc {
    self.title = nil;
    self.value = nil;
    [super dealloc];
}

@end
