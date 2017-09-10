#import "AGActionManager+External.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MapKit/MapKit.h>
#import <RMUniversalAlert/RMUniversalAlert.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MBProgressHUD/MBProgressHUD+Hide.h>
#import <SoundManager/SoundManager.h>
#import "AGLocalizationManager.h"
#import "AGFileManager.h"
#import "AGLocalStorage.h"
#import "AGPaymentViewController.h"
#import "AGCodeScannerController.h"
#import "AGRFC822DateParser.h"
#import "AGRFC3339DateParser.h"
#import "AGImageAsset.h"
#import "AGOfflineReader.h"
#import "AGApplication+Popup.h"
#import "NSString+UriEncoding.h"
#import "NSString+URL.h"
#import "NSString+YouTube.h"
#import "NSString+HTML.h"
#import "NSObject+Nil.h"

@implementation AGActionManager (External)

- (void)showInVideoPlayer:(id)sender :(id)object :(NSString *)uri {
    uri = [uri uriString];
    
    if ([uri hasPrefix:@"http"]) {
        NSString *youTubeVideoId = [uri stringByExtractingYouTubeVideoId];
        
        if (youTubeVideoId) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri] ];
        } else {
            AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:uri] ];
            AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
            playerController.player = player;
            [player release];
            [AGAPPLICATION.navigationController presentViewController:playerController animated:YES completion:nil];
            [playerController release];
            [player play];
            
        }
    } else {
        uri = [@"http://www.youtube.com/watch?v=" stringByAppendingString:uri];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri] ];
    }
}

- (void)showInWebBrowser:(id)sender :(id)object :(NSString *)uri {
    uri = [uri uriString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri] ];
}

- (void)showInWebBrowser:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString {
    // http query params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    NSString *URLQuery = [NSString URLQueryWithParameters:[httpQueryParams execute:sender] ];
    uri = [uri stringByAppendingURLQuery:URLQuery];
    
    [self showInWebBrowser:sender :object :uri];
}

- (void)openEmail:(id)sender :(id)object :(NSString *)subject :(NSString *)body :(NSString *)recipient {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:subject ];
        [mailComposer setMessageBody:body isHTML:NO];
        [mailComposer setToRecipients:@[recipient] ];
        
        [AGAPPLICATION.navigationController presentViewController:mailComposer animated:YES completion:^{}];
        [mailComposer release];
    } else {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"EMAIL_SEND_ERROR"] ];
    }
}

- (void)openSMS:(id)sender :(id)object :(NSString *)number :(NSString *)message {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        messageController.body = message;
        // iOS changes empty string to 'Buddy name'
        if (number.length) {
            messageController.recipients = @[number];
        }
        
        [AGAPPLICATION.navigationController presentViewController:messageController animated:YES completion:^{}];
        [messageController release];
    } else {
        [RMUniversalAlert showAlertInViewController:AGAPPLICATION.navigationController
                                          withTitle:[AGLOCALIZATION localizedString:@"POPUP_ERROR_HEADER"]
                                            message:[AGLOCALIZATION localizedString:@"ERROR_SEND_SMS"]
                                  cancelButtonTitle:[AGLOCALIZATION localizedString:@"OK"]
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    }
}

- (void)openMap:(id)sender :(id)object :(NSString *)startLatitude :(NSString *)startLongitude :(NSString *)endLatitude :(NSString *)endLongitude :(NSString *)startName :(NSString *)endName :(NSString *)type {
    NSMutableArray *mapItems = [[NSMutableArray alloc] init];
    
    // start location
    if (startLatitude && startLongitude && startName) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([startLatitude doubleValue], [startLongitude doubleValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark ];
        item.name = startName;
        [mapItems addObject:item];
        [placemark release];
        [item release];
    }
    
    // end location
    {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([endLatitude doubleValue], [endLongitude doubleValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark ];
        item.name = endName;
        [mapItems addObject:item];
        [placemark release];
        [item release];
    }
    
    // options
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving};
    if ([[type lowercaseString] isEqualToString:@"transit"]) {
        launchOptions = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit};
    } else if ([[type lowercaseString] isEqualToString:@"walking"]) {
        launchOptions = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking};
    }
    
    // open map
    [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
    [mapItems release];
}

