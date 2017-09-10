#import "AGControl.h"

@interface AGContainer : AGControl {
    NSMutableArray *controls;
    NSMutableArray *interLines;
    BOOL shouldUpdateScrollView;
}

@property(nonatomic, readonly) NSArray *controls;

- (void)addControl:(AGControl *)control;

@end
