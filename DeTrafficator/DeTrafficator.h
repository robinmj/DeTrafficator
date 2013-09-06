//
//  DeTrafficator.h
//  DeTrafficator
//
//  Created by Robin Johnson on 7/15/13.
//  Copyright (c) 2013 Subalpine Technologies. All rights reserved.
//

#ifndef DeTrafficator_DeTrafficator_h
#define DeTrafficator_DeTrafficator_h

#ifdef DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

#endif
