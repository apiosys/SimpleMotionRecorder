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

#import "STSensorManager.h"

@interface CSensorSampleInfoContainer()

@property(nonatomic, strong) STSensorManager *sensorManager;

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

-(STSensorManager *)sensorManager
{
	if(_sensorManager == nil)
		_sensorManager = [[STSensorManager alloc]init];

	return _sensorManager;
}

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

-(BOOL)stopSensors
{
	[self.sensorManager stopSensors];
	return TRUE;
}

-(BOOL)startSensors
{
	return [self.sensorManager startSensors];
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

@end
