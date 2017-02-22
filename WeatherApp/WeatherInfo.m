//
//  WeatherInfo.m
//  WeatherApp
//
//  Created by Kyra McKenna on 22/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "WeatherInfo.h"

#define kWeatherInfoCityName @"cityName"
#define kWeatherInfoIcon @"icon"
#define kWeatherInfoTemperature @"temperature"
#define kWeatherInfoTime @"time"
#define kWeatherInfoPressure @"pressure"
#define kWeatherInfoHumidity @"humidity"
#define kWeatherInfoWindSpeed @"windSpeed"


@implementation WeatherInfo

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]])
        {
            _name = [NSString stringWithFormat:@"%@, %@",
                                    dictionary[@"name"],
                                    dictionary[@"sys"][@"country"]];
            
            NSArray *weatherArray = dictionary[@"weather"];
            NSString *iconName = weatherArray[0][@"icon"];
            _icon = [NSString stringWithFormat:@"%@.png", iconName];
            
            if(dictionary[@"main"][@"temp"] != nil){
                
                // Convert to Celsius
                int celsius = [dictionary[@"main"][@"temp"] floatValue] - 273.15;
                _temp = [NSString stringWithFormat:@"%d℃",celsius];
            }
            
            // Time
            NSDateFormatter *formatter;
            NSDate *date;
            
            if(dictionary[@"dt"] != nil){
                double unixTimeStamp = [dictionary[@"dt"] doubleValue];
                NSTimeInterval _interval=unixTimeStamp;
                date = [NSDate dateWithTimeIntervalSince1970:_interval];
                formatter= [[NSDateFormatter alloc] init];
                [formatter setLocale:[NSLocale currentLocale]];
                
                // Get day - eg:MON
                [formatter setDateFormat:@"EEEE"];
                NSString *day = [formatter stringFromDate:date];
                NSString *capitalDay = [[day substringToIndex:3] capitalizedString];
                
                // Get hour:min
                [formatter setDateFormat:@"HH:mm"];
                NSString *hourMin = [formatter stringFromDate:date];
                
                // Display
                _time =  [NSString stringWithFormat:@"%@ %@", capitalDay, hourMin];
            }
            
            int pressure = [dictionary[@"main"][@"pressure"] intValue];
            _pressure = [NSString stringWithFormat:@"Pressure: %dhp", pressure];
            _humidity = [NSString stringWithFormat:@"Humidity: %@%%", dictionary[@"main"][@"humidity"] ];
            
            // Get wind - convert metres/sec to km/hour
            float windSpeedKM_H = ([dictionary[@"wind"][@"speed"] floatValue]*18) / 5;
            _wind = [NSString stringWithFormat:@"Wind: %.1f km/h", windSpeedKM_H ];
        }
    }
    
    return self;
}

- (NSDictionary*) getDictionary{
    NSDictionary *dictionary = @{
                                 kWeatherInfoCityName : _name,
                                 kWeatherInfoIcon : _icon,
                                 kWeatherInfoTemperature : _temp,
                                 kWeatherInfoTime : _time,
                                 kWeatherInfoPressure : _pressure,
                                 kWeatherInfoHumidity : _humidity,
                                 kWeatherInfoWindSpeed : _wind
                                 };
    
    return dictionary;
}

@end




