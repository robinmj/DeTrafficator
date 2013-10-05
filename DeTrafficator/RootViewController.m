//
//  RootViewController.m
//  DeTrafficator
//
//  Created by Robin Johnson on 7/4/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize CLController = _CLController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->prevSpeed = 0.0;
    
    // Load sounds
    
    CFBundleRef mainBundle = CFBundleGetMainBundle ();
    
    CFURLRef speedUpFileURLRef  = CFBundleCopyResourceURL(mainBundle, CFSTR ("speed_up"), CFSTR ("aif"), NULL);
    CFURLRef slowDownFileURLRef  = CFBundleCopyResourceURL(mainBundle, CFSTR ("slow_down"), CFSTR ("aif"), NULL);
    
    AudioServicesCreateSystemSoundID(speedUpFileURLRef, &speedUpSound);
    AudioServicesCreateSystemSoundID(slowDownFileURLRef, &slowDownSound);
    

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.view.frame = pageViewRect;
	
    CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
    [self setSamplingPeriod:self.periodSlider];
	[CLController.locMgr startUpdatingLocation];
    
    self.speedometer = [self.speedometer init];
    
    //assemble constraints needed to be added in order to adjust layout for landscape orientation
    
    self->landSpeedometerBottomSpacing = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.speedometer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    self->landControlViewSpeedometerSpacing = [NSLayoutConstraint constraintWithItem:self.controlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.speedometer attribute:NSLayoutAttributeRight multiplier:1.0 constant:8.0];
    
    /*
    debug_NSLog(@"view %@", self.view);
    debug_NSLog(@"speedometer %@", self.speedometer);
    debug_NSLog(@"controlView %@", self.controlView);
    
    [self displayConstraint:self.controlViewSpeedometerSpacing withName:@"controlViewSpeedometerSpacing"];
    
    [self displayConstraint:self->landSpeedometerBottom withName:@"landSpeedometerBottom"];
    [self displayConstraint:self->landControlViewSpeedometerSpacing withName:@"landControlViewSpeedometerSpacing"];*/
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    /*for(NSLayoutConstraint* c in self.view.constraints) {
        [self displayConstraint:c withName:@""];
    }*/
    
    //reposition views
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        [self.view removeConstraint:self.controlViewSpeedometerSpacing];
        [self.view removeConstraint:self.controlViewLeftSpacing];
        [self.view addConstraint:self->landSpeedometerBottomSpacing];
        [self.view addConstraint:self->landControlViewSpeedometerSpacing];
    } else {
        [self.view removeConstraint:self->landSpeedometerBottomSpacing];
        [self.view removeConstraint:self->landControlViewSpeedometerSpacing];
        [self.view addConstraint:self.controlViewSpeedometerSpacing];
        [self.view addConstraint:self.controlViewLeftSpacing];
    }
    
    [self.view setNeedsUpdateConstraints];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //speedometer indicator gets thrown off when it is resized.
    // this is only a problem when the speed is not being updated
    [self.speedometer refreshIndicator];
}

//for debugging layouts
- (void)displayConstraint:(NSLayoutConstraint*)c withName:(NSString*)name
{
    NSString* firstItem = [self identifyItem:c.firstItem];
    NSString* secondItem = [self identifyItem:c.secondItem];
    
    debug_NSLog(@"constraint %@(%@): %@ %@ %f %d %@ %@", name, c, firstItem, [self identifyLayoutAttribute:c.firstAttribute], c.constant, c.relation, secondItem, [self identifyLayoutAttribute:c.secondAttribute]);
}

//for debugging layouts
- (NSString*)identifyItem:(id)item
{
    if(item == self.view) {
        return @"view";
    } else if(item == self.speedometer) {
        return @"speedometer";
    } else if(item == self.controlView) {
        return @"controlView";
    }
    return [[NSString alloc] initWithFormat:@"%@",item];
}

//for debugging layouts
- (NSString*)identifyLayoutAttribute:(NSLayoutAttribute)attr
{
    switch ((NSInteger)attr) {
        case NSLayoutAttributeLeft:
            return @"NSLayoutAttributeLeft";
        case NSLayoutAttributeRight:
            return @"NSLayoutAttributeRight";
        case NSLayoutAttributeTop:
            return @"NSLayoutAttributeTop";
        case NSLayoutAttributeBottom:
            return @"NSLayoutAttributeBottom";
        case NSLayoutAttributeLeading:
            return @"NSLayoutAttributeLeading";
        case NSLayoutAttributeTrailing:
            return @"NSLayoutAttributeTrailing";
        case NSLayoutAttributeWidth:
            return @"NSLayoutAttributeWidth";
        case NSLayoutAttributeHeight:
            return @"NSLayoutAttributeHeight";
        case NSLayoutAttributeCenterX:
            return @"NSLayoutAttributeCenterX";
        case NSLayoutAttributeCenterY:
            return @"NSLayoutAttributeCenterY";
        case NSLayoutAttributeBaseline:
            return @"NSLayoutAttributeBaseline";
    }
    
    return @"NSLayoutAttributeNotAnAttribute";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationUpdate:(CLLocation *)location withAvgSpeed:(CLLocationSpeed)avgSpeed {
    double currentSpeed = [location speed];
    
    if(currentSpeed < 0.0) {
        [self.speedometer disable];
        return;
    }
    
    self.speedometer.currentSpeed = currentSpeed;
    self.speedometer.avgSpeed = avgSpeed;
    
    double dsRatio = (currentSpeed - avgSpeed) / currentSpeed;
    
    if(dsRatio > 0.1 && prevSpeed <= currentSpeed) {
        AudioServicesPlaySystemSound (self->slowDownSound);
    } else if(dsRatio < -0.1 && prevSpeed >= currentSpeed) {
        AudioServicesPlaySystemSound (self->speedUpSound);
    }
    self->prevSpeed = currentSpeed;
}

- (void)locationError:(NSError *)error {
    [self.speedometer disable];
}

- (IBAction)resetAverage:(id)sender {
    [self.speedometer resetAvg];
    [CLController resetAvg];
}

- (IBAction)adjustSamplingPeriod:(id)sender {
    UISlider *periodSlider = (UISlider*)sender;
    
    self.periodLabel.text = [self humanizePeriod:roundf(periodSlider.value)];
}

- (IBAction)setSamplingPeriod:(id)sender {
    UISlider *periodSlider = (UISlider*)sender;
    
    //round to the nearest half minute
    float periodHalfMinutes = roundf(periodSlider.value);
    
    periodSlider.value = periodHalfMinutes;
    
    self.periodLabel.text = [self humanizePeriod:(NSInteger)periodHalfMinutes];
    
    float periodSeconds = periodHalfMinutes * 30.0f;
    [CLController setSamplingPeriod:periodSeconds];
}

- (NSString*)humanizePeriod:(NSInteger) halfMinutes {
    
    if(halfMinutes == 1) {
        return @"30 sec";
    }
    
    NSInteger minutes = halfMinutes / 2;
    
    if(halfMinutes % 2 == 0) {
        
        return [NSString stringWithFormat:@"%d min",minutes];
    }
    
    return [NSString stringWithFormat:@"%d.5 min",minutes];
}

@end
