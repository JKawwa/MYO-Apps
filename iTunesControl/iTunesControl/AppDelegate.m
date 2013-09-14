//
//  AppDelegate.m
//  iTunesControl
//
//  Created by Jad Kawwa on 2013-09-13.
//  Copyright (c) 2013 Jad Kawwa. All rights reserved.
//

#import "AppDelegate.h"
#import "iTunes.h"
#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "GCDAsyncSocket.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
void error(const char *msg);

iTunesApplication * iTunes;
//GCDAsyncSocket *socket;

- (void)sendcmd:(NSString*)cmd {
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    uint16_t port = 27015;//[[[self serverPort] text] intValue];
    
    if (![socket connectToHost:@"169.254.107.125" onPort:port error:&error])
    {
        printf("Unable to connect to due to invalid configuration: %s", error);
        //  [self debugPrint:[NSString stringWithFormat:@"Unable to connect to due to invalid configuration: %@", error]];
    }
    else
    {
        printf("Connecting...");
    }
    NSString *requestStr = @"JKJKJKJKJKJK";
    NSData *requestData = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    while (1)
//    {
    [socket writeData:requestData withTimeout:1.0 tag:0];
//=    }
    NSData *received = [[NSData alloc] init];
    while (1)
    {
        if (socket != nil)
        {
            [socket readDataToData:received withTimeout:10.0 tag:0];
            if((int)[received length] > 0)
                [self execute:socket receivedData:received socket:socket];
        }
    }
}
           
- (void)execute:(GCDAsyncSocket *)sock receivedData:(NSData *)data socket:(GCDAsyncSocket*)socket
{
    printf("%s\n",[(NSString *)data UTF8String]);
    NSString *cmd = (NSString *)data;
    if ([cmd rangeOfString:@"info"].location != NSNotFound)
    {
        iTunesTrack *current = iTunes.currentTrack;
        NSString *name = current.name;
        NSInteger position = iTunes.playerPosition;
        NSString *posS = [NSString stringWithFormat:@"%d", (int)position];
        NSMutableString *finalsend;
        finalsend = [NSString stringWithFormat:@"play:%@:%@", name, posS];
        NSData *sendData = [finalsend dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:sendData withTimeout:-1.0 tag:0];
    }
    else if([cmd rangeOfString:@"play"].location != NSNotFound)
    {
        NSString *inputName = [cmd componentsSeparatedByString:@":"][1];
        NSString *inputTime = [cmd componentsSeparatedByString:@":"][2];
        SBElementArray *allSources = iTunes.sources;
        iTunesSource *iTunesSource = allSources[0];
        iTunesLibraryPlaylist *iTunesLibrary = iTunesSource.libraryPlaylists[0];
        SBElementArray *allSongs = iTunesLibrary.fileTracks;
        for (iTunesTrack *song in allSongs)
        {
            if([song.name isEqualToString:inputName])
            {
                [song playOnce:true];
                iTunes.playerPosition = [inputTime integerValue];
                break;
            }
//          printf("%s\n",[song.name UTF8String]);
        }
    }
    else if([cmd isEqualToString:@"pause"])
    {
        [iTunes pause];
    }
    else if([cmd isEqualToString:@"next"])
    {
        [iTunes nextTrack];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack *current = iTunes.currentTrack;
    NSString *name = current.name;
    NSInteger position = iTunes.playerPosition;
    printf("%s %d\n",[name UTF8String],(int)position);
    iTunes.playerPosition=85;


  
    [self sendcmd:@"JK3"];
    
    
    
   // [self sendcmd:@"active"];
    
  //  GCDAsyncSocket *test = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [test connectToHost:@"169.254.107.125" onPort:27015 withTimeout:0.5 error:NULL];
    //    NSString *myStr = @"testing...123...\r\n";
//    NSData *myData = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    
//    [test writeData:myData withTimeout:0.5 tag:0];


}


//int tryrun

//void searchForSite(void)
//{
//    NSString *urlStr = @"169.254.107.125";
//    if (![urlStr isEqualToString:@""]) {
//        NSURL *website = [NSURL URLWithString:urlStr];
//        if (!website) {
//            NSLog(@"%@ is not a valid URL");
//            return;
//        }
//        
//        CFReadStreamRef readStream;
//        CFWriteStreamRef writeStream;
//        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[website host], 27015, &readStream, &writeStream);
//        
//        CFWriteStreamOpen(writeStream);
//        CFWriteStreamWrite(writeStream, "Hello\n", 6);
//        
//        NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
//        NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *) writeStream;
//                                        
////        [inputStream setDelegate:self];
////        [outputStream setDelegate:self];
//        
//        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [inputStream open];
//        [outputStream open];
//        
//        uint8 *inputS;
//        NSString *outputS = @"ACTIVATED!";
//        int i;
//        for(int i=0; i<100; i++)
//        {
//            [outputStream write: (uint8 *)[outputS UTF8String] maxLength:11];
//            printf("sent!\n");
//        }
//        while(1)
//        {
//            printf("attempting to read...");
//            while (![inputStream hasBytesAvailable])
//            {}
//            [inputStream read:inputS maxLength:20];
//            printf("%s",(char *)inputS);
//        }
////        [outputStream write:outputS maxLength:20];
//        /* Store a reference to the input and output streams so that
//         they don't go away.... */
//    }
//}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.JK3.iTunesControl" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.JK3.iTunesControl"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iTunesControl" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"iTunesControl.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end

void error(const char *msg)
{
    perror(msg);
    exit(0);
}

