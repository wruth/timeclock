//
//  AppController.h
//  TimeClock
//
//  Created by Ward Ruth on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TimeClock_AppDelegate;
@class TasksWindowController;
@class ReportWindowController;
@class DayDetailsWindowController;
@class TimeStamp;
@class Task;
@class ManagedObjectContextManager;

#define ONE_MINUTE 60
#define FIVE_MINUTES 60 * 5
#define ONE_DAY 60 * 60 * 24
#define STATE_NOT_TRACKING 0
#define STATE_TRACKING 1
#define NOTE_PLACEHOLDER_STRING @"Task note"

@interface AppController : NSResponder 
{
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *insertTimeStampSheet;
	IBOutlet NSDatePicker *insertTimePicker;
	IBOutlet NSArrayController *tasksArrayController;
	IBOutlet NSButton *startStopTrackingButton;
	IBOutlet NSPopUpButton *tasksPopUpButton;
	IBOutlet NSMenuItem *tasksMainMenuItem;
	IBOutlet NSView *jumpMessageView;
	IBOutlet NSView *insertMessageView;
	IBOutlet NSTextField *noteTextField;
	IBOutlet NSTextField *insertNoteTextField;
	ManagedObjectContextManager *sharedManager;
	TasksWindowController *tasksWindowController;
	ReportWindowController *reportWindowController;
	DayDetailsWindowController *dayDetailsWindowController;
	NSDateFormatter *windowTitleFormatter;
	NSDateFormatter *timeFormatter;
	NSTimer *elapsedTimeTimer;
	NSMenuItem *selectedMenuItem;
	TimeStamp *activeTimeStamp;
	Task *activeTask;
	Task *proposedTask;
	NSInteger elapsedTimeActiveTimeStamp;
	BOOL fastTimeStampSwitchingMode;
	BOOL insertTimeStampMode;
	NSString *insertSheetTitle;
	NSString *insertSheetBodyText;
}

@property (nonatomic, retain) TimeStamp *activeTimeStamp;
@property (nonatomic, assign) NSInteger elapsedTimeActiveTimeStamp;
@property (nonatomic, copy) NSString *insertSheetTitle;
@property (nonatomic, copy) NSString *insertSheetBodyText;

- (IBAction)showMainWindow:(id)sender;
- (IBAction)showTasksWindow:(id)sender;
- (IBAction)showReportWindow:(id)sender;
- (IBAction)showDayDetailsWindow:(id)sender;
- (IBAction)changeTracking:(id)sender;
- (IBAction)changeActiveTask:(id)sender;
- (IBAction)insertTimeStampAndResumeCurrent:(id)sender;
- (IBAction)insertNewActiveTimeStamp:(id)sender;
- (IBAction)cancelInsertTimeStamp:(id)sender;
- (void)endActiveTimeStamp;

@end
