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
#define SPEED_INDICATOR_LEFT_MARGIN LABEL_COLUMN_WIDTH + 10
#define AVG_SPEED_INDICATOR_LEFT_MARGIN SPEED_INDICATOR_LEFT_MARGIN + 20

#define MPH_CONVERSION_FACTOR 2.2369363
#define KPH_CONVERSION_FACTOR 3.6

@interface SpeedometerView () {
    
    CGFloat statusBarOverlapMargin;
    UIColor *avgColor;
    UIColor *indicatorWindowColor;
    UIColor *indicatorWindowHighlightColor;
    CGMutablePathRef topAvgSpeedPlaceholderPath;
    CGMutablePathRef bottomAvgSpeedPlaceholderPath;
    
    /*
     multiply by this to convert from m/s to the current speed unit
     */
    double conversionFactor;
}

@property (strong, nonatomic) CAGradientLayer *topGradient;
@property (strong, nonatomic) CAShapeLayer *shadowLayer;
@property (strong, nonatomic) CAScrollLayer *speedometerLayer;
@property (strong, nonatomic) CAShapeLayer *currentSpeedIndicator;
@property (strong, nonatomic) CATextLayer *currentSpeedText;
@property (strong, nonatomic) CATextLayer *currentSpeedUnit;
@property (strong, nonatomic) CAShapeLayer *avgSpeedIndicator;
@property (strong, nonatomic) CATextLayer *avgSpeedIntervalText;
@property (strong, nonatomic) CAShapeLayer *placeholderAvgSpeed;
@property (strong, nonatomic) CATextLayer *placeholderAvgSpeedIntervalText;
@property (strong, nonatomic) CATextLayer *placeholderAvgSpeedText;
@property (strong, nonatomic) CATextLayer *placeholderAvgSpeedUnit;


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
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            
            self->statusBarOverlapMargin = 20;
            
            //white gradient that appears under status bar to make it more visible
            self.topGradient = [[CAGradientLayer alloc] init];
            self.topGradient.bounds = CGRectMake(0,0, self.bounds.size.width, 40);
            self.topGradient.position = CGPointMake(0, 0);
            self.topGradient.anchorPoint = CGPointMake(0, 0);
            
            self.topGradient.colors = [[NSArray alloc] initWithObjects:(id)[[UIColor whiteColor] CGColor], (__bridge_transfer id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor], NULL];
            self.topGradient.backgroundColor = [[UIColor clearColor] CGColor];
        } else {
            //status bar doesn't overlap- no need to push down the placeholder indicator
            self->statusBarOverlapMargin = 0;
        }
        
        //inset shadow around edge of view
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
        [self.layer addSublayer:self.topGradient];
        
        self.avgSpeedIndicator = [[CAShapeLayer alloc] init];
        self.avgSpeedIndicator.bounds = CGRectMake(0, 0, 80, 40);
        self.avgSpeedIndicator.anchorPoint = CGPointMake(0.0,0.5);
        self.avgSpeedIndicator.fillColor = [avgColor CGColor];
        self.avgSpeedIndicator.lineWidth = 2;
        self.avgSpeedIndicator.strokeColor = [avgColor CGColor];
        self.avgSpeedIndicator.lineJoin = kCALineJoinBevel;
        
        CGMutablePathRef avgSpeedIndicatorPath = CGPathCreateMutable();
        
        CGFloat halfHeight = CGRectGetMidY(self.avgSpeedIndicator.bounds);
        
        //bottom left
        CGPathMoveToPoint(avgSpeedIndicatorPath, NULL, halfHeight, self.avgSpeedIndicator.bounds.size.height);
        //left
        CGPathAddArcToPoint(avgSpeedIndicatorPath, NULL, 0, self.avgSpeedIndicator.bounds.size.height, 0, halfHeight, halfHeight);
        //top left
        CGPathAddArcToPoint(avgSpeedIndicatorPath, NULL, 0, 0, halfHeight, 0, halfHeight);
        //top right
        CGPathAddLineToPoint(avgSpeedIndicatorPath, NULL, self.avgSpeedIndicator.bounds.size.width - halfHeight, 0);
        //right
        CGPathAddArcToPoint(avgSpeedIndicatorPath, NULL, self.avgSpeedIndicator.bounds.size.width, 0, self.avgSpeedIndicator.bounds.size.width, self.avgSpeedIndicator.bounds.size.height - halfHeight, halfHeight);
        //bottom right
        CGPathAddArcToPoint(avgSpeedIndicatorPath, NULL, self.avgSpeedIndicator.bounds.size.width, self.avgSpeedIndicator.bounds.size.height, self.avgSpeedIndicator.bounds.size.width - halfHeight, self.avgSpeedIndicator.bounds.size.height, halfHeight);
        //bottom left
        CGPathCloseSubpath(avgSpeedIndicatorPath);
        
        self.avgSpeedIndicator.path = avgSpeedIndicatorPath;
        
        self.avgSpeedIntervalText = [[CATextLayer alloc] init];
        self.avgSpeedIntervalText.bounds = CGRectMake(0,0, 60, 44);
        self.avgSpeedIntervalText.position = CGPointMake(10, CGRectGetMidY(self.avgSpeedIndicator.bounds));
        self.avgSpeedIntervalText.anchorPoint = CGPointMake(0.0, 0.5);
        self.avgSpeedIntervalText.foregroundColor = [[UIColor whiteColor] CGColor];
        self.avgSpeedIntervalText.alignmentMode = kCAAlignmentCenter;
        self.avgSpeedIntervalText.wrapped = YES;
        self.avgSpeedIntervalText.contentsScale = [[UIScreen mainScreen] scale];
        self.avgSpeedIntervalText.fontSize = 17.0;
        
        [self initPlaceholderAvgSpeedIndicator];
        
        [self setAvgInterval:0];
        
        [self.avgSpeedIndicator addSublayer:self.avgSpeedIntervalText];
        
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
    
    self.currentSpeedIndicator.bounds = CGRectMake(0, 0, 229, 40);
    self.currentSpeedIndicator.position = CGPointMake(SPEED_INDICATOR_LEFT_MARGIN,
                                                      CGRectGetMidY(self.bounds));
    
    if(self.topGradient) {
        self.topGradient.bounds = CGRectMake(0,0, self.bounds.size.width, self.topGradient.bounds.size.height);
    }
    
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

