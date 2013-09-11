//
//  CoreLocationController.h
//  DeTrafficator
//
//  Created by Robin Johnson on 7/12/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//http://www.vellios.com/2010/08/16/core-location-gps-tutorial/

@interface CoreLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;

- (void)resetAvg;

@end

@protocol CoreLocationControllerDelegate
@required
- (void)locationUpdate:(CLLocation *)location withAvgSpeed:(CLLocationSpeed) avgSpeed;
- (void)locationError:(NSError *)error;
@end
