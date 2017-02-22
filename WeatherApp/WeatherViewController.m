//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherFeed.h"
#import "WeatherConstants.h"
#import "WeatherInfo.h"
#import "ForecastInfo.h"

@interface WeatherViewController ()

@property (nonatomic, strong) WeatherFeed *weatherFeed;
@property (nonatomic, strong) NSArray *forecast;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic) int downloadCount;

@end

@implementation WeatherViewController

- (void)viewDidLoad {

    // City Image
    int radius = self.cityImage.frame.size.width/2;
    self.cityImage.layer.cornerRadius = radius;
    self.cityName.layer.masksToBounds = YES;
    self.cityName.layer.borderWidth = 0;
    
    // Weather Key
    _weatherFeed = [[WeatherFeed alloc] init];
    
    // Sign up for Json notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"weather"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"forecast"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"weatherRejected"
                                               object:nil];
    
    // Initialize the refresh control.
    UIRefreshControl *refreshControl;
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor purpleColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                            action:@selector(getForecast)
                  forControlEvents:UIControlEventValueChanged];
    self.forecastTableView.refreshControl = refreshControl;
    
    // Get the City Weather first
    [self.activityIndicator startAnimating];
    _weatherFeed = [[WeatherFeed alloc]init];
    [_weatherFeed currentWeatherByCityName:CITYNAME];
}

-(void)getForecast{
    _weatherFeed = [[WeatherFeed alloc]init];
    [_weatherFeed forecastByCityName:CITYNAME];
    
    [self.forecastTableView.refreshControl endRefreshing];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[WeatherInfo class]])
    {
        WeatherInfo *weatherInfo = [notification object];
        
        _downloadCount++;
        
        if(weatherInfo != nil){
            
            self.cityName.text = [weatherInfo name];
            NSString *icon = [weatherInfo icon];
            if(icon != nil){
                NSString *weatherIcon = [NSString stringWithFormat:@"%@.png", icon];
                self.weatherView.image = [UIImage imageNamed:weatherIcon];
            }
            
            self.currentTemp.text = [weatherInfo temp];
            self.currentTimestamp.text = [weatherInfo time];
            self.currentPressure.text = [weatherInfo pressure];
            self.currentHumidity.text = [weatherInfo humidity];
            self.currentWind.text = [weatherInfo wind];
            
            // Now get the Forecast for the next 5 days
            [self getForecast];
            
        }
        
    }else if ([notification.object isKindOfClass:[ForecastInfo class]])
    {
        
        //NSDictionary *weatherDict = [notification object];
        ForecastInfo *forcastInfo = [notification object];
        
        _downloadCount++;
        
        if (_downloadCount > 1){
            [self.activityIndicator stopAnimating];
        }
        
        _forecast = [forcastInfo getDictionary];
        
        [self.forecastTableView reloadData];
    }
    else if([[notification name] isEqualToString:@"weatherRejected"])
    {
        [self.activityIndicator stopAnimating];
        [self displayToastWithMessage:@"We are having difficulties connecting to the Weather site"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _forecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *forecastData = [_forecast objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@   %@  %@, %@",
                           forecastData[@"capitalDay"],
                           forecastData[@"time"],
                           forecastData[@"weatherType"],
                           forecastData[@"celsius"],
                           forecastData[@"windspeed"]];
    
    cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
    
    // Weather icon
    NSString *weatherIcon = forecastData[@"weatherIcon"];
    
    if(weatherIcon != nil)
        cell.imageView.image = [UIImage imageNamed:weatherIcon];
    
    return cell;
}

-(void)displayToastWithMessage:(NSString *)toastMessage
{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:toastMessage
                                        attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){keyWindow.frame.size.width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize textSize = rect.size;
        
        UILabel *toastView = [[UILabel alloc] init];
        toastView.text = toastMessage;
        toastView.textColor = [UIColor whiteColor];
        toastView.backgroundColor = [UIColor darkGrayColor];
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.frame = CGRectMake(0.0, 0.0, textSize.width, 50.0);
        toastView.layer.cornerRadius = 10;
        toastView.layer.masksToBounds = YES;
        toastView.center = keyWindow.center;
        
        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 3.0f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             toastView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [toastView removeFromSuperview];
                         }
         ];
    }];
}

- (NSString *)capitilizeEachWord:(NSString *)sentence {
    NSArray *words = [sentence componentsSeparatedByString:@" "];
    NSMutableArray *newWords = [NSMutableArray array];
    for (NSString *word in words) {
        if (word.length > 0) {
            NSString *capitilizedWord = [[[word substringToIndex:1] uppercaseString] stringByAppendingString:[word substringFromIndex:1]];
            [newWords addObject:capitilizedWord];
        }
    }
    return [newWords componentsJoinedByString:@" "];
}


@end