- (void)initPlaceholderAvgSpeedIndicator {
    
    self.placeholderAvgSpeed = [[CAShapeLayer alloc] init];
    self.placeholderAvgSpeed.bounds = CGRectMake(0, 0, 199, 50);
    self.placeholderAvgSpeed.anchorPoint = CGPointMake(0.0,0.0);
    self.placeholderAvgSpeed.fillColor = [avgColor CGColor];
    self.placeholderAvgSpeed.lineWidth = 2;
    self.placeholderAvgSpeed.strokeColor = [avgColor CGColor];
    self.placeholderAvgSpeed.lineJoin = kCALineJoinBevel;
    
    CAShapeLayer *placeholderAvgSpeedWindow = [[CAShapeLayer alloc] init];
    placeholderAvgSpeedWindow.bounds = CGRectMake(0, 0, 125, 40);
    placeholderAvgSpeedWindow.position = CGPointMake(self.placeholderAvgSpeed.bounds.size.width - 5, 5);
    placeholderAvgSpeedWindow.anchorPoint = CGPointMake(1.0, 0.0);
    placeholderAvgSpeedWindow.path = CGPathCreateWithRoundedRect(placeholderAvgSpeedWindow.bounds, 5, 5, NULL);
    placeholderAvgSpeedWindow.fillColor = [[UIColor whiteColor] CGColor];
    [self.placeholderAvgSpeed addSublayer:placeholderAvgSpeedWindow];
    
    self->topAvgSpeedPlaceholderPath = CGPathCreateMutable();
    
    CGFloat leftCornerRadius = 20;
    CGFloat rightCornerRadius = 10;
    
    //bottom left
    CGPathMoveToPoint(self->topAvgSpeedPlaceholderPath, NULL, leftCornerRadius, self.placeholderAvgSpeed.bounds.size.height - 10);
    //left
    CGPathAddArcToPoint(self->topAvgSpeedPlaceholderPath, NULL, 0, self.placeholderAvgSpeed.bounds.size.height - 10, 0, leftCornerRadius, leftCornerRadius);
    //top left
    CGPathAddLineToPoint(self->topAvgSpeedPlaceholderPath, NULL, 0, 0);
    //top right
    CGPathAddLineToPoint(self->topAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width, 0);
    
    //right
    CGPathAddLineToPoint(self->topAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width, self.placeholderAvgSpeed.bounds.size.height - rightCornerRadius);
    //bottom right
    CGPathAddArcToPoint(self->topAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width, self.placeholderAvgSpeed.bounds.size.height, self.placeholderAvgSpeed.bounds.size.width - rightCornerRadius, self.placeholderAvgSpeed.bounds.size.height, rightCornerRadius);
    //bottom
    CGPathAddLineToPoint(self->topAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width - placeholderAvgSpeedWindow.bounds.size.width, self.placeholderAvgSpeed.bounds.size.height);
    CGPathAddArcToPoint(self->topAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width - (placeholderAvgSpeedWindow.bounds.size.width + rightCornerRadius), self.placeholderAvgSpeed.bounds.size.height, self.placeholderAvgSpeed.bounds.size.width - (placeholderAvgSpeedWindow.bounds.size.width + rightCornerRadius), self.placeholderAvgSpeed.bounds.size.height - rightCornerRadius, rightCornerRadius);
    //bottom left
    CGPathCloseSubpath(self->topAvgSpeedPlaceholderPath);
    
    self->bottomAvgSpeedPlaceholderPath = CGPathCreateMutable();
    
    //top left
    CGPathMoveToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, leftCornerRadius, 10);
    //left
    CGPathAddArcToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, 0, 10, 0, leftCornerRadius + 10, leftCornerRadius);
    //bottom left
    CGPathAddLineToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, 0, self.placeholderAvgSpeed.bounds.size.height);
    //bottom right
    CGPathAddLineToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width, self.placeholderAvgSpeed.bounds.size.height);
    
    //right
    CGPathAddLineToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width, rightCornerRadius);
    //top right
    CGPathAddArcToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width, 0, self.placeholderAvgSpeed.bounds.size.width - rightCornerRadius, 0, rightCornerRadius);
    //top
    CGPathAddLineToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width - placeholderAvgSpeedWindow.bounds.size.width, 0);
    CGPathAddArcToPoint(self->bottomAvgSpeedPlaceholderPath, NULL, self.placeholderAvgSpeed.bounds.size.width - (placeholderAvgSpeedWindow.bounds.size.width + rightCornerRadius), 0, self.placeholderAvgSpeed.bounds.size.width - (placeholderAvgSpeedWindow.bounds.size.width + rightCornerRadius), rightCornerRadius, rightCornerRadius);
    //bottom left
    CGPathCloseSubpath(self->bottomAvgSpeedPlaceholderPath);
    
    self.placeholderAvgSpeedIntervalText = [[CATextLayer alloc] init];
    self.placeholderAvgSpeedIntervalText.bounds = CGRectMake(0,0, 60, 44);
    self.placeholderAvgSpeedIntervalText.anchorPoint = CGPointMake(0.0, 0.1);
    self.placeholderAvgSpeedIntervalText.foregroundColor = [[UIColor whiteColor] CGColor];
    self.placeholderAvgSpeedIntervalText.alignmentMode = kCAAlignmentCenter;
    self.placeholderAvgSpeedIntervalText.wrapped = YES;
    self.placeholderAvgSpeedIntervalText.contentsScale = [[UIScreen mainScreen] scale];
    self.placeholderAvgSpeedIntervalText.fontSize = 17.0;
    
    self.placeholderAvgSpeedUnit = [[CATextLayer alloc] init];
    self.placeholderAvgSpeedUnit.bounds = CGRectMake(0,0, 40, 23);
    self.placeholderAvgSpeedUnit.position = CGPointMake(placeholderAvgSpeedWindow.bounds.size.width - (self.placeholderAvgSpeedUnit.bounds.size.width + 3), placeholderAvgSpeedWindow.bounds.size.height);
    self.placeholderAvgSpeedUnit.anchorPoint = CGPointMake(0.0, 1.0);
    self.placeholderAvgSpeedUnit.foregroundColor = [[UIColor darkGrayColor] CGColor];
    self.placeholderAvgSpeedUnit.alignmentMode = kCAAlignmentLeft;
    self.placeholderAvgSpeedUnit.fontSize = 18.0;
    self.placeholderAvgSpeedUnit.contentsScale = [[UIScreen mainScreen] scale];
    
    [placeholderAvgSpeedWindow addSublayer:self.placeholderAvgSpeedUnit];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //force refresh the speed unit
    _unit = -1;
    [self setUnit:[defaults integerForKey:@"speed_unit_preference"]];
    
    self.placeholderAvgSpeedText = [[CATextLayer alloc] init];
    self.placeholderAvgSpeedText.bounds = CGRectMake(0,0, 80, placeholderAvgSpeedWindow.bounds.size.height);
    self.placeholderAvgSpeedText.position = CGPointMake(self.placeholderAvgSpeedUnit.position.x - 5, placeholderAvgSpeedWindow.bounds.size.height);
    self.placeholderAvgSpeedText.anchorPoint = CGPointMake(1.0, 1.0);
    self.placeholderAvgSpeedText.foregroundColor = [[UIColor darkGrayColor] CGColor];
    self.placeholderAvgSpeedText.alignmentMode = kCAAlignmentRight;
    self.placeholderAvgSpeedText.contentsScale = [[UIScreen mainScreen] scale];
    self.placeholderAvgSpeedText.string = @"0.0";
    
    [placeholderAvgSpeedWindow addSublayer:self.placeholderAvgSpeedText];
    
    [self.placeholderAvgSpeed addSublayer:self.placeholderAvgSpeedIntervalText];
    
    [self.placeholderAvgSpeed setHidden:TRUE];
    
    [self.layer addSublayer:self.placeholderAvgSpeed];
}

