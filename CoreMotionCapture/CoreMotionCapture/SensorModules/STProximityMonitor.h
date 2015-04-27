/*
//  STProximityMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 4/20/15.
//  Copyright (c) 2015 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class CMMotionManager;

@interface STProximityMonitor : NSObject

/**
 The most recent proximity value
 */
@property(nonatomic, readonly) BOOL latestProximityReading;

@property(nonatomic, readonly) NSString *printableProximityInfo;

/**
 Allows the caller to stop listening for the proximity sensor updates.
 */
-(void)stopProximitySensor;

/**
 Allows the caller to start the proximity sensor.
 
 @return True if the proximity sensor is available and was started successfully. False otherwise.
 */
-(BOOL)startProximitySensor;


@end
