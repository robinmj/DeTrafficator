//
//  SpeedometerView.h
//  DeTrafficator
//
//  Created by Robin Johnson on 9/5/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#ifndef DeTrafficator_SpeedometerView_h
#define DeTrafficator_SpeedometerView_h

#import "DeTrafficator.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface SpeedometerView : UIView

/*
 
 current speed, in m/s
 
 */
@property (assign, nonatomic) double currentSpeed;

/*
 
 average speed, in m/s
 
 */
@property (assign, nonatomic) double avgSpeed;

/*
 
 time interval, in seconds, over which avgSpeed was calculated
 
 */
@property (assign, nonatomic) NSTimeInterval avgInterval;

@property (assign, nonatomic) SpeedUnit unit;

/*
 
 Indicate that there is no speed data to display.
 Setting currentSpeed reverts this.
 
 */
- (void)disable;

- (void)resetAvg;

/*
 
 repositions the gauge layer to correct for a situation where the view was resized
 
 */
- (void)refreshIndicator;

@end

#endif
