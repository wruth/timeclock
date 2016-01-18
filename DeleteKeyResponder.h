//
//  DeleteManagedObjectKeyResponder.h
//  TimeClock
//
//  Created by Ward Ruth on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DeleteKeyResponder : NSResponder 
{
	id deleteTarget;
	SEL deleteSelector;
}

- (id)initWithDeleteTarget:(id)target andSelector:(SEL) selector;

@end
