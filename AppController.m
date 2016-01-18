//
//  AppController.m
//  TimeClock
//
//  Created by Ward Ruth on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "TimeClock_AppDelegate.h"
#import "TasksWindowController.h"
#import "ReportWindowController.h"
#import "DayDetailsWindowController.h"
#import "TimeStamp.h"
#import "Task.h"
#import "ManagedObjectContextManager.h"

@interface AppController (PrivateAPI)

- (void)setUpTasksArrayController;
- (void)updateWindowTitle;
- (void)createMenuItems;
- (void)updateActiveTask:(Task *)task;
- (void)changeTrackingWithState:(int)state;
- (void)enableFastTimeStampSwitching:(BOOL)isFast;
- (void)enableInsertTimeStamp:(BOOL)isInsert;
- (void)endActiveTimeStampWithTime:(NSDate *)time;
- (void)startActiveTimeStamp;
- (void)updateModeViews;
- (void)endInsertTimeStampSheet;
- (void)startInsertTimeStamp;
- (void)endInsertTimeStamp;
@end


@implementation AppController

@synthesize activeTimeStamp;
@synthesize elapsedTimeActiveTimeStamp;
@synthesize insertSheetTitle;
@synthesize insertSheetBodyText;

#pragma mark Initialization and destruction methods

