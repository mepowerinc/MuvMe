#import "AGLabel.h"
#import <CoreText/CoreText.h>
#import "AGTextLineData.h"

@interface AGLabel (){
    CGSize attriibutedStringSize;
    NSAttributedString *attriibutedString;
    CTTypesetterRef typesetter;
}
@property(nonatomic, retain) NSAttributedString *attriibutedString;
@end

@implementation AGLabel

@synthesize textAlign;
@synthesize textValign;
@synthesize string;
@synthesize attriibutedString;

- (void)dealloc {
    self.string = nil;
    self.attriibutedString = nil;
    if (typesetter) {
        CFRelease(typesetter);
        typesetter = nil;
    }
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // typesetter
    typesetter = nil;

    return self;
}

#pragma mark Setters

- (void)setString:(AGString *)string_ {
    // !!!
    if (string != string_) {
        [self setNeedsDisplay];
    }

    [string release];
    string = [string_ retain];

    if (![attriibutedString isEqualToAttributedString:string.attributedString]) {
        [attriibutedString release];
        attriibutedString = [string.attributedString retain];

        if (typesetter) {
            CFRelease(typesetter);
            typesetter = nil;
        }
        typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)attriibutedString);

        [self setNeedsDisplay];
    }

    if (!CGSizeEqualToSize(attriibutedStringSize, string.size) ) {
        attriibutedStringSize = string.size;
        [self setNeedsDisplay];
    }
}

- (void)setTextAlign:(AGAlignType)textAlign_ {
    if (textAlign == textAlign_) return;

    textAlign = textAlign_;

    [self setNeedsDisplay];
}

- (void)setTextValign:(AGValignType)textValign_ {
    if (textValign == textValign_) return;

    textValign = textValign_;

    [self setNeedsDisplay];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    NSArray* lines = string.lines;
    CGFloat fontLineHeight = string.fontLineHeight;
    CGFloat fontInterline = string.fontInterline;

    CGSize textSize = string.size;
    textSize = CGSizeMake(MAX(self.bounds.size.width, textSize.width), textSize.height);
    CGPoint textPosition = CGPointMake(0, textSize.height);
    CGFloat textFlush = 0;

    if (textAlign == alignCenter) {
        textFlush = 0.5;
    } else if (textAlign == alignRight) {
        textFlush = 1;
    }

    if (lines.count > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, textSize.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);

        // valign
        CGFloat differrence = self.bounds.size.height-(fontLineHeight+fontInterline)*(CGFloat)lines.count;
        if (textValign == valignBottom || textValign == valignBelow) {
            CGContextTranslateCTM(context, 0, -differrence);
        } else if (textValign == valignCenter) {
            CGContextTranslateCTM(context, 0, -differrence*0.5f);
        }

        for (int i = 0; i < lines.count; ++i) {
            AGTextLineData *lineData = lines[i];

            if (lineData.length == 0) {
                textPosition.y -= fontLineHeight+fontInterline;
                continue;
            }

            CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineData.startIndex, lineData.length));

            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            //CGFloat realLineHeight = ascent + descent + leading;
            //CGFloat measuredLineHeight = rowHeight;
            //CGFloat lineHeightDifference = measuredLineHeight-realLineHeight;

            CGFloat penOffset = CTLineGetPenOffsetForFlush(line, textFlush, textSize.width);
            CGContextSetTextPosition(context, textPosition.x+penOffset, textPosition.y-ascent); //ceil(ascent);
            CTLineDraw(line, context);
            CFRelease(line);

            textPosition.y -= fontLineHeight+fontInterline;
        }
    }
}

@end
