//
//  TasksController.h
//  TimeClock
//
//  Created by Ward Ruth on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ManagedObjectContextManager;
@class DeleteKeyResponder;

@interface TasksWindowController : NSWindowController 
{
	ManagedObjectContextManager *sharedManager;
	
	IBOutlet NSArrayController *projectsArrayController;
	IBOutlet NSArrayController *tasksArrayController;
	IBOutlet NSWindow *window;
	IBOutlet NSTableView *projectsTableView;
	IBOutlet NSTableView *tasksTableView;
	
	DeleteKeyResponder *deleteProjectResponder;
	DeleteKeyResponder *deleteTaskResponder;
}

- (IBAction)deleteSelectedProjectAction:(id)sender;
- (IBAction)deleteSelectedTaskAction:(id)sender;

@end
