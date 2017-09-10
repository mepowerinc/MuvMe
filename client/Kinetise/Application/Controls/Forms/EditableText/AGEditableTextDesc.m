#import "AGEditableTextDesc.h"
#import "AGActionManager.h"

@implementation AGEditableTextDesc

@synthesize form;
@synthesize watermark;
@synthesize textStyle;
@synthesize keyboardType;
@synthesize onAccept;
@synthesize iconSrc;
@synthesize iconSizeMode;
@synthesize iconWidth;
@synthesize iconHeight;
@synthesize iconAlign;
@synthesize iconValign;

#pragma mark - Initialization

- (void)dealloc {
    self.form = nil;
    self.watermark = nil;
    self.textStyle = nil;
    self.onAccept = nil;
    self.iconSrc = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    // defaults
    keyboardType = keyboardTypeText;
    
    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
    
    // icon
    [AGACTIONMANAGER executeVariable:iconSrc withSender:self];
    
    // watermark
    [AGACTIONMANAGER executeVariable:watermark withSender:self];
    
    // form
    [form executeVariables:self];
    
    // initial value
    form.value = form.initialValue.value;
}

#pragma mark - Lifecycle

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];
    
    if (onAccept) [actions addObject:onAccept ];
    
    return actions;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGEditableTextDesc *obj = [super copyWithZone:zone];
    
    obj.form = [[form copy] autorelease];
    obj.watermark = [[watermark copy] autorelease];
    obj.textStyle = [[textStyle copy] autorelease];
    obj.keyboardType = keyboardType;
    obj.onAccept = [[onAccept copy] autorelease];
    obj.iconSrc = [[iconSrc copy] autorelease];
    obj.iconSizeMode = iconSizeMode;
    obj.iconWidth = iconWidth;
    obj.iconHeight = iconHeight;
    obj.iconAlign = iconAlign;
    obj.iconValign = iconValign;
    
    return obj;
}

@end
