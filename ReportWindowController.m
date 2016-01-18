//
//  ReportWindowController.m
//  TimeClock
//
//  Created by Ward Ruth on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReportWindowController.h"
#import "ReportTreeNode.h"
#import "ManagedObjectContextManager.h"
#import "TimeStamp.h"
#import "Task.h"
#import "Project.h"
#import "DurationFormatter.h"

@interface ReportWindowController (PrivateAPI)

- (void)createThisWeek;
- (void)createContent;
//- (void)addTimeStamps:(NSArray *)timeStampsForDay forDay:(NSString *)dayName inProjectNodes:(NSMutableArray *)projectNodes;
- (void)addTimeStampsToTaskNode:(NSArray *)timeStampsForDay 
				 inProjectNodes:(NSMutableArray *)projectNodes 
				  andTotalsNode:(ReportTreeNode *)totalsNode 
						 forDay:(NSString *)dayName;
- (ReportTreeNode *)reportNodeMatchingAbstractTask:(AbstractTask *)task 
									  inChildNodes:(NSMutableArray *)childNodes;
- (NSDate *)weekDateFromDate:(NSDate *)date;
- (void)selectWeek:(NSDate *)week;
- (void)updateUi;

@end


@implementation ReportWindowController
@synthesize content;

- (id)init
{
	if (![super initWithWindowNibName:@"Report"])
		return nil;
	
	windowTitleFormatter = [[NSDateFormatter alloc] init];
	[windowTitleFormatter setDateStyle:NSDateFormatterFullStyle];
	selectedWeek = nil;
	return self;
}

- (void)dealloc
{
	[selectedWeek release];
	[thisWeek release];
	[windowTitleFormatter release];
	[super dealloc];
}

- (void)windowDidLoad
{
	[durationFormatter setRoundingStrategy:WMRDurationToClosestFifteenMinutes];
}


/**
	Create the content array for a NSTreeController that is the data source of
	the report view. This is an array of project nodes, each of which contains
	a collection of child leaf task nodes. Project and taks nodes are instances
	of ReportTreeNode, and contain key paths for name, days of the week, and
	total.
*/

- (void)createContent
{
	NSArray *dayNames = [NSArray arrayWithObjects:MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY, nil];
	
	// the direct data source for the NSTreeController
	NSMutableArray *projectNodes = [[[NSMutableArray alloc] init] autorelease];
	ReportTreeNode *totalsNode = [[[ReportTreeNode alloc] init] autorelease];
	[totalsNode setName:@"Total:"];
	
	NSArray *timeStampsForDay;
	NSDate *theDay;
	NSError *error;
	int i = 0;

	do {
		// determine the day of the week, in sequence, from Monday to Sunday
		theDay = [[[NSDate alloc] initWithTimeInterval:ONE_DAY * i sinceDate:selectedWeek] retain];
		
		// get all TimeStamps for the specifed day from the ManagedObjectContext
		timeStampsForDay = [[ManagedObjectContextManager sharedManager] fetchResultForTimeStampsForDay:theDay error:&error];
		
		if (timeStampsForDay == nil) {
			NSLog(@"error retrieving timeStamps: %@", [error localizedDescription]);
		}
		else if ([timeStampsForDay count] > 0) {
			[self addTimeStampsToTaskNode:timeStampsForDay 
						   inProjectNodes:projectNodes 
							andTotalsNode:totalsNode 
								   forDay:[dayNames objectAtIndex:i]];
		}
		
		[theDay release];

	} while (++i < 7);
	
	[projectNodes addObject:totalsNode];
	
	// trigger binding association for the NSTreeController instance
	[self setContent:projectNodes];
}

/**
	Find the projectNode -> taskNode for each TimeStamp for this day, and add
	the duration of the TimeStamp to the taskNode.
 */
- (void)addTimeStampsToTaskNode:(NSArray *)timeStampsForDay 
				 inProjectNodes:(NSMutableArray *)projectNodes 
				  andTotalsNode:(ReportTreeNode *)totalsNode 
						 forDay:(NSString *)dayName 
		 
{
	TimeStamp *aTimeStamp;
	Task *aTask;
	Project *aProject;
	ReportTreeNode *projectNode;
	ReportTreeNode *taskNode;
	
	for (aTimeStamp in timeStampsForDay) {
		aTask = [aTimeStamp task];
		aProject = [aTask project];
		
		projectNode = [self reportNodeMatchingAbstractTask:aProject 
											  inChildNodes:projectNodes];

		taskNode = [self reportNodeMatchingAbstractTask:aTask 
										   inChildNodes:[projectNode mutableChildNodes]];
		
		[taskNode addValue:[aTimeStamp duration] forKey:dayName];
		[totalsNode addValue:[aTimeStamp duration] forKey:dayName];
	}
}

