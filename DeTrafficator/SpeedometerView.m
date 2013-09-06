//
//  SpeedometerView.m
//  
//
//  Created by Robin Johnson on 9/5/13.
//
//

#import "SpeedometerView.h"

@implementation SpeedometerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        debug_NSLog(@"initWithFrame()");
        
        self.frame = frame;
        self.bounds = frame;
        
        [[SpeedometerLayer alloc] initWithParentView:self];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@implementation SpeedometerLayer

- (id)initWithParentView:(UIView*)parent {
    self = [super init];
    
    [parent.layer addSublayer:self];
    
    self.bounds = parent.bounds;
    self.frame = parent.frame;
    
    debug_NSLog(@"initWithParentView()");
    
    // the gradient
    CAGradientLayer* g = [[CAGradientLayer alloc] init];
    g.frame = self.bounds;
    g.colors = [NSArray arrayWithObjects:
                (id)[[UIColor blackColor] CGColor],
                [[UIColor redColor] CGColor],
                nil];
    g.locations = [NSArray arrayWithObjects:
                   [NSNumber numberWithFloat: 0.0], [NSNumber numberWithFloat: 1.0], nil];
    [self addSublayer:g];
    // the circle
    CAShapeLayer* circle = [[CAShapeLayer alloc] init];
    circle.lineWidth = 2.0;
    circle.fillColor =
    [[UIColor colorWithRed:0.9 green:0.95 blue:0.93 alpha:0.9] CGColor]; circle.strokeColor = [[UIColor grayColor] CGColor];
    CGMutablePathRef p = CGPathCreateMutable(); CGPathAddEllipseInRect(p, NULL, CGRectInset(self.bounds, 3, 3));
    circle.path = p;
    [self addSublayer:circle];
    circle.bounds = self.bounds;
    circle.position = CGPointMake(CGRectGetMidX(self.bounds),
                                  CGRectGetMidY(self.bounds));
    // the four cardinal points
    NSArray* pts = [NSArray arrayWithObjects: @"N", @"E", @"S", @"W", nil]; for (int i = 0; i < 4; i++) {
        CATextLayer* t = [[CATextLayer alloc] init]; t.string = [pts objectAtIndex: i];
        t.bounds = CGRectMake(0,0,40,30);
        t.position = CGPointMake(CGRectGetMidX(circle.bounds),
                                 CGRectGetMidY(circle.bounds));
        CGFloat vert = (CGRectGetMidY(circle.bounds) - 5) / CGRectGetHeight(t.bounds);
        t.anchorPoint = CGPointMake(0.5, vert);
        t.alignmentMode = kCAAlignmentCenter;
        t.foregroundColor = [[UIColor blackColor] CGColor];
        [t setAffineTransform:CGAffineTransformMakeRotation(i*M_PI/2.0)];
        [circle addSublayer:t]; }
    // the arrow
    CALayer* arrow = [[CALayer alloc] init];
    arrow.bounds = CGRectMake(0, 0, 40, 100);
    arrow.position = CGPointMake(CGRectGetMidX(self.bounds),
                                 CGRectGetMidY(self.bounds)); arrow.anchorPoint = CGPointMake(0.5, 0.8);
    arrow.delegate = self;
    [arrow setAffineTransform:CGAffineTransformMakeRotation(M_PI/5.0)]; [self addSublayer:arrow];
    [arrow setNeedsDisplay];
    
    return self;
}

- (void)drawLayer:(CALayer *)theLayer inContext:(CGContextRef)theContext {
    
    debug_NSLog(@"drawLayer()");
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    
    
    
    CGPathMoveToPoint(thePath,NULL,15.0f,15.f);
    
    CGPathAddCurveToPoint(thePath,
                          
                          NULL,
                          
                          15.f,250.0f,
                          
                          295.0f,250.0f,
                          
                          295.0f,15.0f);
    
    
    
    CGContextBeginPath(theContext);
    
    CGContextAddPath(theContext, thePath);
    
    
    
    CGContextSetLineWidth(theContext, 5);
    
    CGContextStrokePath(theContext);
    
    
    
    // Release the path
    
    CFRelease(thePath);
    
}

@end
