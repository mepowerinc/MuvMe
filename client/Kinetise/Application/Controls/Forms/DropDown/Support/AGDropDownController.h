#import <UIKit/UIKit.h>

@protocol AGDropDownControllerDelegate;

@interface AGDropDownController : UIViewController {
    id<AGDropDownControllerDelegate> delegate;
}

@property(nonatomic, readonly) UIPickerView *picker;
@property(nonatomic, assign) id<AGDropDownControllerDelegate> delegate;

@end

@protocol AGDropDownControllerDelegate <NSObject>
- (void)dropDownPicker:(AGDropDownController *)dropDown didSelectRow:(NSInteger)row;
- (void)dropDownPickerDidCancel:(AGDropDownController *)dropDown;
@end