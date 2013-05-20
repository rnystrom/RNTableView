//
//  RNSampleView.m
//  TableView
//
//  Created by Ryan Nystrom on 5/19/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNSampleView.h"
#import <QuartzCore/QuartzCore.h>

@interface RNSampleView ()
@property (nonatomic, strong, readwrite) UILabel *textLabel;
@end

@implementation RNSampleView
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
    _textLabel = [[UILabel alloc] init];
    _textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_textLabel];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect bounds = CGRectInset(self.bounds, 10, 0);
    self.textLabel.frame = bounds;
}

@end
