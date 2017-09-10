#import "AGActionManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MBProgressHUD/MBProgressHUD+Hide.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/message.h>
#import "AGJSApplication.h"
#import "AGJSUtil.h"
#import "AGJSCustom.h"
#import "AGScriptParser.h"
#import "AGServicesManager.h"
#import "AGLocalizationManager.h"
#import "AGReachability.h"
#import "AGAlterApiResponse.h"
#import "AGPhotoDesc.h"
#import "AGPasswordDesc.h"
#import "AGSignatureDesc.h"
#import "AGFormProtocol.h"
#import "AGCompoundButtonDesc.h"
#import "AGApplication+Control.h"
#import "AGApplication+Authentication.h"
#import "AGApplication+Popup.h"
#import "AGActionManager+Actions.h"
#import "AGActionManager+Navigation.h"
#import "AGActionManager+Forms.h"
#import "AGActionManager+Authorization.h"
#import "AGActionManager+Controls.h"
#import "AGActionManager+Localization.h"
#import "AGActionManager+External.h"
#import "AGActionManager+Logic.h"
#import "AGActionManager+Text.h"
#import "NSObject+Nil.h"
#import "NSString+URL.h"
#import "NSData+Base64.h"
#import "NSURLRequest+HTTP.h"
#import "NSString+MD5.h"
#import "NSString+SHA.h"
#import <JSONQuery/NSData+JQ.h>

@interface AGActionManager (){
    AGJSApplication *jsApplication;
    AGJSUtil *jsUtil;
    AGJSCustom *jsCustom;
}
@end

@implementation AGActionManager

SINGLETON_IMPLEMENTATION(AGActionManager)

#pragma mark - Initialization

- (void)dealloc {
    [jsApplication release];
    [jsUtil release];
    [jsCustom release];
    [session release];
    [dateFormatterRFC3339 release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    // js application
    jsApplication = [[AGJSApplication alloc] init];
    
    // js utils
    jsUtil = [[AGJSUtil alloc] init];
    
    // js custom
    jsCustom = [[AGJSCustom alloc] init];
    
    // date formatter
    dateFormatterRFC3339 = [[NSDateFormatter alloc] init];
    dateFormatterRFC3339.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatterRFC3339.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatterRFC3339.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    
    // session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;
    
    // session
    session = [[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]] retain];
    
    return self;
}

#pragma mark - Lifecycle

- (id)executeString:(NSString *)string withSender:(AGDesc *)sender {
    id result = nil;
    
    if (isNotEmpty(string) ) {
        if ([string hasPrefix:@"[d]"] && [string hasSuffix:@"[/d]"]) {
            AGScriptParser *parser = [[AGScriptParser alloc] initWithString:string];
            result = [parser parseUsingBlock:^id (id target, NSString *method, NSArray *attributes){
                return [self invokeMethod:method onObject:target withAttributes:attributes andSender:sender];
            }];
            [parser release];
        } else if ([string hasPrefix:@"[js]"] && [string hasSuffix:@"[/js]"]) {
            NSString *script = [string substringWithRange:NSMakeRange(4, string.length-9) ];
            
            JSContext *context = [[[JSContext alloc] init] autorelease];
            context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
                NSLog(@"%@\n", exception);
            };
            context[@"app"] = jsApplication;
            context[@"util"] = jsUtil;
            context[@"custom"] = jsCustom;
            
            if ([sender isKindOfClass:[AGControlDesc class]]) {
                AGControlDesc *controlDesc = (AGControlDesc *)sender;
                context[@"sender"] = [[[AGJSControl alloc] initWithControlDesc:controlDesc] autorelease];
                script = [NSString stringWithFormat:@"(function(app,util,custom){%@}).call(sender,app,util,custom)", script];
            }

            
            return [[context evaluateScript:script] toObject];
        } else {
            result = string;
        }
    }
    
    return result;
}

- (void)executeVariable:(AGVariable *)variable withSender:(AGDesc *)sender {
    if (!variable) return;
    
    id value = [self executeString:variable.text withSender:sender];
    
    variable.value = value ? value : @"";
}