- (void)openMapCurrentLocation:(id)sender :(id)object :(NSString *)endLatitude :(NSString *)endLongitude :(NSString *)endName :(NSString *)type {
    [self openMap:sender :object :nil :nil :endLatitude :endLongitude :nil :endName :type];
}

- (void)openFile:(id)sender :(id)object :(NSString *)uri {
    uri = [uri uriString];
    
    // url
    NSURL *url = nil;
    if ([uri hasPrefix:@"assets://"]) {
        NSString *fileName = [uri substringFromIndex:[@"assets://" length] ];
        NSString *filePath = [AGFILEMANAGER pathForResource:fileName];
        url = [NSURL fileURLWithPath:filePath];
    } else if ([uri hasPrefix:@"local://"]) {
        NSString *fileName = [uri substringFromIndex:[@"local://" length] ];
        NSString *filePath = [AGLOCALSTORAGE attachmentPath:fileName];
        url = [NSURL fileURLWithPath:filePath];
    } else if ([uri hasPrefix:@"http"]) {
        url = [NSURL URLWithString:uri];
    }
    
    if (url.isFileURL) {
        UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:url];
        controller.delegate = self;
        [controller presentPreviewAnimated:YES];
    } else {
        // progress hud
        MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
        progressHUD.labelText = [AGLOCALIZATION localizedString:@"DOWNLOADING_FILE"];
        
        // request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
        // session
        [[session downloadTaskWithRequest:request] resume];
    }
}

- (void)addCalendarEvent:(id)sender :(id)object :(NSString *)title :(NSString *)notes :(NSString *)location :(NSString *)start :(NSString *)end :(NSString *)allDay {
    EKEventStore *store = [[[EKEventStore alloc] init] autorelease];
    EKEvent *event = [EKEvent eventWithEventStore:store];
    event.title = title;
    event.notes = notes;
    event.location = location;
    event.calendar = [store defaultCalendarForNewEvents];
    event.allDay = [allDay boolValue];
    
    AGRFC822DateParser *rfc822DateParser = [[AGRFC822DateParser alloc] init];
    AGRFC3339DateParser *rfc3339DateParser = [[AGRFC3339DateParser alloc] init];
    
    NSDate *startDate = nil;
    startDate = [rfc822DateParser dateFromString:start ];
    if (!startDate) {
        startDate = [rfc3339DateParser dateFromString:start ];
    }
    if (!startDate) {
        startDate = [NSDate date];
    }
    
    NSDate *endDate = nil;
    endDate = [rfc822DateParser dateFromString:end ];
    if (!endDate) {
        endDate = [rfc3339DateParser dateFromString:end ];
    }
    if (!endDate) {
        endDate = [NSDate date];
    }
    
    event.startDate = startDate;
    event.endDate = endDate;
    
    [rfc822DateParser release];
    [rfc3339DateParser release];
    
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            NSLog(@"Calendar event error: %@", error.localizedDescription);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                EKEventEditViewController *eventController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
                eventController.eventStore = store;
                eventController.event = event;
                eventController.editViewDelegate = self;
                [AGAPPLICATION.navigationController presentViewController:eventController animated:YES completion:^{}];
                [eventController release];
            });
        }
    }];
}

