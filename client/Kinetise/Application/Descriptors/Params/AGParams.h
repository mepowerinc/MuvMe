#import <Foundation/Foundation.h>

@interface AGParams : NSObject {
    NSMutableDictionary *params;
}

@property(nonatomic, readonly) NSMutableDictionary *params;

+ (instancetype)paramsWithJSONString:(NSString *)jsonString;
+ (instancetype)paramsWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)execute;
- (NSMutableDictionary *)execute:(id)sender;

@end
