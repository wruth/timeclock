//
//  Project.h
//  TimeClock
//
//  Created by Ward Ruth on 3/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AbstractTask.h"
#import "Deletable.h"
@class Task;

@interface Project :  AbstractTask <Deletable>  
{
}

@property (retain) NSSet* tasks;

@end

@interface Project (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end