- (void)executeAction:(AGAction *)action withSender:(AGDesc *)sender {
    if (!action) return;
    
    [self executeString:action.text withSender:sender];
}

- (id)invokeMethod:(NSString *)method onObject:(id)object withAttributes:(NSArray *)attributes andSender:(AGDesc *)sender {
    NSMutableString *signature = [NSMutableString stringWithString:method];
    [signature appendString:@"::"];
    for (int i = 0; i < attributes.count; ++i) {
        [signature appendString:@":"];
    }
    
    SEL selector = NSSelectorFromString(signature);
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    
    if ([method isEqualToString:@"merge"]) {
        return [self merge:sender :object :attributes];
    } else if (methodSignature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = selector;
        invocation.target = self;
        
        [invocation setArgument:&sender atIndex:2];
        [invocation setArgument:&object atIndex:3];
        
        for (int i = 0; i < attributes.count; ++i) {
            id arg = attributes[i];
            
            if (arg == [NSNull null]) {
                arg = nil;
            }
            
            [invocation setArgument:&arg atIndex:4+i];
        }
        
        [invocation invoke];
        
        if (methodSignature.methodReturnLength) {
            id returnValue = nil;
            [invocation getReturnValue:&returnValue];
            return returnValue;
        }
    } else {
        NSLog(@"Unknown action");
    }
    
    return nil;
}

- (void)resetControls:(NSArray *)controls {
    for (AGControlDesc *controlDesc in controls) {
        AGControl<AGFormProtocol> *control = (AGControl<AGFormProtocol> *)[AGAPPLICATION getControl:controlDesc.identifier];
        if ([control conformsToProtocol:@protocol(AGFormProtocol)]) {
            [controlDesc executeVariables];
            [controlDesc update];
            [control reset];
        }
    }
}

- (BOOL)validate:(AGControlDesc *)controlDesc {
    BOOL isValid = YES;
    
    // validate descriptors
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    for (AGControlDesc<AGFormClientProtocol> *controlDesc in forms) {
        if (![controlDesc.form validate:controlDesc.form.value]) {
            isValid = NO;
        }
    }
    [forms release];
    
    // validate controls
    AGControl *control = [AGAPPLICATION getControl:controlDesc.identifier];
    NSMutableArray *controls = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControls:control withArray:controls];
    
    for (AGControl *control in controls) {
        [control validate];
    }
    [controls release];
    
    return isValid;
}

