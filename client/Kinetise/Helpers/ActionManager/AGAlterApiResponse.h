#import "AGJSONProtocol.h"
#import "AGXMLProtocol.h"

@interface AGAlterApiResponse : NSObject <AGJSONProtocol, AGXMLProtocol>

@property(nonatomic, readonly) BOOL isAlterApiResponse;
@property(nonatomic, readonly) NSString *sessionId;
@property(nonatomic, readonly) NSString *messageTitle;
@property(nonatomic, readonly) NSString *messageDescription;
@property(nonatomic, readonly) NSArray *messages;
@property(nonatomic, readonly) NSArray *expiredUrls;
@property(nonatomic, readonly) NSDictionary *applicationVariables;

+ (AGAlterApiResponse *)responseWithData:(NSData *)data error:(NSError * *)error;

@end
