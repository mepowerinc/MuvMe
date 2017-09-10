#import "AGPickerDesc.h"

@interface AGDatePickerDesc : AGPickerDesc{
    AGDatePickerMode mode;
    AGVariable *minDate;
    AGVariable *maxDate;
    NSString *dateFormat;
    AGVariable *watermark;
}

@property(nonatomic, assign) AGDatePickerMode mode;
@property(nonatomic, retain) AGVariable *minDate;
@property(nonatomic, retain) AGVariable *maxDate;
@property(nonatomic, copy) NSString *dateFormat;
@property(nonatomic, retain) AGVariable *watermark;

@end
