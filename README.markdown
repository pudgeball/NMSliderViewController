NMSliderViewController
======================

Yup, another sliding view controller.

I made this for two reasons:

+ I wanted to learn more about UIGestureRecognizers
+ All the versions of this I've found are just not for me.

This repo holds the code for NMSliderViewController.  This will be updated with a link to a demo soon.

How to set up
======================

All you need to do is initialize an instance of NMSliderViewController with your `topViewController` and `bottomViewController` as parameters.

The `topViewController` and `bottomViewController` can be of any type, can be be loaded from xibs or have their views written in code.

 _The code will take care of the rest_.


In `AppDelegate.m`, initialize an NMSliderViewController object like this:

`[[NMSliderViewController alloc] initWithTopViewController:topViewController andBottomViewController:bottomViewController];`

And set the root view controller like this:

`self.window.rootViewController = slideViewController;`

That's all that's needed.

-------

###Upcoming Options
 + Distance openned
 + Auto-Hamburger button
