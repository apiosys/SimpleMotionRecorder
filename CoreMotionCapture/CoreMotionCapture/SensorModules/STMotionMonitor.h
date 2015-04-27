/*
//  STMotionMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "SensorModuleProtocols.h"

@class CMMotionManager;

/**
 This class is the convenience wrapper around the motion sensor of the CMMotionManager API.
 */
@interface STMotionMonitor : NSObject

@property(nonatomic, readonly) NSString *printableMotionRateInfo;
@property(nonatomic, readonly) NSString *printableCalibratedMagnetometerInfo;
@property(nonatomic, readonly) NSString *printableCalibratedAccelerometerInfo;

/**
 The delegate which is called whenever a motion update is received. This is the protocol
 which the SALWrapper conforms to so that the call to SALAnalyze can be made when a motion
 update is received.
 */
@property(nonatomic, strong) id<deviceMotionNotifications> updateDelegate;

/**
 The actual Motion data as provided by Core Motion
 */
@property(nonatomic, readonly) CMDeviceMotion *latestDeviceMotionData;//Don't synthesize

/**
 Allows the caller to stop listening for the motion updates.
 
 @param motionMgr The motion manager used to access the motion detections.
 */
-(void)stopMotionMonitoring:(CMMotionManager *)motionMgr;

/**
 Allows the caller to start the motion detection at the desired sampling rate.
 
 @param tmInterval - The sampling rate in Hz
 @param motionMgr - The motion manager used to access the device motion.
 
 @return True if the device motion monitoring is available and was started successfully. False otherwise.
 */
-(BOOL)startMotionMonitoring:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr;

@end
