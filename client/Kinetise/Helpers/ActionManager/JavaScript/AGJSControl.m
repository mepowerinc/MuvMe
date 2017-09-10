#import "AGJSControl.h"
#import "AGControlDesc.h"
#import "AGControl.h"
#import "AGTextDesc.h"
#import "AGText.h"
#import "AGApplication+Control.h"
#import "AGUnits.h"
#import "AGLayoutManager.h"
#import "AGDesc+Layout.h"

@interface AGJSControl()
@property(nonatomic, retain) AGControlDesc *controlDesc;
@property(nonatomic, retain) AGControl *control;
@end

@implementation AGJSControl

@synthesize controlDesc;
@synthesize control;

- (void)dealloc {
    self.controlDesc = nil;
    self.control = nil;
    [super dealloc];
}

- (id)initWithControlId:(NSString*)controlId {
    self = [super init];
    
    self.controlDesc = [[AGApplication sharedInstance] getControlDesc:controlId];
    self.control = [[AGApplication sharedInstance] getControl:controlId];
    
    return self;
}

- (id)initWithControlDesc:(AGControlDesc*)controlDesc_ {
    self = [super init];
    
    self.controlDesc = controlDesc_;
    self.control = [[AGApplication sharedInstance] getControlWithDesc:controlDesc];
    
    return self;
}

- (NSString*)identifier {
    return controlDesc.identifier;
}

- (NSString *)backgroundColor {
    return [self hexColorWithAGColor:controlDesc.backgroundColor];
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    controlDesc.backgroundColor = AGColorWithText(backgroundColor);
    control.backgroundColor = [UIColor colorWithRed:controlDesc.backgroundColor.r green:controlDesc.backgroundColor.g blue:controlDesc.backgroundColor.b alpha:controlDesc.backgroundColor.a];
}

- (NSString *)textColor {
    if (![controlDesc isKindOfClass:[AGTextDesc class]]) {
        return nil;
    }
    
    AGTextDesc *textDesc = (AGTextDesc *)controlDesc;
    
    return [self hexColorWithAGColor:textDesc.textStyle.textColor];
}

- (void)setTextColor:(NSString *)textColor {
    if (![controlDesc isKindOfClass:[AGTextDesc class]]) {
        return;
    }
    
    AGTextDesc *textDesc = (AGTextDesc *)controlDesc;
    textDesc.textStyle.textColor = AGColorWithText(textColor);
    textDesc.string.color = textDesc.textStyle.textColor;
    
    AGText *textControl = (AGText *)control;
    textControl.label.string = textDesc.string;
}

- (NSString *)text {
    if (![controlDesc isKindOfClass:[AGTextDesc class]]) {
        return @"";
    }
    
    AGTextDesc *textDesc = (AGTextDesc *)controlDesc;
    
    return textDesc.text.value;
}

- (void)setText:(NSString *)text {
    if (![controlDesc isKindOfClass:[AGTextDesc class]]) {
        return;
    }
    
    AGTextDesc *textDesc = (AGTextDesc *)controlDesc;
    textDesc.text.text = text;
    textDesc.text.value = text;
    textDesc.string.string = text;
    
    AGText *textControl = (AGText *)control;
    textControl.label.string = textDesc.string;
    
    AGDesc *parentDesc = [self findViewForCalculate:controlDesc];
    [AGLAYOUTMANAGER layout:parentDesc];
    
    AGView *parent = [AGAPPLICATION getViewWithDesc:parentDesc];
    [parent setNeedsLayout];
}

- (NSString *)hexColorWithAGColor:(AGColor)color {
    return [NSString stringWithFormat:@"0x%02lX%02lX%02lX%02lX",
            lroundf(color.a * 255),
            lroundf(color.r * 255),
            lroundf(color.g * 255),
            lroundf(color.b * 255)];
}

- (AGDesc *)findViewForCalculate:(AGControlDesc *)controlDesc_ {
    if (controlDesc_.width.units != unitMin && controlDesc_.height.units != unitMin) {
        return controlDesc_;
    } else if (controlDesc_.parent) {
        return [self findViewForCalculate:controlDesc_.parent];
    } else {
        if (controlDesc_.section) {
            return controlDesc_.section;
        } else {
            return [AGAPPLICATION getControlPresenterDesc:controlDesc_];
        }
    }
}

@end
