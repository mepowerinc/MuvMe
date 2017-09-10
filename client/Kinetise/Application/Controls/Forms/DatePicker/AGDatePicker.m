#import "AGDatePicker.h"
#import "AGDatePickerDesc.h"
#import "AGActionManager.h"
#import "AGDateFormatter.h"
#import "AGFeedDateParser.h"
#import "NSObject+Nil.h"
#import "AGLocalizationManager.h"
#import "AGDatePickerController.h"

@interface AGDatePicker () <AGDatePickerControllerDelegate>{
    AGDatePickerController *datePickerController;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *outputDateFormatter;
    NSDate *date;
    AGFeedDateParser *dateParser;
}
@property(nonatomic, retain) NSDateFormatter *dateFormatter;
@property(nonatomic, retain) NSDate *date;
@end

@implementation AGDatePicker

@synthesize dateFormatter;
@synthesize date;

#pragma mark - Initialization

- (void)dealloc {
    [datePickerController release];
    [outputDateFormatter release];
    [dateParser release];
    self.dateFormatter = nil;
    self.date = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGDatePickerDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // date parser
    dateParser = [[AGFeedDateParser alloc] init];
    
    // date picker controller
    datePickerController = [[AGDatePickerController alloc] initWithNibName:nil bundle:nil];
    datePickerController.delegate = self;
    
    // date picker mode
    if (descriptor_.mode == datePickerModeDate) {
        datePickerController.datePicker.datePickerMode = UIDatePickerModeDate;
    } else if (descriptor_.mode == datePickerModeTime) {
        datePickerController.datePicker.datePickerMode = UIDatePickerModeTime;
    } else if (descriptor_.mode == datePickerModeDateTime) {
        datePickerController.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    // date formatter
    AGDateFormatter *formatter = [[AGDateFormatter alloc] init];
    formatter.dateFormat = descriptor_.dateFormat;
    self.dateFormatter = formatter.dateFormatter;
    [formatter release];
    
    // output date formatter
    outputDateFormatter = [[NSDateFormatter alloc] init];
    outputDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    outputDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    outputDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    
    // value
    [self setValue:descriptor_.form.value];
    
    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGDatePickerDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }
    
    // value
    [self setValue:descriptor_.form.value];
}

#pragma mark - Lifecycle

- (UIView *)inputView {
    datePickerController.datePicker.date = date ? : [NSDate date];
    
    return datePickerController.view;
}

#pragma mark - Assets

- (void)loadAssets {
    [super loadAssets];
    
    AGDatePickerDesc *desc = (AGDatePickerDesc *)descriptor;
    
    // min date
    if (isNotEmpty(desc.minDate.value) ) {
        NSDate *minDate = [dateParser dateFromString:desc.minDate.value ];
        datePickerController.datePicker.minimumDate = minDate;
    }
    
    // max date
    if (isNotEmpty(desc.maxDate.value) ) {
        NSDate *maxDate = [dateParser dateFromString:desc.maxDate.value ];
        datePickerController.datePicker.maximumDate = maxDate;
    }
    
    // value
    [self setValue:desc.form.value];
}

#pragma mark - Form

- (void)setValue:(NSString *)value_ {
    // date
    if (isNotEmpty(value_) ) {
        self.date = [dateParser dateFromString:value_];
        
        if (!date) {
            self.date = [NSDate distantFuture];
        } else {
            if (datePickerController.datePicker.minimumDate) {
                if ([date compare:datePickerController.datePicker.minimumDate] == NSOrderedAscending) {
                    self.date = datePickerController.datePicker.minimumDate;
                }
            }
            if (datePickerController.datePicker.maximumDate) {
                if ([date compare:datePickerController.datePicker.maximumDate] == NSOrderedDescending) {
                    self.date = datePickerController.datePicker.maximumDate;
                }
            }
        }
    } else {
        self.date = nil;
    }
}

- (void)setDate:(NSDate *)date_ {
    if ([date isEqualToDate:date_]) return;
    
    AGDatePickerDesc *desc = (AGDatePickerDesc *)descriptor;
    
    [date release];
    date = [date_ retain];
    
    // value
    if ([date isEqualToDate:[NSDate distantFuture] ]) {
        desc.form.value = [AGLOCALIZATION localizedString:@"INVALID_DATE_FORMAT"];
    } else if (date) {
        desc.form.value = [outputDateFormatter stringFromDate:date];
    } else {
        desc.form.value = nil;
    }
    
    // filled
    self.filled = (date != nil);
    
    // update appearance
    [self updateAppearance];
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];
    
    AGDatePickerDesc *desc = (AGDatePickerDesc *)descriptor;
    
    if (self.isFilled) {
        if ([date isEqualToDate:[NSDate distantFuture] ]) {
            desc.text.text = desc.text.value = [AGLOCALIZATION localizedString:@"INVALID_DATE_FORMAT"];
        } else {
            desc.text.text = desc.text.value = [dateFormatter stringFromDate:date];
        }
        
        if (self.isInvalid) {
            desc.string.color = desc.textStyle.textInvalidColor;
        } else if (self.isHighlighted) {
            desc.string.color = desc.textStyle.textActiveColor;
        } else if (self.isSelected) {
            desc.string.color = desc.textStyle.textActiveColor;
        } else {
            desc.string.color = desc.textStyle.textColor;
        }
    } else {
        desc.text.text = desc.text.value = desc.watermark.value;
        desc.string.color = desc.textStyle.watermarkColor;
    }
    
    desc.string.string = desc.text.value;
    label.string = desc.string;
}

#pragma mark - AGDatePickerControllerDelegate

- (void)datePicker:(AGDatePickerController *)datePicker didChangeDate:(NSDate *)date_ {
    AGDatePickerDesc *desc = (AGDatePickerDesc *)descriptor;
    
    // date
    self.date = date_;
    
    // on change
    if (desc.onChangeAction) {
        [AGACTIONMANAGER executeAction:desc.onChangeAction withSender:desc];
    }
    
    // validate
    if (![desc.form isValid:desc.form.value]) {
        [self validate];
    } else {
        [self invalidate];
    }
    
    // resign responder
    [self resignFirstResponder];
}

- (void)datePickerDidCancel:(AGDatePickerController *)datePicker {
    // resign responder
    [self resignFirstResponder];
}

@end
