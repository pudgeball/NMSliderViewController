NMSliderViewController
======================

Yup, another sliding view controller.

I made this for two reasons:

+ I wanted to learn more about UIGestureRecognizers
+ All the versions of this I've found are just not for me.

This repo holds the code for NMSliderViewController.  This will be updated with a link to a demo soon.

**How to set up**

All you need to do is initialize the `slideViewController` with your `topViewController` and `bottomViewController` as parameters.
 _The code will take care of the rest_.


======================
In `AppDelegate.m`, initialize an NMSliderViewController object like this:

`[[NMSliderViewController alloc] initWithTopViewController:topViewController andBottomViewController:bottomViewController];`

And set the root view controller like this:

`self.window.rootViewController = slideViewController;`

Thats it. Easy.