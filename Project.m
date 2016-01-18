// 
//  Project.m
//  TimeClock
//
//  Created by Ward Ruth on 3/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AbstractTask.h"
#import "Project.h"
#import "Task.h"

@implementation Project 

@dynamic tasks;

/**
	Checks for whether it is allowable to be able to delete the Project. If the
	Project contains any Tasks which are not deletable, then the Project is not
	deletable. A Task would not be deletable if it was assigned to a TimeStamp.
*/
- (BOOL)canDelete:(NSError **)outError
{
	Task *task;
	
	for (task in [self tasks]) {
		if (! [task canDelete:outError]) {
			NSString *errorStr;
			NSDictionary *userInfoDict;
			NSError *error;
			
			if ([*outError code] == TASK_ASSIGNED_ERROR_CODE) {
				errorStr = @"Cannot delete a Project that contains Tasks that are assigned to a Timestamp.";
				userInfoDict = [NSDictionary dictionaryWithObject:errorStr 
														   forKey:NSLocalizedDescriptionKey];
				error = [[[NSError alloc] initWithDomain:TASK_ERROR_DOMAIN 
													code:TASK_ASSIGNED_ERROR_CODE 
												userInfo:userInfoDict] autorelease];
				*outError = error;
			}
						
			return NO;
		}
	}
	
	return YES;
}

@end
