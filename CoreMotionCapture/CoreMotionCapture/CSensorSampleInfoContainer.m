/*
 //  CSensorSampleInfoContainer.m
 //  CoreMotionCapture
 //
 //  Created by Jeff Behrbaum on 9/26/14.
 //  Copyright (c) 2014 Apio Systems. All rights reserved.
 */

#import <Coremotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "CSensorSampleInfoContainer.h"

@interface CSensorSampleInfoContainer()

@property(nonatomic, strong) NSDateFormatter *dtFmtr;

@end

@implementation CSensorSampleInfoContainer

@synthesize dtFmtr = _dtFmtr;
@synthesize gyroData = _gyroData;
@synthesize motionData = _motionData;
@synthesize locationData = _locationData;
@synthesize rawAcceleration = _rawAcceleration;
@synthesize magnetrometerData = _magnetrometerData;

-(NSDateFormatter *)dtFmtr
{
	if(_dtFmtr == nil)
	{
		_dtFmtr = [[NSDateFormatter alloc]init];
		[_dtFmtr setDateStyle:NSDateFormatterShortStyle];
		[_dtFmtr setTimeStyle:NSDateFormatterShortStyle];
	}
	
	return _dtFmtr;
}

-(NSString *)printableString
{
	//https://developer.apple.com/library/ios/Documentation/CoreLocation/Reference/CLLocation_Class/index.html
	//http://stackoverflow.com/questions/15380632/in-ios-what-is-the-difference-between-the-magnetic-field-values-from-the-core-l
	//https://developer.apple.com/library/prerelease/iOS/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html#//apple_ref/occ/instp/CMDeviceMotion/magneticField
	//https://developer.apple.com/library/IOs/documentation/CoreMotion/Reference/CMAccelerometerData_Class/index.html#//apple_ref/c/tdef/CMAcceleration
	//https://developer.apple.com/LIBRARY/IOS/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html
	
	
	NSString *strInfo;
	
	NSString *strMotion;
	NSString *strLocation;
	NSString *strLocationTime;
	NSString *strLocationMetaData;
	NSString *strGyroInfo;
	NSString *strMagnetrometer;
	//NSString *strCalabratedMagnetrometer
	NSString *strRawAcceleration;
	NSString *strCalabratedMagnetrometer;//User Acceleration

	if(self.gyroData != nil)
		strGyroInfo = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.z];

	if(self.magnetrometerData != nil)
		strMagnetrometer = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.magnetrometerData.magneticField.x, self.magnetrometerData.magneticField.y, self.magnetrometerData.magneticField.z];

	if(self.locationData != nil)
	{
		strLocationTime = [NSString stringWithFormat:@"%@", [self.dtFmtr stringFromDate:self.locationData.timestamp]];
		strLocation = [NSString stringWithFormat:@"%@ %.5lf %.5lf %.5lf", [self.dtFmtr stringFromDate:self.locationData.timestamp], self.locationData.coordinate.latitude, self.locationData.coordinate.longitude, self.locationData.altitude];
		strLocationMetaData = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf 0.0", self.locationData.horizontalAccuracy, self.locationData.verticalAccuracy, self.locationData.speed];
	}

	if(self.rawAcceleration != nil)
		strRawAcceleration = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.rawAcceleration.acceleration.x, self.rawAcceleration.acceleration.y, self.rawAcceleration.acceleration.z];

	if(self.motionData != nil)
	{
		//self.motionData.magneticField.field.x
		strMotion = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.motionData.attitude.roll, self.motionData.attitude.pitch, self.motionData.attitude.yaw];
		strCalabratedMagnetrometer = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.motionData.userAcceleration.x, self.motionData.userAcceleration.y, self.motionData.userAcceleration.z];
	}

	strInfo = [NSString stringWithFormat:@"%@ %@ %@\n", strLocation, strRawAcceleration, strMotion];

	return strInfo;
}

@end
