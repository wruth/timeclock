//
//  ManagedObjectContextManager.h
//  TimeClock
//
//  Created by Ward Ruth on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define ONE_DAY 60 * 60 * 24

@interface ManagedObjectContextManager : NSObject 
{
	NSManagedObjectContext *managedObjectContext;
	
	NSPredicate *tasksFilterPredicate;
	NSArray *tasksSortDescriptors;
	NSArray *timestampsSortDescriptors;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (ManagedObjectContextManager *)sharedManager;

- (void)saveState;

- (NSFetchRequest *)fetchRequestForTimeStampsForDay:(NSDate *)day;
- (NSArray *)fetchResultForTimeStampsForDay:(NSDate *)day error:(NSError **)error;

- (NSPredicate *)tasksFilterPredicate;
- (NSArray *)tasksSortDescriptors;
- (NSArray *)timestampsSortDescriptors;


@end
