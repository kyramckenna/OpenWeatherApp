//
//  WeatherRequest.m
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "WeatherRequest.h"
#import "WeatherConstants.h"
#import "CConnectionManager.h"
#import "WeatherInfo.h"

@interface WeatherRequest () {
    NSError *_error;
    NSURLSessionDataTask *_finderTask;
    NSURLSession *_session;
}

@end

@implementation WeatherRequest

- (void)getResponse:(NSString *)urlString
{
    if(![[CConnectionManager sharedManager] isConnected])
        return;
    
    int timeOutInterval = 60;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeOutInterval];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    // create a session
    _session = [self createSession];
    _finderTask = [_session dataTaskWithRequest:request];
    [_finderTask resume];
}

#pragma mark Find Using NSURLSession Delegate Approach
- (NSURLSession *)createSession
{
    static NSURLSession *session = nil;
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                            delegate:self
                                       delegateQueue:[NSOperationQueue mainQueue]];
    return session;
}


-(void)printMyJSON:(NSDictionary*)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"PRINTING JSON: %@", jsonString);
    }
}

#pragma  NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    if(data != nil){
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"Weather: %@", jsonDictionary);
        
        if(jsonDictionary != nil){
            
            NSObject<WeatherProtocol> *weatherInfo;
            weatherInfo = [[WeatherInfo alloc] initWithDictionary:jsonDictionary];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weather" object:weatherInfo];
        }
    }
}

- (void) URLSession:(NSURLSession *)session
           dataTask:(NSURLSessionDataTask *)dataTask
 didReceiveResponse:(NSURLResponse *)response
  completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
    NSLog(@"httpResp: %@",httpResp);
    
    if(httpResp.statusCode != 200){
        [[NSNotificationCenter defaultCenter] postNotificationName: @"weatherRejected" object:nil userInfo:nil];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
    NSLog(@"%s",__func__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    _error = error;
    
    if(error == nil)
    {
        NSLog(@"Download is Succesfull");
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName: @"weatherRejected" object:nil];
        NSLog(@"Error %@",[error userInfo]);
    }
}

// Server trust authentication for https sites

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

@end


