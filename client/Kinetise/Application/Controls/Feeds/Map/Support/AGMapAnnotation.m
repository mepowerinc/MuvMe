#import "AGMapAnnotation.h"

@implementation AGMapAnnotation

@synthesize uniqueIdentifier;
@synthesize coordinate;
@synthesize dataSource;
@synthesize size;
@synthesize uri;

- (void)dealloc {
    self.uniqueIdentifier = nil;
    self.dataSource = nil;
    self.uri = nil;
    [super dealloc];
}

@end
