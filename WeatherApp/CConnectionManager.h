//
//  CConnectionManager.h
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Reachability;

@interface CConnectionManager : NSObject

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) bool bWifi;

+ (CConnectionManager*) sharedManager;
- (BOOL)isConnected;

+ (void) saveCookies;
+ (NSArray*) getCookies;
+ (void) clearCookies;

+ (void) addParameters:(NSDictionary* )parameters toRequest:(NSMutableURLRequest*) request;
+ (void) addParameters:(NSDictionary* )parameters toRequest:(NSMutableURLRequest*) request changeURL:(bool)url;

@end
