//
//  AnnotationViewAdapter.m
//  QAHelper
//
//  Created by Sarath Vijay on 18/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

#import "AnnotationViewAdapter.h"
#import <Masonry/Masonry.h>

@implementation AnnotationViewAdapter

- (instancetype)init {
    if ((self = [super init])) {
        _jotViewController = [JotViewController new];
        self.jotViewController.view.backgroundColor = [UIColor clearColor];
        self.jotViewController.state = JotViewStateDrawing;
        self.jotViewController.textColor = [UIColor redColor];
        self.jotViewController.font = [UIFont boldSystemFontOfSize:64.f];
        self.jotViewController.fontSize = 64.f;
        self.jotViewController.textEditingInsets = UIEdgeInsetsMake(12.f, 6.f, 0.f, 6.f);
        self.jotViewController.initialTextInsets = UIEdgeInsetsMake(6.f, 6.f, 6.f, 6.f);
        self.jotViewController.fitOriginalFontSizeToViewWidth = YES;
        self.jotViewController.textAlignment = NSTextAlignmentLeft;
        self.jotViewController.drawingColor = [UIColor redColor];
    }
    return self;
}

- (void)addAnnotationViewToContainerView:(UIView*)container andParantController:(UIViewController*)controller {
    [controller addChildViewController:self.jotViewController];
    [container addSubview:self.jotViewController.view];
    [self.jotViewController didMoveToParentViewController:controller];
    [self.jotViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    [self enableAnnotationView:YES];
}

- (void)switchToTextEditingState {
    [self enableAnnotationView:YES];
    if (self.jotViewController.textString.length == 0) {
        self.jotViewController.state = JotViewStateEditingText;
    } else {
        self.jotViewController.state = JotViewStateText;
    }
}

- (void)switchToDrawingState {
    [self enableAnnotationView:YES];
    self.jotViewController.state = JotViewStateDrawing;
}

- (void)setPencilColor:(UIColor*)pencilColor {
    self.jotViewController.drawingColor = pencilColor;
}

- (void)setTextColor:(UIColor*)textColor {
    self.jotViewController.textColor = textColor;
    
}

- (void)enableAnnotationView:(BOOL)enable {
    self.jotViewController.view.superview.userInteractionEnabled = YES;//SV since we add jot inside a uiview.
    self.jotViewController.view.userInteractionEnabled = enable;
}

- (UIImage*)drawOnImage:(UIImage*)image {
    UIImage * finalImage = [self.jotViewController drawOnImage:image];
    return finalImage;
}

- (void)clearAll {
    [self.jotViewController clearAll];
}

@end

