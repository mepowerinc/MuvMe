#import <Foundation/Foundation.h>

@interface AGFeedRequiredField : NSObject {
    NSString *field;
    id match;
    NSString *regexName;
    BOOL allowEmpty;
}

@property(nonatomic, copy) NSString *field;
@property(nonatomic, copy) id match;
@property(nonatomic, copy) NSString *regexName;
@property(nonatomic, assign) BOOL allowEmpty;

@end
