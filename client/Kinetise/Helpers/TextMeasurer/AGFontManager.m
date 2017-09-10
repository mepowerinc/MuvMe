#import "AGFontManager.h"

inline CGFloat ag_pround(CGFloat x, NSInteger precision);

typedef struct {
    CGFloat aComponent;
    CGFloat bComponent;
} AGFontLetterData;

typedef struct {
    NSString *fontName;
    NSString *attributeFontName[4];
    AGFontLetterData letters[4][65536]; // 0-regular, 1-bold, 2-italic, 3-bolditalic
    CGFloat aHeightComponent[4];
    CGFloat bHeightComponent[4];
} AGFontData;

CGFloat ag_pround(CGFloat x, NSInteger precision){
    NSInteger y = x;
    CGFloat z = x-y;
    CGFloat m = pow(10, precision);
    CGFloat q = z*m;
    CGFloat r = round(q);

    return (CGFloat)(y)+(1.0f/m)*r;
}

@interface AGFontManager (){
    AGFontData *currentFont;
    CGFloat currentFontSize;
    NSInteger currentAttributeFontIndex;
    NSInteger numOfFonts;
    AGFontData *fonts;
}
@end

@implementation AGFontManager

SINGLETON_IMPLEMENTATION(AGFontManager)

- (void)dealloc {
    for (int i = 0; i < numOfFonts; ++i) {
        AGFontData *fontData = &fonts[i];
        [fontData->fontName release];
        for (int j = 0; j < 4; ++j) {
            [fontData->attributeFontName[j] release];
        }
    }
    free(fonts);
    [super dealloc];
}

- (id)init {
    self = [super init];

    // load fonts
    [self loadFont:AG_FONT_NAME];

    return self;
}

