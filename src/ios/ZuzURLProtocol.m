//
//  ZuzURLProtocol.m
//  
//
//
//

#import "ZuzURLProtocol.h"

@implementation ZuzURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL canInit = [[[request URL] scheme] isEqualToString:@"http"]
    || [[[request URL] scheme] isEqualToString:@"https"];
    if(canInit){
        NSString *pathString = [[request URL] absoluteString];
        
        if ([pathString hasSuffix:@"js"] &&
            ([pathString hasPrefix:@"http://s1.mob-server.com/files/phonegap/remoteToLocal"]
             || [pathString hasPrefix:@"https://s1.mob-server.com/files/phonegap/remoteToLocal"]) ) {
                canInit = true;
            }
        else{
            canInit = false;
        }
        
    }
	return canInit;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void) startLoading {
    id<NSURLProtocolClient> client = [self client];
    NSURLRequest* request = [self request];
    NSString *pathString = [[request URL] absoluteString];
    NSString* fileToLoad = nil;   
    
    if ([pathString hasSuffix:@"js"] &&
        ([pathString hasPrefix:@"http://s1.mob-server.com/files/phonegap/remoteToLocal"]
         || [pathString hasPrefix:@"https://s1.mob-server.com/files/phonegap/remoteToLocal"]) ) {
            NSString* theFileName = [[pathString lastPathComponent] stringByDeletingPathExtension];
            NSString* dir = pathString;
            if([pathString hasPrefix:@"http:"])
            {
               dir = [dir stringByReplacingOccurrencesOfString:@"http://s1.mob-server.com/files/phonegap/remoteToLocal" withString:@"www"];
            }
            else{
                dir = [dir stringByReplacingOccurrencesOfString:@"https://s1.mob-server.com/files/phonegap/remoteToLocal" withString:@"www"];
            }
            dir = [dir stringByDeletingLastPathComponent];
            fileToLoad = [[NSBundle mainBundle] pathForResource:theFileName ofType:@"js" inDirectory:dir];
        }
    NSData *data = nil;
    if (fileToLoad) {
        data = [NSData dataWithContentsOfFile:fileToLoad];
        
        if(data){
        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[request URL] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:[NSDictionary dictionary]];
        
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        
        
        [client URLProtocol:self didLoadData:data];
        [client URLProtocolDidFinishLoading:self];
        }
        else{
            [super startLoading];
        }
    }
    else{
        [super startLoading];
    }
    
    
}

- (void) stopLoading {
    
}

@end
