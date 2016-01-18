// 
//  Task.m
//  TimeClock
//
//  Created by Ward Ruth on 3/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "AbstractTask.h"

@implementation Task 

@dynamic billable;
@dynamic timeStamps;
@dynamic project;

/**
	Checks for whether it is allowable to be able to delete the Task. If the
	Task is assigned to any TimeStamps, it is not deletable. 
 */
- (BOOL)canDelete:(NSError **)outError
{
	//NSLog(@"Task canDelete, timeStamps count = %@", [[self timeStamps] count]);
	if ([[self timeStamps] count] && [[self timeStamps] count] > 0)
	{
		if (outError != NULL) {
			NSString *errorStr = @"Cannot delete a Task that is assigned to a Timestamp.";
			NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr 
																	 forKey:NSLocalizedDescriptionKey];
			NSError *error = [[[NSError alloc] initWithDomain:TASK_ERROR_DOMAIN 
														 code:TASK_ASSIGNED_ERROR_CODE 
													 userInfo:userInfoDict] autorelease];
			*outError = error;
		}
		return NO;
	}
	else {
		return YES;
	}
}


@end
