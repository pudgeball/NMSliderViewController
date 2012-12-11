//
//  NMSliderViewController.m
//
//
//  Created by Nick McGuire on 2012-12-08.
//  Copyright (c) 2012 RND Consulting. All rights reserved.
//

#import "NMSliderViewController.h"

typedef NS_ENUM(NSInteger, SlideState) {
	SlideStateOpen,
	SlideStateClosed
};

@interface NMSliderViewController ()

@property (nonatomic) CGPoint startingPoint;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIViewController *topViewController;
@property (strong, nonatomic) UIViewController *bottomViewController;
@property (nonatomic) SlideState currentState;
@property (nonatomic) CGRect screenBounds;
@property (nonatomic) NSInteger distanceFromLeft;

- (void)setState:(SlideState)state forSliderView:(UIView *)view;

@end

@implementation NMSliderViewController

- (id)initWithTopViewController:(UIViewController *)topViewController andBottomViewController:(UIViewController *)bottomViewController
{
	self = [super init];
    if (self)
	{
		_screenBounds = [[UIScreen mainScreen] bounds];
		
		NSString *deviceModel = [[UIDevice currentDevice] model];
		
		NSLog(@"deviceModel: %@", deviceModel);
		
		_distanceFromLeft = 280.0f;
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
		[panGesture setDelegate:self];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
		[tapGesture setDelegate:self];
		
		_topViewController = topViewController;
		
		_bottomViewController = bottomViewController;
		[[_bottomViewController view] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		
		_navigationController = [[UINavigationController alloc] initWithRootViewController:_topViewController];
		_navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		
		[[_navigationController view] addGestureRecognizer:panGesture];
		[[_navigationController view] addGestureRecognizer:tapGesture];
		
		_currentState = SlideStateClosed;
		
		[[self view] addSubview:[_bottomViewController view]];
		[[self view] addSubview:[_navigationController view]];
		
		_startingPoint = [[_navigationController view] center];
		NSLog(@"Current Center: %f, %f", _startingPoint.x, _startingPoint.y);
    }
    return self;
}

- (void)setTopViewController:(UIViewController *)topViewController
{
	[[topViewController view] setFrame:CGRectMake(0, 0, topViewController.view.frame.size.width, topViewController.view.frame.size.height)];

	_topViewController = topViewController;
	
	[_navigationController setViewControllers:@[ _topViewController ]];
	[self setState:SlideStateClosed forSliderView:_navigationController.view];
}

- (void)setState:(SlideState)state forSliderView:(UIView *)view
{
	if (state == SlideStateOpen)
	{
		_currentState = state;
		NSTimeInterval interval = 0.5 * ([view frame].origin.x / [view frame].size.width);
		NSLog(@"Should open to: %f from width: %f", [view frame].size.width - _distanceFromLeft, [view frame].size.width);
		[UIView animateWithDuration:interval animations:^{
			[view setFrame:CGRectMake(_distanceFromLeft, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
		}completion:NULL];
	}
	else if (state == SlideStateClosed)
	{
		_currentState = state;
		NSTimeInterval interval = 0.5 * ([view frame].origin.x / [view frame].size.width);
		[UIView animateWithDuration:interval delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			[view setCenter:_startingPoint];
		} completion:NULL];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view];
	CGPoint translation = [gestureRecognizer translationInView:[view superview]];
	CGPoint velocity = [gestureRecognizer velocityInView:[view superview]];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
	{
		if ([view center].x == _startingPoint.x && translation.x < 0.0) return;
		
		if ([view center].x + translation.x < _startingPoint.x)
		{
			translation = CGPointMake(_startingPoint.x - [view center].x, translation.y);
		}
			
		[view setCenter:CGPointMake([view center].x + translation.x, [view center].y)];
		[gestureRecognizer setTranslation:CGPointMake(0.1, 0.0) inView:[view superview]];
		
    }
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		if (velocity.x > 1000)
		{
			[self setState:SlideStateOpen forSliderView:view];
		}
		else if (velocity.x < -1000)
		{
			[self setState:SlideStateClosed forSliderView:view];
		}
		else
		{
			if ([view center].x == _startingPoint.x)
			{
				[self setCurrentState:SlideStateClosed];
			}
			else if ([view frame].origin.x > 160)
			{
				[self setState:SlideStateOpen forSliderView:view];
			}
			else
			{
				[self setState:SlideStateClosed forSliderView:view];
			}
		}
	}
}

- (void)tapView:(UITapGestureRecognizer *)tapGesture
{
	UIView *view = [tapGesture view];
	
	[self setState:SlideStateClosed forSliderView:view];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{	
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
	{
		UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
		CGPoint translation = [panGesture translationInView:self.view];
		BOOL isHorizontalPan = (fabsf(translation.x) > fabs(translation.y));
		return isHorizontalPan;
	}
	else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
	{
		if (_currentState == SlideStateClosed)
		{
			return NO;
		}
		else if (_currentState == SlideStateOpen)
		{
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIView *view = [_navigationController view];
	NSLog(@"Current Center: %f, %f", view.center.x, view.center.y);
	
	if (_currentState == SlideStateClosed)
	{
		_startingPoint = CGPointMake([view center].x, [view center].y);
	}
	else if (_currentState == SlideStateOpen)
	{
		_startingPoint = CGPointMake([view center].x - _distanceFromLeft, [view center].y);
	}
	
	NSLog(@"Current Center: %f, %f", _startingPoint.x, _startingPoint.y);
}


@end
