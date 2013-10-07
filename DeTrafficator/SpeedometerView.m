//
//  SpeedometerView.m
//  
//
//  Created by Robin Johnson on 9/5/13.
//
//

#import "SpeedometerView.h"

#define GAUGE_HEIGHT 900
#define MAX_SPEED_M_S 53.6448
#define MAJOR_TICK_INTERVAL 10
#define MINOR_TICK_INTERVAL 5
#define TICK_SPACING 10
#define LABEL_INTERVAL 5
#define LABEL_HEIGHT 43
#define LABEL_COLUMN_WIDTH 65
#define VERTICAL_PADDING 20

#define MPH_CONVERSION_FACTOR 2.2369363
#define KPH_CONVERSION_FACTOR 3.6

@interface SpeedometerView () {
    
    UIColor *avgColor;
    UIColor *indicatorWindowColor;
    UIColor *indicatorWindowHighlightColor;
    
    /*
     multiply by this to convert from m/s to the current speed unit
     */
    double conversionFactor;
}

@property (strong, nonatomic) CAShapeLayer *shadowLayer;
@property (strong, nonatomic) CAScrollLayer *speedometerLayer;
@property (strong, nonatomic) CAShapeLayer *currentSpeedIndicator;
@property (strong, nonatomic) CATextLayer *currentSpeedText;
@property (strong, nonatomic) CATextLayer *currentSpeedUnit;
@property (strong, nonatomic) CAShapeLayer *avgSpeedIndicator;
@property (strong, nonatomic) CATextLayer *avgSpeedText;
@property (strong, nonatomic) CATextLayer *avgSpeedUnit;

@end

@implementation SpeedometerView

@synthesize currentSpeed = _currentSpeed;
@synthesize avgSpeed = _avgSpeed;
@synthesize avgInterval = _avgInterval;
@synthesize speedometerLayer = _speedometerLayer;
@synthesize unit = _unit;

- (id)init
{
    self = [super init];
    if (self) {
        
        // Initialization code
        
        self.shadowLayer = [[CAShapeLayer alloc] init];
        self.shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
        self.shadowLayer.shadowOffset = CGSizeMake(1.0, 2.0);
        self.shadowLayer.shadowOpacity = 0.5;
        self.shadowLayer.backgroundColor = [[UIColor clearColor] CGColor];
        self.shadowLayer.fillColor = [[UIColor clearColor] CGColor];
        self.shadowLayer.strokeColor = [[UIColor blackColor] CGColor];
        self.shadowLayer.lineWidth = 10;
        
        self.speedometerLayer = [[CAScrollLayer alloc] init];
        
        self->avgColor = [UIColor colorWithRed:0.365 green:0.318 blue:0.58 alpha:1.0];
        
        [self.layer addSublayer:self.speedometerLayer];
        [self.layer addSublayer:self.shadowLayer];
        
        self.avgSpeedIndicator = [[CAShapeLayer alloc] init];
        self.avgSpeedIndicator.bounds = CGRectMake(0, 0, 80, 40);
        self.avgSpeedIndicator.anchorPoint = CGPointMake(0.0,0.5);
        self.avgSpeedIndicator.fillColor = [avgColor CGColor];
        self.avgSpeedIndicator.lineWidth = 2;
        self.avgSpeedIndicator.strokeColor = [avgColor CGColor];
        self.avgSpeedIndicator.lineJoin = kCALineJoinBevel;
        
        CGMutablePathRef diamond = CGPathCreateMutable();
        
        CGFloat halfHeight = CGRectGetMidY(self.avgSpeedIndicator.bounds);
        
        //bottom left
        CGPathMoveToPoint(diamond, NULL, halfHeight, self.avgSpeedIndicator.bounds.size.height);
        //left
        CGPathAddArcToPoint(diamond, NULL, 0, self.avgSpeedIndicator.bounds.size.height, 0, halfHeight, halfHeight);
        //top left
        CGPathAddArcToPoint(diamond, NULL, 0, 0, halfHeight, 0, halfHeight);
        //top right
        CGPathAddLineToPoint(diamond, NULL, self.avgSpeedIndicator.bounds.size.width - halfHeight, 0);
        //right
        CGPathAddArcToPoint(diamond, NULL, self.avgSpeedIndicator.bounds.size.width, 0, self.avgSpeedIndicator.bounds.size.width, self.avgSpeedIndicator.bounds.size.height - halfHeight, halfHeight);
        //bottom right
        CGPathAddArcToPoint(diamond, NULL, self.avgSpeedIndicator.bounds.size.width, self.avgSpeedIndicator.bounds.size.height, self.avgSpeedIndicator.bounds.size.width - halfHeight, self.avgSpeedIndicator.bounds.size.height, halfHeight);
        //bottom left
        CGPathCloseSubpath(diamond);
        
        self.avgSpeedIndicator.path = diamond;
        
        self.avgSpeedText = [[CATextLayer alloc] init];
        self.avgSpeedText.bounds = CGRectMake(0,0, 60, 44);
        self.avgSpeedText.position = CGPointMake(10, CGRectGetMidY(self.avgSpeedIndicator.bounds));
        self.avgSpeedText.anchorPoint = CGPointMake(0.0, 0.5);
        self.avgSpeedText.foregroundColor = [[UIColor whiteColor] CGColor];
        self.avgSpeedText.alignmentMode = kCAAlignmentCenter;
        self.avgSpeedText.wrapped = YES;
        self.avgSpeedText.contentsScale = [[UIScreen mainScreen] scale];
        self.avgSpeedText.fontSize = 17.0;
        
        [self setAvgInterval:5 * 60];
        
        [self.avgSpeedIndicator addSublayer:self.avgSpeedText];
        
        [self.avgSpeedIndicator setHidden:TRUE];
        
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
        self.currentSpeedUnit.contentsScale = [[UIScreen mainScreen] scale];
        
        [self.currentSpeedIndicator addSublayer:self.currentSpeedUnit];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        //force refresh the speed unit
        _unit = -1;
        [self setUnit:[defaults integerForKey:@"speed_unit_preference"]];
        
        self.currentSpeedText = [[CATextLayer alloc] init];
        self.currentSpeedText.anchorPoint = CGPointMake(1.0, 1.0);
        self.currentSpeedText.foregroundColor = [[UIColor blackColor] CGColor];
        self.currentSpeedText.alignmentMode = kCAAlignmentRight;
        self.currentSpeedText.contentsScale = [[UIScreen mainScreen] scale];
        self.currentSpeedText.string = @"0.0";
        
        [self.currentSpeedIndicator addSublayer:self.currentSpeedText];
        
        [self.layer addSublayer:self.currentSpeedIndicator];
    }
    return self;
}

