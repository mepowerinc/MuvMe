#import "AGTextMeasurer.h"
#import "AGLayoutManager.h"
#import "AGTextLineData.h"
#import "AGFontManager.h"

@interface AGTextMeasurer (){
    NSString *fontName;
    BOOL isItalic;
    BOOL isBold;
    NSInteger maxLines;
    NSInteger maxCharacters;
    CGFloat fontSize;
    CGFloat measuredWidth;
    CGFloat measuredHeight;
    CGFloat fontInterline;
    CGFloat rowHeight;
}
@end

@implementation AGTextMeasurer

SINGLETON_IMPLEMENTATION(AGTextMeasurer)

@synthesize maxLines;
@synthesize maxCharacters;
@synthesize isItalic;
@synthesize isBold;
@synthesize fontSize;
@synthesize fontName;
@synthesize measuredWidth;
@synthesize measuredHeight;
@synthesize fontInterline;
@synthesize rowHeight;

- (void)dealloc {
    [AGFontManager end];
    [super dealloc];
}

- (id)init {
    self = [super init];

    AGFONTMANAGER;

    return self;
}

#pragma mark - Measure

- (NSArray *)measureText:(NSString *)text forWidth:(CGFloat)width_ {
    NSMutableArray* linesData = [NSMutableArray array];

    [AGFONTMANAGER setFont:fontName withSize:fontSize andBold:isBold andItalic:isItalic];

    rowHeight = [AGFONTMANAGER getHeightForSize:fontSize];
    fontInterline = -fontSize*0.15;
    measuredWidth = 0;
    measuredHeight = 0;

    if (width_ < 0) {
        width_ = 0;
    }

    if (text == nil || !text.length) {
        text = @"";
    }

    if (maxCharacters > 0) {
        text = [text substringToIndex:MIN(text.length, maxCharacters)];
    }
    NSArray *textByLines = [text componentsSeparatedByString:@"\n"];
    NSInteger currentLinesCount = 0;
    NSInteger previousCharacterIndex = 0;

    for (int i = 0; i < textByLines.count; ++i) {
        NSArray *currentLinesData = [self calculateLines:textByLines[i] width:width_ startLineIndex:currentLinesCount previousCharacterIndex:previousCharacterIndex];

        [linesData addObjectsFromArray:currentLinesData];
        currentLinesCount = linesData.count;
        AGTextLineData *previousData = [currentLinesData lastObject];
        previousCharacterIndex = previousData.startIndex+previousData.length;

        CGFloat longestLineWidth = [self measureLongestLineWidth:textByLines[i] linesData:currentLinesData];
        measuredWidth = MAX(measuredWidth, longestLineWidth);

        for (AGTextLineData *lineData in currentLinesData) {
            lineData.startIndex += i;
        }

        if (maxLines > 0 && currentLinesCount >= maxLines) {
            break;
        }
    }

    NSInteger lineCount = linesData.count;
    CGFloat interlinesHeight = 0;
    if (lineCount > 0) {
        interlinesHeight = (lineCount - 1) * fontInterline;
    }
    measuredHeight = lineCount * rowHeight + interlinesHeight;

    return linesData;
}

- (CGFloat)calcStringWidth:(NSString *)string firstIndex:(NSInteger)firstIndex length:(NSInteger)length {
    CGFloat result = 0;
    CGFloat width = 0;
    if (length == 0) {
        return 0;
    }

    for (NSInteger _char = 0, max = length; _char < max; _char++) {
        NSInteger strIndex = MIN(firstIndex+_char, string.length-1);
        CGFloat w = [AGFONTMANAGER getWidthForChar:[string characterAtIndex:strIndex]];
        width += w;
    }

    result = [AGFONTMANAGER round:width withPrecision:6];

    return result;
}

- (CGFloat)measureLongestLineWidth:(NSString *)text linesData:(NSArray *)linesData {
    CGFloat longestLineWidth = 0;

    for (int i = 0; i < linesData.count; ++i) {
        AGTextLineData *lineData = linesData[i];
        CGFloat lineWidth = lineData.width;
        if (lineWidth > longestLineWidth) {
            longestLineWidth = lineWidth;
        }
    }

    return longestLineWidth;
}

