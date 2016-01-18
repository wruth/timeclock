//
//  TasksWindowController.m
//  TimeClock
//
//  Created by Ward Ruth on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TasksWindowController.h"
#import "Deletable.h"
#import "ManagedObjectContextManager.h"
#import "DeleteKeyResponder.h"

@interface TasksWindowController (PrivateAPI)

- (void)alertWithMessageText:(NSString *)messageText withInformativeText:(NSString *)informativeText;

@end


@implementation TasksWindowController

- (id)init
{
	NSLog(@"TasksWindowController init");
	if (![super initWithWindowNibName:@"Tasks"])
		return nil;
	
	sharedManager = [[ManagedObjectContextManager sharedManager] retain];
	
	return self;
}

- (void)awakeFromNib
{
	deleteProjectResponder = [[[DeleteKeyResponder alloc] initWithDeleteTarget:self andSelector:@selector(deleteSelectedProjectAction:)] retain];
	[projectsTableView setNextResponder:deleteProjectResponder];
	[deleteProjectResponder setNextResponder:window];
	
	deleteTaskResponder = [[[DeleteKeyResponder alloc] initWithDeleteTarget:self andSelector:@selector(deleteSelectedTaskAction:)] retain];
	[tasksTableView setNextResponder:deleteTaskResponder];
	[deleteTaskResponder setNextResponder:window];
}

- (void)windowDidLoad
{
	NSLog(@"TasksWindowController windowDidLoad");
	NSLog(@"\tsharedManager = %@, managedObjectContext = %@", sharedManager, sharedManager.managedObjectContext);
}

- (void)dealloc
{
	[sharedManager release];
	[deleteProjectResponder release];
	[deleteTaskResponder release];
	[super dealloc];
}

#pragma mark Actions

/**
	Selector to delete the selected Project. A Project can only be removed if
	any of its contained Tasks are not attached to a TimeStamp.
 */
- (IBAction)deleteSelectedProjectAction:(id)sender
{
	NSLog(@"deleteSelectedProjectAction");
	NSError *error;
	id <Deletable> project = [[projectsArrayController selectedObjects] lastObject];
	BOOL canDelete = [project canDelete:&error];
	NSLog(@"canDelete = %d, error = %@", canDelete, error);
	
	if (canDelete) {
		[projectsArrayController removeObject:project];
	}
	else {
		[self alertWithMessageText:@"Cannot Delete Selected Project" withInformativeText:[error localizedDescription]];
	}
}

/**
	Selector to delete the selected Task. A Task can only be removed if it is
	not attached to a TimeStamp
 */
- (IBAction)deleteSelectedTaskAction:(id)sender
{
	NSLog(@"deleteSelectedTaskAction");
	NSError *error;
	id <Deletable> task = [[tasksArrayController selectedObjects] lastObject];
	BOOL canDelete = [task canDelete:&error];
	NSLog(@"canDelete = %d", canDelete);
	
	if (canDelete) {
		[tasksArrayController removeObject:task];
	}
	else {
		[self alertWithMessageText:@"Cannot Delete Selected Task" withInformativeText:[error localizedDescription]];
	}
}

- (void)alertWithMessageText:(NSString *)messageText withInformativeText:(NSString *)informativeText
{
	NSAlert *alert = [NSAlert alertWithMessageText:messageText 
									 defaultButton:@"OK" 
								   alternateButton:nil 
									   otherButton:nil 
						 informativeTextWithFormat:informativeText];
	
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:nil
					 didEndSelector:nil
						contextInfo:NULL];
}


@end
