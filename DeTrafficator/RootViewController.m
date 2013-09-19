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
    
    [self.speedometer initWithFrame:CGRectMake(0, 0, 304, 400)];
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
