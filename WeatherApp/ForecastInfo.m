//
//  ForecastInfo.m
//  WeatherApp
//
//  Created by Kyra McKenna on 22/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "ForecastInfo.h"

@interface ForecastInfo ()

@property (nonatomic,strong) NSMutableArray *forecastArray;

@end

@implementation ForecastInfo


- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    _forecastArray = [[NSMutableArray alloc] init];
    
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]])
        {
            NSArray *localArray = dictionary[@"list"];
            
            for(int i=0;i<[localArray count]; i++){
                
                NSDictionary *dict = [localArray objectAtIndex:i];
                
                float farenHeight = [dict[@"main"][@"temp"] floatValue];
                float celsius = farenHeight - 273.15;
                NSString *temp = [NSString stringWithFormat:@"%.1f℃", celsius ];
                
                // Convert to Day in 3 letters and captital eg: MON TUES etc
                NSString *dateString = dict[@"dt_txt"];
                NSString *capitalDay;
                NSString *time;
                
                // Format date string 2017-02-17 21:00:00
                if(dateString != nil){
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *date = [dateFormatter dateFromString:dateString];
                    
                    // Set output format and convert to string
                    [dateFormatter setDateFormat:@"EEEE"];
                    NSString *day = [dateFormatter stringFromDate:date];
                    capitalDay = [[day substringToIndex:3] uppercaseString];
                    
                    // Set output format and convert to string
                    [dateFormatter setDateFormat:@"HH:mm"];
                    time = [dateFormatter stringFromDate:date];
                }
                
                float speed = [dict[@"wind"][@"speed"] floatValue];
                float windSpeedKM_H = (speed * 18) / 5;
                NSString *windSpeed = [NSString stringWithFormat:@"Wind: %.1f km/h", windSpeedKM_H ];
        
                // Weather icon
                NSArray *weather = dict[@"weather"];
                NSString *iconName = weather[0][@"icon"];
                NSString *weatherIconName = [NSString stringWithFormat:@"%@.png", iconName];
                NSString *weatherType = dict[@"weather"][0][@"main"];
                
                // Add item to Dictionary and then Array
                NSMutableDictionary *convertedDict = [[NSMutableDictionary alloc] init];
                [convertedDict setValue:capitalDay forKey:@"capitalDay"];
                [convertedDict setValue:time forKey:@"time"];
                [convertedDict setValue:weatherType forKey:@"weatherType"];
                [convertedDict setValue:weatherIconName forKey:@"weatherIcon"];
                [convertedDict setValue:temp forKey:@"celsius"];
                [convertedDict setValue:windSpeed forKey:@"windspeed"];
                [_forecastArray addObject:convertedDict];
            }
        }
    }
    
    return self;
}

- (NSMutableArray*) getDictionary{
    return _forecastArray;
}

@end




