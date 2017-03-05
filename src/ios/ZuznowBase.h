//
//  ZuznowBase.h
//

#import <Cordova/CDVPlugin.h>
#import "ZuzProcessIndicator.h"
#import "MainViewController.h"

@interface ZuznowBase : CDVPlugin
{
    ZuzProcessIndicator* processIndicator;
    NSTimer *showTimer;
    
    bool initialized;
    bool automaticSpinner;
    
    NSString* currentUrl;
}

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)showWithTimeout:(CDVInvokedUrlCommand*)command;
- (void)hideAfterTimeout:(NSTimer*)timer;
- (void)hide:(CDVInvokedUrlCommand*)command;
- (void)setAutomaticSpinner:(CDVInvokedUrlCommand*)command;
    

- (BOOL)shouldStartLoadWithRequest:(UIWebView *) theWebView request:(NSURLRequest *) request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)theWebView;
- (void)webViewDidFinishLoad:(UIWebView *)theWebView;
- (void)didFailLoadWithError:(UIWebView *) theWebView error:(NSError *)error;

@end
