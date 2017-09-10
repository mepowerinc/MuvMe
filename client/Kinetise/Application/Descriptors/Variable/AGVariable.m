#import "AGVariable.h"
#import "NSObject+Nil.h"

@implementation AGVariable

@synthesize value;

#pragma mark - Initialization

- (void)dealloc {
    self.value = nil;
    [super dealloc];
}

+ (id)variableWithText:(NSString *)text {
    return [AGVariable actionWithText:text];
}

@end
