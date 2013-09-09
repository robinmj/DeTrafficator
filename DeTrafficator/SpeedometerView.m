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
    
    // the speedometer gauge
    CAShapeLayer* arc = [[CAShapeLayer alloc] init];
    arc.lineWidth = 2.0;
    arc.fillColor =
    [[UIColor colorWithRed:0.9 green:0.95 blue:0.93 alpha:0.9] CGColor];
    arc.strokeColor = [[UIColor grayColor] CGColor];
    CGMutablePathRef p = CGPathCreateMutable();
    CGPathAddEllipseInRect(p, NULL, CGRectInset(self.bounds, 3, 3));
    arc.path = p;
    [self addSublayer:arc];
    arc.bounds = self.bounds;
    arc.position = CGPointMake(CGRectGetMidX(self.bounds),
                                  CGRectGetMidY(self.bounds));
    
    for (int i = 0; i < 9; i++) {
        CATextLayer* t = [[CATextLayer alloc] init];
        t.string = [NSString stringWithFormat:@"%i", i * 5];
        t.bounds = CGRectMake(0,0,40,60);
        t.position = CGPointMake(CGRectGetMidX(arc.bounds),
                                 CGRectGetMidY(arc.bounds));
        CGFloat vert = (CGRectGetMidY(arc.bounds) - 5) / CGRectGetHeight(t.bounds);
        t.anchorPoint = CGPointMake(0.5, vert);
        t.alignmentMode = kCAAlignmentCenter;
        t.foregroundColor = [[UIColor blackColor] CGColor];
        [t setAffineTransform:CGAffineTransformMakeRotation((i - 4)*M_PI/8.0)];
        [arc addSublayer:t];
    }
    
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
