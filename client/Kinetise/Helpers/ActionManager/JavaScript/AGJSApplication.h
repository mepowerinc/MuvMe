#import <JavaScriptCore/JavaScriptCore.h>
#import "AGJSScreen.h"
#import "AGJSOverlay.h"
#import "AGJSPopup.h"
#import "AGJSAlert.h"
#import "AGJSExternal.h"
#import "AGJSAudio.h"
#import "AGJSLocalization.h"
#import "AGJSStorage.h"
#import "AGJSForm.h"
#import "AGJSAuth.h"
#import "AGJSDevice.h"
#import "AGJSGps.h"
#import "AGJSDb.h"

@protocol AGJSApplicationExport <JSExport>
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, assign) float textMultiplier;
@property(nonatomic, readonly) AGJSScreen *screen;
@property(nonatomic, readonly) AGJSOverlay *overlay;
@property(nonatomic, readonly) AGJSPopup *popup;
@property(nonatomic, readonly) AGJSAlert *alert;
@property(nonatomic, readonly) AGJSExternal *external;
@property(nonatomic, readonly) AGJSAudio *audio;
@property(nonatomic, readonly) AGJSLocalization *localization;
@property(nonatomic, readonly) AGJSStorage *storage;
@property(nonatomic, readonly) AGJSForm *form;
@property(nonatomic, readonly) AGJSAuth *auth;
@property(nonatomic, readonly) AGJSDevice *device;
@property(nonatomic, readonly) AGJSGps *gps;
@property(nonatomic, readonly) AGJSDb *db;
@end

@interface AGJSApplication : NSObject <AGJSApplicationExport>
@end
