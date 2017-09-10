#import <JavaScriptCore/JavaScriptCore.h>
#import "AGActionManager+Forms.h"
#import "AGLocalizationManager.h"
#import "AGSynchronizer.h"
#import "AGContainer.h"
#import "AGToggleButtonDesc.h"
#import "AGLocalStorage.h"
#import "AGFormClientProtocol.h"
#import "AGFormProtocol.h"
#import "AGPhotoDesc.h"
#import "AGPasswordDesc.h"
#import "AGSignatureDesc.h"
#import "AGApplication+Control.h"
#import "NSString+URL.h"
#import "NSString+MD5.h"
#import "NSString+SHA.h"
#import "NSString+GUID.h"

@implementation AGActionManager (Forms)

- (void)sendEmail:(id)sender :(id)object :(NSString *)address :(NSString *)controlAction :(NSString *)action :(NSString *)httpQueryParamsString :(NSString *)headerParamsString {
    // form container
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    
    // validation
    if (![self validate:controlDesc]) {
        [AGAPPLICATION.toast makeValidationToast:[AGLOCALIZATION localizedString:@"FORM_INVALID"] ];
        return;
    }
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    
    // forms
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    // uri
    address = [address URLEncodedString];
    NSString *host = [[AGLOCALIZATION localizedString:@"ALTER_API_EMAIL_HOST"] uriString];
    NSString *uri = [NSString stringWithFormat:@"%@?_email=%@", host, address];
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.httpHeaderParams = [httpHeaderParams execute:sender];
    request.httpBody = [self postDataFrom:sender withForms:forms separateForms:YES];
    request.action = @"sendEmail";
    request.postAction = action;
    request.controlsToReset = forms;
    request.sender = sender;
    [self sendRequest:request];
    [request release];
    [forms release];
}

- (void)sendForm:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)action :(NSString *)httpQueryParamsString :(NSString *)headerParamsString {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    
    // forms
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.httpHeaderParams = [httpHeaderParams execute:sender];
    request.httpBody = [self postDataFrom:sender withForms:forms];
    request.action = @"sendForm";
    request.postAction = action;
    request.controlsToReset = forms;
    request.sender = sender;
    [self sendRequest:request];
    [request release];
    [forms release];
}

- (void)sendFormV3:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)action :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)requestTransform :(NSString *)responseTransform {
    // form container
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    
    // validation
    if (![self validate:controlDesc]) {
        [AGAPPLICATION.toast makeValidationToast:[AGLOCALIZATION localizedString:@"FORM_INVALID"] ];
        return;
    }
    
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    AGHTTPBodyParams *httpBodyParams = [AGHTTPBodyParams paramsWithJSONString:bodyParamsString ];
    
    // forms
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpMethod = httpMethod;
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.httpHeaderParams = [httpHeaderParams execute:sender];
    request.httpBody = [self postDataFrom:sender withForms:forms andHttpBodyParams:[httpBodyParams execute:sender] usingTransform:requestTransform];
    request.action = @"sendFormV3";
    request.postAction = action;
    request.controlsToReset = forms;
    request.responseTransform = responseTransform;
    request.sender = sender;
    [self sendRequest:request];
    [request release];
    [forms release];
}

- (void)sendAsyncForm:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)httpQueryParamsString :(NSString *)headerParamsString {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    
    // forms
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    if (forms.count > 1) {
        [forms removeObjectsInRange:NSMakeRange(1, forms.count-1)];
    }
    AGControlDesc<AGFormClientProtocol> *formControlDesc = forms.firstObject;
    
    // synchronizer request
    AGSynchronizerRequest *synchronizerRequest = [[AGSynchronizerRequest alloc] init];
    synchronizerRequest.uri = uri;
    synchronizerRequest.key = formControlDesc.form.formId.value;
    synchronizerRequest.value = formControlDesc.form.value;
    synchronizerRequest.httpQueryParams = [httpQueryParams execute:sender];
    synchronizerRequest.httpHeaderParams = [httpHeaderParams execute:sender];
    synchronizerRequest.httpBody = [self postDataFrom:sender withForms:forms];
    [AGSYNCHRONIZER addRequest:synchronizerRequest];
    [synchronizerRequest release];
    [forms release];
}

