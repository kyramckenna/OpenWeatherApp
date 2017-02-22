//
//  ForecastInfo.h
//  WeatherApp
//
//  Created by Kyra McKenna on 22/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherProtocol.h"

@interface ForecastInfo : NSObject<WeatherProtocol>

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (NSArray*) getDictionary;

@end