- (void)showBottomPlaceholderAvgSpeed
{
    self.placeholderAvgSpeed.position = CGPointMake(AVG_SPEED_INDICATOR_LEFT_MARGIN, self.bounds.size.height - self.placeholderAvgSpeed.bounds.size.height);
    self.placeholderAvgSpeedIntervalText.position = CGPointMake(10, (self.placeholderAvgSpeed.bounds.size.height - self.placeholderAvgSpeedIntervalText.bounds.size.height) + 6);
    [self.placeholderAvgSpeed setHidden:NO];
    self.placeholderAvgSpeed.path = self->bottomAvgSpeedPlaceholderPath;
    [self.placeholderAvgSpeed removeAllAnimations];
    
}

- (void)showTopPlaceholderAvgSpeed
{
    
    //leave a 20px top margin for the status bar
    self.placeholderAvgSpeed.position = CGPointMake(AVG_SPEED_INDICATOR_LEFT_MARGIN, self->statusBarOverlapMargin);
    self.placeholderAvgSpeedIntervalText.position = CGPointMake(10, 2);
    [self.placeholderAvgSpeed setHidden:NO];
    self.placeholderAvgSpeed.path = self->topAvgSpeedPlaceholderPath;
    [self.placeholderAvgSpeed removeAllAnimations];
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
    self.avgSpeedIndicator.position = CGPointMake(AVG_SPEED_INDICATOR_LEFT_MARGIN, [self getYCoordForSpeed:avgSpeed]);
    self.placeholderAvgSpeedText.string = [self abbreviate:avgSpeed * self->conversionFactor];
    
    CGFloat yPosInView = self.avgSpeedIndicator.position.y - ([self getYCoordForSpeed:_currentSpeed] - CGRectGetMidY(self.bounds));
    
    CGFloat avgSpeedIndicatorHalfHeight = self.avgSpeedIndicator.bounds.size.height / 2;
    
    //leave a 20px top margin for the status bar
    if(yPosInView < avgSpeedIndicatorHalfHeight + 20) {
        [self.avgSpeedIndicator setHidden:YES];
        [self showTopPlaceholderAvgSpeed];
    } else if(yPosInView > self.bounds.size.height - avgSpeedIndicatorHalfHeight) {
        [self.avgSpeedIndicator setHidden:YES];
        [self showBottomPlaceholderAvgSpeed];
    } else {
        [self.avgSpeedIndicator setHidden:NO];
        [self.placeholderAvgSpeed setHidden:YES];
    }
}

