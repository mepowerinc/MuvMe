#import "AGChartView.h"

@implementation AGChartView

@synthesize dataSource;

#pragma mark - Initialization

- (void)dealloc {
    self.dataSource = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // host view
    self.allowPinchScaling = YES;

    // graph view
    graphView = [[CPTXYGraph alloc] initWithFrame:frame];
    self.hostedGraph = graphView;
    [graphView release];

    // graph padding
    graphView.paddingTop = 0;
    graphView.paddingBottom = 0;
    graphView.paddingLeft = 0;
    graphView.paddingRight = 0;

    return self;
}

#pragma mark - Lifecycle

- (void)setDataSource:(AGChartData *)dataSource_ {
    if (dataSource == dataSource_) return;

    [dataSource release];
    dataSource = [dataSource_ retain];
}

@end
