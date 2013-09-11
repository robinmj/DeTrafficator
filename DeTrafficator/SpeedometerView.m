//
//  SpeedometerView.m
//  
//
//  Created by Robin Johnson on 9/5/13.
//
//

#import "SpeedometerView.h"

#define MARKING_DENSITY 20
#define MAX_SPEED_MPH 120
#define MAJOR_TICK_INTERVAL 10
#define MINOR_TICK_INTERVAL 5
#define LABEL_INTERVAL 5
#define VERTICAL_PADDING 20

@interface SpeedometerView ()

@property (strong, nonatomic) CAScrollLayer *speedometerLayer;
@property (strong, nonatomic) CAShapeLayer *currentSpeedIndicator;
@property (assign, nonatomic) double pixelsPerTick;
@property (assign, nonatomic) NSInteger speedometerSublayerHeight;

@end

@implementation SpeedometerView

@synthesize currentSpeed = _currentSpeed;
@synthesize speedometerLayer = _speedometerLayer;
@synthesize pixelsPerTick = _pixelsPerTick;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        self.frame = frame;
        
        self.speedometerLayer = [[CAScrollLayer alloc] init];
        
        self.speedometerLayer.frame = self.frame;
        self.speedometerLayer.bounds = self.bounds;
        
        self.pixelsPerTick = (double)self.speedometerLayer.bounds.size.height / (double)MARKING_DENSITY;
        self.speedometerSublayerHeight = self.pixelsPerTick * (double)MAX_SPEED_MPH + VERTICAL_PADDING;
        
        for (int i = 0; i < MAX_SPEED_MPH; i++) {
            if(i % LABEL_INTERVAL == 0) {            
                CATextLayer* t = [[CATextLayer alloc] init];
                t.string = [NSString stringWithFormat:@"%i", i];
                t.bounds = CGRectMake(0,0,40,60);
                t.position = CGPointMake(CGRectGetMidX(self.speedometerLayer.bounds), [self getYCoordForSpeed:i]);
                t.foregroundColor = [[UIColor blackColor] CGColor];
                [self.speedometerLayer addSublayer:t];
            }
        }
        
        [self.layer addSublayer:self.speedometerLayer];
        
        self.currentSpeedIndicator = [[CAShapeLayer alloc] init];
        self.currentSpeedIndicator.bounds = CGRectMake(0, 0, self.bounds.size.width, 5);
        self.currentSpeedIndicator.position = CGPointMake(0,
                                                          CGRectGetMidY(self.bounds));
        //self.currentSpeedIndicator.anchorPoint = CGPointMake(1,0.5);
        self.currentSpeedIndicator.fillColor = [[UIColor colorWithRed:1.0 green:0.2 blue:0.0 alpha:0.9] CGColor];
        self.currentSpeedIndicator.strokeColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.9] CGColor];
        CGMutablePathRef p = CGPathCreateMutable();
        
        CGPathAddRect(p, NULL, CGRectMake(0, 0, self.bounds.size.width, 5));
        self.currentSpeedIndicator.path = p;
        
        [self.layer addSublayer:self.currentSpeedIndicator];
    }
    return self;
}

- (void)setCurrentSpeed:(double)currentSpeed {
    _currentSpeed = currentSpeed;
    [self.speedometerLayer scrollToPoint:CGPointMake(0, [self getYCoordForSpeed:currentSpeed] - CGRectGetMidY(self.bounds))];
}

- (CGFloat)getYCoordForSpeed:(double)speed {
    return (CGFloat)self.speedometerSublayerHeight - self.pixelsPerTick * speed;
}

@end
