//
//  CoreLocationController.m
//  DeTrafficator
//
//  Created by Robin Johnson on 7/12/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#import "CoreLocationController.h"
#import "DeTrafficator.h"

@interface CoreLocationController ()

@property (nonatomic, retain) NSMutableArray *speedData;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) CLLocationSpeed avgSpeed;

@end

@implementation CoreLocationController

@synthesize locMgr = _locMgr;
@synthesize delegate = _delegate;

- (id)init {
	self = [super init];
    
	if(self != nil) {
		self.locMgr = [[CLLocationManager alloc] init]; // Create new instance of locMgr
		self.locMgr.delegate = self; // Set the delegate as self.
        
        //5 minutes
        self.timeInterval = 5 * 60;
        self.speedData = [NSMutableArray array];
	}
    
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    CLLocation *firstValidReading = nil;
    
    NSInteger firstValidReadingIdx = 0;
    
    debug_NSLog(@"speedData.count = %i", self.speedData.count);
    debug_NSLog(@"reading interval=%f",[newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]);
    
    for (; firstValidReadingIdx < _speedData.count; firstValidReadingIdx++) {
        CLLocation *reading = [_speedData objectAtIndex:firstValidReadingIdx];
        
        if([newLocation.timestamp timeIntervalSinceDate:reading.timestamp] <= _timeInterval) {
            firstValidReading = reading;
            break;
        }
    }
    
    if(firstValidReading == nil) {
        //only one reading- no calculations to be done
        [self.speedData removeAllObjects];
        [self.speedData addObject:newLocation];
        self.avgSpeed = [newLocation speed];
        [self.delegate locationUpdate:newLocation withAvgSpeed:self.avgSpeed];
        return;
    }
    
    if(firstValidReadingIdx > 0) {
        [_speedData removeObjectsInRange:NSMakeRange(0, firstValidReadingIdx - 1)];
    }
    
    [self.speedData addObject:newLocation];
    
    NSDate *firstReadingTime = firstValidReading.timestamp;
    
    NSTimeInterval totalElapsed = [newLocation.timestamp timeIntervalSinceDate:firstReadingTime];
    
    double totalSpeedTime = 0;
    
    CLLocation *prevReading = firstValidReading;
    
    for (NSInteger a = 1; a < _speedData.count; a++) {
        CLLocation *reading = [_speedData objectAtIndex:a];
        
        totalSpeedTime += reading.speed * [reading.timestamp timeIntervalSinceDate:prevReading.timestamp];
        
        prevReading = reading;
    }
    
    self.avgSpeed = totalSpeedTime / totalElapsed;
    
	[self.delegate locationUpdate:newLocation withAvgSpeed:self.avgSpeed];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self.delegate locationError:error];
}

@end
