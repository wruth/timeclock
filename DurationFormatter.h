//
//  DurationFormatter.h
//  TimeClock
//
//  Created by Ward Ruth on 3/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


 enum {
	 WMRDurationToClosestMinute			= 0,
	 WMRDurationToClosestFiveMinutes	= 1,
	 WMRDurationToClosestFifteenMinutes	= 2
 };

typedef NSUInteger WMRDurationRoundingMode;

@interface DurationFormatter : NSFormatter 
{
	WMRDurationRoundingMode roundingStrategy;
}

@property(readwrite, assign) WMRDurationRoundingMode roundingStrategy;

@end
