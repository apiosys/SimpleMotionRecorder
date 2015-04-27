/*
//  STSensorManager.m
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

//#import "CMasterController.h"
#import "STActivityMonitor.h"
#import "STSensorManager.h"
#import "STGpsMonitor.h"
#import "STGyroMonitor.h"
#import "STMotionMonitor.h"
#import "STMagnetrometerMonitor.h"
#import "STAccelerometerMonitor.h"
#import "STProximityMonitor.h"
#import "SensorMonitoringDefs.h"
//#import "HelperMethods.h"

//#import "SALLog.h"

@interface STSensorManager()
	@property(nonatomic, strong) NSDateFormatter *dtFrmtr;
	@property(nonatomic, strong) CMMotionManager *motionManager;

	@property(nonatomic, strong) STGpsMonitor *gpsMonitor;
	@property(nonatomic, strong) STGyroMonitor *gyroMonitor;
	@property(nonatomic, strong) STMotionMonitor *motionMonitor;
	@property(nonatomic, strong) STActivityMonitor *activityMonitor;
	@property(nonatomic, strong) STAccelerometerMonitor *accelMonitor;
	@property(nonatomic, strong) STProximityMonitor *proximityMonitor;
	@property(nonatomic, strong) STMagnetrometerMonitor *magnetrometerMonitor;
@end

@implementation STSensorManager

@synthesize dtFrmtr = _dtFrmtr;
@synthesize gpsMonitor = _gpsMonitor;
@synthesize gyroMonitor = _gyroMonitor;
@synthesize accelMonitor = _accelMonitor;
@synthesize motionManager = _motionManager;
@synthesize motionMonitor = _motionMonitor;
@synthesize activityMonitor = _activityMonitor;
@synthesize proximityMonitor = _proximityMonitor;

-(NSDateFormatter *)dtFrmtr
{
	if(_dtFrmtr == nil)
	{
		_dtFrmtr = [[NSDateFormatter alloc]init];
		[_dtFrmtr setTimeStyle:NSDateFormatterMediumStyle];
	}
	
	return _dtFrmtr;
}

+(STSensorManager *)theSensorManager
{
	static STSensorManager *sensorMgr;
	
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sensorMgr = [[STSensorManager alloc] initTheSensorManager];
	});
	
	return sensorMgr;
}

-(id)initTheSensorManager
{
	self = [super init];
	
	if(!self)
		return self;
	
	return self;
}

-(id)init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
											 reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `theSensorManager` instead.",
														NSStringFromClass([self class])]
										  userInfo:nil];
}



#pragma mark - Read-only properties

-(BOOL)bHasNativeMotionActivityDetection
{
	return self.activityMonitor.bHasNativeMotionActivityDetection;
}

-(STGpsMonitor *)gpsSensorMonitor
{
	return self.gpsMonitor;
}

-(STGyroMonitor *)gyroSensorMonitor
{
	return self.gyroMonitor;
}

-(STMotionMonitor *)motionSensorMonitor
{
	return self.motionMonitor;
}

-(STActivityMonitor *)activitySensorMonitor
{
	return self.activityMonitor;
}

-(STProximityMonitor *)proximitySensorMonitor
{
	return self.proximityMonitor;
}

-(STAccelerometerMonitor *)accelSensorMonitor
{
	return self.accelMonitor;
}

-(STMagnetrometerMonitor *)magnetrometerSensorMonitor
{
	return self.magnetrometerMonitor;
}

-(CMMotionManager *)motionManager
{
	if(_motionManager == nil)
		_motionManager = [[CMMotionManager alloc]init];
	
	return _motionManager;
}

-(STGpsMonitor *)gpsMonitor
{
	if(_gpsMonitor == nil)
		_gpsMonitor = [[STGpsMonitor alloc]init];
	
	return _gpsMonitor;
}

-(STGyroMonitor *)gyroMonitor
{
	if(_gyroMonitor == nil)
		_gyroMonitor = [[STGyroMonitor alloc]init];
	
	return _gyroMonitor;
}

-(STMotionMonitor *)motionMonitor
{
	if(_motionMonitor == nil)
	{
		_motionMonitor = [[STMotionMonitor alloc]init];
		_motionMonitor.updateDelegate = self;//So we know when we have motion information. This causes SALAnalyze to get called.
	}
	
	return _motionMonitor;
}

-(STActivityMonitor *)activityMonitor
{
	if(_activityMonitor == nil)
		_activityMonitor = [[STActivityMonitor alloc]init];
	
	return _activityMonitor;
}

-(STProximityMonitor *)proximityMonitor
{
	if(_proximityMonitor == nil)
		_proximityMonitor = [[STProximityMonitor alloc]init];
	
	return _proximityMonitor;
}

-(STAccelerometerMonitor *)accelMonitor
{
	if(_accelMonitor == nil)
		_accelMonitor = [[STAccelerometerMonitor alloc]init];
	
	return _accelMonitor;
}

-(STMagnetrometerMonitor *)magnetrometerMonitor
{
	if(_magnetrometerMonitor == nil)
		_magnetrometerMonitor = [[STMagnetrometerMonitor alloc]init];
	
	return _magnetrometerMonitor;
}

//Notification when motion update occurs
-(void)motionDataUpdated:(CMDeviceMotion *)devMotion
{
//	[[CMasterController theMasterController] callSalAnalyze];
}

-(void)stopSensors
{
	//Stop this first since it is the update which fires off the calls to the SAL
	[self.accelMonitor stopAccelerometer:self.motionManager];

	[self.gpsMonitor stopGps];
	[self.proximityMonitor stopProximitySensor];
	[self.activityMonitor stopActivityMonitoring];
	[self.gyroMonitor stopGyro:self.motionManager];
	[self.motionMonitor stopMotionMonitoring:self.motionManager];
	[self.magnetrometerMonitor stopMagnetrometer:self.motionManager];
}

-(BOOL)startSensors
{
	if([self.gpsMonitor startUpGps] == FALSE)
		NSLog(@"Issue Starting GPS");

	if([self.proximityMonitor startProximitySensor] == FALSE)
		NSLog(@"Issue Starting the Proximity Sensor");

	if([self.activityMonitor startUpActivityMonitoring] == FALSE)
		NSLog(@"Activity Monitoring not available");

	if([self.gyroMonitor startGyro:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		NSLog(@"Issue Starting the Gyro");

	if([self.motionMonitor startMotionMonitoring:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		NSLog(@"Issue Starting the Motion Monitor");

	if([self.magnetrometerMonitor startMagnetrometer:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		NSLog(@"Issue Starting the Magnetrometer");

	//Initialize last since once this updates, we save the record. This is just to
	//increase our chances all the other data will be populated before an acceleration
	//update. It doesn't really matter, but it just may allow for a clean first record.
	if([self.accelMonitor startAccelerometer:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		NSLog(@"Issue Starting the Accelerometer");

	return TRUE;
}

-(void)startUpNeededSensors
{
	if([self.accelMonitor startAccelerometer:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		[self logErrorMessage:@"APP ERROR LOG: Unable to start the Accelerometer\n"];

	if([self.gyroMonitor startGyro:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		[self logErrorMessage:@"APP ERROR LOG: Unable to start the Gyro\n"];

	if([self.magnetrometerMonitor startMagnetrometer:SAMPLING_INTERVAL motion:self.motionManager] == FALSE)
		[self logErrorMessage:@"APP ERROR LOG: Unable to start the Magnetometer\n"];

	if([self.gpsMonitor startUpGps] == FALSE)
		[self logErrorMessage:@"APP ERROR LOG: Unable to start the GPS\n"];

	if([self.activityMonitor startUpActivityMonitoring] == FALSE)
		[self logErrorMessage:@"APP ERROR LOG: Unable to start the Activity monitoring\n"];

//	if( (sensorsNowNeeded & RAW_ACCELEROMETER) == RAW_ACCELEROMETER)
//		[self logSensorPowerManagementEvent:TRUE theSensor:RAW_ACCELEROMETER];//--NEED VERIFYING
}

-(void)shutdownSensorsNoLongerNeeded
{
	[self.accelMonitor stopAccelerometer:self.motionManager];

	[self.gyroMonitor stopGyro:self.motionManager];

	[self.magnetrometerMonitor stopMagnetrometer:self.motionManager];

	[self.gpsMonitor startGpsInLowPowerMode];

	[self.activityMonitor stopActivityMonitoring];
	
//	if( (sensorsNoLongerNeeded & RAW_ACCELEROMETER) == RAW_ACCELEROMETER)
//		[self logSensorPowerManagementEvent:TRUE theSensor:RAW_ACCELEROMETER];//--NEED VERIFYING;
}

-(void)logErrorMessage:(NSString *)strError
{
	if( (strError == nil) || (strError.length <= 0) )// || (isLoggingAllowed() == FALSE) )
		return;
	
//	SALLogWrite([strError UTF8String], FALSE);
}


-(NSString *)printableString:(NSString *)dateString
{
	/*
	//https://developer.apple.com/library/ios/Documentation/CoreLocation/Reference/CLLocation_Class/index.html
	//http://stackoverflow.com/questions/15380632/in-ios-what-is-the-difference-between-the-magnetic-field-values-from-the-core-l
	//https://developer.apple.com/library/prerelease/iOS/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html#//apple_ref/occ/instp/CMDeviceMotion/magneticField
	//https://developer.apple.com/library/IOs/documentation/CoreMotion/Reference/CMAccelerometerData_Class/index.html#//apple_ref/c/tdef/CMAcceleration
	//https://developer.apple.com/LIBRARY/IOS/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html
	*/

	return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@\n",
			  dateString, //-2, -1
			  self.motionMonitor.printableCalibratedMagnetometerInfo,//1, 2, 3
			  self.motionMonitor.printableCalibratedAccelerometerInfo,//4, 5, 6,
			  self.gpsMonitor.printableLocationInfo,//7, 8, 9
			  self.gyroMonitor.printableGyroInfo,//10, 11, 12
			  self.motionMonitor.printableMotionRateInfo,//13, 14, 15
			  self.magnetrometerMonitor.printableMagnetometerInfo,//16, 17, 18
			  self.gpsMonitor.printableLocationMetaDataInfo,//19, 20, 21, 22, 23
			  self.accelMonitor.printableRawAccelerometerInfo,//24, 25, 26
			  self.activityMonitor.printableActivityInfo,//27
			  self.proximityMonitor.printableProximityInfo,//28
			  [self orientationToString]];//29
}

-(NSString *)orientationToString
{
	switch (self.deviceOrientation)
	{
		case UIDeviceOrientationPortrait:
			return @"OrientationPortrait";
		case UIDeviceOrientationPortraitUpsideDown: // Device oriented vertically, home button on the top
			return @"OrientationPortraitUpsideDown";
		case UIDeviceOrientationLandscapeLeft:     // Device oriented horizontally, home button on the right
			return @"OrientationLandscapeLeft";
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			return @"OrientationLandscapeRight";
		case UIDeviceOrientationFaceUp:         // Device oriented flat, face up
			return @"OrientationFlatFaceUp";
		case UIDeviceOrientationFaceDown:             // Device oriented flat, face down
			return @"OrientationFlatFaceDown";
		case UIDeviceOrientationUnknown:
		default:
			return @"OrientationUnknown";
			break;
	}

	return @"OrientationUnDefined";
}

@end
