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

@interface SpeedometerLayer : CALayer
- (id)initWithParentView:(UIView*)parent;
@end

@interface SpeedometerView : UIView

@property (assign, nonatomic) double currentSpeed;

- (id)initWithFrame:(CGRect)frame;

@end

#endif
