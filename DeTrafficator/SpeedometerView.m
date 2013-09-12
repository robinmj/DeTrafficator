//
//  SpeedometerView.m
//  
//
//  Created by Robin Johnson on 9/5/13.
//
//

#import "SpeedometerView.h"

#define MAX_SPEED_MPH 120
#define MAJOR_TICK_INTERVAL 10
#define MINOR_TICK_INTERVAL 5
#define LABEL_INTERVAL 5
#define VERTICAL_PADDING 20

@interface SpeedometerView () {
    
    UIColor *avgColor;
    UIColor *indicatorWindowColor;
    UIColor *indicatorWindowHighlightColor;
}

@property (strong, nonatomic) CAScrollLayer *speedometerLayer;
@property (strong, nonatomic) CAShapeLayer *currentSpeedIndicator;
@property (strong, nonatomic) CAShapeLayer *avgSpeedIndicator;
@property (assign, nonatomic) NSInteger speedometerSublayerHeight;

@end

@implementation SpeedometerView

@synthesize currentSpeed = _currentSpeed;
@synthesize avgSpeed = _avgSpeed;
@synthesize speedometerLayer = _speedometerLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        self.frame = frame;
        
        self.speedometerLayer = [[CAScrollLayer alloc] init];
        
        self.speedometerLayer.frame = self.frame;
        self.speedometerLayer.bounds = self.bounds;
        
        self.speedometerSublayerHeight = self.speedometerLayer.bounds.size.height * log10(MAX_SPEED_MPH) + VERTICAL_PADDING;
        
        CGColorRef tickColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
        
        self->avgColor = [UIColor colorWithRed:0.365 green:0.318 blue:0.58 alpha:1.0];
        
        CGFloat lastTickY = 1000000.0;
        CGFloat lastLabelY = 1000000.0;
        
        for (int i = 0; i <= MAX_SPEED_MPH; i++) {
            
            CGFloat speedYPos = [self getYCoordForSpeed:i];
            
            BOOL majorTick = i % MAJOR_TICK_INTERVAL == 0;
            BOOL minorTick = i % MINOR_TICK_INTERVAL == 0;
            
            if((lastTickY - speedYPos) > 9 ||
               ((lastTickY - speedYPos) > 2 && minorTick) ||
               ((lastTickY - speedYPos) > 1 && majorTick)) {
                
                CAShapeLayer* tick = [[CAShapeLayer alloc] init];
                tick.position = CGPointMake(70, speedYPos);
                tick.anchorPoint = CGPointMake(0,0.5);
                tick.fillColor = tickColor;
                tick.strokeColor = tickColor;
                tick.lineWidth = 4;
                tick.lineJoin = kCALineJoinRound;
                
                if(majorTick) {
                    tick.bounds = CGRectMake(0,0,16,1);
                } else if(minorTick) {
                    tick.bounds = CGRectMake(0,0,6,1);
                } else {
                    tick.bounds = CGRectMake(0,0,1,1);
                }
                
                CGMutablePathRef tickRect = CGPathCreateMutable();
                CGPathAddRect(tickRect, NULL, tick.bounds);
                tick.path = tickRect;
                
                [self.speedometerLayer addSublayer:tick];
            }
            lastTickY = speedYPos;
            
            if((i % LABEL_INTERVAL == 0) && ((lastLabelY - speedYPos) >= 30 || majorTick)) {
                CATextLayer* label = [[CATextLayer alloc] init];
                label.string = [NSString stringWithFormat:@"%i", i];
                label.bounds = CGRectMake(0,0,65,43);
                label.position = CGPointMake(0, speedYPos);
                label.anchorPoint = CGPointMake(0,0.5);
                label.foregroundColor = [[UIColor blackColor] CGColor];
                label.alignmentMode = kCAAlignmentRight;
                [self.speedometerLayer addSublayer:label];
                
                lastLabelY = speedYPos;
            }
        }
        
        [self.layer addSublayer:self.speedometerLayer];
        
        self.avgSpeedIndicator = [[CAShapeLayer alloc] init];
        self.avgSpeedIndicator.bounds = CGRectMake(0, 0, 30, 30);
        self.avgSpeedIndicator.anchorPoint = CGPointMake(1,0.5);
        self.avgSpeedIndicator.fillColor = [avgColor CGColor];
        self.avgSpeedIndicator.lineWidth = 2;
        self.avgSpeedIndicator.strokeColor = [avgColor CGColor];
        self.avgSpeedIndicator.lineJoin = kCALineJoinBevel;
        
        CGMutablePathRef diamond = CGPathCreateMutable();
        CGPathMoveToPoint(diamond, NULL, CGRectGetMidX(self.avgSpeedIndicator.bounds), 0);
        CGPathAddLineToPoint(diamond, NULL, 0, CGRectGetMidY(self.avgSpeedIndicator.bounds));
        CGPathAddLineToPoint(diamond, NULL, CGRectGetMidX(self.avgSpeedIndicator.bounds), self.avgSpeedIndicator.bounds.size.height);
        CGPathAddLineToPoint(diamond, NULL, self.avgSpeedIndicator.bounds.size.width, CGRectGetMidY(self.avgSpeedIndicator.bounds));
        CGPathAddLineToPoint(diamond, NULL, CGRectGetMidX(self.avgSpeedIndicator.bounds), 0);
        
        self.avgSpeedIndicator.path = diamond;
        [self.avgSpeedIndicator setHidden:TRUE];
        
        [self.speedometerLayer addSublayer:self.avgSpeedIndicator];
        
        self->indicatorWindowColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:0.5];
        self->indicatorWindowHighlightColor = [[UIColor alloc] initWithRed:0.0 green:0.6 blue:0.9 alpha:0.5];
        
        self.currentSpeedIndicator = [[CAShapeLayer alloc] init];
        self.currentSpeedIndicator.bounds = CGRectMake(0, 0, CGRectGetMidX(self.bounds), 40);
        self.currentSpeedIndicator.position = CGPointMake(CGRectGetMidX(self.bounds),
                                                          CGRectGetMidY(self.bounds));
        self.currentSpeedIndicator.anchorPoint = CGPointMake(0,0.5);
        self.currentSpeedIndicator.fillColor = [self->indicatorWindowColor CGColor];
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
    if(currentSpeed > MAX_SPEED_MPH) {
        currentSpeed = MAX_SPEED_MPH;
    }
    _currentSpeed = currentSpeed;
    self.speedometerLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self.speedometerLayer scrollToPoint:CGPointMake(0, [self getYCoordForSpeed:currentSpeed] - CGRectGetMidY(self.bounds))];
    
    if(currentSpeed > 0) {
        double ds = ABS(currentSpeed - _avgSpeed);
        double accuracy = ds / (double)currentSpeed;
        
        //highlight indicator if speed is within 10% the average speed
        if(accuracy < 0.1) {
            self.currentSpeedIndicator.fillColor = [self->indicatorWindowHighlightColor CGColor];
        } else {
            self.currentSpeedIndicator.fillColor = [self->indicatorWindowColor CGColor];
        }
    } else {
        self.currentSpeedIndicator.fillColor = [self->indicatorWindowColor CGColor];
    }
}

- (void)setAvgSpeed:(double)avgSpeed {
    _avgSpeed = avgSpeed;
    [self.avgSpeedIndicator setHidden:FALSE];
    self.avgSpeedIndicator.position = CGPointMake(self.speedometerLayer.bounds.size.width - 13, [self getYCoordForSpeed:avgSpeed]);
}

- (void)disable {
    [self.avgSpeedIndicator setHidden:TRUE];
    [self setCurrentSpeed:0];
    self.speedometerLayer.backgroundColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] CGColor];
}

- (CGFloat)getYCoordForSpeed:(double)speed {
    if(speed == 0.0) {
        return (CGFloat)self.speedometerSublayerHeight;
    }
    return (CGFloat)self.speedometerSublayerHeight - self.speedometerLayer.bounds.size.height * log10(speed);
}

@end
