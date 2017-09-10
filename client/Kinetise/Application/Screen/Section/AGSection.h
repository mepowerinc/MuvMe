#import "AGSectionDesc.h"
#import "AGView.h"

@interface AGSection : AGView {
    NSMutableArray *controls;
    UIView *contentView;
}

@property(nonatomic, readonly) NSArray *controls;
@property(nonatomic, readonly) UIView *contentView;

@end
