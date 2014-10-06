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
@property(nonatomic) NSTimeInterval offsetRecordTimeOffset;

@end

@implementation CSensorSampleInfoContainer

static NSDate *m_startRecordingTime;//Under no circumstance does this become a property!

@synthesize dtFmtr = _dtFmtr;

@synthesize gyroData = _gyroData;
@synthesize motionData = _motionData;
@synthesize dateOfRecord = _dateOfRecord;
@synthesize locationData = _locationData;
@synthesize rawAcceleration = _rawAcceleration;
@synthesize magnetrometerData = _magnetrometerData;

-(NSDate *)dateOfRecord
{
	if(_dateOfRecord == nil)
		_dateOfRecord = [NSDate date];
	
	return _dateOfRecord;
}

-(void)setDateOfRecord:(NSDate *)dateOfRecord
{
	_dateOfRecord = dateOfRecord;
}

-(NSTimeInterval)offsetRecordTimeOffset
{
	NSTimeInterval interval = [self.dateOfRecord timeIntervalSinceDate:CSensorSampleInfoContainer.startRecTime];
	
	if(interval < 0.0)
		interval *= -1.0;
	
	return interval;
}

+(NSDate *)startRecTime
{
	if(m_startRecordingTime == nil)
		m_startRecordingTime = [NSDate date];
	
	return m_startRecordingTime;
}

+(void)setStartRecTime:(NSDate *)startRecTime
{
	m_startRecordingTime = startRecTime;
}

-(NSDateFormatter *)dtFmtr
{
	if(_dtFmtr == nil)
	{
		_dtFmtr = [[NSDateFormatter alloc]init];
		[_dtFmtr setDateFormat:@"yyyyMMdd HHmmss"];

		//[_dtFmtr setDateStyle:NSDateFormatterShortStyle];
		//[_dtFmtr setTimeStyle:NSDateFormatterShortStyle];
	}
	
	return _dtFmtr;
}

-(NSString *)printableString
{
	/*
	//https://developer.apple.com/library/ios/Documentation/CoreLocation/Reference/CLLocation_Class/index.html
	//http://stackoverflow.com/questions/15380632/in-ios-what-is-the-difference-between-the-magnetic-field-values-from-the-core-l
	//https://developer.apple.com/library/prerelease/iOS/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html#//apple_ref/occ/instp/CMDeviceMotion/magneticField
	//https://developer.apple.com/library/IOs/documentation/CoreMotion/Reference/CMAccelerometerData_Class/index.html#//apple_ref/c/tdef/CMAcceleration
	//https://developer.apple.com/LIBRARY/IOS/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html
	 */

	NSString *strRecordTime;
	
	NSString *strInfo;
	NSString *strGyroInfo;
	NSString *strLocation;
	NSString *strMotionRate;
	NSString *strMagnetrometer;
	NSString *strRawAcceleration;
	NSString *strLocationMetaData;
	NSString *strCalibratedAccelerometer;//User Acceleration
	NSString *strCalibratedMagnetrometer;

	strRecordTime = [NSString stringWithFormat:@"%@", [self.dtFmtr stringFromDate:self.dateOfRecord]];
	
	if(self.gyroData != nil)
	{
		//Rate - Fields, 10, 11, 12
		strGyroInfo = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
							self.gyroData.rotationRate.x,
							self.gyroData.rotationRate.y,
							self.gyroData.rotationRate.z];
	}

	if(self.magnetrometerData != nil)
	{
		//UnCalibrated/raw magnetrometer - Fields 16, 17, 18
		strMagnetrometer = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
								  self.magnetrometerData.magneticField.x,
								  self.magnetrometerData.magneticField.y,
								  self.magnetrometerData.magneticField.z];
	}

	if(self.locationData != nil)
	{
		//Lat lon alt - Fields 7, 8, 9
		strLocation = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
							self.locationData.coordinate.latitude,
							self.locationData.coordinate.longitude,
							self.locationData.altitude];

		//... - Fields 19, 20, 21, 22, 23
		strLocationMetaData = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf %.5lf 0.0",
									  [self.locationData.timestamp timeIntervalSince1970],
									  self.locationData.horizontalAccuracy,
									  self.locationData.verticalAccuracy,
									  self.locationData.speed];
	}

	if(self.rawAcceleration != nil)
	{
		//Uncalibrated accelerometer - Fields 24, 25, 26
		strRawAcceleration = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
									 self.rawAcceleration.acceleration.x,
									 self.rawAcceleration.acceleration.y,
									 self.rawAcceleration.acceleration.z];
	}

	if(self.motionData != nil)
	{
		//Calibrated magnetic field - Fields 1, 2, 3
		strCalibratedMagnetrometer= [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
											  self.motionData.magneticField.field.x,
											  self.motionData.magneticField.field.y,
											  self.motionData.magneticField.field.z];

		//Motion rate - Fields 13, 14, 15
		strMotionRate = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
							  self.motionData.attitude.roll,
							  self.motionData.attitude.pitch,
							  self.motionData.attitude.yaw];

		//Calibrated accelerometer - Fields 4, 5, 6
		strCalibratedAccelerometer = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
												self.motionData.userAcceleration.x,
												self.motionData.userAcceleration.y,
												self.motionData.userAcceleration.z];
	}

	//Field - 1
	NSString *strTimeSinceStart = [NSString stringWithFormat:@"%.5lf", self.offsetRecordTimeOffset];

	strInfo = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ \n",
				  strRecordTime, //-3, -2
				  strTimeSinceStart,//-1
				  strCalibratedMagnetrometer,//1, 2, 3
				  strCalibratedAccelerometer,//4, 5, 6,
				  strLocation,//7, 8, 9
				  strGyroInfo,//10, 11, 12
				  strMotionRate,//13, 14, 15
				  strMagnetrometer,//16, 17, 18
				  strLocationMetaData,//19, 20, 21, 22, 23
				  strRawAcceleration];//24, 25, 26

	return strInfo;
}

@end