- (NSData *)postDataFrom:(AGControlDesc *)sender withForms:(NSArray *)forms separateForms:(BOOL)separate {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    json[@"items"] = [NSMutableArray array];
    
    NSMutableDictionary *noAlterApiItem = [NSMutableDictionary dictionary];
    noAlterApiItem[@"alterapicontext"] = AGAPPLICATION.alterApiContext ? AGAPPLICATION.alterApiContext : [NSNull null];
    if (separate) {
        noAlterApiItem[@"form"] = [NSMutableArray array];
    } else {
        noAlterApiItem[@"form"] = [NSMutableDictionary dictionary];
    }
    [json[@"items"] addObject:noAlterApiItem];
    
    id<AGFeedClientProtocol> prevFeed = nil;
    NSInteger prevItemIndex = 0;
    for (AGControlDesc<AGFormClientProtocol> *form in forms) {
        id<AGFeedClientProtocol> feed = [AGAPPLICATION getControlFeedParent:form];
        if (feed) {
            AGDSFeedItem *feedItemDataSource = feed.feed.dataSource.items[form.itemIndex];
            NSString *alterApiContext = feedItemDataSource.alterApiContext ? feedItemDataSource.alterApiContext : @"";
            NSInteger itemIndex = form.itemIndex;
            if (prevFeed != feed) {
                NSMutableDictionary *feedItem = [NSMutableDictionary dictionary];
                feedItem[@"alterapicontext"] = alterApiContext;
                if (separate) {
                    feedItem[@"form"] = [NSMutableArray array];
                } else {
                    feedItem[@"form"] = [NSMutableDictionary dictionary];
                }
                [json[@"items"] addObject:feedItem];
                prevFeed = feed;
                prevItemIndex = itemIndex;
            } else {
                if (prevItemIndex != itemIndex) {
                    NSMutableDictionary *feedItem = [NSMutableDictionary dictionary];
                    feedItem[@"alterapicontext"] = alterApiContext;
                    if (separate) {
                        feedItem[@"form"] = [NSMutableArray array];
                    } else {
                        feedItem[@"form"] = [NSMutableDictionary dictionary];
                    }
                    [json[@"items"] addObject:feedItem];
                    prevItemIndex = itemIndex;
                }
            }
            
            NSMutableDictionary *feedItem = [json[@"items"] lastObject];
            if (separate) {
                NSMutableDictionary *formItem = [NSMutableDictionary dictionary];
                formItem[form.form.formId.value] = [self formJSONValue:form];
                [feedItem[@"form"] addObject:formItem];
            } else {
                feedItem[@"form"][form.form.formId.value] = [self formJSONValue:form];
            }
        } else {
            if (separate) {
                NSMutableDictionary *formItem = [NSMutableDictionary dictionary];
                formItem[form.form.formId.value] = [self formJSONValue:form];
                [noAlterApiItem[@"form"] addObject:formItem];
            } else {
                noAlterApiItem[@"form"][form.form.formId.value] = [self formJSONValue:form];
            }
        }
    }
    
    // empty form inside feed
    if ([sender isKindOfClass:[AGControlDesc class]] && forms.count == 0) {
        id<AGFeedClientProtocol> feed = [AGAPPLICATION getControlFeedParent:sender];
        if (feed) {
            AGDSFeedItem *feedItemDataSource = feed.feed.dataSource.items[sender.itemIndex];
            NSString *alterApiContext = feedItemDataSource.alterApiContext ? feedItemDataSource.alterApiContext : @"";
            NSMutableDictionary *feedItem = [NSMutableDictionary dictionary];
            feedItem[@"alterapicontext"] = alterApiContext;
            if (separate) {
                feedItem[@"form"] = [NSMutableArray array];
            } else {
                feedItem[@"form"] = [NSMutableDictionary dictionary];
            }
            [json[@"items"] addObject:feedItem];
        }
    }
    
    // debug
    NSLog(@"%@", [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] autorelease]);
    
    return [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)postDataFrom:(AGControlDesc *)sender withForms:(NSArray *)forms {
    return [self postDataFrom:sender withForms:forms separateForms:NO];
}

- (NSData *)postDataFrom:(AGControlDesc *)sender withForms:(NSArray *)forms andHttpBodyParams:(NSDictionary *)httpBodyParams usingTransform:(NSString *)requestTransform {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    json[@"form"] = [NSMutableDictionary dictionary];
    json[@"params"] = httpBodyParams;
    
    // sender feed
    id<AGFeedClientProtocol> senderFeed = [AGAPPLICATION getControlFeedParent:sender];
    
    // forms
    if (senderFeed) {
        AGDSFeedItem *feedItemDataSource = senderFeed.feed.dataSource.items[sender.itemIndex];
        
        if (feedItemDataSource.guid) {
            json[@"form"][@"id"] = feedItemDataSource.guid;
        }
        
        for (AGControlDesc<AGFormClientProtocol> *form in forms) {
            json[@"form"][form.form.formId.value] = [self formJSONValue:form];
        }
    } else {
        if (AGAPPLICATION.guidContext) {
            json[@"form"][@"id"] = AGAPPLICATION.guidContext;
        }
        
        id<AGFeedClientProtocol> prevFeed = nil;
        
        for (AGControlDesc<AGFormClientProtocol> *form in forms) {
            id<AGFeedClientProtocol> feed = [AGAPPLICATION getControlFeedParent:form];
            if (feed) {
                if (prevFeed != feed) {
                    json[@"form"][feed.feed.formId.value] = [NSMutableArray array];
                    
                    for (int i = 0; i < feed.feed.dataSource.items.count; ++i) {
                        AGDSFeedItem *feedItemDataSource = feed.feed.dataSource.items[i];
                        [json[@"form"][feed.feed.formId.value] addObject:[NSMutableDictionary dictionary] ];
                        
                        if (feedItemDataSource.guid) {
                            json[@"form"][feed.feed.formId.value][i][@"id"] = feedItemDataSource.guid;
                        }
                    }
                    
                    prevFeed = feed;
                }
                
                json[@"form"][feed.feed.formId.value][form.itemIndex][form.form.formId.value] = [self formJSONValue:form];
            } else {
                json[@"form"][form.form.formId.value] = [self formJSONValue:form];
            }
        }
    }
    
    // transform
    if (isNotEmpty(requestTransform) ) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        NSLog(@"forms json before transform:\n%@\n", [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] autorelease]);
        
        NSData *transformedJsonData = [jsonData jq:requestTransform];
        if (transformedJsonData) {
            NSLog(@"forms json after transform:\n%@\n", [[[NSString alloc] initWithData:transformedJsonData encoding:NSUTF8StringEncoding] autorelease]);
            return transformedJsonData;
        }
    }
    
    // debug
    NSLog(@"%@", [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] autorelease]);
    
    return [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
}

