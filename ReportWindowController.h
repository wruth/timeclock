//
//  ReportWindowController.h
//  TimeClock
//
//  Created by Ward Ruth on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DurationFormatter;

#define PREVIOUS_WEEK 0
#define NEXT_WEEK 1
#define ONE_DAY 60 * 60 * 24

@interface ReportWindowController : NSWindowController 
{
	IBOutlet NSButton *thisWeekButton;
	IBOutlet NSSegmentedControl *previousNextWeekControl;
	IBOutlet NSDatePicker *datePicker;
	IBOutlet NSButton *refreshButton;
	IBOutlet DurationFormatter *durationFormatter;
	IBOutlet NSPanel *datePanel;
	
	NSDate *selectedWeek;
	NSDate *thisWeek;
	NSMutableArray *content;
	NSDateFormatter *windowTitleFormatter;
}

- (IBAction)thisWeekAction:(id)sender;
- (IBAction)previousNextWeekAction:(id)sender;
- (IBAction)chooseWeekAction:(id)sender;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)refreshAction:(id)sender;

@property(retain) NSMutableArray *content;

@end
