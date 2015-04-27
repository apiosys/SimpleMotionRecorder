/*
//  STGpsMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

/**
 This class is the convenience wrapper around the GPS sensor of the CLLocationManager API.
 */
@interface STGpsMonitor : NSObject<CLLocationManagerDelegate>

@property(nonatomic, readonly) NSString *printableLocationInfo;
@property(nonatomic, readonly) NSString *printableLocationMetaDataInfo;

/**
 The actual and latest CLLocation as provided by Core Location
 */
@property(nonatomic, readonly) CLLocation *latestLocation;//Don't synthesize

/**
 Stops listening for location updates provided by the CLLocationManager
 */
-(void)stopGps;

/**
 Puts the GPS into "Significant Change" state to reduce power consumption
 */
-(void)startGpsInLowPowerMode;

/**
 Starts listening for GPS updates from the CLLocationManager. The GPS updates are requested as "kCLLocationAccuracyBest" in this call.
 
 @return True if the locationServicesEnabled variable is true and the GPS is successfully initialized. False otherwise. 
 */
-(BOOL)startUpGps;

@end
