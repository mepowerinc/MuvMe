#import "AGJSApplication.h"
#import "AGApplication.h"

@interface AGJSApplication ()
@property(nonatomic, retain) AGJSScreen *screen;
@property(nonatomic, retain) AGJSOverlay *overlay;
@property(nonatomic, retain) AGJSPopup *popup;
@property(nonatomic, retain) AGJSAlert *alert;
@property(nonatomic, retain) AGJSExternal *external;
@property(nonatomic, retain) AGJSAudio *audio;
@property(nonatomic, retain) AGJSLocalization *localization;
@property(nonatomic, retain) AGJSStorage *storage;
@property(nonatomic, retain) AGJSForm *form;
@property(nonatomic, retain) AGJSAuth *auth;
@property(nonatomic, retain) AGJSDevice *device;
@property(nonatomic, retain) AGJSGps *gps;
@property(nonatomic, retain) AGJSDb *db;
@end

@implementation AGJSApplication

- (void)dealloc {
    self.screen = nil;
    self.overlay = nil;
    self.popup = nil;
    self.alert = nil;
    self.external = nil;
    self.audio = nil;
    self.localization = nil;
    self.storage = nil;
    self.form = nil;
    self.auth = nil;
    self.device = nil;
    self.gps = nil;
    self.db = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    self.screen = [[[AGJSScreen alloc] init] autorelease];
    self.overlay = [[[AGJSOverlay alloc] init] autorelease];
    self.popup = [[[AGJSPopup alloc] init] autorelease];
    self.alert = [[[AGJSAlert alloc] init] autorelease];
    self.external = [[[AGJSExternal alloc] init] autorelease];
    self.audio = [[[AGJSAudio alloc] init] autorelease];
    self.localization = [[[AGJSLocalization alloc] init] autorelease];
    self.storage = [[[AGJSStorage alloc] init] autorelease];
    self.form = [[[AGJSForm alloc] init] autorelease];
    self.auth = [[[AGJSAuth alloc] init] autorelease];
    self.device = [[[AGJSDevice alloc] init] autorelease];
    self.gps = [[[AGJSGps alloc] init] autorelease];
    self.db = [[[AGJSDb alloc] init] autorelease];
    
    return self;
}

- (NSString *)name {
    return AGAPPLICATION.descriptor.name;
}

- (float)textMultiplier {
    return AGAPPLICATION.textMultiplier;
}

- (void)setTextMultiplier:(float)textMultiplier {
    textMultiplier = MIN(textMultiplier, AGAPPLICATION.descriptor.maxTextMultiplier);
    textMultiplier = MAX(textMultiplier, AGAPPLICATION.descriptor.minTextMultiplier);
    
    AGAPPLICATION.textMultiplier = textMultiplier;
}

@end
