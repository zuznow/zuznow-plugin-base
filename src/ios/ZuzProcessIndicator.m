//
//  ZuzProcessIndicator.m 
//
//
//

#import "ZuzProcessIndicator.h"

@implementation ZuzProcessIndicator

UIViewController* viewController;
    
UIActivityIndicatorView* indicator;
int connectionTimeout;
BOOL loaderBackgroundImageExists;
NSTimer *showTimer;
UIImageView* imageView;
UIImage *loaderImage;



-(void)show
{
    
    connectionTimeout = 8; //todo read from config
    
    if(!indicator)
    {
        //check if the loader background image exists
        loaderImage = [UIImage imageNamed:@"loader-background.png"];
        if (loaderImage){
            loaderBackgroundImageExists = YES;
        }
        else{
            loaderBackgroundImageExists = NO;
        }
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        //build the UI
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (loaderBackgroundImageExists){
            imageView = [[UIImageView alloc] init];
            
            [viewController.view addSubview:imageView];            
            //load the icon image
            //NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
            //NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
            imageView.image = loaderImage;
            
            CGRect imgFrame = CGRectMake(0, 0, 0, 0);
            if( orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight )
            {
                // landscape
                imgFrame.size.width = viewController.view.frame.size.height;
                imgFrame.size.height = viewController.view.frame.size.width;
            }
            else
            {
                // portrait
                imgFrame.size.width = viewController.view.frame.size.width;
                imgFrame.size.height = viewController.view.frame.size.height;
            }
            
            imageView.frame = imgFrame;
        }
        
        
        indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color = [UIColor blackColor];
        
        // center indicator and resize/colorize frame (take screen orientation into account)
        CGRect frame = indicator.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        if( orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight )
        {
            // landscape
            frame.size.width = viewController.view.frame.size.height;
            frame.size.height = viewController.view.frame.size.width;
        }
        else
        {
            // portrait
            frame.size.width = viewController.view.frame.size.width;
            frame.size.height = viewController.view.frame.size.height;
        }
        indicator.frame = frame;
        indicator.layer.cornerRadius = 0;
        indicator.opaque = YES;
        indicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    }
    else
    {
        [indicator removeFromSuperview];
        
        if (loaderBackgroundImageExists){
            [imageView removeFromSuperview];
        }
    }
    
    
    if( connectionTimeout > 0 )
    {
        showTimer = [NSTimer scheduledTimerWithTimeInterval:connectionTimeout target:self selector:@selector(hideAfterTimeout:) userInfo:Nil repeats:NO];
    }
    
    [viewController.view addSubview:indicator];
    [indicator startAnimating];
}

-(void)hideAfterTimeout:(NSTimer*)timer
{
    [timer invalidate];
    [self hide];
    showTimer = nil;
}

-(void)hide
{
    [indicator stopAnimating];
    [indicator removeFromSuperview];
    indicator = nil;
    
    if (loaderBackgroundImageExists){
        [imageView removeFromSuperview];
        imageView = nil;
    }
    
    if(showTimer){
        [showTimer invalidate];
        showTimer = nil;
    }
    
    
    
}



@end
