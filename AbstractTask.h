//
//  AbstractTask.h
//  TimeClock
//
//  Created by Ward Ruth on 3/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#define TASK_ERROR_DOMAIN @"WRTaskErrorDomain"
#define TASK_ASSIGNED_ERROR_CODE 0

@interface AbstractTask :  NSManagedObject
{
}

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * id;

@end


