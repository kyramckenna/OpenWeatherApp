//
//  WeatherInfo.h
//  WeatherApp
//
//  Created by Kyra McKenna on 22/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherProtocol.h"

@interface WeatherInfo : NSObject<WeatherProtocol>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *temp;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *pressure;
@property (nonatomic, strong) NSString *humidity;
@property (nonatomic, strong) NSString *wind;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary*) getDictionary;

@end

