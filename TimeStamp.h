//
//  TimeStamp.h
//  TimeClock
//
//  Created by Ward Ruth on 2/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
@class Task;

@interface TimeStamp :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) Task *task;
@property (readonly) NSTimeInterval duration;
@end


