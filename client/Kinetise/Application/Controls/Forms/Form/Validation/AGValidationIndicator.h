#import <UIKit/UIKit.h>

@interface AGValidationIndicator : UIButton

@property(nonatomic, copy) NSString *message;
@property(nonatomic, retain) UIColor *color;
@property(nonatomic, assign) UIOffset offset;

@end
