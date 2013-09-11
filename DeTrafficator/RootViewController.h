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

@interface RootViewController : UIViewController <CoreLocationControllerDelegate> {
    CoreLocationController *CLController;
}

@property (nonatomic, retain) CoreLocationController *CLController;
@property (strong, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (strong, nonatomic) IBOutlet SpeedometerView *speedometer;
@property (strong, nonatomic) id dataObject;

@end
