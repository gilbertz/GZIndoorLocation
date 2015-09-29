//
//  ViewController.m
//  GZIndoorLocation
//
//  Created by zhaoguoqi on 15/7/25.
//  Copyright (c) 2015年 MDH. All rights reserved.
//


#import "ViewController.h"
//static NSString * const kUUID = @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825";//weixin
//static NSString * const kUUID = @"23A01AF0-232A-4518-9C0E-323FB773F5EF";//yunzi
static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";//estimote
//static NSString * const kUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";//bright
//static NSString * const kUUID = @"B5B182C7-EAB1-4988-AA99-B5C1517008D9";//april



static NSString * const kIdentifier = @"SomeIdentifier";

static NSString * const kOperationCellIdentifier = @"OperationCell";
static NSString * const kBeaconCellIdentifier = @"BeaconCell";
static NSString * const kRangingOperationTitle = @"Ranging";
static NSUInteger const kNumberOfSections = 2;
static NSUInteger const kNumberOfAvailableOperations = 1;
static CGFloat const kOperationCellHeight = 44;
static CGFloat const kBeaconCellHeight = 52;
static NSString * const kBeaconSectionTitle = @"Looking for beacons...";
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 12};
static NSString * const kBeaconsHeaderViewIdentifier = @"BeaconsHeader";

static void * const kMonitoringOperationContext = (void *)&kMonitoringOperationContext;
static void * const kRangingOperationContext = (void *)&kRangingOperationContext;

typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTOperationsSection,
    NTDetectedBeaconsSection
};

typedef NS_ENUM(NSUInteger, NTOperationsRow) {
    NTRangingRow
};

@interface ViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, weak) UISwitch *rangingSwitch;
@property (nonatomic, unsafe_unretained) void *operationContext;

@end

@implementation ViewController
@synthesize myWebView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startRangingForBeacons];
    self.myWebView.delegate=self;
    self.myWebView.scalesPageToFit = YES;
    
    NSString *localHTMLPageFilePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *localHTMLPageFileURL = [NSURL fileURLWithPath:localHTMLPageFilePath];
    [myWebView loadRequest:[NSURLRequest requestWithURL:localHTMLPageFileURL]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/false"] ) {
        NSLog( @"not clicked" );
        return false;
    }
    
    if ( [request.mainDocumentURL.relativePath isEqualToString:@"/click/true"] ) {        //the image is clicked, variable click is true
        NSLog( @"image clicked" );

//        [myWebView stringByEvaluatingJavaScriptFromString:@"show([{'minor':4215,'major':10004,'rssi':42,'measuredPower': 59},{'minor':4332,'major':10004,'rssi':49,'measuredPower': 59},{'minor':4180,'major':10004,'rssi':45,'measuredPower': 59},{'minor':4218,'major':10004,'rssi':43,'measuredPower': 59}])"];
//        NSString *str = [self.detectedBeacons componentsJoinedByString:@","];
//        NSLog(str);
//        NSLog(@"params:%@",self.detectedBeacons);
//        NSData *jsonData  =[self toJSONData : self.detectedBeacons];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData
//                                                     encoding:NSUTF8StringEncoding];
//        NSLog(jsonString);
//        NSError* error = nil;
//        NSString *result = [NSJSONSerialization dataWithJSONObject:self.detectedBeacons
//                                                    options:kNilOptions error:&error];
//        NSLog(result);
//                CLBeacon *beacon = self.detectedBeacons[0];
//                [self detailsStringForBeacon:beacon];
//        NSLog([self detailsStringForBeacon:beacon]);
        
        
        NSMutableArray *dictArray = self.detectedBeacons;
        NSMutableArray *dictArr = [NSMutableArray array];
        for (int i = 0; i < dictArray.count; i++) {
            CLBeacon *beacon = self.detectedBeacons[i];
//            NSUInteger anInteger = [beacon.rssi integerValue];
            NSString *rssiString = [NSString stringWithFormat:@"%li", abs(beacon.rssi)];
            NSDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[beacon.minor floatValue]],@"minor",[NSNumber numberWithFloat:[beacon.major floatValue]],@"major", [NSNumber numberWithInt:[rssiString intValue]] ,@"rssi",[NSNumber numberWithInt:59],@"measuredPower",nil];
                [dictArr addObject:dict];
        }
