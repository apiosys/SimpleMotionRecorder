/*
//  STAccelerometerMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class CMMotionManager;
@class CMAccelerometerData;

/**
 This class is the convenience wrapper around the accelerometer sensor of the CMMotionManager API.
 */
@interface STAccelerometerMonitor : NSObject

/**
 The actual Accelerometer as provided by Core Motion
 */
@property(nonatomic, readonly) CMAccelerometerData *latestAccelerometerReading;//Don't synthesize

@property(nonatomic, readonly) NSString *printableRawAccelerometerInfo;


/**
 Allows the caller to stop listening for the accelerometer updates.
 
 @param motionMgr The motion manager used to access the accelerometer.
 */
-(void)stopAccelerometer:(CMMotionManager *)motionMgr;

/**
 Allows the caller to start the accelerometer at the desired sampling rate.
 
 @param tmInterval - The sampling rate in Hz
 @param motionMgr - The motion manager used to access the accelerometer.
 
 @return True if the accelerometer is available and was started successfully. False otherwise.
 */
-(BOOL)startAccelerometer:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr;

@end