- (id)formJSONValue:(AGControlDesc<AGFormClientProtocol> *)form {
    id result = [NSNull null];
    
    if (form.form.value) {
        if ([form isKindOfClass:[AGPhotoDesc class]]) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:form.form.value];
            result = [data base64EncodedString];
            [data release];
        } else if ([form isKindOfClass:[AGPasswordDesc class]]) {
            AGPasswordDesc *passwordForm = (AGPasswordDesc *)form;
            if (passwordForm.encryptionType == encryptionMD5) {
                result = [form.form.value md5];
            } else if (passwordForm.encryptionType == encryptionSHA1) {
                result = [form.form.value sha1];
            } else {
                result = form.form.value;
            }
        } else if ([form isKindOfClass:[AGSignatureDesc class]]) {
            UIBezierPath *path = form.form.value;
            
            if (!path.isEmpty) {
                AGSignatureDesc *desc = (AGSignatureDesc *)form;
                
                UIColor *strokeColor = [UIColor colorWithRed:desc.strokeColor.r green:desc.strokeColor.g blue:desc.strokeColor.b alpha:desc.strokeColor.a];
                
                UIGraphicsBeginImageContext(CGSizeMake(desc.viewportWidth, desc.viewportHeight) );
                [strokeColor setStroke];
                [path stroke];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSData *data = UIImagePNGRepresentation(image);
                result = [data base64EncodedString];
            }
        } else {
            result = form.form.value;
        }
    }
    
    return result;
}

- (NSString *)formStringValue:(AGControlDesc<AGFormClientProtocol> *)form {
    NSString *result = @"";
    
    if (form.form.value) {
        if ([form isKindOfClass:[AGPhotoDesc class]]) {
            /*NSData* data = [[NSData alloc] initWithContentsOfFile:form.form.value];
             result = [data base64EncodedString];
             [data release];*/
        } else if ([form isKindOfClass:[AGPasswordDesc class]]) {
            AGPasswordDesc *passwordForm = (AGPasswordDesc *)form;
            if (passwordForm.encryptionType == encryptionMD5) {
                result = [form.form.value md5];
            } else if (passwordForm.encryptionType == encryptionSHA1) {
                result = [form.form.value sha1];
            } else {
                result = form.form.value;
            }
        } else if ([form isKindOfClass:[AGSignatureDesc class]]) {
            /*AGSignatureDesc* desc = (AGSignatureDesc*)form;
             
             UIColor* strokeColor = [UIColor colorWithRed:desc.strokeColor.r green:desc.strokeColor.g blue:desc.strokeColor.b alpha:desc.strokeColor.a];
             UIBezierPath* path = [[form.form.value copy] autorelease];
             
             UIGraphicsBeginImageContext( CGSizeMake(desc.viewportWidth, desc.viewportHeight) );
             [strokeColor setStroke];
             [path stroke];
             UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             
             NSData* data = UIImagePNGRepresentation(image);
             result = [data base64EncodedString];*/
        } else if ([form isKindOfClass:[AGCompoundButtonDesc class]]) {
            result = [form.form.value boolValue] ? @"true" : @"false";
        } else {
            result = form.form.value;
        }
    }
    
    return result;
}

