#import "AGJSForm.h"
#import "AGActionManager.h"
#import "AGActionManager+Forms.h"

@implementation AGJSForm

- (void)send:(NSDictionary *)request :(NSString *)controlId :(NSNumber *)async :(JSValue *)successCallback :(JSValue *)failureCallback {
    if (async) {
        [AGACTIONMANAGER sendAsyncFormV3:nil
                                        :nil
                                        :request[@"url"]
                                        :controlId
                                        :[AGACTIONMANAGER paramsJsonString:request[@"params"]]
                                        :[AGACTIONMANAGER paramsJsonString:request[@"headers"]]
                                        :[AGACTIONMANAGER paramsJsonString:request[@"body"]]
                                        :request[@"method"]
                                        :request[@"requestTransform"]
                                        :request[@"responseTransform"]];
    } else {
        
    }
}

@end