- (void)layoutSubviews
{
    
    self.speedometerLayer.frame = self.bounds;
    
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    CGPathAddRect(shadowPath, NULL, CGRectInset(self.bounds, -5, -5));
    
    self.shadowLayer.path = shadowPath;
    
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
    CGPathCloseSubpath(p);
    
    self.currentSpeedIndicator.path = p;
    
    self.currentSpeedUnit.bounds = CGRectMake(0,0, 50, 23);
    self.currentSpeedUnit.position = CGPointMake(self.currentSpeedIndicator.bounds.size.width - (self.currentSpeedUnit.bounds.size.width + 10), self.currentSpeedIndicator.bounds.size.height);
    
    self.currentSpeedText.bounds = CGRectMake(0,0, 80, self.currentSpeedIndicator.bounds.size.height);
    self.currentSpeedText.position = CGPointMake(self.currentSpeedUnit.position.x - 5, self.currentSpeedIndicator.bounds.size.height);
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [self setUnit:[defaults integerForKey:@"speed_unit_preference"]];
    
    [super layoutSubviews];
}

- (void)drawGaugeMarkings
{
    
    CGColorRef tickColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor];
    
    self.speedometerLayer.sublayers = [[NSArray alloc] init];
    
    CGFloat lastTickY = VERTICAL_PADDING;
    CGFloat lastLabelY = VERTICAL_PADDING - LABEL_HEIGHT;
    
    BOOL tinyTicksEnabled = FALSE;
    
    BOOL majorLabelsEnabled = FALSE;
    BOOL minorLabelsEnabled = FALSE;
    BOOL tinyTickLabelsEnabled = FALSE;
    
    NSInteger gaugeMax = (NSInteger)(MAX_SPEED_M_S * self->conversionFactor);
    
    for (int i = gaugeMax; i >= 0; i--) {
        
        CGFloat speedYPos = [self getYCoordForSpeed:i / self->conversionFactor];
        
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
        
        if(majorTick) {
            majorLabelsEnabled = (speedYPos - lastLabelY) >= LABEL_HEIGHT;
        } else if(minorTick) {
            if(majorLabelsEnabled && !minorLabelsEnabled) {
                minorLabelsEnabled = (speedYPos - lastLabelY) >= LABEL_HEIGHT;
            }
        } else {
            if(tinyTicksEnabled && minorLabelsEnabled && !tinyTickLabelsEnabled) {
                CGFloat nextSpeedYPos = [self getYCoordForSpeed:(i - 1) / self->conversionFactor];
                
                tinyTickLabelsEnabled = (nextSpeedYPos - speedYPos) >= LABEL_HEIGHT;
            }
        }
        
        if((majorTick && majorLabelsEnabled) ||
            (minorTick && minorLabelsEnabled) ||
            tinyTickLabelsEnabled) {
            
            CATextLayer* label = [[CATextLayer alloc] init];
            label.string = [NSString stringWithFormat:@"%i", i];
            label.bounds = CGRectMake(0,0,LABEL_COLUMN_WIDTH,LABEL_HEIGHT);
            label.position = CGPointMake(0, speedYPos);
            label.anchorPoint = CGPointMake(0,0.5);
            label.foregroundColor = [[UIColor blackColor] CGColor];
            label.alignmentMode = kCAAlignmentRight;
            label.contentsScale = [[UIScreen mainScreen] scale];
            [self.speedometerLayer addSublayer:label];
            
            lastLabelY = speedYPos;
        }
    }
    
    [self.speedometerLayer addSublayer:self.avgSpeedIndicator];
}

