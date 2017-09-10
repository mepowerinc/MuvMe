#import "AGChart.h"
#import "AGChartDesc.h"
#import "AGChartView.h"
#import "AGLineChartView.h"
#import "AGPieChartView.h"
#import "AGBarChartView.h"
#import "AGHorizontalBarChartView.h"
#import "UIColor+Hex.h"

@interface AGChart (){
    AGControl *indicator;
}
@property(nonatomic, retain) AGControl *indicator;
@end

@implementation AGChart

@synthesize indicator;

#pragma mark - Initialization

- (void)dealloc {
    self.indicator = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGChartDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    return self;
}

- (Class)contentClass {
    AGChartDesc *desc = (AGChartDesc *)descriptor;

    Class chartClass = [AGChartView class];

    if (desc.type == chartLine) {
        chartClass = [AGLineChartView class];
    } else if (desc.type == chartPie) {
        chartClass = [AGPieChartView class];
    } else if (desc.type == chartBar) {
        chartClass = [AGBarChartView class];
    } else if (desc.type == chartHorizontalBar) {
        chartClass = [AGHorizontalBarChartView class];
    }

    return chartClass;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGChartDesc *desc = (AGChartDesc *)descriptor;

    // indicator
    indicator.frame = CGRectMake(desc.indicatorDesc.positionX+desc.indicatorDesc.marginLeft.value,
                                 desc.indicatorDesc.positionY+desc.indicatorDesc.marginTop.value,
                                 MAX(desc.indicatorDesc.width.value+desc.indicatorDesc.borderLeft.value+desc.indicatorDesc.borderRight.value, 0),
                                 MAX(desc.indicatorDesc.height.value+desc.indicatorDesc.borderTop.value+desc.indicatorDesc.borderBottom.value, 0));

    [indicator setNeedsLayout];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    // indicator
    [indicator setupAssets];
}

- (void)loadAssets {
    [super loadAssets];

    // indicator
    [indicator loadAssets];
}

#pragma mark - Reload

- (void)reloadData {
    AGChartDesc *desc = (AGChartDesc *)descriptor;

    // indicator
    [indicator removeFromSuperview];

    if (desc.indicatorDesc) {
        self.indicator = [AGControl controlWithDesc:desc.indicatorDesc];
        indicator.parent = self;
        [contentView addSubview:indicator];
        [indicator setupAssets];
        [indicator loadAssets];
    }

    // chart data
    NSInteger numOfItems = desc.feed.dataSource.items.count;

    if (numOfItems > 0) {
        if (desc.type == chartPie) {
            // data sets
            NSMutableArray *dataSets = [[NSMutableArray alloc] initWithCapacity:desc.dataset.count];

            NSDictionary *dataSetDict = [desc.dataset firstObject];

            // values
            NSString *valueUsingField = dataSetDict[@"value"];

            for (int i = 0; i < desc.feed.dataSource.items.count; ++i) {
                AGDSFeedItem *item = desc.feed.dataSource.items[i];

                AGChartDataSet *dataSet = [[AGChartDataSet alloc] init];
                [dataSets addObject:dataSet];
                [dataSet release];

                // name
                dataSet.name = item.values[desc.label] ? : [NSString stringWithFormat:@"label %zd", index+1];

                // value
                if (item.values[valueUsingField]) {
                    double value = [item.values[valueUsingField] doubleValue];
                    dataSet.values = @[ @(value) ];
                } else {
                    dataSet.values = @[ [NSNull null] ];
                }

                // color
                dataSet.color = [UIColor colorWithHex:desc.colors[i%desc.colors.count]];
            }

            // data
            AGChartData *data = [[AGChartData alloc] init];
            data.dataSets = dataSets;
            ((AGChartView *)self.contentView).dataSource = data;

            // clean
            [dataSets release];
            [data release];
        } else {
            // data sets
            NSMutableArray *dataSets = [[NSMutableArray alloc] initWithCapacity:desc.dataset.count];

            for (NSDictionary *dataSetDict in desc.dataset) {
                NSInteger index = [desc.dataset indexOfObject:dataSetDict];

                AGChartDataSet *dataSet = [[AGChartDataSet alloc] init];
                [dataSets addObject:dataSet];
                [dataSet release];

                // name
                dataSet.name = dataSetDict[@"name"];

                // values
                NSString *valueUsingField = dataSetDict[@"value"];
                NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:numOfItems];

                for (int i = 0; i < desc.feed.dataSource.items.count; ++i) {
                    AGDSFeedItem *item = desc.feed.dataSource.items[i];

                    if (item.values[valueUsingField]) {
                        double value = [item.values[valueUsingField] doubleValue];
                        [values addObject:@(value) ];
                    } else {
                        [values addObject:[NSNull null] ];
                    }
                }

                // color
                dataSet.color = [UIColor colorWithHex:desc.colors[index]];

                dataSet.values = values;
                [values release];
            }

            // x values
            NSMutableArray *xValues = [[NSMutableArray alloc] initWithCapacity:numOfItems];
            for (AGDSFeedItem *item in desc.feed.dataSource.items) {
                NSInteger index = [desc.feed.dataSource.items indexOfObject:item];
                [xValues addObject:item.values[desc.label] ? : [NSString stringWithFormat:@"label %zd", index+1] ];
            }

            // data
            AGChartData *data = [[AGChartData alloc] init];
            data.dataSets = dataSets;
            data.xValues = xValues;
            ((AGChartView *)self.contentView).dataSource = data;

            // clean
            [dataSets release];
            [xValues release];
            [data release];
        }
    }
}

@end
