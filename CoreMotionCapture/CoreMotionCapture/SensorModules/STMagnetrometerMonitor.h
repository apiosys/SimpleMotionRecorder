/*
//  STMagnetrometerMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class CMMotionManager;
@class CMMagnetometerData;

/**
 This class is the convenience wrapper around the magnetometer sensor of the CMMotionManager API.
 */
@interface STMagnetrometerMonitor : NSObject

@property(nonatomic, readonly) NSString *printableMagnetometerInfo;

/**
 The actual Magnetometer as provided by Core Motion
 */
@property(nonatomic, readonly) CMMagnetometerData *latestMagnetometerReading;

/**
 Allows the caller to stop listening for the magnetometer updates.
 
 @param motionMgr The motion manager used to access the magnetometer.
 */
-(void)stopMagnetrometer:(CMMotionManager *)motionMgr;

/**
 Allows the caller to start the gyro at the desired sampling rate.
 
 @param tmInterval - The sampling rate in Hz
 @param motionMgr - The motion manager used to access the magnetometer.
 
 @return True if the magnetometer is available and was started successfully. False otherwise.
 */
-(BOOL)startMagnetrometer:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr;

@end