/*
 
 currentSpeed - in m/s
 
 */
- (void)setCurrentSpeed:(double)currentSpeed {
    _currentSpeed = currentSpeed;
    self.currentSpeedText.string = [self abbreviate:currentSpeed * self->conversionFactor];
    self.speedometerLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self refreshIndicator];
    
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

- (void)refreshIndicator
{
    [self.speedometerLayer scrollToPoint:CGPointMake(0, [self getYCoordForSpeed:MIN(_currentSpeed,MAX_SPEED_M_S)] - CGRectGetMidY(self.bounds))];
}

/*
 
 avgSpeed - in m/s
 
 */
- (void)setAvgSpeed:(double)avgSpeed {
    _avgSpeed = avgSpeed;
    [self.avgSpeedIndicator setHidden:FALSE];
    self.avgSpeedIndicator.position = CGPointMake(LABEL_COLUMN_WIDTH + 30, [self getYCoordForSpeed:avgSpeed]);
}

- (void)disable {
    [self.avgSpeedIndicator setHidden:TRUE];
    [self setCurrentSpeed:0];
    self.speedometerLayer.backgroundColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] CGColor];
}

- (void)resetAvg {
    if([self.avgSpeedIndicator isHidden]) {
        return;
    }
    
    [self setAvgSpeed:self.currentSpeed];
}

/*
 
  speed - in m/s
 
 */
- (CGFloat)getYCoordForSpeed:(double)speed {
    return (CGFloat)(GAUGE_HEIGHT + VERTICAL_PADDING - GAUGE_HEIGHT * log10(speed + 1.0) / log10(MAX_SPEED_M_S + 1.0));
}

- (NSString *)abbreviate:(double) number {
    if(number >= 100.0) {
        return [NSString stringWithFormat:@"%d",(NSInteger)round(number)];
    }
    
    NSInteger wholePart = (NSInteger)number;
    NSInteger decimalPart = (NSInteger)round((number - wholePart) * 10);
    //decimal part rounded up to 10
    if(decimalPart > 9) {
        wholePart++;
        decimalPart = 0;
    }
    return [NSString stringWithFormat:@"%d.%d", wholePart, decimalPart];
}

- (void)setUnit:(SpeedUnit)unit {
    if(_unit == unit) {
        return;
    }
    
    _unit = unit;
    
    switch(_unit) {
        case mph:
            self.currentSpeedUnit.string = @"mi/h";
            self->conversionFactor = MPH_CONVERSION_FACTOR;
            break;
        case kph:
            self.currentSpeedUnit.string = @"km/h";
            self->conversionFactor = KPH_CONVERSION_FACTOR;
            break;
    }
    
    //force immediate update of speed reading
    [self setCurrentSpeed:self.currentSpeed];
    
    [self drawGaugeMarkings];
}

- (void)setAvgInterval:(NSTimeInterval)avgInterval {
    if(avgInterval <= 59.0) {
        self.avgSpeedText.string = [[NSString alloc] initWithFormat:@"%d sec avg", (NSInteger)round(avgInterval)];
        return;
    }
    
    NSInteger halfMinutes = round(avgInterval / 30);
    
    NSInteger minutes = halfMinutes / 2;
    
    if(halfMinutes % 2 == 0) {
        self.avgSpeedText.string = [[NSString alloc] initWithFormat:@"%d min avg",minutes];
    } else {
        self.avgSpeedText.string = [[NSString alloc] initWithFormat:@"%d.5 min avg",minutes];
    }
}

@end
