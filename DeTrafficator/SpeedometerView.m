//
//  SpeedometerView.m
//  
//
//  Created by Robin Johnson on 9/5/13.
//
//

#import "SpeedometerView.h"

#define GAUGE_HEIGHT 840
#define MAX_SPEED_MPH 120
#define MAJOR_TICK_INTERVAL 10
#define MINOR_TICK_INTERVAL 5
#define TICK_SPACING 10
#define LABEL_INTERVAL 5
#define LABEL_HEIGHT 43
#define LABEL_COLUMN_WIDTH 65
#define VERTICAL_PADDING 20

@interface SpeedometerView () {
    
    UIColor *avgColor;
    UIColor *indicatorWindowColor;
    UIColor *indicatorWindowHighlightColor;
}

@property (strong, nonatomic) CAScrollLayer *speedometerLayer;
@property (strong, nonatomic) CAShapeLayer *currentSpeedIndicator;
@property (strong, nonatomic) CATextLayer *currentSpeedText;
@property (strong, nonatomic) CATextLayer *currentSpeedUnit;
@property (strong, nonatomic) CAShapeLayer *avgSpeedIndicator;
@property (strong, nonatomic) CATextLayer *avgSpeedText;
@property (strong, nonatomic) CATextLayer *avgSpeedUnit;
@property (assign, nonatomic) NSInteger speedometerSublayerHeight;

@end

@implementation SpeedometerView

@synthesize currentSpeed = _currentSpeed;
@synthesize avgSpeed = _avgSpeed;
@synthesize speedometerLayer = _speedometerLayer;

