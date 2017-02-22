//
//  WeatherViewController.h
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *currentTemp;
@property (weak, nonatomic) IBOutlet UITableView *forecastTableView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimestamp;
@property (weak, nonatomic) IBOutlet UILabel *currentPressure;
@property (weak, nonatomic) IBOutlet UILabel *currentHumidity;
@property (weak, nonatomic) IBOutlet UILabel *currentWind;
@property (weak, nonatomic) IBOutlet UIImageView *weatherView;
@property (weak, nonatomic) IBOutlet UIImageView *cityImage;

@end