//                NSLog(@"params:%@",dictArr);
                NSData *jsonData  =[self toJSONData : dictArr];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                             encoding:NSUTF8StringEncoding];
//                NSLog(jsonString);
                NSString *jsonDataString = [NSString stringWithFormat:@"show(%@)", jsonString];
//        NSLog(jsonDataString);
                [myWebView stringByEvaluatingJavaScriptFromString:jsonDataString];
//                [myWebView stringByEvaluatingJavaScriptFromString:@"show([{'minor':4215,'major':10004,'rssi':42,'measuredPower': 59},{'minor':4332,'major':10004,'rssi':49,'measuredPower': 59},{'minor':4180,'major':10004,'rssi':45,'measuredPower': 59},{'minor':4218,'major':10004,'rssi':43,'measuredPower': 59}])"];


        return false;
    }
    
    return true;
}

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}



- (NSArray *)filteredBeacons:(NSArray *)beacons
{
    // Filters duplicate beacons out; this may happen temporarily if the originating device changes its Bluetooth id
    NSMutableArray *mutableBeacons = [beacons mutableCopy];
    
    NSMutableSet *lookup = [[NSMutableSet alloc] init];
    for (int index = 0; index < [beacons count]; index++) {
        CLBeacon *curr = [beacons objectAtIndex:index];
        NSString *identifier = [NSString stringWithFormat:@"%@/%@", curr.major, curr.minor];
        
        // this is very fast constant time lookup in a hash table
        if ([lookup containsObject:identifier]) {
            [mutableBeacons removeObjectAtIndex:index];
        } else {
            [lookup addObject:identifier];
        }
    }
    
    return [mutableBeacons copy];
}

#pragma mark - Table view functionality
- (NSString *)detailsStringForBeacon:(CLBeacon *)beacon
{
    NSString *proximity;
    switch (beacon.proximity) {
        case CLProximityNear:
            proximity = @"Near";
            break;
        case CLProximityImmediate:
            proximity = @"Immediate";
            break;
        case CLProximityFar:
            proximity = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximity = @"Unknown";
            break;
    }
    
    NSString *format = @"%@, %@ • %@ • %f • %li";
//    NSLog(format);
    return [NSString stringWithFormat:format, beacon.major, beacon.minor, proximity, beacon.accuracy, beacon.rssi];
}



#pragma mark - Common
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kIdentifier];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

- (void)createLocationManager
{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
}

- (void)startRangingForBeacons
{
    self.operationContext = kRangingOperationContext;
    
    [self createLocationManager];
    
    [self checkLocationAccessForRanging];
    
    self.detectedBeacons = [NSArray array];
    [self turnOnRanging];
}

- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        self.rangingSwitch.on = NO;
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self createBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
}

- (void)stopRangingForBeacons
{
    if (self.locationManager.rangedRegions.count == 0) {
        NSLog(@"Didn't turn off ranging: Ranging already off.");
        return;
    }
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    

    self.detectedBeacons = [NSArray array];
    
    [self.beaconTableView beginUpdates];
    [self.beaconTableView endUpdates];
    
    NSLog(@"Turned off ranging.");
}

#pragma mark - Location manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
        self.rangingSwitch.on = NO;
        return;
        
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
            self.rangingSwitch.on = YES;
            return;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            self.rangingSwitch.on = YES;
            
            return;
            
        default:
            NSLog(@"Couldn't turn on monitoring: Required Location Access(WhenInUse) missing.");
            self.rangingSwitch.on = NO;
            return;
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    NSArray *filteredBeacons = [self filteredBeacons:beacons];
    
    if (filteredBeacons.count == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        NSLog(@"Found %lu %@.", (unsigned long)[filteredBeacons count],
              [filteredBeacons count] > 1 ? @"beacons" : @"beacon");

    }

    
    self.detectedBeacons = filteredBeacons;
    
    [self.beaconTableView beginUpdates];
    [self.beaconTableView endUpdates];
}

#pragma mark - Location access methods (iOS8/Xcode6)
- (void)checkLocationAccessForRanging {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

@end
