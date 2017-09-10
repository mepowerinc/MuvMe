#import "AGPieChartView.h"

@implementation AGPieChartView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // host view
    self.allowPinchScaling = NO;

    // graph view
    graphView.axisSet = nil;

    // graph plot padding
    graphView.plotAreaFrame.paddingTop = 0;
    graphView.plotAreaFrame.paddingRight = 0;
    graphView.plotAreaFrame.paddingBottom = 0;
    graphView.plotAreaFrame.paddingLeft = 0;

    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CPTPieChart *pieChart = [graphView.allPlots firstObject];
    pieChart.pieRadius = (MIN(self.bounds.size.width, self.bounds.size.height) * 0.9f) * 0.5f;
    pieChart.labelOffset = -0.5f * pieChart.pieRadius;
}

#pragma mark - Lifecycle

- (void)setDataSource:(AGChartData *)dataSource_ {
    [super setDataSource:dataSource_];

    if (!dataSource_) return;

    // remove all plots
    NSArray *plots = graphView.allPlots;
    for (CPTPlot *plot in plots) {
        [graphView removePlot:plot];
    }

    // plots
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.delegate = self;
    pieChart.dataSource = self;
    pieChart.startAngle = 0;
    pieChart.sliceDirection = CPTPieDirectionClockwise;

    // pie chart border
    CPTMutableLineStyle *borderStyle = [CPTMutableLineStyle lineStyle];
    borderStyle.lineColor = [CPTColor whiteColor];
    borderStyle.lineWidth = 1;
    pieChart.borderLineStyle = borderStyle;

    // pie chart text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 10;
    textStyle.color = [CPTColor whiteColor];
    textStyle.textAlignment = CPTTextAlignmentCenter;
    pieChart.labelTextStyle = textStyle;

    // animation
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];
    [CPTAnimation animate:pieChart
                 property:@"endAngle"
                     from:2*M_PI
                       to:0
                 duration:1.0f
           animationCurve:CPTAnimationCurveBounceOut
                 delegate:nil];

    // add chart
    [graphView addPlot:pieChart];
    [pieChart release];

    // legend text style
    CPTMutableTextStyle *legendTextStyle = [CPTMutableTextStyle textStyle];
    legendTextStyle.fontName = @"Helvetica";
    legendTextStyle.fontSize = 10;
    legendTextStyle.color = [CPTColor blackColor];

    // legend
    CPTLegend *legend = [CPTLegend legendWithGraph:graphView];
    graphView.legend = legend;
    legend.swatchSize = CGSizeMake(10, 10);
    legend.textStyle = legendTextStyle;
    graphView.legendAnchor = CPTRectAnchorBottom;
    graphView.legendDisplacement = CGPointMake(0, 20);
}

#pragma mark - CPTPieChartDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return dataSource.dataSets.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    AGChartDataSet *dataSet = dataSource.dataSets[idx];

    return [dataSet.values firstObject];
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx {
    //AGChartDataSet* dataSet = dataSource.dataSets[idx];
    //NSNumber* value = [dataSet.values firstObject];

    //CPTTextLayer* text = [[[CPTTextLayer alloc] initWithText: [NSString stringWithFormat:@"%@", value] ] autorelease];
    //text.textStyle = plot.labelTextStyle;

    CPTTextLayer *text = [[[CPTTextLayer alloc] initWithText:@""] autorelease];

    return text;
}

- (CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
    AGChartDataSet *dataSet = dataSource.dataSets[idx];

    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:dataSet.color.CGColor] ];
}

- (NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
    AGChartDataSet *dataSet = dataSource.dataSets[idx];

    return dataSet.name;
}

@end
