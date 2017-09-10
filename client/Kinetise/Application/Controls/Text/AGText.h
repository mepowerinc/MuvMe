#import "AGControl.h"
#import "AGLabel.h"

@interface AGText : AGControl {
    AGLabel *label;
}

@property(nonatomic, readonly) AGLabel *label;

@end
