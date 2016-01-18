//
//  AdjustTimeStampController.m
//  TimeClock
//
//  Created by Ward Ruth on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AdjustTimeStampController.h"
#import "TimeStamp.h"
#import "ManagedObjectContextManager.h"

NSString * const WMRKeyMessageText = @"keyMessageText";
NSString * const WMRKeyInformativeText = @"keyInformativeText";

@interface AdjustTimeStampController (PrivateAPI)

- (void)beginTimeSheet;
- (void)endTimeSheet;
- (BOOL)validateWithErrorDictionary:(NSMutableDictionary *)dictionary;

@end


@implementation AdjustTimeStampController

@synthesize endTime;
@synthesize startTime;


#pragma mark Actions

- (IBAction)editSelectedTimeStamp:(id)sender
{
	NSLog(@"table double clicked, sender = %@", sender);

	TimeStamp *timeStamp = [sender lastObject];
	[timeStamp retain];

	[selectedTimeStamp release];
	selectedTimeStamp = timeStamp;
	
	
	NSManagedObject *taskForSelectedTimeStamp = [[selectedTimeStamp task] autorelease];
	NSLog(@"task = %@", taskForSelectedTimeStamp);
	BOOL result = [tasksArrayController setSelectedObjects:[NSArray arrayWithObject:taskForSelectedTimeStamp]];
	NSLog(@"result = %d", result);
	
	[self setStartTime:[[selectedTimeStamp startTime] copy]];
	[self setEndTime:[[selectedTimeStamp endTime] copy]];
	[startTimeDatePicker setMaxDate:[NSDate date]];
	
	if (endTime) {
		[endTimeDatePicker setDatePickerElements:NSHourMinuteDatePickerElementFlag];
		[endTimeDatePicker setMaxDate:[NSDate date]];
	}
	else {
		[endTimeDatePicker setDatePickerElements:0];
	}

	[self beginTimeSheet];
}

- (IBAction)saveChanges:(id)sender
{
	NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
	
	if ([self validateWithErrorDictionary:errorDictionary]) {
		[selectedTimeStamp setStartTime:[self startTime]];
		[selectedTimeStamp setEndTime:[self endTime]];
		[sharedManager saveState];
		[self endTimeSheet];
	}
	else {
		NSAlert *alert = [NSAlert alertWithMessageText:[errorDictionary valueForKey:WMRKeyMessageText] 
										 defaultButton:@"OK" 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:[errorDictionary valueForKey:WMRKeyInformativeText]];
		
		[alert beginSheetModalForWindow:adjustTimeSheet 
						  modalDelegate:nil
						 didEndSelector:nil
							contextInfo:NULL];
	}
}

- (IBAction)cancelChanges:(id)sender
{
	[self endTimeSheet];
}

/**
	 Action handler for the task Pop Up Button. The currentTask pointer is
	 reassigned to the newly selected task. The currentTask is then applied to
	 the currently selected TimeStamp, if defined.
 */

- (IBAction)changeCurrentTask:(id)sender
{
	[selectedTimeStamp setTask:[[tasksArrayController selectedObjects] lastObject]];
}


- (BOOL)validateWithErrorDictionary:(NSMutableDictionary *)dictionary
{
	if ([startTime isEqualToDate:[selectedTimeStamp startTime]] && [endTime isEqualToDate:[selectedTimeStamp endTime]]) {
		NSLog(@"times are equal");
		return YES;
	}
	
	if ([endTime timeIntervalSinceDate:startTime] < 0) {
		[dictionary setValue:@"End Time Cannot Be Earlier Than Start Time" forKey:WMRKeyMessageText];
		[dictionary setValue:@"The end time is currently set to occur before the start time. Please adjust the start and end time so that they occur in chronological order." forKey:WMRKeyInformativeText];
		return NO;
	}
	
	NSArray *timeStamps = [timeStampsArrayController content];
	TimeStamp *timeStamp;
	
	for (timeStamp in timeStamps) {
		//NSLog(@"timeStamp = %@", timeStamp);
		
		if (selectedTimeStamp == timeStamp)
			continue;
		
		// if the proposed endTime ends before the test TimeStamp begins, ok
		if ([endTime timeIntervalSinceDate:[timeStamp startTime]] <= 0)
			continue;
		
		// if the proposed startTime starts after the test TimeStamp ends, ok
		if ([startTime timeIntervalSinceDate:[timeStamp endTime]] >= 0)
			continue;
		
		[dictionary setValue:@"Proposed Interval Overlaps Another TimeStamp" forKey:WMRKeyMessageText];
		[dictionary setValue:@"The interval defined by the start and end time overlaps that of another TimeStamp. Please adjust the start and end time so that this TimeStamp falls in a unique interval." forKey:WMRKeyInformativeText];
		return NO;
	}
	
	return YES;
}

- (void)beginTimeSheet
{
	[NSApp beginSheet:adjustTimeSheet
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:NULL];
}

- (void)endTimeSheet
{
	[NSApp endSheet:adjustTimeSheet];
	[adjustTimeSheet orderOut:self];
}

- (void)dealloc
{
	[selectedTimeStamp release];
	[startTime release];
	[endTime release];
	[super dealloc];
}

@end