- (void)sendAsyncFormV3:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)requestTransform :(NSString *)responseTransform {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    AGHTTPBodyParams *httpBodyParams = [AGHTTPBodyParams paramsWithJSONString:bodyParamsString ];
    
    // forms
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    // key and value
    NSString *key = nil;
    NSString *value = nil;
    if ([controlDesc isKindOfClass:[AGToggleButtonDesc class]]) {
        key = ((AGControlDesc<AGFormClientProtocol> *)controlDesc).form.formId.value;
        value = ((AGControlDesc<AGFormClientProtocol> *)controlDesc).form.value;
    }
    
    // synchronizer request
    AGSynchronizerRequest *synchronizerRequest = [[AGSynchronizerRequest alloc] init];
    synchronizerRequest.uri = uri;
    synchronizerRequest.key = key;
    synchronizerRequest.value = value;
    synchronizerRequest.httpMethod = httpMethod;
    synchronizerRequest.httpQueryParams = [httpQueryParams execute:sender];
    synchronizerRequest.httpHeaderParams = [httpHeaderParams execute:sender];
    synchronizerRequest.httpBody = [self postDataFrom:sender withForms:forms andHttpBodyParams:[httpBodyParams execute:sender] usingTransform:requestTransform];
    synchronizerRequest.responseTransform = responseTransform;
    [AGSYNCHRONIZER addRequest:synchronizerRequest];
    [synchronizerRequest release];
    [forms release];
}

- (void)saveFormToLocalDB:(id)sender :(id)object :(NSString *)controlAction :(NSString *)tableName :(NSString *)operation :(NSString *)paramsString :(NSString *)matchString :(NSString *)action {
    // form container
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    
    // validation
    if (![self validate:controlDesc]) {
        [AGAPPLICATION.toast makeValidationToast:[AGLOCALIZATION localizedString:@"FORM_INVALID"] ];
        return;
    }
    
    // operation
    operation = [operation lowercaseString];
    
    // params
    AGParams *params = [AGParams paramsWithJSONString:paramsString ];
    
    // forms
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    // values
    NSMutableDictionary *values = [self storageParametersWithForms:forms];
    [values addEntriesFromDictionary:[params execute:sender] ];
    
    // match
    JSValue *matchFunction = nil;
    {
        // context
        JSContext *context = [[[JSContext alloc] init] autorelease];
        context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"%@\n", exception);
        };
        
        // script
        NSString *script = [NSString stringWithFormat:@"function match(item, input){%@}", matchString];
        [context evaluateScript:script];
        
        // match function
        matchFunction = [context objectForKeyedSubscript:@"match"];
    }
    
    // create
    if ([operation isEqualToString:@"create"]) {
        [AGLOCALSTORAGE insert:tableName values:values completion:nil];
    }
    // update
    else if ([operation isEqualToString:@"update"]) {
        [AGLOCALSTORAGE update:tableName values:values by:^BOOL (NSDictionary *item, NSDictionary *input) {
            if (matchString.length > 0) {
                return [matchFunction callWithArguments:@[item, input] ].toBool;
            }
            
            return YES;
        } completion:nil];
    }
    // delete
    else if ([operation isEqualToString:@"delete"]) {
        [AGLOCALSTORAGE delete:tableName values:values by:^BOOL (NSDictionary *item, NSDictionary *input) {
            if (matchString.length > 0) {
                return [matchFunction callWithArguments:@[item, input] ].toBool;
            }
            
            return YES;
        } completion:nil];
    }
    
    // reset controls
    [self resetControls:forms ];
    
    // post action
    [self executeString:action withSender:sender];
    
    // clean
    [forms release];
}

- (NSMutableDictionary *)storageParametersWithForms:(NSArray *)forms {
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (AGControlDesc<AGFormClientProtocol> *form in forms) {
        parameters[form.form.formId.value] = [self formStorageValue:form];
    }
    
    return parameters;
}

- (id)formStorageValue:(AGControlDesc<AGFormClientProtocol> *)form {
    if (!form.form.value) return nil;
    
    if ([form isKindOfClass:[AGPhotoDesc class]]) {
        return [NSURL fileURLWithPath:form.form.value];
    } else if ([form isKindOfClass:[AGPasswordDesc class]]) {
        AGPasswordDesc *passwordForm = (AGPasswordDesc *)form;
        if (passwordForm.encryptionType == encryptionMD5) {
            return [form.form.value md5];
        } else if (passwordForm.encryptionType == encryptionSHA1) {
            return [form.form.value sha1];
        } else {
            return form.form.value;
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
            
            NSString *fileName = [NSString stringWithFormat:@"%@.png", [NSString stringWithGUID]];
            NSString *filePath = FILE_PATH_TEMP(fileName);
            NSData *data = UIImagePNGRepresentation(image);
            [data writeToFile:filePath atomically:YES];
            
            return [NSURL fileURLWithPath:filePath];
        } else {
            return nil;
        }
    }
    
    return form.form.value;
}

@end
