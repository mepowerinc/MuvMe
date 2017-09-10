#import "NSObject+Singleton.h"
#import "AGActionManagerRequest.h"
#import "AGControlDesc.h"
#import "AGDesc.h"
#import "AGVariable.h"
#import "AGAction.h"

#define AGACTIONMANAGER [AGActionManager sharedInstance]

@interface AGActionManager : NSObject {
    NSURLSession *session;
    NSDateFormatter *dateFormatterRFC3339;
}

SINGLETON_INTERFACE(AGActionManager)

- (NSMutableDictionary *)postParametersWithForms:(NSArray *)forms;
- (NSData *)postDataFrom:(AGControlDesc *)control withForms:(NSArray *)forms;
- (NSData *)postDataFrom:(AGControlDesc *)control withForms:(NSArray *)forms separateForms:(BOOL)separate;
- (NSData *)postDataFrom:(AGControlDesc *)sender withForms:(NSArray *)forms andHttpBodyParams:(NSDictionary *)httpBodyParams usingTransform:(NSString *)requestTransform;
- (NSData *)postDataFrom:(AGControlDesc *)sender withJSON:(NSDictionary *)json usingTransform:(NSString *)requestTransform;
- (void)sendRequest:(AGActionManagerRequest *)actionManagerRequest;
- (void)resetControls:(NSArray *)controls;
- (BOOL)validate:(AGControlDesc *)controlDesc;
- (NSString *)paramsJsonString:(NSDictionary *)request;

- (id)executeString:(NSString *)string withSender:(AGDesc *)sender;
- (void)executeVariable:(AGVariable *)variable withSender:(AGDesc *)sender;
- (void)executeAction:(AGAction *)action withSender:(AGDesc *)sender;

@end