- (void)call:(id)sender :(id)object :(NSString *)phoneNumber {
    NSString *uri = [NSString stringWithFormat:@"tel:%@", phoneNumber];
    
    NSURL *url = [NSURL URLWithString:uri];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)payment:(id)sender :(id)object :(NSString *)uri :(NSString *)successAction :(NSString *)failureAction :(NSString *)httpQueryParamsString {
    // uri
    uri = [uri uriString];
    
    // http query params
    if (httpQueryParamsString) {
        AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
        NSString *URLQuery = [NSString URLQueryWithParameters:[httpQueryParams execute:sender] ];
        uri = [uri stringByAppendingURLQuery:URLQuery];
    }
    
    // url
    NSURL *url = [NSURL URLWithString:uri];
    
    AGPaymentViewController *paymentViewController = [[AGPaymentViewController alloc] initWithURL:url success:^{
        [AGAPPLICATION.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self executeString:successAction withSender:sender];
    } cancel:^{
        [AGAPPLICATION.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failure:^{
        [AGAPPLICATION.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self executeString:failureAction withSender:sender];
    }];
    
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [paymentViewController release];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        navigationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [AGAPPLICATION.navigationController presentViewController:navigationViewController animated:YES completion:nil];
    [navigationViewController release];
}

- (void)postToFacebook:(id)sender :(id)object :(NSString *)appId :(NSString *)name :(NSString *)caption :(NSString *)link :(NSString *)picture :(NSString *)description {
    // post
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:link];
    content.contentTitle = caption;
    content.contentDescription = description;
    content.imageURL = [NSURL URLWithString:picture];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"] ]) {
        [FBSDKShareDialog showFromViewController:AGAPPLICATION.rootController withContent:content delegate:self];
    } else {
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.shareContent = content;
        dialog.fromViewController = AGAPPLICATION.rootController;
        dialog.mode = FBSDKShareDialogModeFeedWeb;
        dialog.delegate = self;
        [dialog show];
        [dialog release];
    }
    
    [content release];
}

