//
//  DurationFormatter.m
//  TimeClock
//
//  Created by Ward Ruth on 3/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DurationFormatter.h"


@implementation DurationFormatter

@synthesize roundingStrategy;

- (id)init
{
	if (![super init])
	{
		return nil;
	}
	
	[self setRoundingStrategy:WMRDurationToClosestMinute];
	return self;
}

/**
	Format an NSNumber instance representing a number of seconds into the form
	[M]M:SS. Rounding can be performed at a granularity of minutes, five minutes,
	and fifteen minutes.
 */
- (NSString *)stringForObjectValue:(id)anObject
{
	if (![anObject isKindOfClass:[NSNumber class]]) {
		return nil;
	}
	
	float totalMinutes = [(NSNumber *)anObject floatValue] / 60.0;
	int hours = totalMinutes / 60;
	int minutes;
	float remainingMinutes = totalMinutes - hours * 60;
	float numMinutes, numFives, numFifteens;
	
	switch ([self roundingStrategy]) {
		case WMRDurationToClosestFiveMinutes:
			numFives = round(remainingMinutes / 5.0);
			
			if (numFives == 12) {
				minutes = 0;
				++hours;
			}
			else {
				minutes = numFives * 5;
			}

			break;
		case WMRDurationToClosestFifteenMinutes:
			numFifteens = round(remainingMinutes / 15.0);

			if (numFifteens == 4) {
				minutes = 0;
				++hours;
			}
			else {
				minutes = numFifteens * 15;
			}
			break;
		default:
			numMinutes = round(remainingMinutes);
			
			if (numMinutes == 60) {
				minutes = 0;
				++hours;
			}
			else {
				minutes = numMinutes;
			}
			break;
	}
	
	NSString *formattedDuration;
	
	if (minutes < 10) {
		formattedDuration = [NSString stringWithFormat:@"%d:0%d", hours, minutes];
	}
	else {
		formattedDuration = [NSString stringWithFormat:@"%d:%d", hours, minutes];
	}

	return formattedDuration;
}

/**
	Return an NSNumber instance representing a number of seconds from a string
	of the form [M...]M:SS.
 */
- (BOOL)getObjectValue:(id *)obj 
			 forString:(NSString *)string 
	  errorDescription:(NSString **)error
{
	int seconds;
	int hoursResult;
	int minutesResult;
	NSScanner *scanner;
	BOOL returnValue = NO;
	
	scanner = [NSScanner scannerWithString:string];
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@":"]];
	
	if ([scanner scanInt:&hoursResult] && ![scanner isAtEnd]) {
		
		if ([scanner scanInt:&minutesResult] && [scanner isAtEnd]) {
			returnValue = YES;
			seconds = hoursResult * 60 + minutesResult;
			
			if (obj)
				*obj = [NSNumber numberWithInt:seconds];
		}
	}
	
	if (returnValue == NO && error)
		*error = @"Couldn't convert to seconds";
	
	return returnValue;
}

@end
