/*
 Zuznow MainViewController
 */

//
//  MainViewController.h
//  HybridApp
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>
#import "ZuzProcessIndicator.h"

@interface MainViewController : CDVViewController <UIWebViewDelegate>

- (void)setNotificationMessage:(NSString *) urlString message: (NSString *) messageString;
@end

@interface MainCommandDelegate : CDVCommandDelegateImpl
@end

@interface MainCommandQueue : CDVCommandQueue
@end
