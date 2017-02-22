//
//  WeatherFeed.h
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherFeed : NSObject

#pragma mark - current weather

-(void) currentWeatherByCityName:(NSString *) name;
-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate ;
-(void) currentWeatherByCityId:(NSString *) cityId ;

#pragma mark - forecast

-(void) forecastByCityName:(NSString *) name ;
-(void) forecastByCoordinate:(CLLocationCoordinate2D) coordinate ;
-(void) forecastByCityId:(NSString *) cityId ;

@end
