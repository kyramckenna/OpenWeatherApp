//
//  WeatherFeed.m
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "WeatherFeed.h"

#import "WeatherFeed.h"
#import "WeatherRequest.h"
#import "ForecastRequest.h"
#import "WeatherConstants.h"


@implementation WeatherFeed


- (void) callMethod:(NSString *) method
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@,%@&APPID=%@", BASEURL, APIVERSION, method, COUNTRYCODE, APIKEY];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        WeatherRequest *request = [[WeatherRequest alloc] init];
        [request getResponse:urlString];
    });
}

#pragma mark current weather

-(void) currentWeatherByCityName:(NSString *)name
{
    
    NSString *method = [NSString stringWithFormat:@"/weather?q=%@", name];
    [self callMethod:method];
    
}

-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
{
    
    NSString *method = [NSString stringWithFormat:@"/weather?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method ];
    
}

-(void) currentWeatherByCityId:(NSString *) cityId

{
    NSString *method = [NSString stringWithFormat:@"/weather?id=%@", cityId];
    [self callMethod:method ];
}

#pragma mark forcast

-(void) forecastByCityName:(NSString *) name
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast?q=%@", name];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&APPID=%@", BASEURL, APIVERSION, method, APIKEY];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        ForecastRequest *request = [[ForecastRequest alloc] init];
        [request getResponse:urlString];
    });
    
}

-(void) forecastByCoordinate:(CLLocationCoordinate2D) coordinate

{
    
    NSString *method = [NSString stringWithFormat:@"/forecast?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method ];
    
}

-(void) forecastByCityId:(NSString *) cityId

{
    NSString *method = [NSString stringWithFormat:@"/forecast?id=%@", cityId];
    [self callMethod:method ];
}

@end