- (NSArray *)calculateLines:(NSString *)text width:(CGFloat)width startLineIndex:(NSInteger)startLineIndex previousCharacterIndex:(NSInteger)previousCharacterIndex {
    NSMutableArray *linesData = [NSMutableArray array];

    NSInteger lineIndex = startLineIndex;
    BOOL addEndLineIndexAfterWhile = true;
    CGFloat totalStringWidth = [self calcStringWidth:text firstIndex:0 length:text.length];

    NSInteger currentIndex = 0;
    while (totalStringWidth > width) {

        if (maxLines > 0 && lineIndex >= maxLines) {
            addEndLineIndexAfterWhile = NO;
            break;
        }

        CGFloat stringWidth = 0;
        NSInteger length = 0;
        [self calcMaxLineWidth:text stringIndex:currentIndex maxWidth:width stringWidth:&stringWidth stringLenght:&length];
        stringWidth = [AGFONTMANAGER round:stringWidth withPrecision:6];
        totalStringWidth -= stringWidth;
        currentIndex += length;

        if (currentIndex < text.length && [text characterAtIndex:currentIndex] == ' ') {
            currentIndex++;
            length++;
        }

        AGTextLineData *lineData = [[AGTextLineData alloc] init];
        lineData.width = stringWidth;
        lineData.startIndex = previousCharacterIndex+currentIndex-length;
        lineData.length = length;
        [linesData addObject:lineData];
        [lineData release];

        lineIndex++;

        if (maxLines > 0 && lineIndex >= maxLines) {
            addEndLineIndexAfterWhile = false;
            break;
        }
    }

    if (addEndLineIndexAfterWhile) {
        AGTextLineData *lineData = [[AGTextLineData alloc] init];
        lineData.width = [self calcStringWidth:text firstIndex:currentIndex length:text.length-currentIndex];
        lineData.startIndex = previousCharacterIndex+currentIndex;
        lineData.length = text.length-currentIndex;
        [linesData addObject:lineData];
        [lineData release];
    }

    return linesData;
}

- (void)calcMaxLineWidth:(NSString *)text stringIndex:(NSInteger)stringIndex maxWidth:(CGFloat)maxWidth stringWidth:(CGFloat *)stringWidth stringLenght:(NSInteger *)stringLenght {
    CGFloat previousWidth = 0;
    CGFloat actualWidth = 0;
    NSInteger startIndex = stringIndex;
    NSInteger previousIndex = stringIndex;
    NSInteger actualIndex = stringIndex + 1;

    CGFloat minWidth = [self calcStringWidth:text firstIndex:stringIndex length:1];

    while (actualIndex > 0 && actualIndex < text.length && actualWidth <= maxWidth) {

        previousIndex = actualIndex;
        actualIndex = previousIndex+1+[[text substringWithRange:NSMakeRange(previousIndex+1, text.length-(previousIndex+1))] rangeOfString:@" "].location;
        previousWidth = actualWidth;

        if (actualIndex == NSNotFound || actualIndex < 0) {
            if (previousWidth == 0) {
                previousWidth = [self calcStringWidth:text firstIndex:startIndex length:text.length-startIndex];
                previousIndex = text.length;
            }
            break;
        } else {
            actualWidth = [self calcStringWidth:text firstIndex:startIndex length:actualIndex+1-startIndex];

            if (previousWidth == 0) {
                previousWidth = actualWidth;
            }
        }
    }

    stringIndex = previousIndex;

    if (previousWidth > maxWidth) {
        stringIndex = [self breakWord:text startIndex:startIndex maxWidth:maxWidth];
        previousWidth = [self calcStringWidth:text firstIndex:startIndex length:stringIndex-startIndex];
    }

    if (previousWidth < minWidth) {
        previousWidth = minWidth;
    }

    *stringWidth = previousWidth;
    *stringLenght = stringIndex-startIndex;
}

- (NSInteger)breakWord:(NSString *)text startIndex:(NSInteger)stringIndex maxWidth:(CGFloat)maxWidth {
    NSInteger startStringIndex = stringIndex;
    NSInteger actualIndex = startStringIndex + 1;
    CGFloat stringWidth = 0;

    while (stringIndex < text.length) {
        stringWidth = [self calcStringWidth:text firstIndex:startStringIndex length:actualIndex-startStringIndex];

        if (stringWidth > maxWidth) {
            if (actualIndex > (startStringIndex + 1)) {
                actualIndex--;
            }
            break;
        }
        actualIndex++;
    }

    return actualIndex;
}

@end
