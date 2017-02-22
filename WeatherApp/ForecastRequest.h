//
//  ForecastRequest.h
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForecastRequest : NSObject<NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

- (void)getResponse:(NSString *)urlString;

@end
