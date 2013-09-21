//
//  RootViewController.h
//  DeTrafficator
//
//  Created by Robin Johnson on 7/4/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"
#import <QuartzCore/QuartzCore.h>
#import "SpeedometerView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RootViewController : UIViewController <CoreLocationControllerDelegate> {
    NSLayoutConstraint* portSpeedometerTrailingConstraint;
    NSLayoutConstraint* portSpeedometerResetButtonConstraint;
    
    NSLayoutConstraint* landSpeedometerTrailingConstraint;
    NSLayoutConstraint* landSpeedometerResetButtonConstraint;
    
    CoreLocationController *CLController;
    SystemSoundID speedUpSound;
    SystemSoundID slowDownSound;
    double prevSpeed;
}

@property (nonatomic, retain) CoreLocationController *CLController;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet SpeedometerView *speedometer;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;

@end
