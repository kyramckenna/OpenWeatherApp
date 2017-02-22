//
//  CConnectionManager.m
//  WeatherApp
//
//  Created by Kyra McKenna on 14/02/2017.
//  Copyright © 2017 Kyra McKenna. All rights reserved.
//

#import "CConnectionManager.h"
#import "Reachability.h"

@implementation CConnectionManager

+ (CConnectionManager*) sharedManager {
    static CConnectionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager; }

- (id)init {
    self = [super init];
    
    if (self) {
        
        // Apple Reachibility
        NSString *remoteHostName = @"www.apple.com";
        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        
        // Start Monitoring
        [self.hostReachability startNotifier];
    }
    
    return self;
}

- (BOOL)isConnected {
    
    bool connected = false;
    
    /*Removal of reachabilityForLocalWiFi
     ============
     Older versions of this sample included the method reachabilityForLocalWiFi. As originally designed, this method allowed apps using Bonjour to check the status of "local only" Wi-Fi (Wi-Fi without a connection to the larger internet) to determine whether or not they should advertise or browse.
     
     However, the additional peer-to-peer APIs that have since been added to iOS and OS X have rendered it largely obsolete.  Because of the narrow use case for this API and the large potential for misuse, reachabilityForLocalWiFi has been removed from Reachability.*/
    
    if([self isWanWifiOn]){
        connected = true;
    }
    
    if(!connected){
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Internet Connection",nil)
                                     message:@"You must be connected to the internet to use this App!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                    }];
        
        [alert addAction:yesButton];
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc presentViewController:alert animated:YES completion:nil];
        });
    }
    
    return connected;
}

- (BOOL)isWanWifiOn {
    Reachability* wanReach = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus netStatus = [wanReach currentReachabilityStatus];
    bool result = (netStatus==ReachableViaWWAN);
    if(!result)
        result = (netStatus==ReachableViaWiFi);
    return result;
}


/* --------------- COOKIES --------------- */

+ (void) clearCookies
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IZY_COOKIES"];
}

+ (void) saveCookies
{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSMutableDictionary* cookieDictionary = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"IZY_COOKIES"]];
        [cookieDictionary setValue:cookie.properties forKey:@"google.com"];
        [[NSUserDefaults standardUserDefaults] setObject:cookieDictionary forKey:@"IZY_COOKIES"];
    }
}

+(NSArray*) getCookies
{
    NSDictionary* cookieDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"IZY_COOKIES"];
    NSDictionary* cookieProperties = [cookieDictionary valueForKey:@"google.com"];
    if (cookieProperties != nil) {
        NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        NSArray* cookieArray = [NSArray arrayWithObject:cookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        return cookieArray;
    }
    return nil;
}

+(void) printCookies
{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSLog(@"name: '%@'\n",   [cookie name]);
        NSLog(@"value: '%@'\n",  [cookie value]);
        NSLog(@"domain: '%@'\n", [cookie domain]);
        NSLog(@"path: '%@'\n",   [cookie path]);
    }
}

/* --------------- ADD PARAMETERS TO URL --------------- */

+(void) addParameters:(NSDictionary* )parameters toRequest:(NSMutableURLRequest*) request
{
    [self addParameters:parameters toRequest:request changeURL:YES];
}

+(void) addParameters:(NSDictionary* )parameters toRequest:(NSMutableURLRequest*) request changeURL:(bool)url
{
    NSString* postString;
    for (NSString* key in parameters.allKeys)
        postString = [self appendKey:key andValue:[parameters valueForKey:key] inToString:postString];
    
    if(postString && url){
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",[[request URL] absoluteString],postString]]];
    }
    NSData *data = [NSData dataWithBytes:[postString UTF8String]  length:[postString length]];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
}

+ (NSString*) appendKey:(NSString*) key andValue:(NSString*) value inToString:(NSString*) string
{
    if(!value)
        return string;
    if(string || string.length > 0)
        string = [string stringByAppendingString:@"&"];
    else
        string = @"";
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    return string;
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        _bWifi = (bool)(netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
    }
    
    if (reachability == self.internetReachability)
    {
        
        //[self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
    }
    
}


- (void)configureTextField:(UITextField *)textField imageView:(UIImageView *)imageView reachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            break;
        }
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            imageView.image = [UIImage imageNamed:@"Airport.png"];
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    textField.text= statusString;
}



@end
