//
//  DayDetailsWindowController.m
//  TimeClock
//
//  Created by Ward Ruth on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DayDetailsWindowController.h"
#import "ManagedObjectContextManager.h"
#import "TimeStamp.h"
#import "ManagedObjectContextManager.h"

@interface DayDetailsWindowController (PrivateAPI)
- (void)selectDay:(NSDate *)day;
- (NSDate *)startDayFromDate:(NSDate *)date;
- (void)updateUi;
- (void)createToday;
- (void)fetchTimeStampsForDate:(NSDate *)date;
@end

@implementation DayDetailsWindowController

- (id)init
{
	if (![super initWithWindowNibName:@"DayDetails"])
		return nil;
	
	windowTitleFormatter = [[NSDateFormatter alloc] init];
	[windowTitleFormatter setDateStyle:NSDateFormatterFullStyle];
	selectedDay = nil;
	
	sharedManager = [[ManagedObjectContextManager sharedManager] retain];
		
	return self;
}

- (void)awakeFromNib
{
	[timeStampsTableView setNextResponder:self];
	[self setNextResponder:window];
}

- (void)dealloc
{
	[selectedDay release];
	[today release];
	[windowTitleFormatter release];
	[sharedManager release];
	[super dealloc];
}

- (void)updateUi
{
	NSString *windowTitle = [NSString stringWithFormat:@"Timestamp Details for %@", [windowTitleFormatter stringFromDate:selectedDay]];
	[[self window] setTitle:windowTitle];
	[datePicker setDateValue:selectedDay];
	[todayButton setEnabled:![selectedDay isEqualToDate:today]];
	[previousNextDayControl setEnabled:![selectedDay isEqualToDate:today] forSegment:1];
	[self fetchTimeStampsForDate:selectedDay];
}


- (void)createToday
{
	NSDate *newToday = [[self startDayFromDate:[NSDate date]] retain];
	[today release];
	today = newToday;
}

- (void)fetchTimeStampsForDate:(NSDate *)date
{
	NSLog(@"fetchTimeStampsForToday");
	NSFetchRequest *request = [ sharedManager fetchRequestForTimeStampsForDay:date];
	NSError *error;
	NSLog(@"about to fetch on timeStampsController...");
	
	
	BOOL ok = [timeStampsController fetchWithRequest:request merge:NO error:&error];
	
	NSLog(@"Result of fetch on timeStampsController %d", ok);
}



/**
	Finds and returns the first Monday on or before the passed in date
 */

- (NSDate *)startDayFromDate:(NSDate *)date
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
	
	int year = [comps year];
	int week = [comps week];
	int weekday = [comps weekday];
	
	NSLog( @"year: %d, week: %d, weekday: %d", year, week, weekday );
	
	NSDate *dayStart = [calendar dateFromComponents:comps];
	NSLog(@"dayStart (from comps) = %@", dayStart);
	
	return dayStart;
}



/**
	 Selects the current week for the controller. This is an NSDate object
	 representing the Monday of the week.
 */

- (void)selectDay:(NSDate *)day
{
	NSLog(@"selectDay, day = %@", day);
	
	// don't select a day past today 
	if ([day timeIntervalSinceDate:today] > 0)
	{
		NSBeep();
		return;
	}
	
	[day retain];
	[selectedDay release];
	selectedDay = day;
	
	[self updateUi];
}

#pragma mark Actions

- (IBAction)showWindow:(id)sender
{
	[self createToday];
	
	[datePicker setMaxDate:today];
	
	//
	// recreate the content each time the window is shown, since it might have
	// changed
	//
	if (!selectedDay) {
		[self selectDay:today];
	}
	else {
		[self updateUi];
	}
	
	[super showWindow:sender];
}

- (IBAction)showDatePicker:(id)sender
{
	NSPoint cornerPoint = [sender convertPointToBase:NSZeroPoint];
	NSPoint panelCornerPoint = [[sender window] convertBaseToScreen:cornerPoint];
	[datePanel setFrameTopLeftPoint:panelCornerPoint];
	[datePanel makeKeyAndOrderFront:self];
}


/**
	Handles click on the This Week button. Set the date to the current week.
 */

- (IBAction)todayAction:(id)sender
{
	NSLog(@"todayAction");
	[self selectDay:[self startDayFromDate:[NSDate date]]];
}


/**
	 Handles click on the previous or next segment of the by week segmented
	 control
 */

- (IBAction)previousNextDayAction:(id)sender
{
	int interval = ([sender selectedSegment] == PREVIOUS_DAY) ? - 1 : 1;
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:interval];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *newDate = [calendar dateByAddingComponents:comps toDate:selectedDay options:0];
	[self selectDay:newDate];
}


/**
	Handles click on the date picker
 */

- (IBAction)chooseDayAction:(id)sender
{
	NSLog(@"chooseDayAction");
	[self selectDay:[self startDayFromDate:[sender dateValue]]];
}


#pragma mark NSResponder methods

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

/**
	Delete key press deletes selected TimeStamp
 */
- (void)keyDown:(NSEvent *)e
{
	NSManagedObject *selectedTimeStamp = [[[timeStampsController selectedObjects] lastObject] autorelease];
	
	NSLog(@"keyDown, selectedTimeStamp = %@", selectedTimeStamp);
	if (([e keyCode] == 51) || ([e keyCode] == 117)) {
		if (selectedTimeStamp)
			[[sharedManager managedObjectContext] deleteObject:selectedTimeStamp];
	}
}


@end
