//
//  ZuznowBase.m
//


#import "ZuznowBase.h"
#import "ZuzURLProtocol.h"


@implementation ZuznowBase

//preference options
NSString *const ZUZNOW_AUTOMATIC_SPINNER = @"AutomaticSpinner";

    
- (void)pluginInitialize {
    
    automaticSpinner = true;
    processIndicator = Nil;
    currentUrl = Nil;
    
    if(!initialized)
    {
		[NSURLProtocol registerClass:[ZuzURLProtocol class]];
	
        initialized = true;
        id automaticSpinnerString = [self.commandDelegate.settings objectForKey: [ZUZNOW_AUTOMATIC_SPINNER lowercaseString]];
        if(automaticSpinnerString != nil) automaticSpinner = [automaticSpinnerString boolValue];        
    }    
}


- (void)init:(CDVInvokedUrlCommand*)command
{
    
}

- (void)show:(CDVInvokedUrlCommand*)command
{
    if(!processIndicator){
        processIndicator =  [ZuzProcessIndicator alloc];
    }
    if(processIndicator){
        [processIndicator show];
    }
    
}

- (void)showWithTimeout:(CDVInvokedUrlCommand*)command
{
    int timeout = [[command.arguments objectAtIndex:0] intValue] / 1000;
    
    if( timeout > 0 )
    {
        showTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hideAfterTimeout:) userInfo:Nil repeats:NO];
    }
    
    if(processIndicator){
        [processIndicator show];
    }
    
}

- (void)hideAfterTimeout:(NSTimer*)timer
{
    [timer invalidate];
    if(processIndicator){
        [processIndicator hide];
    }
    showTimer = nil;
}

- (void)hide:(CDVInvokedUrlCommand*)command
{
    if(processIndicator){
        [processIndicator hide];
    }
}

- (void)setAutomaticSpinner:(CDVInvokedUrlCommand*)command
{
    bool show = [[command.arguments objectAtIndex:0] boolValue];
    automaticSpinner = show;
}


- (void)log:(NSString *)message
{
    NSLog(@"%@",message);
}
    
    
    
- (BOOL)shouldStartLoadWithRequest:(UIWebView *) theWebView request:(NSURLRequest *) request navigationType:(UIWebViewNavigationType)navigationType;    {
    
        //zuznow UI settings
        theWebView.backgroundColor = [UIColor blackColor];
        theWebView.scrollView.bounces = NO;
        theWebView.scalesPageToFit = YES;

    
        NSURL* url = [request URL];
    
        
        BOOL shouldLoad = YES;
    
    
        NSString *newUrl = url.absoluteString;
        
        if(shouldLoad)
        {
            NSRange textRange = [url.absoluteString rangeOfString:@"zuzapp_external_url=true"];
            if(textRange.location != NSNotFound)
            {
                shouldLoad = NO;
                newUrl = [newUrl stringByReplacingOccurrencesOfString:@"&zuzapp_external_url=true" withString:@""];
                newUrl = [newUrl stringByReplacingOccurrencesOfString:@"?zuzapp_external_url=true&" withString:@"?"];
                newUrl = [newUrl stringByReplacingOccurrencesOfString:@"?zuzapp_external_url=true" withString:@""];
            }
        }
        url = [NSURL URLWithString:newUrl];
    
        if(!shouldLoad){
            [[UIApplication sharedApplication] openURL:url];
            if(processIndicator){
                [processIndicator hide];
            }
            return NO;
        }
        if(shouldLoad){
            currentUrl = url.absoluteString;
        }
        return shouldLoad;
    }
    
- (void)webViewDidStartLoad:(UIWebView *)theWebView
    {
        if(automaticSpinner){
            if(!processIndicator){
                processIndicator =  [ZuzProcessIndicator alloc];
            }
            [processIndicator show];
        }
    }
- (void)webViewDidFinishLoad:(UIWebView *)theWebView
    {
        if(processIndicator){
            [processIndicator hide];
        }
    }
    
- (void)didFailLoadWithError:(UIWebView *) theWebView error:(NSError *)error
    {
        if(processIndicator){
            [processIndicator hide];
        }
        if ([error code] == NSURLErrorNotConnectedToInternet || [error code] == NSURLErrorNetworkConnectionLost) {
            NSLog(@"Could not load the webPage network issue");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem connecting" message:@"Please check your network and try again." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles: nil];
            [alert show];
        }        
    }
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Retry"])
        {
            if(currentUrl != Nil)
            {
                NSURL *url = [NSURL URLWithString:currentUrl];
                NSURLRequest* appReq = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
                [self.webViewEngine loadRequest:appReq];
            }
        }
    }



@end
