//
//  DataViewController.m
//  DeTrafficator
//
//  Created by Robin Johnson on 7/4/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#import "DataViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DataViewController ()

@end

@class SpeedometerView;

@implementation DataViewController

@synthesize CLController = _CLController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    debug_NSLog(@"viewWillAppear");
}

- (void)locationUpdate:(CLLocation *)location withAvgSpeed:(CLLocationSpeed)avgSpeed {
    self.speedometer.currentSpeed = [location speed];
	self.currentSpeedLabel.text = [NSString stringWithFormat:@"%f", [location speed]];
	self.avgSpeedLabel.text = [NSString stringWithFormat:@"%f", avgSpeed];
}

- (void)locationError:(NSError *)error {
	self.currentSpeedLabel.text = [error description];
}



+ (void)logRect:(CGRect) rect withDesc:(NSString *) description {
    debug_NSLog(@"%@ %f %f %f %f",description, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

@end
