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
        
        struct CGColor *tickColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
        
        for (int i = 0; i < MAX_SPEED_MPH; i++) {
            
            CAShapeLayer* tick = [[CAShapeLayer alloc] init];
            tick.position = CGPointMake(70, [self getYCoordForSpeed:i]);
            tick.anchorPoint = CGPointMake(0,0.5);
            tick.fillColor = tickColor;
            tick.strokeColor = tickColor;
            tick.lineWidth = 4;
            tick.lineJoin = kCALineJoinRound;
            
            if(i % MAJOR_TICK_INTERVAL == 0) {
                tick.bounds = CGRectMake(0,0,16,1);
            } else if(i % MINOR_TICK_INTERVAL == 0) {
                tick.bounds = CGRectMake(0,0,6,1);
            } else {
                tick.bounds = CGRectMake(0,0,1,1);
            }
            
            CGMutablePathRef tickRect = CGPathCreateMutable();
            CGPathAddRect(tickRect, NULL, tick.bounds);
            tick.path = tickRect;
            
            [self.speedometerLayer addSublayer:tick];
            
            if(i % LABEL_INTERVAL == 0) {
                CATextLayer* label = [[CATextLayer alloc] init];
                label.string = [NSString stringWithFormat:@"%i", i];
                label.bounds = CGRectMake(0,0,65,43);
                label.position = CGPointMake(0, [self getYCoordForSpeed:i]);
                label.anchorPoint = CGPointMake(0,0.5);
                label.foregroundColor = [[UIColor blackColor] CGColor];
                label.alignmentMode = kCAAlignmentRight;
                [self.speedometerLayer addSublayer:label];
            }
        }
        
        [self.layer addSublayer:self.speedometerLayer];
        
        self.currentSpeedIndicator = [[CAShapeLayer alloc] init];
        self.currentSpeedIndicator.bounds = CGRectMake(0, 0, CGRectGetMidX(self.bounds), 40);
        self.currentSpeedIndicator.position = CGPointMake(CGRectGetMidX(self.bounds),
                                                          CGRectGetMidY(self.bounds));
        self.currentSpeedIndicator.anchorPoint = CGPointMake(0,0.5);
        self.currentSpeedIndicator.fillColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5] CGColor];
        self.currentSpeedIndicator.lineWidth = 2;
        self.currentSpeedIndicator.strokeColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9] CGColor];
        self.currentSpeedIndicator.lineJoin = kCALineJoinBevel;
        
        CGMutablePathRef p = CGPathCreateMutable();
        CGPathMoveToPoint(p, NULL, self.currentSpeedIndicator.bounds.size.width - 10, 0);
        CGPathAddLineToPoint(p, NULL, 30, 0);
        CGPathAddLineToPoint(p, NULL, 0, CGRectGetMidY(self.currentSpeedIndicator.bounds));
        CGPathAddLineToPoint(p, NULL, 30, self.currentSpeedIndicator.bounds.size.height);
        CGPathAddLineToPoint(p, NULL, self.currentSpeedIndicator.bounds.size.width - 10, self.currentSpeedIndicator.bounds.size.height);
        CGPathAddLineToPoint(p, NULL, self.currentSpeedIndicator.bounds.size.width - 10, 0);
        
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
