#import "AGControlDesc+XML.h"
#import "AGDesc+XML.h"

@implementation AGControlDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    NSString *xmlValue;

    // identifier
    if ([node hasNodeForXPath:@"@id"]) {
        self.identifier = [node stringValueForXPath:@"@id"];
    }

    // width
    self.width = AGSizeWithText([node stringValueForXPath:@"@width"]);

    // height
    self.height = AGSizeWithText([node stringValueForXPath:@"@height"]);

    // margin left
    self.marginLeft = AGSizeWithText([node stringValueForXPath:@"@marginleft"]);

    // margin right
    self.marginRight = AGSizeWithText([node stringValueForXPath:@"@marginright"]);

    // margin top
    self.marginTop = AGSizeWithText([node stringValueForXPath:@"@margintop"]);

    // margin bottom
    self.marginBottom = AGSizeWithText([node stringValueForXPath:@"@marginbottom"]);

    // padding left
    self.paddingLeft = AGSizeWithText([node stringValueForXPath:@"@paddingleft"]);

    // padding right
    self.paddingRight = AGSizeWithText([node stringValueForXPath:@"@paddingright"]);

    // padding top
    self.paddingTop = AGSizeWithText([node stringValueForXPath:@"@paddingtop"]);

    // padding bottom
    self.paddingBottom = AGSizeWithText([node stringValueForXPath:@"@paddingbottom"]);

    // radius top left
    self.radiusTopLeft = AGSizeWithText([node stringValueForXPath:@"@radiustopleft"]);

    // radius top right
    self.radiusTopRight = AGSizeWithText([node stringValueForXPath:@"@radiustopright"]);

    // radius bottom left
    self.radiusBottomLeft = AGSizeWithText([node stringValueForXPath:@"@radiusbottomleft"]);

    // radius bottom right
    self.radiusBottomRight = AGSizeWithText([node stringValueForXPath:@"@radiusbottomright"]);

    // align
    self.align = AGAlignWithText([node stringValueForXPath:@"@align"]);

    // valign
    self.valign = AGValignWithText([node stringValueForXPath:@"@valign"]);

    // border left
    self.borderLeft = AGSizeWithText([node stringValueForXPath:@"@borderleft"]);
    self.borderRight = AGSizeWithText([node stringValueForXPath:@"@borderright"]);
    self.borderTop = AGSizeWithText([node stringValueForXPath:@"@bordertop"]);
    self.borderBottom = AGSizeWithText([node stringValueForXPath:@"@borderbottom"]);

    // border
    if ([node hasNodeForXPath:@"@border"]) {
        self.borderLeft = AGSizeWithText([node stringValueForXPath:@"@border"]);
        self.borderRight = borderLeft;
        self.borderTop = borderLeft;
        self.borderBottom = borderLeft;
    }

    // border color
    self.borderColor = AGColorWithText([node stringValueForXPath:@"@bordercolor"]);

    // invalid border color
    if ([node hasNodeForXPath:@"@invalidbordercolor"]) {
        self.invalidBorderColor = AGColorWithText([node stringValueForXPath:@"@invalidbordercolor"]);
    } else {
        self.invalidBorderColor = self.borderColor;
    }

    // background
    self.background = [AGVariable variableWithText:[node stringValueForXPath:@"@background"] ];

    // background color
    self.backgroundColor = AGColorWithText([node stringValueForXPath:@"@backgroundcolor"]);

    // background size mode
    self.backgroundSizeMode = AGSizeModeWithText([node stringValueForXPath:@"@backgroundsizemode"]);

    // exclude form calculate
    if ([node hasNodeForXPath:@"@excludefromcalculate"]) {
        xmlValue = [node stringValueForXPath:@"@excludefromcalculate"];
        if ([xmlValue hasPrefix:@"[d]"]) {
            self.excludeFromCalculateVar = [AGVariable variableWithText:[node stringValueForXPath:@"@excludefromcalculate"] ];
        } else {
            self.excludeFromCalculate = [xmlValue boolValue];
        }
    }

    // hidden
    if ([node hasNodeForXPath:@"@hidden"]) {
        if (!excludeFromCalculate) {
            xmlValue = [node stringValueForXPath:@"@hidden"];
            if ([xmlValue hasPrefix:@"[d]"]) {
                self.hiddenVar = [AGVariable variableWithText:[node stringValueForXPath:@"@hidden"] ];
            } else {
                self.hidden = [xmlValue boolValue];
            }
        } else {
            self.hidden = YES;
        }
    }

    // on click action
    self.onClickAction = [AGAction actionWithText:[node stringValueForXPath:@"@onclick"] ];

    // on swipe left action
    if ([node hasNodeForXPath:@"@onswipeleft"]) {
        self.onSwipeLeftAction = [AGAction actionWithText:[node stringValueForXPath:@"@onswipeleft"] ];
    }

    // on swipe right action
    if ([node hasNodeForXPath:@"@onswiperight"]) {
        self.onSwipeRightAction = [AGAction actionWithText:[node stringValueForXPath:@"@onswiperight"] ];
    }

    // on change
    if ([node hasNodeForXPath:@"@onchange"]) {
        self.onChangeAction = [AGAction actionWithText:[node stringValueForXPath:@"@onchange"] ];
    }
    
    // on update
    if ([node hasNodeForXPath:@"@onupdate"]) {
        self.onUpdateAction = [AGAction actionWithText:[node stringValueForXPath:@"@onupdate"] ];
    }

    // on end editing
    if ([node hasNodeForXPath:@"@onendediting"]) {
        self.onEndEditing = [AGAction actionWithText:[node stringValueForXPath:@"@onendediting"] ];
    }

    return self;
}

@end
