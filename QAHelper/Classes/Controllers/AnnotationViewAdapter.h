//
//  AnnotationViewAdapter.h
//  QAHelper
//
//  Created by Sarath Vijay on 18/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <jot/jot.h>

@interface AnnotationViewAdapter : NSObject

@property (nonatomic, strong) JotViewController * jotViewController;

- (void)addAnnotationViewToContainerView:(UIView*)container andParantController:(UIViewController*)controller;
- (void)switchToTextEditingState;
- (void)switchToDrawingState;
- (void)setPencilColor:(UIColor*)pencilColor;
- (void)setTextColor:(UIColor*)textColor;
- (void)enableAnnotationView:(BOOL)enable;
- (UIImage*)drawOnImage:(UIImage*)image;
- (void)clearAll;
@end
