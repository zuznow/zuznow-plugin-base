/*
 Zuznow MainViewController
 */

//
//  AppDelegate.m
//  HybridApp
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    
    //check if notification activate the applicaion
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            //now we need to load the message and url
            NSString *message = [[dictionary valueForKey:@"aps"] valueForKey:@"alert"];
            NSString *url = [[dictionary valueForKey:@"aps"] valueForKey:@"url"];
            
            if(self.viewController != nil)
            {
                if([self.viewController isKindOfClass:[MainViewController class]])
                {
                    [(MainViewController*)self.viewController setNotificationMessage:url message:message];
                } 
                
            }
            
        }
    }
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
