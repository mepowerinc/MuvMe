#import "AGTextDesc.h"
#import "AGActionManager.h"

@implementation AGTextDesc

@synthesize textStyle;
@synthesize text;
@synthesize maxCharacters;
@synthesize maxLines;
@synthesize string;

#pragma mark - Initialization

- (void)dealloc {
    self.textStyle = nil;
    self.text = nil;
    self.string = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    self.string = [[[AGString alloc] init] autorelease];
    
    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
    
    [AGACTIONMANAGER executeVariable:text withSender:self];
    
    // string
    string.string = text.value;
    string.color = textStyle.textColor;
    string.isBold = textStyle.isBold;
    string.isItalic = textStyle.isItalic;
    string.isUnderline = textStyle.isUnderline;
    string.maxCharacters = maxCharacters;
    string.maxLines = maxLines;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGTextDesc *obj = [super copyWithZone:zone];
    
    obj.textStyle = [[textStyle copy] autorelease];
    obj.text = [[text copy] autorelease];
    obj.maxCharacters = maxCharacters;
    obj.maxLines = maxLines;
    obj.string = [[string copy] autorelease];
    
    return obj;
}

@end
