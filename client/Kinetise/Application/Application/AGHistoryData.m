#import "AGHistoryData.h"

@implementation AGHistoryData

@synthesize screenId;
@synthesize alterApiContext;
@synthesize guidContext;
@synthesize context;

- (void)dealloc {
    self.screenId = nil;
    self.alterApiContext = nil;
    self.guidContext = nil;
    self.context = nil;
    [super dealloc];
}

@end
