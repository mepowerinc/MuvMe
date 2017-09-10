#import "AGValidationIndicator.h"
#import "AGApplication.h"
#import "AGLayoutManager.h"

@implementation AGValidationIndicator

@synthesize message;
@synthesize color;
@synthesize offset;

#pragma mark - Initialization

- (void)dealloc {
    self.message = nil;
    self.color = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    
    // settings
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor redColor];
    self.hidden = YES;
    
    // selector
    [self addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat size = rect.size.width;
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, maxx, miny);
    CGPathAddLineToPoint(path, nil, maxx, miny+size);
    CGPathAddLineToPoint(path, nil, maxx-size, miny);
    CGPathCloseSubpath(path);
    
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CFRelease(path);
    
    CGFloat fontSize = [AGLAYOUTMANAGER KPXToPixels:30];
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    CGRect textRect = CGRectMake(midx-offset.horizontal*0.5f+offset.vertical*0.5f, midy-fontSize-offset.horizontal*0.5f+offset.vertical*0.5f, fontSize, fontSize);
    NSMutableParagraphStyle *textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSParagraphStyleAttributeName: textStyle
                                     };
    [textStyle release];
    
    [@"!" drawInRect:textRect withAttributes:textAttributes];
}

#pragma mark - Lifecycle

- (void)setColor:(UIColor *)color_ {
    [color release];
    color = [color_ retain];
    
    [self setNeedsDisplay];
}

- (void)onTap {
    if (message) {
        [AGAPPLICATION.toast makeValidationToast:message];
    }
}

- (void)setOffset:(UIOffset)offset_ {
    offset = offset_;
    
    [self setNeedsDisplay];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = self.bounds;
    CGFloat size = rect.size.width;
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, maxx, miny);
    CGPathAddLineToPoint(path, nil, maxx, miny+size);
    CGPathAddLineToPoint(path, nil, maxx-size, miny);
    CGPathCloseSubpath(path);
    BOOL pointInside = CGPathContainsPoint(path, nil, point, NO);
    CFRelease(path);
    
    return pointInside;
}

@end
