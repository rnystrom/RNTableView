//
//  RNViewController.h
//  TableView
//
//  Created by Ryan Nystrom on 5/18/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNTableView.h"

@interface RNViewController : UIViewController
<RNTableViewDataSource, RNTableViewDelegate>

@end
