/*
 //  STSensorManager.h
 //  SALTester
 //
 //  Created by Jeff Behrbaum on 10/14/14.
 //  Copyright (c) 2014 Apio Systems. All rights reserved.
 */

#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>

#import "SensorModuleProtocols.h"

@class STGpsMonitor;
@class STGyroMonitor;
@class STMotionMonitor;
@class STActivityMonitor;
@class STProximityMonitor;
@class STAccelerometerMonitor;
@class STMagnetrometerMonitor;

/**
 This is the sensor manager which wraps the calls to and from all the device's sensors.
 This class provides the single point where a user can call to start and/or stop all
 the available sensors with a single call.
 */
@interface STSensorManager : NSObject<deviceMotionNotifications>

//This prevents us from having to query the device orientation at 32HZ.
//Instead, it is set whenever the device orientation changes and then
//we just use it.
@property(nonatomic) UIDeviceOrientation deviceOrientation;

/**
 Allocates the singleton instance of the Sensor Controller. This object is the central
 point of sensor interactions and contains all the sensor data.
 
 @return STSensorManager: The single instance of the manager.
 */
+(STSensorManager *)theSensorManager;

/**
 The wrapper around the CMMotionActivity functionality
 */
@property(nonatomic, readonly) BOOL bHasNativeMotionActivityDetection;

/**
 The wrapper around the CLLocationManager's functionality
 */
@property(nonatomic, readonly) STGpsMonitor *gpsSensorMonitor;

/**
 The wrapper around the CoreMotionManager's Gyro functionality
 */
@property(nonatomic, readonly) STGyroMonitor *gyroSensorMonitor;

/**
 The wrapper around the CoreMotionManager's general motion functionality
 */
@property(nonatomic, readonly) STMotionMonitor *motionSensorMonitor;

/**
 The wrapper around the CMMotionActivity's M7 Activity functionality
 */
@property(nonatomic, readonly) STActivityMonitor *activitySensorMonitor;

/**
 The wrapper around the CoreMotionManager's Accelerometer functionality
 */
@property(nonatomic, readonly) STAccelerometerMonitor *accelSensorMonitor;

/**
 The wrapper around the UI Proximity sensor
 */
@property(nonatomic, readonly) STProximityMonitor *proximitySensorMonitor;

/**
 The wrapper around the CoreMotionManager's Magnetrometer functionality
 */
@property(nonatomic, readonly) STMagnetrometerMonitor *magnetrometerSensorMonitor;

/**
 This call stops all the sensors.
 */
-(void)stopSensors;

/**
 This call tries to start all available sensors on the device.
 
 @return True is ALL the sensors were successfully turned on - False otherwise.
 */
-(BOOL)startSensors;

/**
 This call Retreives a string from each of the sensors with the most recent 
 sensor reads.
 
 @return A non-nil string to print to a file
*/
-(NSString *)printableString:(NSString *)dateString;

@end
