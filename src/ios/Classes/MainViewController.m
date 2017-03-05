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

#import <Cordova/CDVUserAgentUtil.h>
#import "MainViewController.h"
#import "ZuznowBase.h"
#import <objc/message.h>

ZuznowBase* zuznowBase = Nil;
NSString* start_url_message = Nil;

@implementation MainViewController


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
       
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
	
    //set start page with notification url
    if(start_url_message != Nil)
    {
        self.startPage = start_url_message;
    }
    
    //cordova load
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/




#pragma mark UIWebViewDelegate implementation
//Add CDVUIWebViewNavigationDelegate implementation & Zuznow logic

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    /* from CDVUIWebViewNavigationDelegate */
    NSURL* url = [request URL];
    
    /*
     * Execute any commands queued with cordova.exec() on the JS side.
     * The part of the URL after gap:// is irrelevant.
     */
    if ([[url scheme] isEqualToString:@"gap"]) {
        [self.commandQueue fetchCommandsFromJs];
        // The delegate is called asynchronously in this case, so we don't have to use
        // flushCommandQueueWithDelayedJs (setTimeout(0)) as we do with hash changes.
        [self.commandQueue executePending];
        return NO;
    }
    
    /* from CDVUIWebViewNavigationDelegate end */
    
    BOOL shouldLoad = YES;
    if(shouldLoad)
    {
        /* from CDVUIWebViewNavigationDelegate */
    
    
        /*
         * Give plugins the chance to handle the url
         */
    
    
        BOOL anyPluginsResponded = NO;
        BOOL shouldAllowRequest = NO;
     
        for (NSString* pluginName in self.pluginObjects) {
            CDVPlugin* plugin = [self.pluginObjects objectForKey:pluginName];
            SEL selector = NSSelectorFromString(@"shouldOverrideLoadWithRequest:navigationType:");
            if ([plugin respondsToSelector:selector]) {
                anyPluginsResponded = YES;
                shouldAllowRequest = (((BOOL (*)(id, SEL, id, int))objc_msgSend)(plugin, selector, request, navigationType));
                if (!shouldAllowRequest) {
                    break;
                }
            }
        }
     
        if (anyPluginsResponded) {
            shouldLoad = shouldAllowRequest;
        }
        

        if(shouldLoad)
        {
            if(!zuznowBase)
            {
                zuznowBase = [self getCommandInstance:@"ZuznowBase"];
            }
            shouldLoad =  [zuznowBase shouldStartLoadWithRequest: theWebView request:request navigationType:navigationType];
        }
        
        /*
         * Handle all other types of urls (tel:, sms:), and requests to load a url in the main webview.
         */
        if(!anyPluginsResponded && shouldLoad)
        {
            /*
             * If a URL is being loaded that's a file url, just load it internally
             */
            if ( [url isFileURL]) {
                shouldLoad = YES;
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
                shouldLoad = NO;
            }
        }
        
        return shouldLoad;
     /* from CDVUIWebViewNavigationDelegate end */
    }
    
    
    return shouldLoad;
    
    }
- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
    if(!zuznowBase)
    {
        zuznowBase = [self getCommandInstance:@"ZuznowBase"];
    }
    
    [zuznowBase webViewDidStartLoad: theWebView ];
    
    /* from CDVUIWebViewNavigationDelegate */
    NSLog(@"Resetting plugins due to page load.");
    
    [self.commandQueue resetRequestId];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginResetNotification object:self.webView]];
    
    /* from CDVUIWebViewNavigationDelegate end*/

}
- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    if(!zuznowBase)
    {
        zuznowBase = [self getCommandInstance:@"ZuznowBase"];
    }
    [zuznowBase webViewDidFinishLoad: theWebView ];
    
    /* from CDVUIWebViewNavigationDelegate */
    NSLog(@"Finished load of: %@", theWebView.request.URL);
    
    // It's safe to release the lock even if this is just a sub-frame that's finished loading.
    [CDVUserAgentUtil releaseLock:self.userAgentLockToken];
    
    /*
     * Hide the Top Activity THROBBER in the Battery Bar
     */
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPageDidLoadNotification object:self.webView]];
    /* from CDVUIWebViewNavigationDelegate end*/
}
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
    if(!zuznowBase)
    {
        zuznowBase = [self getCommandInstance:@"ZuznowBase"];
    }
    [zuznowBase didFailLoadWithError: theWebView error:error];
    
    
    /* from CDVUIWebViewNavigationDelegate */
    
    [CDVUserAgentUtil releaseLock:self.userAgentLockToken];
    
    NSString* message = [NSString stringWithFormat:@"Failed to load webpage with error: %@", [error localizedDescription]];
    NSLog(@"%@", message);
    
    NSURL* errorUrl = self.errorURL;
    if (errorUrl) {
        errorUrl = [NSURL URLWithString:[NSString stringWithFormat:@"?error=%@", [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] relativeToURL:errorUrl];
        NSLog(@"%@", [errorUrl absoluteString]);
        [theWebView loadRequest:[NSURLRequest requestWithURL:errorUrl]];
    }
    
    /* from CDVUIWebViewNavigationDelegate end */

}


//
- (void)setNotificationMessage:(NSString *) urlString message: (NSString *) messageString
{
    start_url_message = urlString;
}


@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end


