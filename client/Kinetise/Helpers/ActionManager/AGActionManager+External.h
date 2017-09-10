#import "AGActionManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <EventKitUI/EventKitUI.h>

@interface AGActionManager (External) <FBSDKSharingDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, EKEventEditViewDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

- (void)showInVideoPlayer:(id)sender :(id)object :(NSString *)uri;
- (void)showInWebBrowser:(id)sender :(id)object :(NSString *)uri;
- (void)showInWebBrowser:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString;
- (void)openEmail:(id)sender :(id)object :(NSString *)subject :(NSString *)body :(NSString *)recipient;
- (void)openSMS:(id)sender :(id)object :(NSString *)number :(NSString *)message;
- (void)openMap:(id)sender :(id)object :(NSString *)startLatitude :(NSString *)startLongitude :(NSString *)endLatitude :(NSString *)endLongitude :(NSString *)startName :(NSString *)endName :(NSString *)type;
- (void)openMapCurrentLocation:(id)sender :(id)object :(NSString *)endLatitude :(NSString *)endLongitude :(NSString *)endName :(NSString *)type;
- (void)openFile:(id)sender :(id)object :(NSString *)uri;
- (void)addCalendarEvent:(id)sender :(id)object :(NSString *)title :(NSString *)notes :(NSString *)location :(NSString *)start :(NSString *)end :(NSString *)allDay;
- (void)call:(id)sender :(id)object :(NSString *)phoneNumber;
- (void)payment:(id)sender :(id)object :(NSString *)uri :(NSString *)successAction :(NSString *)failureAction :(NSString *)httpQueryParamsString;
- (void)postToFacebook:(id)sender :(id)object :(NSString *)appId :(NSString *)name :(NSString *)caption :(NSString *)link :(NSString *)picture :(NSString *)description;
- (void)offlineReading:(id)sender :(id)object :(NSString *)jsonString;
- (void)scanQRCode:(id)sender :(id)object;
- (void)nativeShare:(id)sender :(id)object :(NSString *)jsonString;
- (void)playSound:(id)sender :(id)object :(NSString *)uri :(NSString *)volume :(NSString *)loop;
- (void)stopAllSounds:(id)sender :(id)object;

@end