/**
	Find the report node corresponding to the associated AbstractTask (a Project
	or Task) in the childNodes array.
 */
- (ReportTreeNode *)reportNodeMatchingAbstractTask:(AbstractTask *)task 
									  inChildNodes:(NSMutableArray *)childNodes
{
	ReportTreeNode *abstractTaskNode;
	ReportTreeNode *matchedAbstractTaskNode = nil;
	
	if ([childNodes count] > 0) {
		for (abstractTaskNode in childNodes) {
			if ([(AbstractTask *)[abstractTaskNode representedObject] objectID] == [task objectID]) {
				matchedAbstractTaskNode = abstractTaskNode;
				break;
			}
		}
	}
	
	if (matchedAbstractTaskNode == nil) {
		matchedAbstractTaskNode = [[[ReportTreeNode alloc] initWithRepresentedObject:task] autorelease];
		[childNodes addObject:matchedAbstractTaskNode];
	}
	
	return matchedAbstractTaskNode;
}

/**
	Finds and returns the first Monday on or before the passed in date
 */
- (NSDate *)weekDateFromDate:(NSDate *)date
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
	
	//
	// Sunday is normally the start of the week, or weekday 1. But in this
	// scheme the start of the week is Monday, so for this purpose Sunday needs
	// to be remapped to the end of the week. Since Monday is weekday 2, Sunday
	// needs to be remapped from weekday 1 to weekday 8.
	//
	if (weekday == 1)
		weekday = 8;
	
	return [[[NSDate alloc] initWithTimeInterval:-(weekday - 2) * ONE_DAY sinceDate:dayStart]autorelease];
}

/**
	Selects the current week for the controller. This is an NSDate object
	representing the Monday of the week.
 */
- (void)selectWeek:(NSDate *)week
{
	NSLog(@"selectWeek, week = %@", week);

	// don't select a week past the current week 
	if ([week timeIntervalSinceDate:thisWeek] > 0)
	{
		NSBeep();
		return;
	}
	
	[week retain];
	[selectedWeek release];
	selectedWeek = week;
	
	[self updateUi];
	[self createContent];
}

- (void)updateUi
{
	NSString *windowTitle = [NSString stringWithFormat:@"Report for Week of %@", [windowTitleFormatter stringFromDate:selectedWeek]];
	[[self window] setTitle:windowTitle];
	[datePicker setDateValue:selectedWeek];
	[thisWeekButton setEnabled:![selectedWeek isEqualToDate:thisWeek]];
	[previousNextWeekControl setEnabled:![selectedWeek isEqualToDate:thisWeek] forSegment:1];
}

- (void)createThisWeek
{
	NSDate *newThisWeek = [[self weekDateFromDate:[NSDate date]] retain];
	[thisWeek release];
	thisWeek = newThisWeek;
}

#pragma mark Actions

- (IBAction)showWindow:(id)sender
{
	[self createThisWeek];
	
	NSDate *maxDate = [[[NSDate alloc] initWithTimeInterval:6 * ONE_DAY sinceDate:thisWeek]autorelease];
	[datePicker setMaxDate:maxDate];
	
	//
	// recreate the content each time the window is shown, since it might have
	// changed
	//
	if (!selectedWeek) {
		[self selectWeek:thisWeek];
	}
	else {
		[self createContent];
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

- (IBAction)thisWeekAction:(id)sender
{
	NSLog(@"thisWeekAction");
	[self selectWeek:[self weekDateFromDate:[NSDate date]]];
}


/**
	Handles click on the previous or next segment of the by week segmented
	control
 */

- (IBAction)previousNextWeekAction:(id)sender
{
	int interval = ([sender selectedSegment] == PREVIOUS_WEEK) ? - 1 : 1;
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setWeek:interval];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *newDate = [calendar dateByAddingComponents:comps toDate:selectedWeek options:0];
	[self selectWeek:newDate];
}


/**
	Handles click on the date picker
 */

- (IBAction)chooseWeekAction:(id)sender
{
	NSLog(@"chooseWeekAction");
	[self selectWeek:[self weekDateFromDate:[sender dateValue]]];
}


/**
	Refresh the report for the currently loaded week
 */

- (IBAction)refreshAction:(id)sender
{
	[self createContent];	
}

@end
