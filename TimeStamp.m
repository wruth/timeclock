// 
//  TimeStamp.m
//  TimeClock
//
//  Created by Ward Ruth on 2/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TimeStamp.h"


@implementation TimeStamp 


+ (NSSet *)keyPathsForValuesAffectingDuration
{
	return [NSSet setWithObjects:@"startTime", @"endTime", nil];
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setStartTime: [NSDate date]];
	
	NSLog( @"endTime = %@", [self endTime]);
}

@dynamic note;
@dynamic endTime;
@dynamic startTime;
@dynamic task;


- (NSTimeInterval)duration
{
	if ([self endTime]) {
		return [[self endTime] timeIntervalSinceDate:[self startTime]];
	}
	
	//return 0;
	return [[NSDate date] timeIntervalSinceDate:[self startTime]];
}

@end
