#import <Foundation/Foundation.h>

@interface AGRegexRule : NSObject {
    NSString *tag;
    NSString *replaceWith;
    BOOL returnMatch;
}

@property(nonatomic, copy) NSString *tag;
@property(nonatomic, copy) NSString *replaceWith;
@property(nonatomic, assign) BOOL returnMatch;

@end
