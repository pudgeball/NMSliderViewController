//
//  NMSliderViewController.h
//  
//
//  Created by Nick McGuire on 2012-12-08.
//  Copyright (c) 2012 RND Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMSliderViewController : UIViewController <UIGestureRecognizerDelegate>

- (id)initWithTopViewController:(UIViewController *)topViewController andBottomViewController:(UIViewController *)bottomViewController;

@end