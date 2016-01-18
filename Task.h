//
//  Task.h
//  TimeClock
//
//  Created by Ward Ruth on 3/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AbstractTask.h"
#import "Deletable.h"

@class TimeStamp;
@class Project;

@interface Task :  AbstractTask <Deletable>
{
}

@property (nonatomic, retain) NSNumber *billable;
@property (nonatomic, retain) NSSet *timeStamps;
@property (nonatomic, retain) Project *project;

@end

@interface Task (CoreDataGeneratedAccessors)
- (void)addTimeStampsObject:(TimeStamp *)value;
- (void)removeTimeStampsObject:(TimeStamp *)value;
- (void)addTimeStamps:(NSSet *)value;
- (void)removeTimeStamps:(NSSet *)value;

@end

