#import <Foundation/Foundation.h>

@protocol AGFormProtocol <NSObject>

- (void)setValue:(id)value;
- (void)reset;
- (void)validate;
- (void)invalidate;

@end
