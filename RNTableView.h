//
//  RNTableView.h
//  TableView
//
//  Created by Ryan Nystrom on 5/18/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RNTableView;

@protocol RNTableViewDataSource <NSObject>
@required
- (NSInteger)numberOfItemsInTableView:(RNTableView *)tableView;
- (UIView *)viewForTableView:(RNTableView *)tableView atIndex:(NSInteger)index withReuseView:(UIView *)reuseView;
@end

@protocol RNTableViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (CGFloat)heightForViewInTableView:(RNTableView *)tableView atIndex:(NSInteger)index;
- (void)tableView:(RNTableView *)tableView didSelectView:(UIView *)view atIndex:(NSInteger)index;
@end

@interface RNTableView : UIScrollView
@property (nonatomic, weak) id <RNTableViewDataSource> dataSource;
@property (nonatomic, weak) id <RNTableViewDelegate> delegate;
- (void)registerContentViewClass:(Class)contentViewClass;
- (void)reloadData;
- (NSArray *)visibleViews;
@end
