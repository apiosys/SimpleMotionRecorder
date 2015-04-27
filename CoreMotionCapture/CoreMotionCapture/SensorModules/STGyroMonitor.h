/*
//  STGyroMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

/**
 This class is the convenience wrapper around the gyroscope sensor of the CMMotionManager API.
 */
@interface STGyroMonitor : NSObject

/**
 The actual Gyroscope data as provided by Core Motion
 */
@property(nonatomic, readonly) CMGyroData *latestGyroData;//Don't synthesize

@property(nonatomic, readonly) NSString *printableGyroInfo;

/**
 Allows the caller to stop listening for the gyroscope updates.
 
 @param motionMgr The motion manager used to access the gyroscope.
 */
-(void)stopGyro:(CMMotionManager *)motionMgr;

/**
 Allows the caller to start the gyro at the desired sampling rate.
 
 @param tmInterval - The sampling rate in Hz
 @param motionMgr - The motion manager used to access the accelerometer.
 
 @return True if the gyroscope is available and was started successfully. False otherwise.
 */
-(BOOL)startGyro:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr;

@end
