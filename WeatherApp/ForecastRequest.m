//
//  ForecastRequest.m
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "ForecastRequest.h"
#import "WeatherConstants.h"
#import "CConnectionManager.h"
#import "ForecastInfo.h"

@interface ForecastRequest () {
    
    //private variables without get/set methods
    NSError *_error;
    NSURLSessionDataTask *_finderTask;
    NSURLSession *_session;
    NSMutableData *_downloadedData;
}

@end

@implementation ForecastRequest

- (void)getResponse:(NSString *)urlString
{
    if(![[CConnectionManager sharedManager] isConnected])
        return;
    
    int timeOutInterval = 60;
    
    _downloadedData = [NSMutableData data];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeOutInterval];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    // create a session with delegate set
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
    
    [_downloadedData appendData:data];
    
    if(data != nil){
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:_downloadedData options:0 error:nil];
        
        NSLog(@"Forecast: %@", jsonDictionary);
        
        if(jsonDictionary != nil){
            
            NSObject<WeatherProtocol> *requestInfo;
            requestInfo = [[ForecastInfo alloc] initWithDictionary:jsonDictionary];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"forecast" object:requestInfo];
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
    }else{
        _downloadedData = [NSMutableData data];
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
    
    if(error != nil)
    {
        NSLog(@"Error %@",[error userInfo]);
        [[NSNotificationCenter defaultCenter] postNotificationName: @"weatherRejected" object:nil];
    }
    else if(_downloadedData != nil)
    {
        NSLog(@"Download is Succesfull");
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:_downloadedData options:0 error:nil];
        
        NSLog(@"Forecast: %@", jsonDictionary);
        if(jsonDictionary != nil){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"forecast"
                                                                object:jsonDictionary];
        }
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



