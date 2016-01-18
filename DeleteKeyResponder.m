//
//  DeleteManagedObjectKeyResponder.m
//  TimeClock
//
//  Created by Ward Ruth on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeleteKeyResponder.h"


@implementation DeleteKeyResponder

- (id)initWithDeleteTarget:(id)target andSelector:(SEL) selector
{
	if (![super init])
		return nil;
	
	deleteTarget = target;
	deleteSelector = selector;
	
	return self;
}



#pragma mark NSResponder methods

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

/**
	Delete key press deletes selected TimeStamp
 */
- (void)keyDown:(NSEvent *)e
{
	NSLog(@"DeleteKeyResponder keyDown");
	 if (([e keyCode] == 51) || ([e keyCode] == 117)) {
		 [deleteTarget performSelector:deleteSelector];
	 }

}

@end
