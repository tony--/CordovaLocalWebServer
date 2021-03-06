
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "SACordovaLocalWebServer.h"
#import "GCDWebServerPrivate.h"
#import <Cordova/CDVViewController.h>

@implementation SACordovaLocalWebServer

- (void) pluginInitialize {
    
    BOOL useLocalWebServer = NO;
    NSString* indexPage = @"index.html";
    NSUInteger port = 80;
    
    // check the content tag src
    CDVViewController* vc = (CDVViewController*)self.viewController;
    NSURL* startPageUrl = [NSURL URLWithString:vc.startPage];
    if (startPageUrl != nil) {
        if ([[startPageUrl scheme] isEqualToString:@"http"] && [[startPageUrl host] isEqualToString:@"localhost"]) {
            port = [[startPageUrl port] unsignedIntegerValue];
            useLocalWebServer = YES;
        }
    }
    
    if (useLocalWebServer) {
        // Create server
        self.server = [[GCDWebServer alloc] init];
        NSString* path = [self.commandDelegate pathForResource:indexPage];
        
        [self.server addGETHandlerForBasePath:@"/" directoryPath:[path stringByDeletingLastPathComponent] indexFilename:@"index.html" cacheAge:0 allowRangeRequests:YES];
        [self.server startWithPort:port bonjourName:nil];
        [GCDWebServer setLogLevel:kGCDWebServerLoggingLevel_Error];
        
        // Update the startPage (supported in cordova-ios 3.7.0, see https://issues.apache.org/jira/browse/CB-7857)
        vc.startPage = self.server.serverURL.description;
        
    } else {
        NSLog(@"WARNING: CordovaLocalWebServer: <content> tag src is not http://localhost[:port] (is %@), local web server not started.", vc.startPage);
    }
}

@end