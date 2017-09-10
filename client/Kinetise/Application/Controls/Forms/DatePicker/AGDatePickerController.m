#import "AGDatePickerController.h"

@interface AGDatePickerController (){
    UIToolbar *toolbar;
    UIDatePicker *datePicker;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *doneButton;
}
@end

@implementation AGDatePickerController

@synthesize datePicker;
@synthesize delegate;

#pragma mark - Initialization

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    // force load view
    [self view];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // toolbar
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:toolbar];
    [toolbar release];

    // toolbar items
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    NSMutableArray *toolbarItems = [NSMutableArray array];
    [toolbarItems addObject:cancelButton];
    [toolbarItems addObject:space];
    [toolbarItems addObject:doneButton];
    [cancelButton release];
    [doneButton release];
    [space release];
    toolbar.items = toolbarItems;

    // date picker
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.view addSubview:datePicker];
    [datePicker release];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    // toolbar
    [toolbar sizeToFit];
    toolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, toolbar.frame.size.height);

    // date picker
    datePicker.frame = CGRectMake(0, toolbar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-toolbar.frame.size.height);
}

#pragma mark - Lifecycle

- (void)onCancel {
    if ([delegate respondsToSelector:@selector(datePickerDidCancel:)]) {
        [delegate datePickerDidCancel:self];
    }
}

- (void)onDone {
    if ([delegate respondsToSelector:@selector(datePicker:didChangeDate:)]) {
        [delegate datePicker:self didChangeDate:datePicker.date];
    }
}

@end
