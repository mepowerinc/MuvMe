#import "AGAlterApiResponse.h"
#import "NSString+UriEncoding.h"

@interface AGAlterApiResponse ()
@property(nonatomic, assign) BOOL isAlterApiResponse;
@property(nonatomic, copy) NSString *sessionId;
@property(nonatomic, copy) NSString *messageTitle;
@property(nonatomic, copy) NSString *messageDescription;
@property(nonatomic, retain) NSArray *messages;
@property(nonatomic, retain) NSArray *expiredUrls;
@property(nonatomic, retain) NSDictionary *applicationVariables;
@end

@implementation AGAlterApiResponse

@synthesize isAlterApiResponse;
@synthesize sessionId;
@synthesize messageTitle;
@synthesize messageDescription;
@synthesize messages;
@synthesize expiredUrls;
@synthesize applicationVariables;

#pragma mark - Initialization

- (void)dealloc {
    self.sessionId = nil;
    self.messageTitle = nil;
    self.messageDescription = nil;
    self.messages = nil;
    self.expiredUrls = nil;
    self.applicationVariables = nil;
    [super dealloc];
}

+ (AGAlterApiResponse *)responseWithData:(NSData *)data error:(NSError * *)error {
    AGAlterApiResponse *responseObject = nil;
    
    // try parse json
    {
        NSData *jsonData = data;
        
        if (jsonData.length == 0) {
            jsonData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
        if (json) {
            responseObject = [[[AGAlterApiResponse alloc] initWithJSON:json] autorelease];
        }
    }
    
    // try parse xml
    if (!responseObject) {
        NSData *xmlData = data;
        
        if (xmlData.length == 0) {
            xmlData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><response/>" dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:error];
        if (xmlDocument) {
            responseObject = [[[AGAlterApiResponse alloc] initWithXML:xmlDocument.rootElement] autorelease];
        }
        [xmlDocument release];
    }
    
    return responseObject;
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    
    self.isAlterApiResponse = YES;
    
    if (![json isKindOfClass:[NSDictionary class]]) return self;
    
    // session id
    if ([json[@"sessionId"] isKindOfClass:[NSString class]]) {
        self.sessionId = json[@"sessionId"];
    } else if ([json[@"sessionId"] isKindOfClass:[NSNumber class]]) {
        self.sessionId = [json[@"sessionId"] stringValue];
    }
    
    // message
    if ([json[@"message"] isKindOfClass:[NSDictionary class]]) {
        self.messageTitle = json[@"message"][@"title"];
        self.messageDescription = json[@"message"][@"description"];
    }
    
    // expired urls
    if ([json[@"expiredUrls"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempExpiredUrls = [NSMutableArray array];
        
        for (NSString *expiredUrlJSON in json[@"expiredUrls"]) {
            [tempExpiredUrls addObject:[expiredUrlJSON uriString] ];
        }
        
        self.expiredUrls = tempExpiredUrls;
    }
    
    // application variables
    if ([json[@"applicationVariables"] isKindOfClass:[NSDictionary class]]) {
        self.applicationVariables = json[@"applicationVariables"];
    }
    
    return self;
}

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super init];
    
    self.isAlterApiResponse = [node hasNodeForXPath:@"//response"];
    
    if (!isAlterApiResponse) {
        return self;
    }
    
    // session id
    if ([node hasNodeForXPath:@"//response/sessionId"]) {
        self.sessionId = [node stringValueForXPath:@"//response/sessionId"];
    }
    
    // messages
    if ([node hasNodeForXPath:@"//response/message"]) {
        NSArray *messagesXML = [node nodesForXPath:@"//response/message/value"];
        NSMutableArray *tempMessages = [NSMutableArray array];
        
        for (GDataXMLNode *messageXML in messagesXML.reverseObjectEnumerator) {
            [tempMessages addObject:[messageXML stringValue] ];
        }
        
        self.messages = tempMessages;
    }
    
    // expired urls
    if ([node hasNodeForXPath:@"//response/expiredUrl"]) {
        NSArray *expiredUrlsXML = [node nodesForXPath:@"//response/expiredUrl/url"];
        NSMutableArray *tempExpiredUrls = [NSMutableArray array];
        
        for (GDataXMLNode *expiredUrlXML in expiredUrlsXML) {
            [tempExpiredUrls addObject:[[expiredUrlXML stringValue] uriString] ];
        }
        
        self.expiredUrls = tempExpiredUrls;
    }
    
    // application variables
    if ([node hasNodeForXPath:@"//response/applicationVariables"]) {
        NSArray *variablesXML = [node nodesForXPath:@"//response/applicationVariables/variable"];
        NSMutableDictionary *tempVariables = [NSMutableDictionary dictionary];
        
        for (GDataXMLNode *variableXML in variablesXML) {
            NSString *key = [variableXML stringValueForXPath:@"key"];
            NSString *value = [variableXML stringValueForXPath:@"value"];
            tempVariables[key] = value;
        }
        
        self.applicationVariables = tempVariables;
    }
    
    return self;
}

@end
