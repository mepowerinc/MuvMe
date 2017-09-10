#import "AGContainerDesc+ThumbnailsLayout.h"
#import "AGControlDesc+Layout.h"
#import "AGContainerDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGContainerDesc (ThumbnailsLayout)

#pragma mark - Layout

- (void)thumbnailsLayout {
    CGFloat controlPositionY = 0;
    CGFloat moveHorizontal = 0;
    CGFloat moveVertical = 0;
    CGFloat lineHeight = 0;
    BOOL nextLine = NO;

    for (int i = 0; i < children.count; ++i) {
        AGControlDesc *child = children[i];

        if (nextLine) {
            moveVertical += lineHeight;
            lineHeight = 0;
            moveHorizontal = 0;
            nextLine = NO;
        }

        // position x
        child.positionX = moveHorizontal;
        child.globalPositionX = globalPositionX+marginLeft.value+borderLeft.value+paddingLeft.value+child.positionX;
        moveHorizontal += child.blockWidth;

        if (i+1 < children.count) {
            AGControlDesc *nextChild = children[i+1];
            if (child.positionX+child.blockWidth+nextChild.blockWidth > contentWidth) {
                nextLine = YES;
            }
        }

        // position y
        controlPositionY = moveVertical;
        if (child.blockHeight > lineHeight) {
            lineHeight = child.blockHeight;
        }

        // set child position
        child.positionY = controlPositionY;
        child.globalPositionY = globalPositionY+marginTop.value+borderTop.value+paddingTop.value+child.positionY;
    }

    // lines align
    NSInteger elementsInLine = 0;
    CGFloat rowWidth = 0;
    CGFloat horizontalFreeSpace = 0;
    CGFloat horizontalMove = 0;
    CGFloat containerAvalibleSpace = contentWidth;
    CGFloat rowHeight = 0;
    CGFloat verticalMove = 0;
    CGFloat rowVerticalFreeSpace = 0;

    for (int i = 0; i < children.count; ++i) {
        AGControlDesc *child = children[i];

        ++elementsInLine;
        rowWidth += child.blockWidth;

        // row end
        if (rowWidth > containerAvalibleSpace) {
            horizontalFreeSpace = (containerAvalibleSpace - rowWidth + child.blockWidth);

            if (child.align == alignLeft) {
                horizontalMove = 0;
            } else if (child.align == alignCenter) {
                horizontalMove = horizontalFreeSpace*0.5;
            } else if (child.align == alignRight) {
                horizontalMove = horizontalFreeSpace;
            } else if (child.align == alignDistributed) {
            }

            // row
            for (NSInteger j = i-elementsInLine+1; j < i; ++j) {
                AGControlDesc *anotherChild = children[j];
                anotherChild.positionX += horizontalMove;
            }

            // valign in row
            for (NSInteger j = i-elementsInLine+1; j < i; ++j) {
                AGControlDesc *anotherChild = children[j];

                rowVerticalFreeSpace = rowHeight - anotherChild.blockHeight;

                if (anotherChild.valign == valignTop) {
                    verticalMove = 0;
                } else if (anotherChild.valign == valignCenter) {
                    verticalMove = rowVerticalFreeSpace*0.5;
                } else if (anotherChild.valign == valignBottom) {
                    verticalMove = rowVerticalFreeSpace;
                }

                anotherChild.positionY += verticalMove;
            }

            elementsInLine = 1;
            rowWidth = child.blockWidth;
            rowHeight = child.blockHeight;
        } else {
            if (child.blockHeight > rowHeight) {
                rowHeight = child.blockHeight;
            }
        }

        // last child
        if (i == children.count-1) {
            horizontalFreeSpace = containerAvalibleSpace-rowWidth;

            if (child.align == alignLeft) {
                horizontalMove = 0;
            } else if (child.align == alignCenter) {
                horizontalMove = horizontalFreeSpace*0.5;
            } else if (child.align == alignRight) {
                horizontalMove = horizontalFreeSpace;
            } else if (child.align == alignDistributed) {
            }

            // last row
            for (NSInteger j = i-elementsInLine+1; j <= i; ++j) {
                AGControlDesc *anotherChild = children[j];
                anotherChild.positionX += horizontalMove;

                // valign in last row
                rowVerticalFreeSpace = rowHeight-anotherChild.blockHeight;

                if (child.valign == valignTop) {
                    verticalMove = 0;
                } else if (child.valign == valignCenter) {
                    verticalMove = rowVerticalFreeSpace*0.5;
                } else if (child.valign == valignBottom) {
                    verticalMove = rowVerticalFreeSpace;
                }

                anotherChild.positionY += verticalMove;
            }
        }
    }
}

#pragma mark - Min

- (void)thumbnailsMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    width.value = [self measureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)thumbnailsMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    height.value = [self measureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
}

#pragma mark - Children

- (CGFloat)thumbnailsMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasHorizontalScroll) {
        maxWidth = INFINITY;
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    }

    CGFloat childrenWidth = 0;
    CGFloat maxLineWidth = 0;
    CGFloat lineWidth = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (lineWidth+child.blockWidth <= maxWidth) {
            lineWidth += child.blockWidth;
        } else {
            lineWidth = child.blockWidth;
        }
        if (lineWidth > maxLineWidth) {
            maxLineWidth = lineWidth;
        }
    }
    childrenWidth = maxLineWidth;

    return childrenWidth;
}

- (CGFloat)thumbnailsMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasVerticalScroll) {
        maxHeight = INFINITY;
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
    }

    CGFloat lineWidth = 0;
    CGFloat maxRowHeight = 0;
    CGFloat result = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (lineWidth+child.blockWidth <= contentWidth) {
            if (child.blockHeight > maxRowHeight) {
                maxRowHeight = child.blockHeight;
            }
            lineWidth += child.blockWidth;
        } else {
            result += maxRowHeight;
            maxRowHeight = child.blockHeight;
            lineWidth = child.blockWidth;
        }
    }

    result += maxRowHeight;

    return result;
}

@end
