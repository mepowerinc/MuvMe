#import "AGDropDown.h"
#import "AGDropDownDesc.h"
#import "AGActionManager.h"
#import "AGDropDownController.h"

@interface AGDropDown () <AGDropDownControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    AGDSDropDownItem *selectedItem;
    AGDropDownController *pickerController;
}
@property(nonatomic, retain) AGDSDropDownItem *selectedItem;
@end

@implementation AGDropDown

@synthesize selectedItem;

#pragma mark - Initialization

- (void)dealloc {
    self.selectedItem = nil;
    pickerController.picker.dataSource = nil;
    pickerController.picker.delegate = nil;
    [pickerController release];
    [super dealloc];
}

- (id)initWithDesc:(AGDropDownDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // picker controller
    pickerController = [[AGDropDownController alloc] initWithNibName:nil bundle:nil];
    pickerController.delegate = self;
    pickerController.picker.dataSource = self;
    pickerController.picker.delegate = self;
    
    // value
    [self setValue:descriptor_.form.value];
    
    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGDropDownDesc *)descriptor_ {
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
    if (selectedItem) {
        AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
        NSInteger selectedItemIndex = [desc.items indexOfObject:selectedItem];
        
        if (selectedItemIndex != NSNotFound) {
            [pickerController.picker selectRow:selectedItemIndex inComponent:0 animated:NO];
        } else {
            [pickerController.picker selectRow:0 inComponent:0 animated:NO];
        }
    } else {
        [pickerController.picker selectRow:0 inComponent:0 animated:NO];
    }
    
    return pickerController.view;
}

#pragma mark - Assets

- (void)loadAssets {
    [super loadAssets];
    
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    
    // value
    [self setValue:desc.form.value];
}

#pragma mark - Form

- (void)setValue:(NSString *)value_ {
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    
    // item
    AGDSDropDownItem *activeItem = nil;
    for (AGDSDropDownItem *item in desc.items) {
        if ([item.value isEqualToString:value_]) {
            activeItem = item;
            break;
        }
    }
    
    // selected item
    self.selectedItem = activeItem;
}

- (void)setSelectedItem:(AGDSDropDownItem *)selectedItem_ {
    if (selectedItem == selectedItem_) return;
    
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    
    [selectedItem release];
    selectedItem = [selectedItem_ retain];
    
    // value
    if (selectedItem) {
        desc.form.value = self.selectedItem.value;
        self.filled = YES;
    } else {
        desc.form.value = nil;
        self.filled = NO;
    }
    
    // update appearance
    [self updateAppearance];
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];
    
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    
    if (self.isFilled) {
        desc.text.text = desc.text.value = selectedItem.title;
        
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

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    
    return desc.items.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    AGDSDropDownItem *item = desc.items[row];
    
    return item.title;
}

#pragma mark - AGDropDownControllerDelegate

- (void)dropDownPicker:(AGDropDownController *)dropDown didSelectRow:(NSInteger)row {
    AGDropDownDesc *desc = (AGDropDownDesc *)descriptor;
    
    AGDSDropDownItem *item = nil;
    
    if (row < desc.items.count) {
        item = desc.items[row];
    }
    
    // value
    self.selectedItem = item;
    
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

- (void)dropDownPickerDidCancel:(AGDropDownController *)dropDown {
    // resign responder
    [self resignFirstResponder];
}

@end
