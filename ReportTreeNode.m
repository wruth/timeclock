//
//  ReportNode.m
//  TimeClock
//
//  Created by Ward Ruth on 3/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReportTreeNode.h"
#import "AbstractTask.h"

@implementation ReportTreeNode

//@synthesize name;

- (id)initWithRepresentedObject:(id)representedObject
{
	if (![super initWithRepresentedObject:representedObject])
	{
		return nil;
	}
	
	if (representedObject) {
		[self setName:[(AbstractTask *)representedObject name]];
	}
	
	NSNumber *zero = [NSNumber numberWithFloat:0.0];
	workDays = [NSMutableDictionary dictionaryWithObjectsAndKeys:zero, MONDAY, zero, TUESDAY, zero, WEDNESDAY, zero, THURSDAY, zero, FRIDAY, zero, SATURDAY, zero, SUNDAY, nil];
	[workDays retain];
	
	return self;
}

- (void)dealloc
{
	[workDays release];
	[name release];
	[super dealloc];
}

- (NSString *)name
{
	//return [(AbstractTask *)[self representedObject] name];
	return name;
}

- (void)setName:(NSString *)aName
{
	[aName retain];
	[name release];
	name = aName;
}

/**
	Adds float value to the value already defined in the specified workday
 */
- (void)addValue:(float)value forKey:(NSString *)key
{
	float currentValue = [(NSNumber *)[workDays valueForKey:key] floatValue];
	NSNumber *newValue = [NSNumber numberWithFloat:(value + currentValue)];
	[workDays setObject:newValue forKey:key];
}

- (float)total
{
	if (![self isLeaf]) {
		return [(NSNumber *)[self valueForKeyPath:@"childNodes.@sum.total"] floatValue];
	}
	else {
		float sum = 0.0;
		NSEnumerator *enumerator = [workDays objectEnumerator];
		id value;
		
		while ((value = [enumerator nextObject])) {
			sum += [((NSNumber *)value) floatValue];
		}
		
		return sum;
	}
}

- (id)valueForUndefinedKey:(NSString *)key
{
	if (![self isLeaf]) {
		NSString *keyPath = [NSString stringWithFormat:@"childNodes.@sum.%@", key];
		return [self valueForKeyPath:keyPath];
	}
	else {
		id value;
		value = [workDays valueForKey:key];
		
		if (value) {
			return value;
		}
		else {
			NSLog(@"value for key %@ is undefined!", key);
			return nil;
		}
	}
}

@end
