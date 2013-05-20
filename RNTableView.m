//
//  RNTableView.m
//  TableView
//
//  Created by Ryan Nystrom on 5/18/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNTableView.h"

CGFloat const kRNTableViewCellDefaultHeight = 40;

@interface RNRowObject : NSObject
@property (nonatomic, strong) UIView *cachedView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat height;
@end
@implementation RNRowObject
@end

@interface RNTableView ()
@property (nonatomic, strong) NSMutableArray *reusePool;
@property (nonatomic, strong) NSMutableArray *rowObjects;
@property (nonatomic, copy) Class contentViewClass;
@property (nonatomic, strong) NSMutableIndexSet* visibleRows;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation RNTableView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:_tapGesture];
    
    _reusePool = [NSMutableArray array];
    _visibleRows = [NSMutableIndexSet indexSet];
    
    self.bounces = YES;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = YES;
}

- (UIView *)dequeReusableView {
    UIView *view = [self.reusePool lastObject];
    if (! view) {
        view = [[self.contentViewClass alloc] init];
    }
    else {
        [self.reusePool removeObject:view];
    }
    return view;
}

- (void)generateHeightAndOffsetData {
    BOOL checkForHeightEachRow = [self.delegate respondsToSelector:@selector(heightForViewInTableView:atIndex:)];
    NSInteger numberOfRow = [self.dataSource numberOfItemsInTableView:self];
    CGFloat startY = 0;
    self.rowObjects = [NSMutableArray array];
    @autoreleasepool {
        for (NSInteger i = 0; i < numberOfRow; i++) {
            RNRowObject *rowObject = [[RNRowObject alloc] init];
            rowObject.index = i;
            rowObject.height = checkForHeightEachRow ? [self.delegate heightForViewInTableView:self atIndex:i] : kRNTableViewCellDefaultHeight;
            rowObject.startY = startY;
            startY += rowObject.height;
            [self.rowObjects addObject:rowObject];
        }
    }
    self.contentSize = CGSizeMake(self.bounds.size.width, startY);
}

- (void)layoutTableView {
    CGFloat startY = self.contentOffset.y;
    CGFloat endY = startY + self.frame.size.height;
    NSInteger rowToDisplay = [self findRowForOffsetY:startY inRange:NSMakeRange(0, [self.rowObjects count])];
    NSMutableIndexSet *newVisibleRows = [NSMutableIndexSet indexSet];
    CGFloat yOrigin;
    CGFloat rowHeight;
    do {
        [newVisibleRows addIndex:rowToDisplay];
        yOrigin = [self startPositionYForIndex:rowToDisplay];
        rowHeight = [self heightForIndex:rowToDisplay];
        UIView *view = [self cachedViewForIndex:rowToDisplay];
        if (! view) {
            UIView *view = [self.dataSource viewForTableView:self atIndex:rowToDisplay withReuseView:[self dequeReusableView]];
            [self setCachedView:view forIndex:rowToDisplay];
            view.frame = CGRectMake(0, yOrigin, self.bounds.size.width, rowHeight);
            [self insertSubview:view atIndex:0];
        }
        rowToDisplay++;
    } while (yOrigin + rowHeight < endY && rowToDisplay < [self.rowObjects count]);
    [self returnNonVisibleRowsToThePool:newVisibleRows];
}

- (NSInteger)findRowForOffsetY: (CGFloat) yPosition inRange: (NSRange) range {
    if ([self.rowObjects count] == 0) return 0;
    
    RNRowObject *rowObject = [[RNRowObject alloc] init];
    rowObject.startY = yPosition;
    
    NSInteger index = [self.rowObjects indexOfObject:rowObject inSortedRange:NSMakeRange(0, [self.rowObjects count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult (RNRowObject *r1, RNRowObject *r2) {
        if (r1.startY < r2.startY) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    return MAX(0, index - 1);
}

- (void)reloadData {
    [self returnNonVisibleRowsToThePool:nil];
    [self generateHeightAndOffsetData];
//    [self layoutTableView];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    [self layoutTableView];
}

- (void)returnNonVisibleRowsToThePool:(NSMutableIndexSet*)currentVisibleRows {
    [self.visibleRows removeIndexes:currentVisibleRows];
    [self.visibleRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        UIView *view = [self cachedViewForIndex:idx];
        if (view) {
            [self.reusePool addObject:view];
            [view removeFromSuperview];
            [self setCachedView:nil forIndex:idx];
        }
    }];
    self.visibleRows = currentVisibleRows;
}

- (void)registerContentViewClass:(Class)contentViewClass {
    self.contentViewClass = contentViewClass;
}

- (UIView *)cachedViewForIndex:(NSInteger)index {
    return [(RNRowObject *)self.rowObjects[index] cachedView];
}

- (void)setCachedView:(UIView *)view forIndex:(NSInteger)index {
    RNRowObject *rowObject = self.rowObjects[index];
    rowObject.cachedView = view;
}

- (CGFloat)heightForIndex:(NSInteger)index {
    return [(RNRowObject *)self.rowObjects[index] height];
}

- (CGFloat)startPositionYForIndex:(NSInteger)index {
    return [(RNRowObject *)self.rowObjects[index] startY];
}

- (NSArray *)visibleViews {
    return [[self.rowObjects objectsAtIndexes:self.visibleRows] valueForKeyPath:@"cachedView"];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer == self.tapGesture && [self.delegate respondsToSelector:@selector(tableView:didSelectView:atIndex:)]) {
        UIView *view = [self viewAtPoint:[recognizer locationInView:self]];
        if (view) {
            NSArray *rowObjects = [self.rowObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"cachedView = %@",view]];
            RNRowObject *rowObject = [rowObjects lastObject];
            if (rowObject) {
                [self.delegate tableView:self didSelectView:view atIndex:rowObject.index];
            }
        }
    }
}

- (UIView *)viewAtPoint:(CGPoint)point {
    for (UIView *view in [self visibleViews]) {
        if (CGRectContainsPoint(view.frame, point)) return view;
    }
    return nil;
}

@end
