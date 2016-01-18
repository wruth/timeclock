//
//  AdjustTimeStampController.h
//  TimeClock
//
//  Created by Ward Ruth on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TimeStamp;
@class ManagedObjectContextManager;

extern NSString * const WMRKeyMessageText;
extern NSString * const WMRKeyInformativeText;

@interface AdjustTimeStampController : NSObject 
{
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *adjustTimeSheet;
	IBOutlet NSArrayController *timeStampsArrayController;
	IBOutlet NSArrayController *tasksArrayController;
	IBOutlet NSTableView *timeStampsTableView;
	IBOutlet NSDatePicker *startTimeDatePicker;
	IBOutlet NSDatePicker *endTimeDatePicker;
	ManagedObjectContextManager *sharedManager;
	TimeStamp *selectedTimeStamp;
	
	NSDate *startTime;
	NSDate *endTime;
}

- (IBAction)editSelectedTimeStamp:(id)sender;
- (IBAction)changeCurrentTask:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;

@property (retain) NSDate * startTime;
@property (retain) NSDate * endTime;

@end