- (void)offlineReading:(id)sender :(id)object :(NSString *)jsonString {
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    /*
     NSMutableArray* json = [NSMutableArray array];
     NSMutableDictionary* dict1 = [NSMutableDictionary dictionary];
     [json addObject:dict1];
     dict1[@"httpUrl"] = @"http://www.google.pl/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png";
     dict1[@"httpParams"] = @{};
     dict1[@"httpHeaderParams"] = @{};
     dict1[@"httpMethod"] = @"GET";
     dict1[@"httpBody"] = [NSNull null];
     dict1[@"dataType"] = @"IMAGE";
     
     NSMutableDictionary* dict2 = [NSMutableDictionary dictionary];
     [json addObject:dict2];
     dict2[@"httpUrl"] = @"http://feeds.bbci.co.uk/news/world/rss.xml";
     dict2[@"httpParams"] = @{};
     dict2[@"httpHeaderParams"] = @{};
     dict2[@"httpMethod"] = @"GET";
     dict2[@"httpBody"] = [NSNull null];
     dict2[@"dataType"] = @"XML";
     dict2[@"nodes"] = [NSMutableArray array];
     dict2[@"xmlns"] = @{@"media":@"http://search.yahoo.com/mrss/", @"atom":@"ttp://www.w3.org/2005/Atom"};
     dict2[@"usingFields"] = @{@"media:thumbnail/@url":@"media:thumbnail/@url"};
     dict2[@"itemPath"] = @"/rss/channel/item";
     
     NSMutableDictionary* dict3 = [NSMutableDictionary dictionary];
     [dict2[@"nodes"] addObject:dict3];
     dict3[@"httpUrl"] = [NSNull null];
     dict3[@"usingFieldInParent"] = @"media:thumbnail/@url";
     dict3[@"httpParams"] = @{};
     dict3[@"httpHeaderParams"] = @{};
     dict3[@"httpMethod"] = @"GET";
     dict3[@"httpBody"] = [NSNull null];
     dict3[@"dataType"] = @"IMAGE";
     */
    
    /*
     NSMutableArray* json = [NSMutableArray array];
     NSMutableDictionary* dict1 = [NSMutableDictionary dictionary];
     [json addObject:dict1];
     dict1[@"httpUrl"] = @"https://graph.facebook.com/v2.2/hyundai/posts?access_token=1439134096358130%7CATbKEUiky1e3J4pT5kw0ZC8Qsn0&fields=message%2Cto%7Bname%7D%2Cname%2Cfrom%7Bname%7D%2Ccaption%2Cpicture%2Cobject_id%2Clink%2Cdescription%2Cicon%2Ctype%2Cstatus_type%2Ccreated_time%2Cupdated_time%2Cstory%2Cplace%7Bname%2Clocation%7Bcity%7D%7D";
     dict1[@"httpParams"] = @{};
     dict1[@"httpHeaderParams"] = @{};
     dict1[@"httpMethod"] = @"GET";
     dict1[@"httpBody"] = [NSNull null];
     dict1[@"dataType"] = @"JSON";
     dict1[@"nodes"] = [NSMutableArray array];
     dict1[@"usingFields"] = @{@"$.picture":@"$.picture"};
     dict1[@"itemPath"] = @"$.data.*";
     
     NSMutableDictionary* dict2 = [NSMutableDictionary dictionary];
     [dict1[@"nodes"] addObject:dict2];
     dict2[@"httpUrl"] = [NSNull null];
     dict2[@"httpParams"] = @{};
     dict2[@"httpHeaderParams"] = @{};
     dict2[@"httpMethod"] = @"GET";
     dict2[@"httpBody"] = [NSNull null];
     dict2[@"dataType"] = @"IMAGE";
     dict2[@"usingFieldInParent"] = @"$.picture";
     */
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    if (!progressHUD) {
        progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
        progressHUD.labelText = [AGLOCALIZATION localizedString:@"DOWNLOADING_FILE"];
    }
    
    AGOfflineReader *reader = [[AGOfflineReader alloc] initWithJSON:json];
    reader.completionBlock = ^(AGOfflineReader *offlineReader, NSError *error){
        UIImage *image = nil;
        if (!error) {
            image = [UIImage imageWithContentsOfFile:FILE_PATH_BUNDLE(@"checkmark.png") ];
            progressHUD.labelText = [AGLOCALIZATION localizedString:@"OFFLINE_READING_SUCCEED_TITLE"];
            progressHUD.detailsLabelText = [AGLOCALIZATION localizedString:@"OFFLINE_READING_SUCCEED_DESCRIPTION"];
            [progressHUD hide:YES afterDelay:1.5f];
        } else {
            image = [UIImage imageWithContentsOfFile:FILE_PATH_BUNDLE(@"crosskmark.png") ];
            progressHUD.labelText = [AGLOCALIZATION localizedString:@"OFFLINE_READING_FAILED_TITLE"];
            NSString *description = [NSString stringWithFormat:@"%@\n\n%@", [AGLOCALIZATION localizedString:@"OFFLINE_READING_FAILED_DESCRIPTION"], [AGLOCALIZATION localizedString:@"TAP_TO_CLOSE"]];
            progressHUD.detailsLabelText = description;
            progressHUD.userInteractionEnabled = YES;
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onProgressTap)];
            [progressHUD addGestureRecognizer:gestureRecognizer];
            [gestureRecognizer release];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        progressHUD.mode = MBProgressHUDModeCustomView;
        progressHUD.customView = imageView;
        [imageView release];
    };
    reader.progressBlock = ^(AGOfflineReader *offlineReader, float progress){
        progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
        progressHUD.progress = progress;
    };
    
    [reader start];
    [reader release];
}

- (void)onProgressTap {
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    [progressHUD hide:YES];
}

- (void)scanQRCode:(id)sender :(id)object {
    if (![AGCodeScannerController isAvailable]) return;
    
    AGCodeScannerController *viewController = [[AGCodeScannerController alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode] andCompletionBlock:^(AGCodeScannerController *scanner, UIImage *image, NSString *resultString) {
        [scanner stopScanning];
        [scanner dismissViewControllerAnimated:YES completion:nil];
        
        NSString *uri = [resultString stringByExtractingURLFromHTML];
        NSURL *url = [NSURL URLWithString:uri];
        if (url && isNotEmpty(uri) ) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_QRCODE_INVALID_URL"] ];
        }
    }];
    viewController.title = [AGLOCALIZATION localizedString:@"SCANNER_TITLE"];
    [AGAPPLICATION.navigationController presentViewController:viewController animated:YES completion:nil];
    [viewController release];
}

