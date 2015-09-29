//
//  ViewController.h
//  GZIndoorLocation
//
//  Created by zhaoguoqi on 15/7/25.
//  Copyright (c) 2015年 MDH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate,CLLocationManagerDelegate, CBPeripheralManagerDelegate,UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UIWebView *myWebView;
}
@property (nonatomic,retain) UIWebView *myWebView;
@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;

@end


