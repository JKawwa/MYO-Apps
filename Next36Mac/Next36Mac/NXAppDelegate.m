//
//  NXAppDelegate.m
//  Next36Mac
//
//  Created by Nathan Chau on 2013-09-14.
//  Copyright (c) 2013 Nathan Chau. All rights reserved.
//

#import "NXAppDelegate.h"
#import "GCDAsyncSocket.h"

@implementation NXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![socket connectToHost:@"google.com" onPort:80 error:&error]) {
        NSLog(@"Failed");
    }
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"SUCCESS");
}

@end
