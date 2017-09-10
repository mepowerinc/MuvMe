#import "AGChartDataSet.h"

@implementation AGChartDataSet

@synthesize name;
@synthesize values;
@synthesize color;

- (void)dealloc {
    self.name = nil;
    self.values = nil;
    self.color = nil;
    [super dealloc];
}

@end
