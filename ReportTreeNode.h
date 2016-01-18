//
//  ReportNode.h
//  TimeClock
//
//  Created by Ward Ruth on 3/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MONDAY		@"monday"
#define TUESDAY		@"tuesday"
#define WEDNESDAY	@"wednesday"
#define THURSDAY	@"thursday"
#define FRIDAY		@"friday"
#define SATURDAY	@"saturday"
#define SUNDAY		@"sunday"


@interface ReportTreeNode : NSTreeNode 
{
	NSString *name;
	NSMutableDictionary *workDays;
}

@property(readwrite, retain) NSString *name;
@property(readonly) float total;

- (void)addValue:(float)value forKey:(NSString *)key;

@end