- (void)disable {
    [self.avgSpeedIndicator setHidden:TRUE];
    [self.placeholderAvgSpeed setHidden:TRUE];
    [self setCurrentSpeed:0];
    self.speedometerLayer.backgroundColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] CGColor];
}

- (void)resetAvg {
    if([self.avgSpeedIndicator isHidden]) {
        return;
    }
    
    [self setAvgSpeed:self.currentSpeed];
    [self setAvgInterval:0];
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
            self.placeholderAvgSpeedUnit.string = @"mi/h";
            self->conversionFactor = MPH_CONVERSION_FACTOR;
            break;
        case kph:
            self.currentSpeedUnit.string = @"km/h";
            self.placeholderAvgSpeedUnit.string = @"km/h";
            self->conversionFactor = KPH_CONVERSION_FACTOR;
            break;
    }
    
    //force immediate update of speed reading
    [self setCurrentSpeed:self.currentSpeed];
    
    [self drawGaugeMarkings];
}

- (void)setAvgInterval:(NSTimeInterval)avgInterval {
    NSString *avgIntervalStr;
    if(avgInterval <= 59.0) {
        avgIntervalStr = [[NSString alloc] initWithFormat:@"%d sec avg", (NSInteger)round(avgInterval)];
    } else {
        
        NSInteger halfMinutes = round(avgInterval / 30);
        
        NSInteger minutes = halfMinutes / 2;
        
        if(halfMinutes % 2 == 0) {
            avgIntervalStr = [[NSString alloc] initWithFormat:@"%d min avg",minutes];
        } else {
            avgIntervalStr = [[NSString alloc] initWithFormat:@"%d.5 min avg",minutes];
        }
    }
    
    self.avgSpeedIntervalText.string = avgIntervalStr;
    self.placeholderAvgSpeedIntervalText.string = avgIntervalStr;
}

@end
