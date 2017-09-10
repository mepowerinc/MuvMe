#import "AGButtonDesc.h"
#import "AGActionManager.h"

@implementation AGButtonDesc

@synthesize activeBorderColor;
@synthesize activeSrc;
@synthesize activeHttpQueryParams;
@synthesize activeHttpHeaderParams;
@synthesize invalidSrc;
@synthesize invalidHttpQueryParams;
@synthesize invalidHttpHeaderParams;

- (void)dealloc {
    self.activeSrc = nil;
    self.activeHttpQueryParams = nil;
    self.activeHttpHeaderParams = nil;
    self.invalidSrc = nil;
    self.invalidHttpQueryParams = nil;
    self.invalidHttpHeaderParams = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    [AGACTIONMANAGER executeVariable:activeSrc withSender:self];
    [AGACTIONMANAGER executeVariable:invalidSrc withSender:self];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGButtonDesc *obj = [super copyWithZone:zone];

    obj.activeBorderColor = activeBorderColor;
    obj.activeSrc = [[activeSrc copy] autorelease];
    obj.activeHttpQueryParams = [[activeHttpQueryParams copy] autorelease];
    obj.activeHttpHeaderParams = [[activeHttpHeaderParams copy] autorelease];
    obj.invalidSrc = [[invalidSrc copy] autorelease];
    obj.invalidHttpQueryParams = [[invalidHttpQueryParams copy] autorelease];
    obj.invalidHttpHeaderParams = [[invalidHttpHeaderParams copy] autorelease];

    return obj;
}

@end
