#import <Foundation/Foundation.h>
#import "NSObject+Singleton.h"

@interface AGTextMeasurer : NSObject

    SINGLETON_INTERFACE(AGTextMeasurer)

@property(nonatomic, assign) NSInteger maxLines;
@property(nonatomic, assign) NSInteger maxCharacters;
@property(nonatomic, assign) BOOL isItalic;
@property(nonatomic, assign) BOOL isBold;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, assign) NSString *fontName;
@property(nonatomic, readonly) CGFloat measuredWidth;
@property(nonatomic, readonly) CGFloat measuredHeight;
@property(nonatomic, readonly) CGFloat fontInterline;
@property(nonatomic, readonly) CGFloat rowHeight;

- (NSArray *)measureText:(NSString *)text forWidth:(CGFloat)width;

@end
