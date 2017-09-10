#import "AGImageDesc.h"
#import "AGActionManager.h"

@implementation AGImageDesc

@synthesize src;
@synthesize httpQueryParams;
@synthesize httpHeaderParams;
@synthesize sizeMode;
@synthesize showLoading;

- (void)dealloc {
    self.src = nil;
    self.httpQueryParams = nil;
    self.httpHeaderParams = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    [AGACTIONMANAGER executeVariable:src withSender:self];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGImageDesc *obj = [super copyWithZone:zone];

    obj.src = [[src copy] autorelease];
    obj.sizeMode = sizeMode;
    obj.showLoading = showLoading;
    obj.httpQueryParams = [[httpQueryParams copy] autorelease];
    obj.httpHeaderParams = [[httpHeaderParams copy] autorelease];

    return obj;
}

@end
