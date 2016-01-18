//
//  TimeClock_AppDelegate.h
//  TimeClock
//
//  Created by Ward Ruth on 1/25/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface TimeClock_AppDelegate : NSObject 
{
    //IBOutlet NSWindow *window;
	IBOutlet AppController *appController;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