- (id)init
{
	if (![super init])
	{
		return nil;
	}

	windowTitleFormatter = [[NSDateFormatter alloc] init];
	[windowTitleFormatter setDateStyle:NSDateFormatterFullStyle];
	
	timeFormatter = [[[NSDateFormatter alloc] init] retain];
	[timeFormatter setDateStyle:NSDateFormatterNoStyle];
	[timeFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	fastTimeStampSwitchingMode = NO;
	insertTimeStampMode = NO;

	return self;
}

- (void)awakeFromNib
{
	NSLog(@"AppController awakeFromNib");
	sharedManager = [[ManagedObjectContextManager sharedManager] retain];
	
	
	[self setUpTasksArrayController];
	[self updateWindowTitle];
	[self createMenuItems];
	
	[[noteTextField cell] setPlaceholderString:NOTE_PLACEHOLDER_STRING];
	
	[window setNextResponder:self];
}

- (void)setUpTasksArrayController
{
	[tasksArrayController setManagedObjectContext:[sharedManager managedObjectContext]];
	[tasksArrayController setSortDescriptors:[sharedManager tasksSortDescriptors]];
	[tasksArrayController setFilterPredicate:[sharedManager tasksFilterPredicate]];
}

- (void)updateWindowTitle
{
	NSString *windowTitle = [NSString stringWithFormat:@"Time Clock: %@", [windowTitleFormatter stringFromDate:[NSDate date]]];
	[window setTitle:windowTitle];
}


/**
	Creates the tasksMenu and its associated menu item that are displayed when
	the tasks PopupButton overflows
 */

- (void)createMenuItems
{
	NSLog(@"createMenuItems");
	
	//  create the tasks related submenu
	
	NSMenu *tasksMainMenu = [[[NSMenu alloc] initWithTitle:@"Tasks"] autorelease];
	[tasksMainMenu setDelegate:self];
	[tasksMainMenuItem setSubmenu:tasksMainMenu];
}


- (void)dealloc
{
	[sharedManager release];
	[windowTitleFormatter release];
	[timeFormatter release];
	[elapsedTimeTimer invalidate];
	[elapsedTimeTimer release];
	[tasksWindowController release];
	[reportWindowController release];
	[dayDetailsWindowController release];
	[activeTimeStamp release];
	[activeTask release];
	[proposedTask release];
	
	[selectedMenuItem release];

	[super dealloc];
}


#pragma mark Task and TimeStamp management methods

- (void)updateActiveTask:(Task *)task
{
	NSLog( @"updateCurrentTask: %@", task);
	
	if (task) {
		[task retain];
	}
	
	[activeTask release];
	activeTask = task;
	
	if ( activeTimeStamp ) {
		[activeTimeStamp setTask:activeTask];
	}
	
}


/**
	Finish the activeTimeStamp if it exists
 */

- (void)endActiveTimeStamp
{
	NSLog(@"AppController endActiveTimeStamp");
	if (activeTimeStamp) {
		[self endActiveTimeStampWithTime:[NSDate date]];
		[sharedManager saveState];
	}
}

- (void)endActiveTimeStampWithTime:(NSDate *)time
{
	if (activeTimeStamp) {
		[activeTimeStamp setEndTime:time];
		[activeTimeStamp setNote:[noteTextField stringValue]];
		[activeTimeStamp removeObserver:self forKeyPath:@"startTime"];
		
		[self setActiveTimeStamp: nil];
		
		[elapsedTimeTimer invalidate];
		[elapsedTimeTimer release];
		elapsedTimeTimer = nil;
		
		[self setElapsedTimeActiveTimeStamp:0];
		[noteTextField setEnabled:NO];
		[[noteTextField cell] setPlaceholderString:NOTE_PLACEHOLDER_STRING];
	}
}


/**
	Start a new TimeStamp as the activeTimeStamp
 */

- (void)startActiveTimeStamp
{
	[self updateWindowTitle];
	
	if (! activeTask) {
		activeTask = [[tasksArrayController content] objectAtIndex:0];
		[activeTask retain];
	}
	
	[self setActiveTimeStamp: [NSEntityDescription insertNewObjectForEntityForName:@"TimeStamp" 
															inManagedObjectContext:[sharedManager managedObjectContext]]];
	
	[activeTimeStamp addObserver:self 
					  forKeyPath:@"startTime" 
						 options:NSKeyValueObservingOptionNew 
						 context:NULL];
	
	[activeTimeStamp setTask:activeTask];
	[noteTextField setEnabled:YES];
	[window makeFirstResponder:noteTextField];
	
	elapsedTimeTimer = [[NSTimer scheduledTimerWithTimeInterval:ONE_MINUTE 
														 target:self 
													   selector:@selector(handleElapsedTimeTimer:) 
													   userInfo:nil 
														repeats:YES] retain];
}


- (void)enableFastTimeStampSwitching:(BOOL)isFast
{
	NSLog(@"enableFastTimeStampSwitching %d", isFast);
	
	if (fastTimeStampSwitchingMode != isFast) {
		fastTimeStampSwitchingMode = isFast;
		
		[self updateModeViews];
	}
}

- (void)enableInsertTimeStamp:(BOOL)isInsert
{
	if (! isInsert) {
		insertTimeStampMode = NO;
	}
	else if (activeTimeStamp && [[activeTimeStamp startTime] timeIntervalSinceNow] < -ONE_MINUTE ) {
		insertTimeStampMode = YES;
	}
	else {
		insertTimeStampMode = NO;
	}

	[self updateModeViews];
}

- (void)updateModeViews
{
	[startStopTrackingButton setHidden:(fastTimeStampSwitchingMode || insertTimeStampMode)];
	[jumpMessageView setHidden:!(fastTimeStampSwitchingMode && !insertTimeStampMode)];
	[insertMessageView setHidden:!insertTimeStampMode];
}

- (void)endInsertTimeStampSheet
{
	[NSApp endSheet:insertTimeStampSheet];
	[insertTimeStampSheet orderOut:self];
}

/**
 Helper method called at the start of an insert time stamp handler. End the
 time stamp sheet, and end the active TimeStamp.
 */
- (void)startInsertTimeStamp
{
	[self endInsertTimeStampSheet];
	[self endActiveTimeStampWithTime:[insertTimePicker dateValue]];
}

/**
 Helper method called at the end of an insert time stamp handler. Reset the
 insert note TextField, and reset the control key flags.
 */
- (void)endInsertTimeStamp
{
	[insertNoteTextField setStringValue:@""];
	[self enableFastTimeStampSwitching:NO];
	[self enableInsertTimeStamp:NO];
}


#pragma mark Delegate methods

/**
	Menu delegate, called just before the menu associated with the tasks
	PopupButton needs to display itself. Populate the menu with the arranged
	contents of the tasksArrayController (so that it emulates the content of
	the PopupButton it is standing in for). The menu needs to be cleared and
	rebuilt each time, since the content of the tasksArrayController may be
	changing.
 */

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	NSLog(@"menuNeedsUpdate, menu = %@", menu);
	int i, len;
	len = [menu numberOfItems];
	
	//	remove any existing menu items if necessary
	if (len > 0) {
		for (i = len - 1; i >= 0; i--) {
			[menu removeItemAtIndex:i];
		}
	}

	NSMenuItem *aMenuItem;
	Task *task;
	NSArray *tasks = [tasksArrayController arrangedObjects];
	
	len = [tasks count];
	for (i = 0; i < len; i++) {
		task = [tasks objectAtIndex:i];
		aMenuItem = [menu addItemWithTitle:[task name] action:@selector(handleTasksMenuItem:) keyEquivalent:@""];
		[aMenuItem setTarget:self];
		[aMenuItem setRepresentedObject:task];
		
		if (i == [tasksArrayController selectionIndex]) {
			[selectedMenuItem release];
			selectedMenuItem = aMenuItem;
			[selectedMenuItem retain];
			[selectedMenuItem setState:NSOnState];
		}
	}
}

