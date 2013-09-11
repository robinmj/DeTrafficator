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

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.view.frame = pageViewRect;
	
    CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
    
    [self.speedometer initWithFrame:CGRectMake(0, 0, 300, 300)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationUpdate:(CLLocation *)location withAvgSpeed:(CLLocationSpeed)avgSpeed {
    self.speedometer.currentSpeed = [location speed];
	self.currentSpeedLabel.text = [NSString stringWithFormat:@"%f", [location speed]];
	self.avgSpeedLabel.text = [NSString stringWithFormat:@"%f", avgSpeed];
}

- (void)locationError:(NSError *)error {
	self.currentSpeedLabel.text = [error description];
}

@end
