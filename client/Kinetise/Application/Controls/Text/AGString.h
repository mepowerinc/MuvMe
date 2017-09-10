#import "AGUnits.h"

@interface AGString : NSObject

@property(nonatomic, readonly) NSAttributedString *attributedString;
@property(nonatomic, readonly) NSArray *lines;
@property(nonatomic, readonly) CGFloat fontLineHeight;
@property(nonatomic, readonly) CGFloat fontInterline;
@property(nonatomic, readonly) CGSize size;

@property(nonatomic, copy) NSString *string;
@property(nonatomic, assign) AGColor color;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, assign) BOOL isBold;
@property(nonatomic, assign) BOOL isItalic;
@property(nonatomic, assign) BOOL isUnderline;
@property(nonatomic, assign) NSInteger maxCharacters;
@property(nonatomic, assign) NSInteger maxLines;
@property(nonatomic, assign) CGFloat maxWidth;

@end
