/*
//  CViewController.h
//  CoreMotionCapture
//
//  Created by Jeff Behrbaum on 7/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface CViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic, weak) IBOutlet UILabel *lblAppInfo;

@end