- (NSMutableDictionary *)postParametersWithForms:(NSArray *)forms {
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (AGControlDesc<AGFormClientProtocol> *form in forms) {
        [parameters setObject:[self formStringValue:form] forKey:form.form.formId.value];
    }
    
    return parameters;
}

- (NSData *)postDataFrom:(AGControlDesc *)sender withJSON:(NSDictionary *)json usingTransform:(NSString *)requestTransform {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    
    // transform
    if (isNotEmpty(requestTransform) ) {
        NSLog(@"json before transform:\n%@\n", [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] autorelease]);
        
        NSData *transformedJsonData = [jsonData jq:requestTransform];
        if (transformedJsonData) {
            NSLog(@"json after transform:\n%@\n", [[[NSString alloc] initWithData:transformedJsonData encoding:NSUTF8StringEncoding] autorelease]);
            return transformedJsonData;
        }
    }
    
    return jsonData;
}

- (NSString *)paramsJsonString:(NSDictionary *)request {
    NSDictionary *params = request[@"params"];
    NSMutableArray *result = [NSMutableArray array];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result addObject:@{@"paramName": key, @"paramValue": obj}];
    }];
    
    return [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:0 error:nil] encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark - Request

- (void)sendRequest:(AGActionManagerRequest *)actionManagerRequest {
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    if (!progressHUD) {
        progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
    }
    
    // action
    NSString *action = actionManagerRequest.action;
    
    // url
    NSURL *url = [NSURL URLWithString:actionManagerRequest.uri];
    
    // check internet connection
    if (![action isEqualToString:@"logout"] && [AGReachability sharedInstance].reachability.currentReachabilityStatus == NotReachable) {
        if (progressHUD) {
            [progressHUD hide:YES completion:^{
                [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_NO_CONNECTION"] ];
            }];
        } else {
            [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_NO_CONNECTION"] ];
        }
        
        return;
    }
    
    // request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = actionManagerRequest.httpMethod;
    request.timeoutInterval = AG_TIME_OUT;
    
    // http query params
    [request setURLQuery:actionManagerRequest.httpQueryParams];
    
    // http header params
    [request addHTTPHeaders:actionManagerRequest.httpHeaderParams];
    
    // http body
    if (![request.HTTPMethod isEqualToString:@"GET"]) {
        request.HTTPBody = actionManagerRequest.httpBody;
    }
    
    // content-type
    if (!request.allHTTPHeaderFields[@"Content-Type"] && !request.allHTTPHeaderFields[@"content-type"]) {
        if (isNotEmpty(actionManagerRequest.contentType) ) {
            [request addValue:actionManagerRequest.contentType forHTTPHeaderField:@"Content-Type"];
        } else {
            if ([action isEqualToString:@"sendEmail"] || [action isEqualToString:@"sendForm"] || [action isEqualToString:@"sendFormV3"]) {
                [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            } else {
                [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            }
        }
    }
    
    // user agent
    [request addValue:AGAPPLICATION.descriptor.defaultUserAgent forHTTPHeaderField:@"User-Agent"];
    
    // kinetise headers
    [[AGServicesManager sharedInstance].kinetiseHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    
    // session
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self processResponse:(NSHTTPURLResponse *)response withData:data error:error andRequest:actionManagerRequest];
    }] resume];
}

#pragma mark - Response

- (void)processResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError *)error andRequest:(AGActionManagerRequest *)request {
    NSLog(@"Response code: %zd", response.statusCode);
    
    // transform response
    if (isNotEmpty(request.responseTransform) ) {
        NSData *transformedData = [data jq:request.responseTransform];
        if (transformedData) {
            data = transformedData;
        }
    }
    
    // parse alter api response
    NSError *parserError = nil;
    AGAlterApiResponse *responseObject = [AGAlterApiResponse responseWithData:data error:&parserError];
    
    // parsing error
    if (parserError) {
        NSLog(@"Error: %@", parserError.localizedDescription);
    }
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    [progressHUD hide:YES];
    
    BOOL isAlterApiResponse = NO;
    BOOL isCorrectAlterApiResponse = NO;
    
    // basic auth login
    if ([request.action isEqualToString:@"basicAuthLogin"]) {
        if (response.statusCode) {
            if (response.statusCode >= 200 && response.statusCode < 400) {
                [AGAPPLICATION loginWithBasicAuthSessionId:request.httpHeaderParams[@"Authorization"] ];
                
                // reset controls
                [self resetControls:request.controlsToReset ];
                
                // post action
                [self executeString:request.postAction withSender:request.sender];
            } else if (response.statusCode == 401) {
                [self showErrorPopup:request.action];
            } else {
                [self showHttpErrorPopup:request.action withStatusCode:response.statusCode];
            }
        } else {
            [self showError:error forRequest:request];
        }
        
        return;
    }
    
    // logout
    if ([request.action isEqualToString:@"logout"]) {
        if (!error && responseObject.isAlterApiResponse) {
            // messages
            if (responseObject.messages) {
                for (NSString *message in responseObject.messages) {
                    if (response.statusCode >= 200 && response.statusCode < 400) {
                        [AGAPPLICATION showInfoPopup:message];
                    } else {
                        [AGAPPLICATION showErrorPopup:message];
                    }
                }
            } else {
                if (responseObject.messageDescription) {
                    if (responseObject.messageTitle) {
                        [AGAPPLICATION showAlert:responseObject.messageTitle message:responseObject.messageDescription];
                    } else {
                        if (response.statusCode >= 200 && response.statusCode < 400) {
                            [AGAPPLICATION showInfoPopup:responseObject.messageDescription];
                        } else {
                            [AGAPPLICATION showErrorPopup:responseObject.messageDescription];
                        }
                    }
                }
            }
            
            // expired links
            for (NSString *expiredUri in responseObject.expiredUrls) {
                NSURL *url = [NSURL URLWithString:expiredUri];
                [[AGServicesManager sharedInstance] markURLs:url asExpired:YES];
            }
            
            // application variables
            [responseObject.applicationVariables enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
                [self setLocalValue:nil :nil :key :value];
            }];
        }
        
        // clear session and logout
        if (request.postScreen) {
            [AGAPPLICATION logout:request.postScreen];
        } else {
            [AGAPPLICATION logout];
        }
        
        return;
    }
    
    // alter api
    if (response.statusCode) {
        if ( (response.statusCode >= 200 && response.statusCode <= 400) || response.statusCode == 403) {
            if (!error && responseObject.isAlterApiResponse) {
                isAlterApiResponse = YES;
                
                if (response.statusCode >= 200 && response.statusCode < 400) {
                    isCorrectAlterApiResponse = YES;
                    
                    if ([request.action isEqualToString:@"login"] || [request.action isEqualToString:@"facebookLogin"] || [request.action isEqualToString:@"linkedinLogin"] || [request.action isEqualToString:@"salesforceLogin"] || [request.action isEqualToString:@"googleLogin"]) {
                        if (!responseObject.sessionId) {
                            isCorrectAlterApiResponse = NO;
                        }
                    }
                }
            }
        }
        
        if (isAlterApiResponse) {
            // messages
            if (responseObject.messages) {
                for (NSString *message in responseObject.messages) {
                    if (response.statusCode >= 200 && response.statusCode < 400) {
                        [AGAPPLICATION showInfoPopup:message];
                    } else {
                        [AGAPPLICATION showErrorPopup:message];
                    }
                }
            } else {
                if (responseObject.messageDescription) {
                    if (responseObject.messageTitle) {
                        [AGAPPLICATION showAlert:responseObject.messageTitle message:responseObject.messageDescription];
                    } else {
                        if (response.statusCode >= 200 && response.statusCode < 400) {
                            [AGAPPLICATION showInfoPopup:responseObject.messageDescription];
                        } else {
                            [AGAPPLICATION showErrorPopup:responseObject.messageDescription];
                        }
                    }
                }
            }
            
            // expired links
            for (NSString *expiredUri in responseObject.expiredUrls) {
                NSURL *url = [NSURL URLWithString:expiredUri];
                [[AGServicesManager sharedInstance] markURLs:url asExpired:YES];
            }
            
            // application variables
            [responseObject.applicationVariables enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
                [self setLocalValue:nil :nil :key :value];
            }];
            
            // invalid session
            if (response.statusCode == 403) {
                if (responseObject.messages.count == 0 && !responseObject.messageTitle && !responseObject.messageDescription) {
                    [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_INVALID_SESSION"] ];
                }
                [AGAPPLICATION logout];
            } else if (response.statusCode == 400) {
                if (responseObject.messages.count == 0 && !responseObject.messageTitle && !responseObject.messageDescription) {
                    [self showErrorPopup:request.action];
                }
            } else if (!isCorrectAlterApiResponse) {
                if (responseObject.messages.count == 0 && !responseObject.messageTitle && !responseObject.messageDescription) {
                    [self showErrorPopup:request.action];
                }
            }
        } else {
            if (response.statusCode >= 200 && response.statusCode < 400) {
                [self showErrorPopup:request.action];
            } else {
                [self showHttpErrorPopup:request.action withStatusCode:response.statusCode];
            }
        }
        
        if (isCorrectAlterApiResponse) {
            // execute function
            if ([request.action isEqualToString:@"login"] || [request.action isEqualToString:@"facebookLogin"] || [request.action isEqualToString:@"linkedinLogin"] || [request.action isEqualToString:@"salesforceLogin"] || [request.action isEqualToString:@"googleLogin"]) {
                [AGAPPLICATION loginWithSessionId:responseObject.sessionId ];
            } else if ([request.action isEqualToString:@"sendForm"] || [request.action isEqualToString:@"sendFormV3"]) {
                if (responseObject.sessionId) {
                    [AGAPPLICATION loginOrUpdateWithSessionId:responseObject.sessionId ];
                }
            }
        }
        
        if (isCorrectAlterApiResponse) {
            // reset controls
            [self resetControls:request.controlsToReset ];
            
            // post action
            [self executeString:request.postAction withSender:request.sender];
        }
    } else {
        if (![request.action isEqualToString:@"logout"]) {
            [self showError:error forRequest:request];
        }
    }
}

