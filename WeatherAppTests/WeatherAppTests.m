//
//  WeatherAppTests.m
//  WeatherAppTests
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WeatherFeed.h"
#import "WeatherConstants.h"

@interface WeatherAppTests : XCTestCase
@property (nonatomic, retain) WeatherFeed *weatherFeed;
@end

@implementation WeatherAppTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    // Check that the json feed is working and returning the correct feed for CITYNAME
    NSError *error;
    NSString *method = [NSString stringWithFormat:@"/weather?q=%@", CITYNAME];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@,%@&APPID=%@", BASEURL, APIVERSION, method, COUNTRYCODE, APIKEY];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:jsonObj];
    XCTAssert(isValid);
    
    NSDictionary *weatherDict = jsonObj;
    
    NSString *cityName = [weatherDict[@"name"] uppercaseString];
    NSString *expectedResult = [CITYNAME uppercaseString];
    
    XCTAssertTrue([cityName isEqualToString:expectedResult],
                  @"Strings are not equal %@ %@", expectedResult, cityName);
}

@end
