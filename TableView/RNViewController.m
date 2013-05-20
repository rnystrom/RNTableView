//
//  RNViewController.m
//  TableView
//
//  Created by Ryan Nystrom on 5/18/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNViewController.h"
#import "RNSampleView.h"
#import <QuartzCore/QuartzCore.h>

@interface RNViewController ()

@property (nonatomic, weak) IBOutlet RNTableView *tableView;

@end

@implementation RNViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    [self.tableView registerContentViewClass:[RNSampleView class]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

#pragma mark - Tableview datasource

- (NSInteger)numberOfItemsInTableView:(RNTableView *)tableView {
    return 10000;
}

- (UIView *)viewForTableView:(RNTableView *)tableView atIndex:(NSInteger)index withReuseView:(RNSampleView *)reuseView {
    reuseView.textLabel.text = [NSString stringWithFormat:@"View %i",index];
    reuseView.layer.anchorPoint = CGPointMake(0, 0.5f);
    
    CAGradientLayer *layer = (CAGradientLayer *)reuseView.layer;
    layer.colors = @[
                     (id)[UIColor colorWithWhite:1 alpha:1].CGColor,
                     (id)[UIColor colorWithWhite:0.9 alpha:1].CGColor
                     ];
    
    return reuseView;
}

#pragma mark - Tableview delegate

- (CGFloat)heightForViewInTableView:(RNTableView *)tableView atIndex:(NSInteger)index {
    return 55;
}

- (void)tableView:(RNTableView *)tableView didSelectView:(RNSampleView *)view atIndex:(NSInteger)index {
    __block CGRect frame = view.frame;
    frame.origin.x += 6;
    [UIView animateWithDuration:0.1f animations:^{view.frame = frame;} completion:^(BOOL finished){
        frame.origin.x -= 9;
        [UIView animateWithDuration:0.1f animations:^{view.frame = frame;} completion:^(BOOL finished){
            frame.origin.x += 3;
            [UIView animateWithDuration:0.1f animations:^{view.frame = frame;} completion:nil];
        }];
    }];
}

@end
