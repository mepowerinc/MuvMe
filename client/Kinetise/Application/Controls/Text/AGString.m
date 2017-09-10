#import "AGString.h"
#import "AGTextMeasurer.h"
#import "AGFontManager.h"

@interface AGString (){
    BOOL isDirtyAttributedString;
    BOOL isDirtyMeasure;
}
@property(nonatomic, retain) NSArray *lines;
@property(nonatomic, retain) NSAttributedString *attributedString;
@end

@implementation AGString

@synthesize attributedString;
@synthesize lines;
@synthesize fontLineHeight;
@synthesize fontInterline;
@synthesize size;
@synthesize string;
@synthesize color;
@synthesize fontSize;
@synthesize isBold;
@synthesize isItalic;
@synthesize isUnderline;
@synthesize maxCharacters;
@synthesize maxLines;
@synthesize maxWidth;

- (void)dealloc {
    self.string = nil;
    self.lines = nil;
    self.attributedString = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    isDirtyMeasure = YES;
    isDirtyAttributedString = YES;

    return self;
}

#pragma mark - Measure

- (void)measure {
    NSString *tempText = string ? string : @"";

    [AGTextMeasurer sharedInstance].maxLines = maxLines;
    [AGTextMeasurer sharedInstance].fontName = AG_FONT_NAME;
    [AGTextMeasurer sharedInstance].fontSize = fontSize;
    [AGTextMeasurer sharedInstance].maxCharacters = maxCharacters;
    [AGTextMeasurer sharedInstance].isBold = isBold;
    [AGTextMeasurer sharedInstance].isItalic = isItalic;

    self.lines = [[AGTextMeasurer sharedInstance] measureText:tempText forWidth:maxWidth];
    fontInterline = [AGTextMeasurer sharedInstance].fontInterline;
    fontLineHeight = [AGTextMeasurer sharedInstance].rowHeight;
    size = CGSizeMake([AGTextMeasurer sharedInstance].measuredWidth, [AGTextMeasurer sharedInstance].measuredHeight);
}

#pragma mark - Getters

- (NSArray *)lines {
    if (isDirtyMeasure) {
        [self measure];
        isDirtyMeasure = NO;
    }

    return lines;
}

- (CGFloat)fontLineHeight {
    if (isDirtyMeasure) {
        [self measure];
        isDirtyMeasure = NO;
    }

    return fontLineHeight;
}

- (CGFloat)fontInterline {
    if (isDirtyMeasure) {
        [self measure];
        isDirtyMeasure = NO;
    }

    return fontInterline;
}

- (CGSize)size {
    if (isDirtyMeasure) {
        [self measure];
        isDirtyMeasure = NO;
    }

    return size;
}

- (NSAttributedString *)attributedString {
    if (isDirtyAttributedString) {
        NSString *tempText = string ? string : @"";
        NSMutableAttributedString *tempAttributedString = [[NSMutableAttributedString alloc] initWithString:tempText];
        NSRange textRange = NSMakeRange(0, tempText.length);

        // underline
        if (isUnderline) {
            [tempAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:textRange];
        }

        // color
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {color.r, color.g, color.b, color.a};
        CGColorRef colorRef = CGColorCreate(colorSpace, components);
        [tempAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)colorRef range:textRange];
        CGColorRelease(colorRef);
        CGColorSpaceRelease(colorSpace);

        // font name
        NSString *fontName = [AGFONTMANAGER getAttributeFontName:AG_FONT_NAME withBold:isBold andItalic:isItalic];
        // ???: Why textStyle.fontSize.value-1 ?
        UIFont *font = [UIFont fontWithName:fontName size:fontSize-1.0f];
        [tempAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:textRange];

        // line break
        CTLineBreakMode breakMode = kCTLineBreakByClipping;

        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(breakMode), &breakMode},
        };

        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
        [tempAttributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName value:(id)paragraphStyle range:textRange ];
        CFRelease(paragraphStyle);

        self.attributedString = tempAttributedString;
        [tempAttributedString release];

        isDirtyAttributedString = NO;
    }

    return attributedString;
}

#pragma mark - Setters

- (void)setString:(NSString *)string_ {
    if ([string isEqualToString:string_]) return;

    [string release];
    string = [string_ copy];

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setFontSize:(CGFloat)fontSize_ {
    if (fontSize == fontSize_) return;

    fontSize = fontSize_;

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setColor:(AGColor)color_ {
    if (AGColorEqual(color, color_) ) return;

    color = color_;

    isDirtyAttributedString = YES;
}

- (void)setIsBold:(BOOL)isBold_ {
    if (isBold == isBold_) return;

    isBold = isBold_;

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setIsItalic:(BOOL)isItalic_ {
    if (isItalic == isItalic_) return;

    isItalic = isItalic_;

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setIsUnderline:(BOOL)isUnderline_ {
    if (isUnderline == isUnderline_) return;

    isUnderline = isUnderline_;

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setMaxCharacters:(NSInteger)maxCharacters_ {
    if (maxCharacters == maxCharacters_) return;

    maxCharacters = maxCharacters_;

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setMaxLines:(NSInteger)maxLines_ {
    if (maxLines == maxLines_) return;

    maxLines = maxLines_;

    isDirtyAttributedString = YES;
    isDirtyMeasure = YES;
}

- (void)setMaxWidth:(CGFloat)maxWidth_ {
    if (maxWidth == maxWidth_) return;

    maxWidth = maxWidth_;

    isDirtyMeasure = YES;
}

#pragma mark - NSCompare

- (BOOL)isEqualToString:(AGString *)object {
    if (![string isEqualToString:object.string]) return NO;
    if (AGColorEqual(color, object.color) ) return NO;
    if (fontSize != object.fontSize) return NO;
    if (isBold != object.isBold) return NO;
    if (isItalic != object.isItalic) return NO;
    if (isUnderline != object.isUnderline) return NO;
    if (maxCharacters != object.maxCharacters) return NO;
    if (maxLines != object.maxLines) return NO;
    if (maxWidth != object.maxWidth) return NO;

    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToString:object];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGString *obj = [[[self class] allocWithZone:zone] init];

    obj.string = string;
    obj.fontSize = fontSize;
    obj.color = color;
    obj.isBold = isBold;
    obj.isItalic = isItalic;
    obj.isUnderline = isUnderline;
    obj.maxCharacters = maxCharacters;
    obj.maxLines = maxLines;
    obj.maxWidth = maxWidth;

    obj->attributedString = [attributedString retain];
    obj->fontLineHeight = fontLineHeight;
    obj->fontInterline = fontInterline;
    obj->lines = [lines retain];
    obj->size = size;

    obj->isDirtyMeasure = isDirtyMeasure;
    obj->isDirtyAttributedString = isDirtyAttributedString;

    return obj;
}

@end