- (void)showError:(NSError *)error forRequest:(AGActionManagerRequest *)request {
    if (error.code == NSURLErrorTimedOut) {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_CONNECTION_TIMEOUT"] ];
    } else if (error.code == NSURLErrorCannotFindHost) {
        NSString *host = [request.uri URLHost];
        NSString *message = [NSString stringWithFormat:@"%@%@", [AGLOCALIZATION localizedString:@"ERROR_COULD_NOT_RESOLVE_DOMAIN_NAME"], host];
        [AGAPPLICATION showErrorPopup:message ];
    } else {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_CONNECTION"] ];
    }
}

- (void)showHttpErrorPopup:(NSString *)action withStatusCode:(NSInteger)responseStatusCode {
    [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedHttpError:responseStatusCode] ];
}

- (void)showErrorPopup:(NSString *)action {
    if ([action isEqualToString:@"sendForm"] || [action isEqualToString:@"sendFormV3"]) {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_SEND_FORM"] ];
    } else if ([action isEqualToString:@"sendEmail"]) {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_SEND_EMAIL"] ];
    } else if ([action isEqualToString:@"login"] || [action isEqualToString:@"facebookLogin"] || [action isEqualToString:@"linkedinLogin"] || [action isEqualToString:@"basicAuthLogin"] || [action isEqualToString:@"salesforceLogin"] || [action isEqualToString:@"googleLogin"]) {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
    } else if ([action isEqualToString:@"logout"]) {
        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGOUT"] ];
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

@end