- (void)loadFont:(NSString *)fontName {
    ++numOfFonts;

    // allocate fonts array
    if (numOfFonts == 1) {
        fonts = malloc(sizeof(AGFontData));
    } else {
        fonts = realloc(fonts, sizeof(AGFontData)*numOfFonts);
    }
    memset(&fonts[numOfFonts-1], 0, sizeof(AGFontData));

    // font data
    AGFontData *fontData = &fonts[numOfFonts-1];
    fontData->fontName = [[NSString alloc] initWithString:fontName];

    // font files
    NSString *fontFile[4];
    fontFile[0] = [fontName stringByAppendingString:@"-regular"];
    fontFile[1] = [fontName stringByAppendingString:@"-bold"];
    fontFile[2] = [fontName stringByAppendingString:@"-italic"];
    fontFile[3] = [fontName stringByAppendingString:@"-bolditalic"];

    for (int i = 0; i < 4; ++i) {
        // ctfont
        NSString *fileName = [fontFile[i] stringByAppendingString:@".ttf"];
        NSString *filePath = FILE_PATH_BUNDLE(fileName);
        NSURL *url = [NSURL fileURLWithPath:filePath];
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((CFURLRef)url);
        CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
        CGDataProviderRelease(fontDataProvider);
        CTFontManagerRegisterGraphicsFont(newFont, nil);
        fontData->attributeFontName[i] = (NSString *)CGFontCopyPostScriptName(newFont);
        CGFontRelease(newFont);

        // height data
        fileName = [fontFile[i] stringByAppendingString:@"-h.txt"];
        filePath = FILE_PATH_BUNDLE(fileName);
        NSString *heightFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        heightFile = [heightFile stringByReplacingOccurrencesOfString:@";" withString:@""];
        NSArray *hArray = [heightFile componentsSeparatedByString:@":"];
        fontData->aHeightComponent[i] = [hArray[0] floatValue];
        fontData->bHeightComponent[i] = [hArray[1] floatValue];

        // width data
        fileName = [fontFile[i] stringByAppendingString:@".txt"];
        filePath = FILE_PATH_BUNDLE(fileName);
        NSString *widthFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        widthFile = [widthFile stringByReplacingOccurrencesOfString:@";:" withString:@"<mark1>:"];
        widthFile = [widthFile stringByReplacingOccurrencesOfString:@"::" withString:@"<mark2>:"];
        widthFile = [widthFile stringByReplacingOccurrencesOfString:@"\n:" withString:@"<mark3>:"];
        widthFile = [widthFile stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *wArray = [widthFile componentsSeparatedByString:@";"];
        for (NSString *str in wArray) {
            NSArray *array2 = [str componentsSeparatedByString:@":"];
            if (array2.count <= 1) continue;

            unsigned result = 0;
            NSScanner *scanner = [NSScanner scannerWithString:array2[0]];
            [scanner setScanLocation:2];
            [scanner scanHexInt:&result];
            unichar character = (unichar)result;

            if ([array2[0] isEqualToString:@"<mark1>:"]) {
                character = ';';
            } else if ([array2[0] isEqualToString:@"<mark2>:"]) {
                character = ':';
            } else if ([array2[0] isEqualToString:@"<mark3>:"]) {
                character = '\n';
            }

            CGFloat a = [array2[1] floatValue];
            CGFloat b = [array2[2] floatValue];
            
            fontData->letters[i][character].aComponent = ag_pround(a, 3);
            fontData->letters[i][character].bComponent = b;
        }
    }
}

- (AGFontData *)getFontData:(NSString *)fontName {
    if (numOfFonts == 1) return &fonts[0];

    for (int i = 0; i < numOfFonts; ++i) {
        if ([fonts[i].fontName isEqualToString:fontName]) {
            return &fonts[i];
        }
    }

    return nil;
}

- (void)setFont:(NSString *)font withSize:(CGFloat)size andBold:(BOOL)bold andItalic:(BOOL)italic {
    currentFont = [self getFontData:font];
    currentFontSize = size;
    currentAttributeFontIndex = 0;
    if (bold && italic) {
        currentAttributeFontIndex = 3;
    } else if (bold) {
        currentAttributeFontIndex = 1;
    } else if (italic) {
        currentAttributeFontIndex = 2;
    }
}

- (CGFloat)getWidthForChar:(unichar)character {
    if (currentFont->letters[currentAttributeFontIndex][character].aComponent == 0 && currentFont->letters[currentAttributeFontIndex][character].bComponent == 0) {
        if (character == '\n') {
            return 0;
        } else {
            character = '?';
        }
    }

    return currentFont->letters[currentAttributeFontIndex][character].aComponent*currentFontSize;
}

- (CGFloat)getWidthForString:(NSString *)string {
    CGFloat result = 0;

    for (int i = 0; i < string.length; ++i) {
        unichar character = [string characterAtIndex:i];
        result += [self getWidthForChar:character];
    }

    return result;
}

- (CGFloat)getiOSTextWidth:(NSString *)text {
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];

    CFRange fitRange;
    CTFontRef ctFont = nil;
    ctFont = CTFontCreateWithName( (CFStringRef)currentFont->fontName, currentFontSize, NULL);
    [attString addAttribute:(NSString *)kCTFontAttributeName value:(id)ctFont range:NSMakeRange(0, text.length)];
    CFRelease(ctFont);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, text.length), NULL, CGSizeMake(FLT_MAX, FLT_MAX), &fitRange);
    CFRelease(framesetter);
    [attString release];

    return frameSize.width;
}

- (CGFloat)getHeightForSize:(CGFloat)size {
    return currentFont->aHeightComponent[currentAttributeFontIndex]*size+currentFont->bHeightComponent[currentAttributeFontIndex];
}

- (NSString *)getAttributeFontName:(NSString *)fontName withBold:(BOOL)bold andItalic:(BOOL)italic {
    AGFontData *fontData = [self getFontData:fontName];
    if (!fontData) return nil;

    NSInteger attributeFontIndex = 0;
    if (bold && italic) {
        attributeFontIndex = 3;
    } else if (bold) {
        attributeFontIndex = 1;
    } else if (italic) {
        attributeFontIndex = 2;
    }

    return fontData->attributeFontName[attributeFontIndex];
}

- (CGFloat)round:(CGFloat)value withPrecision:(NSInteger)precision {
    return ag_pround(value, precision);
}

- (UIFont *)fontWithSize:(CGFloat)size bold:(BOOL)bold italic:(BOOL)italic {
    NSString *fontName = [AGFONTMANAGER getAttributeFontName:AG_FONT_NAME withBold:bold andItalic:italic];
    UIFont *font = [UIFont fontWithName:fontName size:size];

    return font;
}

@end