- (void)nativeShare:(id)sender :(id)object :(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    if (!progressHUD) {
        progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
    }
    
    for (NSDictionary *itemDesc in json) {
        NSString *type = itemDesc[@"type"];
        NSString *value = [self executeString:itemDesc[@"value"] withSender:sender];
        NSString *trimValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([type isEqualToString:@"text-url"]) {
            if ([trimValue hasPrefix:@"http"]) {
                NSURL *url = [NSURL URLWithString:[[sender fullPath:value] uriString]];
                if (url) [items addObject:url];
            } else {
                if (value) [items addObject:value];
            }
        } else if ([type isEqualToString:@"image"]) {
            if ([trimValue hasPrefix:@"assets://"]) {
                UIImage *image = [AGImageAsset imageWithAsset:value];
                if (image) [items addObject:image];
            } else if ([trimValue hasPrefix:@"local://"]) {
                UIImage *image = [AGImageAsset imageWithLocal:value];
                if (image) [items addObject:image];
            } else {
                NSURL *url = [NSURL URLWithString:[[sender fullPath:value] uriString]];
                if (url) {
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    if (image) [items addObject:image];
                    [image release];
                }
            }
        }
    }
    
    // hide
    [progressHUD hide:YES completion:^{
        // controller
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        controller.excludedActivityTypes = @[
                                             UIActivityTypeAssignToContact,
                                             UIActivityTypeAddToReadingList,
                                             UIActivityTypeAirDrop
                                             ];
        [AGAPPLICATION.navigationController presentViewController:controller animated:YES completion:nil];
        [controller release];
        [items release];
    }];
}

- (void)playSound:(id)sender :(id)object :(NSString *)uri :(NSString *)volume :(NSString *)loop {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    if ([uri hasPrefix:@"assets://"]) {
        NSString *fileName = [uri substringFromIndex:[@"assets://" length] ];
        NSString *filePath = [AGFILEMANAGER pathForResource:fileName];
        
        Sound *sound = [[Sound alloc] initWithContentsOfFile:filePath];
        [[SoundManager sharedManager] playSound:sound looping:[loop boolValue]];
        sound.volume = [volume doubleValue];
        [sound release];
    }
}

- (void)stopAllSounds:(id)sender :(id)object {
    [[SoundManager sharedManager] stopAllSounds:NO];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return AGAPPLICATION.navigationController.visibleViewController;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"EMAIL_SEND_ERROR"] ];
    }
    
    [AGAPPLICATION.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
        {
            [RMUniversalAlert showAlertInViewController:AGAPPLICATION.navigationController
                                              withTitle:[AGLOCALIZATION localizedString:@"POPUP_ERROR_HEADER"]
                                                message:[AGLOCALIZATION localizedString:@"ERROR_SEND_SMS"]
                                      cancelButtonTitle:[AGLOCALIZATION localizedString:@"OK"]
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil
                                               tapBlock:nil];
            break;
        }
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [AGAPPLICATION.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [AGAPPLICATION.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [AGAPPLICATION showInfoPopup:[AGLOCALIZATION localizedString:@"FACEBOOK_POST_SUCCEED"] ];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"FACEBOOK_POST_FAILED"] ];
    
#ifdef DEBUG
    [AGAPPLICATION showAlert:@"Facebook" message:error.localizedDescription andCancelButton:@"OK"];
#endif
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    
    // http response
    __block AGActionManager *weakSelf = self;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)downloadTask.response;
    
    if (httpResponse.statusCode == 200) {
        NSURL *fileURL = [NSURL fileURLWithPath:FILE_PATH_TEMP(downloadTask.response.suggestedFilename) ];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:nil];
        
        [progressHUD hide:YES completion:^{
            UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            controller.delegate = weakSelf;
            [controller presentPreviewAnimated:YES];
        }];
    } else {
        [progressHUD hide:YES];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    
    if (progressHUD && totalBytesExpectedToWrite > 0) {
        progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
        progressHUD.progress = (float)totalBytesWritten/totalBytesExpectedToWrite;
    }
}

@end
