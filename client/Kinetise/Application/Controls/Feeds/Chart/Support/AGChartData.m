#import "AGChartData.h"

@implementation AGChartData

@synthesize dataSets;
@synthesize xValues;

- (void)dealloc {
    self.dataSets = nil;
    self.xValues = nil;
    [super dealloc];
}

@end
