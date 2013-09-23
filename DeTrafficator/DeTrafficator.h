//
//  DeTrafficator.h
//  DeTrafficator
//
//  Created by Robin Johnson on 7/15/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#ifndef DeTrafficator_DeTrafficator_h
#define DeTrafficator_DeTrafficator_h

enum {
    mph = 0,
    kph
};
typedef NSInteger SpeedUnit;

#ifdef DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

#define logRect(rect, description) debug_NSLog(@"%@ %f %f %f %f",description, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

#endif
