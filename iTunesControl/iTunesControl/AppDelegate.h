//
//  AppDelegate.h
//  iTunesControl
//
//  Created by Jad Kawwa on 2013-09-13.
//  Copyright (c) 2013 Jad Kawwa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end

@interface StreamDelegate: NSViewController <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}
@end