#import <UIKit/UIKit.h>

@protocol AGDatePickerControllerDelegate;

@interface AGDatePickerController : UIViewController {
    id<AGDatePickerControllerDelegate> delegate;
}

@property(nonatomic, readonly) UIDatePicker *datePicker;
@property(nonatomic, assign) id<AGDatePickerControllerDelegate> delegate;

@end

@protocol AGDatePickerControllerDelegate <NSObject>
- (void)datePicker:(AGDatePickerController *)datePicker didChangeDate:(NSDate *)date;
- (void)datePickerDidCancel:(AGDatePickerController *)datePicker;
@end