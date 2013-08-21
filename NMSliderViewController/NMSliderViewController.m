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

@property (nonatomic) NSInteger minimumDistance;
@property (nonatomic) NSInteger distanceFromLeft;
@property (nonatomic) NSInteger minimumVelocity;

- (void)setState:(SlideState)state forSliderView:(UIView *)view;
- (void)setState:(SlideState)state forSliderView:(UIView *)view withAnimationOption:(UIViewAnimationOptions)options;
- (void)setState:(SlideState)state forSliderView:(UIView *)view withVelocity:(CGFloat)velocity withAnimationOption:(UIViewAnimationOptions)options withCompletionBlock:(void (^) (BOOL finished))completion;

@end

@implementation NMSliderViewController

#pragma mark - Initializers

- (id)initWithTopViewController:(UIViewController *)topViewController andBottomViewController:(UIViewController *)bottomViewController
{
    if (self = [super init])
	{
		_distanceFromLeft = 280.0f;
		_minimumDistance = 160.0f;
		_minimumVelocity = 1000.0f;
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
		[panGesture setDelegate:self];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
		[tapGesture setDelegate:self];
		
		_topViewController = topViewController;
		_bottomViewController = bottomViewController;
		
		[[_bottomViewController view] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
		
		_navigationController = [[UINavigationController alloc] initWithRootViewController:_topViewController];
		[[_navigationController view] setFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
		
		[[_navigationController view] addGestureRecognizer:panGesture];
		[[_navigationController view] addGestureRecognizer:tapGesture];
		
		[self setCurrentState:SlideStateClosed];
		
		[self addChildViewController:_bottomViewController];
		[self.view addSubview:_bottomViewController.view];
		[_bottomViewController didMoveToParentViewController:self];
		
		[self addChildViewController:_navigationController];
		[self.view addSubview:_navigationController.view];
		[_navigationController didMoveToParentViewController:self];
		
		_startingPoint = [[_navigationController view] center];
		
		UIImage *hamburger = [UIImage imageNamed:@"Hamburger"];
		
		UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:hamburger style:UIBarButtonItemStyleBordered target:self action:@selector(hamburgerButtonWasPressed)];
		
		self.topViewController.navigationItem.leftBarButtonItem = hamburgerButton;

		_navigationController.view.backgroundColor = _topViewController.view.backgroundColor;
		
		_navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
		_navigationController.view.layer.shadowOffset = CGSizeMake(-1.0, 0.0);
		_navigationController.view.layer.shadowOpacity = 0.5;
		_navigationController.view.layer.shadowRadius = 2.5;
		_navigationController.view.layer.shouldRasterize = YES;
		_navigationController.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
		_navigationController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationController.view.layer.bounds].CGPath;
		_navigationController.view.clipsToBounds = NO;
    }
    return self;
}

#pragma mark - NMSliderViewController Methods

- (void)setTopViewController:(UIViewController *)topViewController
{
	void (^completion)(BOOL finished);
	
	if (_topViewController != topViewController)
	{
		[[topViewController view] setFrame:CGRectMake(0, 0, CGRectGetWidth(topViewController.view.frame), CGRectGetHeight(topViewController.view.frame))];

		_topViewController = topViewController;
		
		_navigationController.view.backgroundColor = _topViewController.view.backgroundColor;
	
		[_navigationController setViewControllers:@[ _topViewController ]];
		
		completion = NULL;
	}
	else
	{
		completion = ^ void (BOOL finished) {
			[[_topViewController navigationController] popToRootViewControllerAnimated:YES];
		};
	}
	
	[self setState:SlideStateClosed forSliderView:_navigationController.view withVelocity:1.5 withAnimationOption:UIViewAnimationOptionCurveEaseOut withCompletionBlock:completion];
}

- (void)hamburgerButtonWasPressed
{
	if (self.currentState == SlideStateClosed) {
		[self setState:SlideStateOpen forSliderView:_navigationController.view];
	} else if (self.currentState == SlideStateOpen) {
		[self setState:SlideStateClosed forSliderView:_navigationController.view];
	}
}

#pragma mark - SlideState Methods

- (void)setState:(SlideState)state forSliderView:(UIView *)view {
	[self setState:state forSliderView:view withVelocity:1.0 withAnimationOption:UIViewAnimationOptionCurveEaseOut withCompletionBlock:NULL];
}

- (void)setState:(SlideState)state forSliderView:(UIView *)view withAnimationOption:(UIViewAnimationOptions)options
{
	[self setState:state forSliderView:view withVelocity:1.0 withAnimationOption:options withCompletionBlock:NULL];
}

- (void)setState:(SlideState)state forSliderView:(UIView *)view withVelocity:(CGFloat)velocity withAnimationOption:(UIViewAnimationOptions)options withCompletionBlock:(void (^) (BOOL finished))completion
{
	_currentState = state;
	NSTimeInterval interval = (0.5 * (CGRectGetMinX([view frame]) / CGRectGetWidth([view frame]))) / velocity;
	
	if (state == SlideStateOpen)
	{
		[UIView animateWithDuration:interval delay:0.0 options:options animations:^{
			[view setFrame:CGRectMake(_distanceFromLeft, CGRectGetMinY([view frame]), CGRectGetWidth([view frame]), CGRectGetHeight([view frame]))];
		}completion:completion];
	}
	else if (state == SlideStateClosed)
	{
		[UIView animateWithDuration:interval delay:0.0 options:options animations:^{
			[view setCenter:_startingPoint];
		} completion:completion];
	}
}

#pragma mark - UIView Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	_navigationController.view.layer.shouldRasterize = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIView *view = [_navigationController view];
	_navigationController.view.layer.shouldRasterize = NO;
	
	if (_currentState == SlideStateClosed)
	{
		_startingPoint = CGPointMake(CGRectGetMidX([view frame]), CGRectGetMidY([view frame]));
	}
	else if (_currentState == SlideStateOpen)
	{
		_startingPoint = CGPointMake(CGRectGetMidX([view frame]) - _distanceFromLeft, CGRectGetMidY([view frame]));
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIGestureRecognizer Delegate Methods

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
	return NO;
}

#pragma mark - UIGestureRecognizer Methods

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
	else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		if (velocity.x > _minimumVelocity)
		{
			[self setState:SlideStateOpen forSliderView:view];
		}
		else if (velocity.x < -_minimumVelocity)
		{
			[self setState:SlideStateClosed forSliderView:view];
		}
		else
		{
			if ([view center].x == _startingPoint.x)
			{
				[self setCurrentState:SlideStateClosed];
			}
			else if ([view frame].origin.x > _minimumDistance)
			{
				[self setState:SlideStateOpen forSliderView:view];
			}
			else
			{
				[self setState:SlideStateClosed forSliderView:view withAnimationOption:UIViewAnimationOptionCurveEaseIn];
			}
		}
	}
}

- (void)tapView:(UITapGestureRecognizer *)tapGesture
{
	UIView *view = [tapGesture view];
	
	[self setState:SlideStateClosed forSliderView:view];
}

- (void)closeDrawer {
	[self setState:SlideStateClosed forSliderView:_navigationController.view withVelocity:1.5 withAnimationOption:UIViewAnimationOptionCurveEaseOut withCompletionBlock:nil];
}

@end
