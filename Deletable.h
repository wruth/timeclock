//
//  Deletable.h
//  TimeClock
//
//  Created by Ward Ruth on 3/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



@protocol Deletable

- (BOOL)canDelete:(NSError **)error;

@end
