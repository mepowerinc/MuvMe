#import "AGApplicationDesc.h"

@implementation AGApplicationDesc

@synthesize name;
@synthesize xmlVersion;
@synthesize xmlCreatedVersion;
@synthesize apiVersion;
@synthesize startScreen;
@synthesize loginScreen;
@synthesize protectedLoginScreen;
@synthesize mainScreen;
@synthesize defaultUserAgent;
@synthesize screens;
@synthesize overlays;
@synthesize regularExpressions;
@synthesize localStorage;
@synthesize permissions;
@synthesize minTextMultiplier;
@synthesize maxTextMultiplier;
@synthesize validationColor;

- (void)dealloc {
    self.name = nil;
    self.xmlVersion = nil;
    self.xmlCreatedVersion = nil;
    self.apiVersion = nil;
    self.startScreen = nil;
    self.loginScreen = nil;
    self.protectedLoginScreen = nil;
    self.mainScreen = nil;
    self.defaultUserAgent = nil;
    [screens release];
    [overlays release];
    [regularExpressions release];
    [localStorage release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    screens = [[NSMutableDictionary alloc] init];
    overlays = [[NSMutableDictionary alloc] init];
    regularExpressions = [[NSMutableDictionary alloc] init];
    localStorage = [[NSMutableDictionary alloc] init];
    permissions = AGPermissionNone;

    return self;
}

@end