- (id)init
{
    self = [super init];
    if (self) {
        
        // Initialization code
        
        self.speedometerLayer = [[CAScrollLayer alloc] init];
        
        self.speedometerSublayerHeight = GAUGE_HEIGHT + VERTICAL_PADDING;
        
        CGColorRef tickColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
        
        self->avgColor = [UIColor colorWithRed:0.365 green:0.318 blue:0.58 alpha:1.0];
        
        CGFloat lastTickY = [self getYCoordForSpeed:MAX_SPEED_MPH];
        CGFloat lastLabelY = [self getYCoordForSpeed:MAX_SPEED_MPH];
        
        BOOL tinyTicksEnabled = FALSE;
        
        for (int i = MAX_SPEED_MPH; i >= 0; i--) {
            
            CGFloat speedYPos = [self getYCoordForSpeed:i];
            
            CGFloat scaleDensity = speedYPos - lastTickY;
            
            BOOL majorTick = i % MAJOR_TICK_INTERVAL == 0;
            BOOL minorTick = i % MINOR_TICK_INTERVAL == 0;
            
            //switch on smallest tick marks once the scale is sparse enough
            if(minorTick && !tinyTicksEnabled) {
                tinyTicksEnabled = scaleDensity > TICK_SPACING;
            }
            
            if(majorTick ||
               (minorTick && scaleDensity > (TICK_SPACING / MINOR_TICK_INTERVAL)) ||
               tinyTicksEnabled) {
                
                CAShapeLayer* tick = [[CAShapeLayer alloc] init];
                tick.position = CGPointMake(LABEL_COLUMN_WIDTH + 5, speedYPos);
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
            
            if((i % LABEL_INTERVAL == 0) && (majorTick || (speedYPos - lastLabelY) >= LABEL_HEIGHT)) {
                CATextLayer* label = [[CATextLayer alloc] init];
                label.string = [NSString stringWithFormat:@"%i", i];
                label.bounds = CGRectMake(0,0,LABEL_COLUMN_WIDTH,LABEL_HEIGHT);
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
        self.currentSpeedIndicator.anchorPoint = CGPointMake(0,0.5);
        self.currentSpeedIndicator.fillColor = [self->indicatorWindowColor CGColor];
        self.currentSpeedIndicator.lineWidth = 2;
        self.currentSpeedIndicator.strokeColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9] CGColor];
        self.currentSpeedIndicator.lineJoin = kCALineJoinBevel;
        
        self.currentSpeedUnit = [[CATextLayer alloc] init];
        self.currentSpeedUnit.anchorPoint = CGPointMake(0.0, 1.0);
        self.currentSpeedUnit.foregroundColor = [[UIColor blackColor] CGColor];
        self.currentSpeedUnit.alignmentMode = kCAAlignmentLeft;
        self.currentSpeedUnit.fontSize = 18.0;
        self.currentSpeedUnit.string = @"mi/h";
        
        [self.currentSpeedIndicator addSublayer:self.currentSpeedUnit];
        
        self.currentSpeedText = [[CATextLayer alloc] init];
        self.currentSpeedText.anchorPoint = CGPointMake(1.0, 1.0);
        self.currentSpeedText.foregroundColor = [[UIColor blackColor] CGColor];
        self.currentSpeedText.alignmentMode = kCAAlignmentRight;
        self.currentSpeedText.string = @"0.0";
        
        [self.currentSpeedIndicator addSublayer:self.currentSpeedText];
        
        [self.layer addSublayer:self.currentSpeedIndicator];
    }
    return self;
}

- (void)layoutSubviews
{
    
    self.speedometerLayer.frame = self.frame;
    
    NSInteger currentSpeedIndicatorLeftMargin = LABEL_COLUMN_WIDTH + 10;
    
    self.currentSpeedIndicator.bounds = CGRectMake(0, 0, self.bounds.size.width - currentSpeedIndicatorLeftMargin, 40);
    self.currentSpeedIndicator.position = CGPointMake(currentSpeedIndicatorLeftMargin,
                                                      CGRectGetMidY(self.bounds));
    
    CGMutablePathRef p = CGPathCreateMutable();
    CGPathMoveToPoint(p, NULL, self.currentSpeedIndicator.bounds.size.width - 10, 0);
    CGPathAddLineToPoint(p, NULL, 30, 0);
    CGPathAddLineToPoint(p, NULL, 0, CGRectGetMidY(self.currentSpeedIndicator.bounds));
    CGPathAddLineToPoint(p, NULL, 30, self.currentSpeedIndicator.bounds.size.height);
    CGPathAddLineToPoint(p, NULL, self.currentSpeedIndicator.bounds.size.width - 10, self.currentSpeedIndicator.bounds.size.height);
    CGPathAddLineToPoint(p, NULL, self.currentSpeedIndicator.bounds.size.width - 10, 0);
    
    self.currentSpeedIndicator.path = p;
    
    self.currentSpeedUnit.bounds = CGRectMake(0,0, 50, self.currentSpeedIndicator.bounds.size.height / 2);
    self.currentSpeedUnit.position = CGPointMake(self.currentSpeedIndicator.bounds.size.width - (self.currentSpeedUnit.bounds.size.width + 10), self.currentSpeedIndicator.bounds.size.height);
    
    self.currentSpeedText.bounds = CGRectMake(0,0, 80, self.currentSpeedIndicator.bounds.size.height);
    self.currentSpeedText.position = CGPointMake(self.currentSpeedUnit.position.x - 5, self.currentSpeedIndicator.bounds.size.height);
    
}

- (void)setCurrentSpeed:(double)currentSpeed {
    if(currentSpeed > MAX_SPEED_MPH) {
        currentSpeed = MAX_SPEED_MPH;
    }
    _currentSpeed = currentSpeed;
    self.currentSpeedText.string = [self abbreviate:currentSpeed];
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
    self.avgSpeedIndicator.position = CGPointMake(LABEL_COLUMN_WIDTH + 70, [self getYCoordForSpeed:avgSpeed]);
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
    return (CGFloat)self.speedometerSublayerHeight - GAUGE_HEIGHT * log10(speed) / log10(MAX_SPEED_MPH);
}

- (NSString *)abbreviate:(double) number {
    NSInteger wholePart = (NSInteger)number;
    NSInteger decimalPart = (NSInteger)round((number - wholePart) * 10);
    //decimal part rounded up to 10
    if(decimalPart > 9) {
        wholePart++;
        decimalPart = 0;
    }
    return [NSString stringWithFormat:@"%d.%d", wholePart, decimalPart];
}

@end
