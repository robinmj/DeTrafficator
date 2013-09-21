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
	[CLController.locMgr startUpdatingLocation];
    
    [self.speedometer init];
    
    //assemble constraints needed to be added in order to adjust layout for landscape orientation
    
    self->landSpeedometerTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.speedometer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    self->landSpeedometerResetButtonConstraint = [NSLayoutConstraint constraintWithItem:self.speedometer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.resetButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-8.0];
    
    
    //retreive constraints needed to be removed in order to adjust layout for landscape orientation
    
    for(NSLayoutConstraint* c in self.contentView.constraints) {
        
        if(c.firstItem == self.speedometer && c.firstAttribute == NSLayoutAttributeTrailing && c.secondItem == self.contentView && c.secondAttribute == NSLayoutAttributeTrailing) {
            self->portSpeedometerTrailingConstraint = c;
        }
        
        if(c.firstItem == self.resetButton
           && c.firstAttribute == NSLayoutAttributeTop
           && c.secondItem == self.speedometer
           && c.secondAttribute == NSLayoutAttributeBottom) {
            self->portSpeedometerResetButtonConstraint = c;
        }
    }
    
    assert(self->portSpeedometerResetButtonConstraint);
    assert(self->portSpeedometerTrailingConstraint);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    //reposition views
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        [self.contentView removeConstraint:self->portSpeedometerResetButtonConstraint];
        [self.contentView removeConstraint:self->portSpeedometerTrailingConstraint];
        [self.contentView addConstraint:self->landSpeedometerResetButtonConstraint];
        [self.contentView addConstraint:self->landSpeedometerTrailingConstraint];
    } else {
        [self.contentView removeConstraint:self->landSpeedometerResetButtonConstraint];
        [self.contentView removeConstraint:self->landSpeedometerTrailingConstraint];
        [self.contentView addConstraint:self->portSpeedometerResetButtonConstraint];
        [self.contentView addConstraint:self->portSpeedometerTrailingConstraint];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationUpdate:(CLLocation *)location withAvgSpeed:(CLLocationSpeed)avgSpeed {
    double currentSpeed = [location speed];
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
    [CLController resetAvg];
}

@end
