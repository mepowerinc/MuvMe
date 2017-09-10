#import <CoreText/CoreText.h>
#import "NSObject+Singleton.h"

#define AGFONTMANAGER [AGFontManager sharedInstance]

@interface AGFontManager : NSObject

    SINGLETON_INTERFACE(AGFontManager)

- (void)setFont:(NSString *)font withSize:(CGFloat)size andBold:(BOOL)bold andItalic:(BOOL)italic;
- (CGFloat)getWidthForChar:(unichar)character;
- (CGFloat)getWidthForString:(NSString *)string;
- (CGFloat)getHeightForSize:(CGFloat)size;
- (CGFloat)getiOSTextWidth:(NSString *)text;
- (NSString *)getAttributeFontName:(NSString *)fontName withBold:(BOOL)bold andItalic:(BOOL)itali;
- (CGFloat)round:(CGFloat)value withPrecision:(NSInteger)precision;
- (UIFont *)fontWithSize:(CGFloat)size bold:(BOOL)bold italic:(BOOL)italic;

@end
