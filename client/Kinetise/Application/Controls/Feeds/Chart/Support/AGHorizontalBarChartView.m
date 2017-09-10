#import "AGHorizontalBarChartView.h"

@implementation AGHorizontalBarChartView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // graph plot padding
    graphView.plotAreaFrame.paddingTop = 10;
    graphView.plotAreaFrame.paddingBottom = 50;
    graphView.plotAreaFrame.paddingLeft = 40;
    graphView.plotAreaFrame.paddingRight = 10;

    // graph space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graphView.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;

    // axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graphView.axisSet;

    // axis text style
    CPTMutableTextStyle *axisTextStyle = [CPTMutableTextStyle textStyle];
    axisTextStyle.fontName = @"Helvetica";
    axisTextStyle.fontSize = 10;
    axisTextStyle.color = [CPTColor blackColor];

    // axis line style
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineCap = kCGLineCapSquare;
    axisLineStyle.lineColor = [CPTColor lightGrayColor];
    axisLineStyle.miterLimit = 1;
    axisLineStyle.lineWidth = 1;

    // axis grid style
    CPTMutableLineStyle *axisGridLineStyle = [CPTMutableLineStyle lineStyle];
    axisGridLineStyle.lineCap = kCGLineCapSquare;
    axisGridLineStyle.lineColor = [CPTColor colorWithGenericGray:0.9f];
    axisGridLineStyle.miterLimit = 1;
    axisGridLineStyle.lineWidth = 1;

    // axis formater
    NSNumberFormatter *axisFormatter = [[NSNumberFormatter alloc] init];
    [axisFormatter setMinimumIntegerDigits:1];
    [axisFormatter setMaximumFractionDigits:0];

    // x axis
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    axisSet.xAxis.majorTickLineStyle = axisLineStyle;
    axisSet.xAxis.labelTextStyle = axisTextStyle;
    axisSet.xAxis.labelOffset = 3;
    axisSet.xAxis.majorIntervalLength = @(1);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.majorTickLength = 0;
    axisSet.xAxis.majorGridLineStyle = axisGridLineStyle;
    axisSet.xAxis.labelFormatter = axisFormatter;
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];

    // y axis
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    axisSet.yAxis.majorTickLineStyle = axisLineStyle;
    axisSet.yAxis.labelTextStyle = axisTextStyle;
    axisSet.yAxis.labelOffset = 3;
    axisSet.yAxis.majorIntervalLength = @(1);
    axisSet.yAxis.minorTicksPerInterval = 0;
    axisSet.yAxis.majorTickLength = 0;
    axisSet.yAxis.labelFormatter = axisFormatter;
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];

    [axisFormatter release];

    return self;
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
    CGFloat barWidth = 0.7f/dataSource.dataSets.count;
    CGFloat barWidthBordered = barWidth;

    for (AGChartDataSet *dataSet in dataSource.dataSets) {
        // plot
        NSInteger idx = [dataSource.dataSets indexOfObject:dataSet];
        CPTBarPlot *plot = [[CPTBarPlot alloc] init];
        plot.identifier = @([dataSource.dataSets indexOfObject:dataSet]);
        plot.title = dataSet.name;
        plot.dataSource = self;
        plot.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:dataSet.color.CGColor ] ];
        plot.barOffset = @(idx*barWidthBordered - dataSource.dataSets.count*barWidthBordered*0.5f + 0.5*barWidthBordered);
        plot.barWidth = @(barWidth);
        plot.barsAreHorizontal = YES;

        // plot line style
        CPTMutableLineStyle *plotLineStyle = [CPTMutableLineStyle lineStyle];
        plotLineStyle.lineCap = kCGLineCapSquare;
        plotLineStyle.lineWidth = 1;
        plotLineStyle.lineColor = [CPTColor colorWithCGColor:dataSet.color.CGColor ];
        plot.lineStyle = plotLineStyle;

        // animation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        animation.duration = 1.0f;
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.16 :0.46 :0.33 :1];
        plot.anchorPoint = CGPointZero;
        [plot addAnimation:animation forKey:@"grow"];

        // add plot
        [graphView addPlot:plot];
        [plot release];
    }

    // plot space
    AGChartDataSet *dataSet = dataSource.dataSets[0];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graphView.defaultPlotSpace;
    [plotSpace scaleToFitPlots:graphView.allPlots ];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(0) length:@(dataSet.values.count+1)];
    plotSpace.globalXRange = plotSpace.xRange; // scrolling x range
    plotSpace.globalYRange = plotSpace.yRange; // scrollinf y range

    // axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graphView.axisSet;

    // y axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;

    // y axis labels
    NSMutableSet *labels = [[NSMutableSet alloc] init];
    for (int i = 0; i < dataSource.xValues.count; ++i) {
        CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:dataSource.xValues[i] textStyle:axisSet.yAxis.labelTextStyle];
        axisLabel.tickLocation = @(i+1);
        axisLabel.offset = 0;
        [labels addObject:axisLabel];
        [axisLabel release];
    }
    axisSet.yAxis.axisLabels = labels;
    [labels release];

    // y axis major ticks
    NSMutableSet *majorTickLocations = [[NSMutableSet alloc] init];
    for (int i = 0; i < dataSource.xValues.count; ++i) {
        [majorTickLocations addObject:@(i) ];
    }
    axisSet.yAxis.majorTickLocations = majorTickLocations;
    [majorTickLocations release];

    // x axis
    double xRange = plotSpace.globalXRange.endDouble - plotSpace.globalXRange.locationDouble;
    axisSet.xAxis.majorIntervalLength = @(xRange/10);

    // legend text style
    CPTMutableTextStyle *legendTextStyle = [CPTMutableTextStyle textStyle];
    legendTextStyle.fontName = @"Helvetica";
    legendTextStyle.fontSize = 10;
    legendTextStyle.color = [CPTColor blackColor];

    // legend
    CPTLegend *legend = [CPTLegend legendWithGraph:graphView];
    graphView.legend = legend;
    legend.textStyle = legendTextStyle;
    legend.swatchSize = CGSizeMake(10, 10);
    legend.numberOfRows = 1;
    graphView.legendAnchor = CPTRectAnchorBottom;
    graphView.legendDisplacement = CGPointMake(0, 0);
}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSInteger dataSetIdx = [(NSNumber *) plot.identifier integerValue];
    AGChartDataSet *dataSet = dataSource.dataSets[dataSetIdx];

    return dataSet.values.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    NSInteger dataSetIdx = [(NSNumber *) plot.identifier integerValue];
    AGChartDataSet *dataSet = dataSource.dataSets[dataSetIdx];

    if (fieldEnum == CPTScatterPlotFieldX) {
        return @(idx+1);
    } else {
        return dataSet.values[idx];
    }
}

@end
