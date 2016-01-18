//
//  DayDetailsWindowController.h
//  TimeClock
//
//  Created by Ward Ruth on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TimeStamp;
@class ManagedObjectContextManager;

#define PREVIOUS_DAY 0
#define NEXT_DAY 1

@interface DayDetailsWindowController : NSWindowController 
{
	IBOutlet NSWindow *window;
	IBOutlet NSButton *todayButton;
	IBOutlet NSSegmentedControl *previousNextDayControl;
	IBOutlet NSDatePicker *datePicker;
	//IBOutlet DurationFormatter *durationFormatter;
	IBOutlet NSPanel *datePanel;
	IBOutlet NSArrayController *timeStampsController;
	IBOutlet NSTableView *timeStampsTableView;
	
	NSDate *selectedDay;
	NSDate *today;
	NSDateFormatter *windowTitleFormatter;
	
	ManagedObjectContextManager *sharedManager;
	
}

- (IBAction)todayAction:(id)sender;
- (IBAction)previousNextDayAction:(id)sender;
- (IBAction)chooseDayAction:(id)sender;
- (IBAction)showDatePicker:(id)sender;

@end
