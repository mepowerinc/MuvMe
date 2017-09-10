#import <CorePlot/CorePlot.h>
#import "AGChartData.h"

@interface AGChartView : CPTGraphHostingView {
    AGChartData *dataSource;
    CPTXYGraph *graphView;
}

@property(nonatomic, retain) AGChartData *dataSource;

@end
