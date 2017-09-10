#import "AGParser.h"
#import "DescriptorsHeader.h"
#import "AGApplicationDesc+XML.h"
#import "AGRegexRule.h"
#import "AGCustomButtonDesc.h"

@implementation AGParser

+ (AGApplicationDesc *)parse:(NSString *)xmlFilePath {
    NSError *error = nil;
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlFilePath];
    
    if (!xmlData) {
        NSLog(@"File does not exists at path: %@", xmlFilePath);
    }
    
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    [xmlData release];
    
    if (error) {
        NSLog(@"Error occur while parsing XML document: %@", [error description]);
    }
    AGApplicationDesc *appDesc = [[[AGApplicationDesc alloc] initWithXML:xmlDocument.rootElement] autorelease];
    
    [xmlDocument release];
    
    // regular expressions
    error = nil;
    NSString *jsonFilePath = [[xmlFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"stripHtmlTagsConfig.json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonFilePath];
    if (jsonData) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"Error occur while parsing JSON document: %@", [error description]);
        }
        [jsonData release];
        
        [jsonDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            appDesc.regularExpressions[key] = rules;
            [rules release];
            
            for (NSDictionary *dict in obj) {
                AGRegexRule *rule = [[AGRegexRule alloc] init];
                rule.tag = dict[@"tag"];
                rule.returnMatch = [dict[@"returnMatch"] boolValue];
                rule.replaceWith = dict[@"replaceWith"];
                [rules addObject:rule];
                [rule release];
            }
        }];
    } else {
        NSLog(@"File does not exists at path: %@", jsonFilePath);
        [jsonData release];
    }
    
    // permissions
    error = nil;
    jsonFilePath = [[xmlFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"permissions.txt"];
    jsonData = [[NSData alloc] initWithContentsOfFile:jsonFilePath];
    if (jsonData) {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"Error occur while parsing JSON document: %@", [error description]);
        }
        [jsonData release];
        
        for (NSString *key in jsonArray) {
            AGPermissions permisiion = AGPermissionWithText(key);
            if (permisiion != AGPermissionNone) {
                if (appDesc.permissions == AGPermissionNone) {
                    appDesc.permissions = permisiion;
                } else {
                    appDesc.permissions |= permisiion;
                }
            }
        }
    } else {
        NSLog(@"File does not exists at path: %@", jsonFilePath);
        [jsonData release];
    }
    
    return appDesc;
}

+ (Class)classWithName:(NSString *)name {
    NSMutableDictionary *classMapper = [[NSMutableDictionary alloc] init];
    [classMapper setObject:NSStringFromClass([AGContainerDesc class]) forKey:@"container"];
    [classMapper setObject:NSStringFromClass([AGContainerVerticalDesc class]) forKey:@"containervertical"];
    [classMapper setObject:NSStringFromClass([AGContainerHorizontalDesc class]) forKey:@"containerhorizontal"];
    [classMapper setObject:NSStringFromClass([AGContainerThumbnailsDesc class]) forKey:@"containerthumbnails"];
    [classMapper setObject:NSStringFromClass([AGContainerGridDesc class]) forKey:@"containergrid"];
    [classMapper setObject:NSStringFromClass([AGContainerAbsoluteDesc class]) forKey:@"containerabsolute"];
    [classMapper setObject:NSStringFromClass([AGTextDesc class]) forKey:@"controltext"];
    [classMapper setObject:NSStringFromClass([AGImageDesc class]) forKey:@"controlimage"];
    [classMapper setObject:NSStringFromClass([AGPinchImageDesc class]) forKey:@"controlpinchimage"];
    [classMapper setObject:NSStringFromClass([AGDataFeedHorizontalDesc class]) forKey:@"controldatafeedhorizontal"];
    [classMapper setObject:NSStringFromClass([AGDataFeedVerticalDesc class]) forKey:@"controldatafeedvertical"];
    [classMapper setObject:NSStringFromClass([AGDataFeedThumbnailsDesc class]) forKey:@"controldatafeedthumbnails"];
    [classMapper setObject:NSStringFromClass([AGDataFeedGridDesc class]) forKey:@"controldatafeedgrid"];
    [classMapper setObject:NSStringFromClass([AGDateDesc class]) forKey:@"controldate"];
    [classMapper setObject:NSStringFromClass([AGGalleryDesc class]) forKey:@"controlgallery"];
    [classMapper setObject:NSStringFromClass([AGButtonDesc class]) forKey:@"controlbutton"];
    [classMapper setObject:NSStringFromClass([AGMapDesc class]) forKey:@"controlmap"];
    [classMapper setObject:NSStringFromClass([AGTextInputDesc class]) forKey:@"controltextinput"];
    [classMapper setObject:NSStringFromClass([AGSearchInputDesc class]) forKey:@"controlsearchinput"];
    [classMapper setObject:NSStringFromClass([AGPasswordDesc class]) forKey:@"controlpassword"];
    [classMapper setObject:NSStringFromClass([AGTextAreaDesc class]) forKey:@"controltextarea"];
    [classMapper setObject:NSStringFromClass([AGCheckBoxDesc class]) forKey:@"controlcheckbox"];
    [classMapper setObject:NSStringFromClass([AGRadioButtonDesc class]) forKey:@"controlradiobutton"];
    [classMapper setObject:NSStringFromClass([AGRadioGroupHorizontalDesc class]) forKey:@"controlradiogrouphorizontal"];
    [classMapper setObject:NSStringFromClass([AGRadioGroupVerticalDesc class]) forKey:@"controlradiogroupvertical"];
    [classMapper setObject:NSStringFromClass([AGRadioGroupThumbnailsDesc class]) forKey:@"controlradiogroupthumbnails"];
    [classMapper setObject:NSStringFromClass([AGHyperlinkDesc class]) forKey:@"controlhyperlink"];
    [classMapper setObject:NSStringFromClass([AGPhotoDesc class]) forKey:@"controlphoto"];
    [classMapper setObject:NSStringFromClass([AGWebBrowserDesc class]) forKey:@"controlwebbrowser"];
    [classMapper setObject:NSStringFromClass([AGDropDownDesc class]) forKey:@"controldropdown"];
    [classMapper setObject:NSStringFromClass([AGDatePickerDesc class]) forKey:@"controldatepicker"];
    [classMapper setObject:NSStringFromClass([AGVideoDesc class]) forKey:@"controlvideo"];
    [classMapper setObject:NSStringFromClass([AGActivityIndicatorDesc class]) forKey:@"controlactivityindicator"];
    [classMapper setObject:NSStringFromClass([AGToggleButtonDesc class]) forKey:@"controltogglebutton"];
    [classMapper setObject:NSStringFromClass([AGDefaultLoadingIndicatorDesc class]) forKey:@"controlactivityindicator"];
    [classMapper setObject:NSStringFromClass([AGCodeScannerDesc class]) forKey:@"controlcodescanner"];
    [classMapper setObject:NSStringFromClass([AGSignatureDesc class]) forKey:@"controlsignature"];
    [classMapper setObject:NSStringFromClass([AGChartDesc class]) forKey:@"controlchart"];
    [classMapper setObject:NSStringFromClass([AGCustomDesc class]) forKey:@"controlcustom"];
    
    // Register custom button
    [classMapper setObject:NSStringFromClass([AGCustomButtonDesc class]) forKey:@"controlcustombutton"];
    
    Class result = NSClassFromString(classMapper[name]);
    if (!result && [name hasPrefix:@"controlcustom"]) {
        result = [AGCustomDesc class];
    }
    [classMapper release];
    
    return result;
}

@end
