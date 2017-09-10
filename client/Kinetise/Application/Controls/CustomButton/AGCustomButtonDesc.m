#import "AGCustomButtonDesc.h"

@implementation AGCustomButtonDesc

@synthesize text;

#pragma mark - Initialization

- (void)dealloc {
    [text release];
    [super dealloc];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGCustomButtonDesc *obj = [super copyWithZone:zone];
    
    obj.text = text;
    
    return obj;
}

@end
