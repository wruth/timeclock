//
//  ManagedObjectContextManager.m
//  TimeClock
//
//  Created by Ward Ruth on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ManagedObjectContextManager.h"
#import "TimeClock_AppDelegate.h"


@implementation ManagedObjectContextManager

@synthesize managedObjectContext;

static ManagedObjectContextManager *sharedMOCManager = nil;

+ (ManagedObjectContextManager *)sharedManager
{
	@synchronized(self) {
		if (sharedMOCManager == nil) {
			[[self alloc] init];	// assignment not done here
		}
	}
	
	return sharedMOCManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedMOCManager == nil) {
			sharedMOCManager = [super allocWithZone:zone];
			return sharedMOCManager;	// assignment and return on first allocation
		}
	}
	return nil;	// on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;	// denotes an object that cannot be released
}

- (void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (id)init
{
	if (![super init])
	{
		return nil;
	}
	NSLog(@"ManagedObjectContextManager init, app delegate = %@", [NSApp delegate]);
	managedObjectContext = [(TimeClock_AppDelegate *)[NSApp delegate] managedObjectContext ];
	NSLog(@"ManagedObjectContextManager managedObjectContext = %@", managedObjectContext);
	return self;
}

- (void)dealloc
{
	//[managedObjectContext release];
	[super dealloc];
}

#pragma mark utility methods

/**
	 Save the current state of the scratchpad, which is to send the save:
	 message to the application's managed object context.  Any encountered errors
	 are presented to the user.
 */

- (void)saveState
{
    NSError *error = nil;
    if (![[[ManagedObjectContextManager sharedManager] managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


#pragma mark fetch methods

- (NSFetchRequest *)fetchRequestForTimeStampsForDay:(NSDate *)day
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:day];
	NSDate *dayStart = [calendar dateFromComponents:comps];
	NSDate *nextDay = [[[NSDate alloc] initWithTimeInterval:ONE_DAY sinceDate:dayStart] autorelease];
	
	NSLog(@"dayStart = %@, nextDay = %@",dayStart, nextDay);
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TimeStamp" inManagedObjectContext:managedObjectContext];
	NSPredicate *betweenPredicate = [NSPredicate predicateWithFormat:@"startTime BETWEEN %@", [NSArray arrayWithObjects:dayStart, nextDay, nil]];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	[request setPredicate:betweenPredicate];

	return request;
}

- (NSArray *)fetchResultForTimeStampsForDay:(NSDate *)day error:(NSError **)error
{
	NSFetchRequest *request = [self fetchRequestForTimeStampsForDay:day];
	return [managedObjectContext executeFetchRequest:request error:error];
}

#pragma mark ArrayController helpers

- (NSPredicate *)tasksFilterPredicate
{
	if (tasksFilterPredicate != nil) {
		return tasksFilterPredicate;
	}
	
	tasksFilterPredicate = [[NSPredicate predicateWithFormat:@"active == 1 AND project.active == 1"] retain];
	
	return tasksFilterPredicate;
}

- (NSArray *)tasksSortDescriptors
{
	if (tasksSortDescriptors != nil) {
		return tasksSortDescriptors;
	}
	
	NSSortDescriptor *tasksSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease];
	tasksSortDescriptors = [[NSArray arrayWithObject:tasksSortDescriptor] retain];
	return tasksSortDescriptors;
}

- (NSArray *)timestampsSortDescriptors
{
	if (timestampsSortDescriptors != nil) {
		return timestampsSortDescriptors;
	}
	
	NSSortDescriptor *timestampsSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES] autorelease];
	timestampsSortDescriptors = [[NSArray arrayWithObject:timestampsSortDescriptor] retain];
	return timestampsSortDescriptors;
}



@end
