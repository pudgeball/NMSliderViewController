//
//  NMSliderViewController.h
//  
//
//  Created by Nick McGuire on 2012-12-08.
//  Copyright (c) 2012 RND Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NMSliderViewController : UIViewController <UIGestureRecognizerDelegate>

- (id)initWithTopViewController:(UIViewController *)topViewController andBottomViewController:(UIViewController *)bottomViewController;
- (void)setTopViewController:(UIViewController *)topViewController;
- (void)hamburgerButtonWasPressed;

- (void)closeDrawer;

@end
