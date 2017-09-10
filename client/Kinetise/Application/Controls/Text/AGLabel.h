#import <UIKit/UIKit.h>
#import "AGUnits.h"
#import "AGString.h"

@interface AGLabel : UIView

@property(nonatomic, assign) AGAlignType textAlign;
@property(nonatomic, assign) AGValignType textValign;
@property(nonatomic, retain) AGString *string;

@end
