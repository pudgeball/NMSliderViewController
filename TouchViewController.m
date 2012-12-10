//
//  TouchViewController.m
//  NMSlider
//
//  Created by Nick McGuire on 2012-12-08.
//  Copyright (c) 2012 RND Consulting. All rights reserved.
//

#import "TouchViewController.h"
#import "NMScrollView.h"
#import "GreenViewController.h"

typedef NS_ENUM(NSInteger, SlideState) {
	SlideStateOpen,
	SlideStateClosed
};

@interface TouchViewController ()

@property (nonatomic) CGPoint startingPoint;

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIViewController *viewController;
@property (nonatomic) SlideState currentState;

- (void)setState:(SlideState )state;

@end

@implementation TouchViewController

@synthesize navController, viewController;

- (id)init
{
	self = [super init];
    if (self)
	{
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
		[panGesture setDelegate:self];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
		[tapGesture setDelegate:self];
		
		UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
		//UINavigationController *tableNav = [[UINavigationController alloc] initWithRootViewController:tableViewController];
		tableViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		[[tableViewController tableView] setDelegate:self];
		[[tableViewController tableView] setDataSource:self];
		
		viewController = [[UIViewController alloc] init];
		[[viewController view] setBackgroundColor:[UIColor redColor]];
		[viewController addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionNew context:NULL];
		
		navController = [[UINavigationController alloc] initWithRootViewController:viewController];
		navController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		
		
		viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(push:)];
		viewController.navigationItem.title = @"Zomg Title";
		
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
		[scrollView setContentSize:CGSizeMake(320, 1000)];

		[scrollView addGestureRecognizer:panGesture];
		[scrollView addGestureRecognizer:tapGesture];
		
		[[navController view] addGestureRecognizer:panGesture];
		[[navController view] addGestureRecognizer:tapGesture];
		
		[scrollView setBackgroundColor:[UIColor blueColor]];
		
		UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height) style:UITableViewStyleGrouped];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		
		_currentState = SlideStateClosed;
		
		[[self view] addSubview:tableViewController.view];
		[[self view] addSubview:navController.view];
		
		_startingPoint = [scrollView center];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"view.frame"])
	{
		NSLog(@"Frame %f", [viewController view].frame.origin.x);
	}
}

-(void)push:(id)sender
{
	GreenViewController *test = [[GreenViewController alloc] init];
	[[viewController navigationController] pushViewController:test animated:YES];
}

- (void)setState:(SlideState)state
{
	if (state == SlideStateOpen)
	{
		_currentState = state;
	}
	else if (state == SlideStateClosed)
	{
		_currentState = state;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
	CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
	CGPoint velocity = [gestureRecognizer velocityInView:[piece superview]];
	
	//NSLog(@"Velocity: %f", velocity.x);
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
	{
		//NSLog(@"Center: %f", translation.x);
		if ([piece center].x == _startingPoint.x && translation.x < 0.0)
		{
			return;
		}
		else
		{
			if ([piece center].x + translation.x < _startingPoint.x)
			{
				translation = CGPointMake(_startingPoint.x - [piece center].x, translation.y);
			}
			
			[piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
			[gestureRecognizer setTranslation:CGPointMake(0.1, 0.0) inView:[piece superview]];
		}
    }
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		if (velocity.x > 1000)
		{
			NSTimeInterval interval = 0.5 * ([piece frame].origin.x / 320);
			[UIView animateWithDuration:interval animations:^{
				[piece setFrame:CGRectMake(320 - 40, piece.frame.origin.y, piece.frame.size.width, piece.frame.size.height)];
			}completion:NULL];
			[self setState:SlideStateOpen];
		}
		else if (velocity.x < -1000)
		{
			NSTimeInterval interval = 0.5 * ([piece frame].origin.x / 320);
			[UIView animateWithDuration:interval delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[piece setCenter:_startingPoint];
			} completion:NULL];
			
			[self setState:SlideStateClosed];
		}
		else
		{
			NSLog(@"velocity");
			if ([piece frame].origin.x > 160)
			{
				NSTimeInterval interval = 0.5 * ([piece frame].origin.x / 320);
				[UIView animateWithDuration:interval animations:^{
					[piece setFrame:CGRectMake(320 - 40, piece.frame.origin.y, piece.frame.size.width, piece.frame.size.height)];
				}completion:NULL];
				
				[self setState:SlideStateOpen];
			}
			else
			{
				NSTimeInterval interval = 0.7 * ([piece frame].origin.x / 320);
				[UIView animateWithDuration:interval delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					[piece setCenter:_startingPoint];
				} completion:NULL];
				
				[self setState:SlideStateClosed];
			}
		}
	}
}

- (void)tapView:(UITapGestureRecognizer *)tapGesture
{
	UIView *piece = [tapGesture view];
	
	NSTimeInterval interval = 0.5 * ([piece frame].origin.x / 320);
	[UIView animateWithDuration:interval delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[piece setCenter:_startingPoint];
	} completion:NULL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	NSLog(@"ZOMG: ");
	
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
			NSLog(@"NO");
			return NO;
		}
		else if (_currentState == SlideStateOpen)
		{
			NSLog(@"YES");
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	
	cell.textLabel.text = @"Text";
	return cell;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 20;
}



@end