/**
	 Returns the NSUndoManager for the application.  In this case, the manager
	 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window 
{
    return [[sharedManager managedObjectContext] undoManager];
}


#pragma mark Actions

- (IBAction)showMainWindow:(id)sender
{
	[window makeKeyAndOrderFront:self];
}

- (IBAction)showTasksWindow:(id)sender
{
	if (!tasksWindowController) {
		tasksWindowController = [[TasksWindowController alloc] init];
	}
	
	[tasksWindowController showWindow:self];
}

- (IBAction)showReportWindow:(id)sender
{
	if (!reportWindowController) {
		reportWindowController = [[ReportWindowController alloc] init];
	}
	
	[reportWindowController showWindow:self];
}

- (IBAction)showDayDetailsWindow:(id)sender
{
	if (!dayDetailsWindowController) {
		dayDetailsWindowController = [[DayDetailsWindowController alloc] init];
	}
	
	[dayDetailsWindowController showWindow:self];
}


- (IBAction)changeTracking:(id)sender
{
	NSLog(@"changeTracking %d, tasksArrayController content count %d", [sender state], [[tasksArrayController content]count]);
	[self changeTrackingWithState:[sender state]];
}

- (void)changeTrackingWithState:(int)state
{
	if (state == STATE_TRACKING && [[tasksArrayController content] count] == 0) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"No Defined Tasks" 
										 defaultButton:@"OK" 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"You must first add a project and tasks before you can begin tracking time. Open the tasks panel to manage projects and tasks."];
		
		[alert beginSheetModalForWindow:window 
						  modalDelegate:self 
						 didEndSelector:@selector(alertEnded:code:context:) 
							contextInfo:NULL];
	}
	else {
		if (state == STATE_NOT_TRACKING) {
			[self endActiveTimeStamp];
		}
		//	STATE_TRACKING
		else {
			[self startActiveTimeStamp];
		}
	}
}


/**
	Action handler for the task Pop Up Button. The activeTask pointer is
	reassigned to the newly selected task. The activeTask is then applied to
	the currently selected TimeStamp, if defined.
 */

- (IBAction)changeActiveTask:(id)sender
{
	if (insertTimeStampMode) {
		[proposedTask release];
		proposedTask = [[tasksArrayController selectedObjects] objectAtIndex:0];
		[proposedTask retain];

		[self setInsertSheetTitle:[[NSString alloc]initWithFormat:/*formatString*/@"Insert Timestamp for %@.", [proposedTask name]]];

		[self setInsertSheetBodyText:[[NSString alloc]initWithFormat:@"Choose a time for the start of the inserted Timestamp after %@.", 
									   [timeFormatter stringFromDate:[activeTimeStamp startTime]]]];
		
		
		[insertTimePicker setMinDate:[[NSDate alloc] initWithTimeInterval:ONE_MINUTE sinceDate:[activeTimeStamp startTime]]];
		[insertTimePicker setMaxDate:[NSDate date]];
		[insertTimePicker setDateValue:[NSDate date]];
		
		[NSApp beginSheet:insertTimeStampSheet modalForWindow:window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	} else {
		
		if (fastTimeStampSwitchingMode) {
			[self endActiveTimeStamp];
		}
		
		[self updateActiveTask:[[tasksArrayController selectedObjects] objectAtIndex:0]];
		
		if (fastTimeStampSwitchingMode) {
			[self startActiveTimeStamp];
			[startStopTrackingButton setState:STATE_TRACKING];
		}
	}

}


/**
	Action handler called when clicking the "Insert And Resume" button in the 
	insertTimeStampSheet. End the sheet, insert a new TimeStamp with the
	designated parameters, and then create and start a new TimeStamp with the
	same properties as the previously active one.
 */

- (IBAction)insertTimeStampAndResumeCurrent:(id)sender
{
	NSString *noteValue = [noteTextField stringValue];
	[self startInsertTimeStamp];
	
	TimeStamp *insertedTimeStamp = [NSEntityDescription insertNewObjectForEntityForName:@"TimeStamp" 
																 inManagedObjectContext:[sharedManager managedObjectContext]];
	[insertedTimeStamp setStartTime:[insertTimePicker dateValue]];
	[insertedTimeStamp setEndTime:[NSDate date]];
	[insertedTimeStamp setTask:proposedTask];
	[insertedTimeStamp setNote:[insertNoteTextField stringValue]];
	
	[tasksArrayController setSelectedObjects:[NSArray arrayWithObject:activeTask]];
	[self startActiveTimeStamp];
	[activeTimeStamp setNote:noteValue];
	
	[self endInsertTimeStamp];
}


/**
	Action handler called when clicking "Insert and Activate" button in the
	insertTimeStampSheet. End the sheet, and insert a new active TimeStamp with
	the designated parameters.
 */

- (IBAction)insertNewActiveTimeStamp:(id)sender
{
	[self startInsertTimeStamp];
	[self updateActiveTask:proposedTask];
	[self startActiveTimeStamp];
	[activeTimeStamp setStartTime:[insertTimePicker dateValue]];
	[activeTimeStamp setNote:[insertNoteTextField stringValue]];	
	[self endInsertTimeStamp];
}


/**
	Action handler called when clicking the Cancel button in the 
	insertTimeStampSheet. End the sheet, and set the tasks popup button back to
	its previous state with the previous activeTask.
 */

- (IBAction)cancelInsertTimeStamp:(id)sender
{
	[self endInsertTimeStampSheet];
	[self enableFastTimeStampSwitching:NO];
	[self enableInsertTimeStamp:NO];
	[tasksArrayController setSelectedObjects:[NSArray arrayWithObject:activeTask]];
}


#pragma mark Handlers

- (void)alertEnded:(NSAlert *)alert code:(int)choice context:(void *)v
{
	NSLog(@"Alert sheet ended");
	[startStopTrackingButton setState:STATE_NOT_TRACKING];
}


- (void)handleElapsedTimeTimer:(NSTimer *)aTimer
{
	if (activeTimeStamp) {
		[self setElapsedTimeActiveTimeStamp: [[NSDate date] timeIntervalSinceDate:[activeTimeStamp startTime]]];
	}
}


/**
	Handles selections in the overflow menu associated with the tasks 
	PopupButton
 */

- (void)handleTasksMenuItem:(NSMenuItem *)menuItem
{
	NSLog(@"handleTasksMenuItem, menuItem = %@", menuItem);
	BOOL success = [tasksArrayController setSelectedObjects:[NSArray arrayWithObject:[menuItem representedObject]]];
	
	if (success) {
		[self updateActiveTask:[menuItem representedObject]];
		[selectedMenuItem setState:NSOffState];
		[menuItem retain];
		[selectedMenuItem release];
		selectedMenuItem = menuItem;
		[selectedMenuItem setState:NSOnState];
	}
}


/**
	Handles selecting the startTrackingMenuItem. This menu item is dispalyed in
	overflow mode when the start/stop stracking toggle button is not visible.
 */

- (void)handleStartTracking:(NSMenuItem *)menuItem
{
	NSLog(@"handleStartTracking");
	[self changeTrackingWithState:STATE_TRACKING];
}


/**
	Handles selecting the stopTrackingMenuItem. This menu item is dispalyed in
	overflow mode when the start/stop stracking toggle button is not visible.
 */

- (void)handleStopTracking:(NSMenuItem *)menuItem
{
	NSLog(@"handleStopTracking");
	[self changeTrackingWithState:STATE_NOT_TRACKING];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	NSLog(@"AppController flagsChanged");
	
	if ([theEvent modifierFlags] & NSControlKeyMask) {
		NSLog(@"control  key mask match");
		[self enableFastTimeStampSwitching:YES];
	} else {
		[self enableFastTimeStampSwitching:NO];
	}
	
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		[self enableInsertTimeStamp:YES];
	} else {
		[self enableInsertTimeStamp:NO];
	}

}

- (void)windowDidResignMain:(NSNotification *)notification
{
	[self enableFastTimeStampSwitching:NO];
	[self enableInsertTimeStamp:NO];
}



/**
	Handle changes in the startTime for the activeTimeStamp
 */

- (void) observeValueForKeyPath:(NSString *)keyPath 
					   ofObject:(id)object 
						 change:(NSDictionary *)change 
						context:(void *)context
{
	[self setElapsedTimeActiveTimeStamp: [activeTimeStamp duration]];
}

@end
