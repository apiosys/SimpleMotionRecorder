/*
//  STAccelerometerMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <CoreMotion/CoreMotion.h>

#import "CMotionLogger.h"
#import "STAccelerometerMonitor.h"

@interface STAccelerometerMonitor()
	@property(nonatomic, strong) CMAccelerometerData *accelerometerData;

	-(void)updateAccelerometer:(CMAccelerometerData *)accelerometerData;
@end

@implementation STAccelerometerMonitor

@synthesize accelerometerData = _accelerometerData;

-(CMAccelerometerData *)latestAccelerometerReading
{
	return self.accelerometerData;
}

-(NSString *)printableRawAccelerometerInfo
{
	if(self.accelerometerData == nil)
		return @"- - -";

	//Uncalibrated accelerometer - Fields 24, 25, 26
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
			  self.accelerometerData.acceleration.x,
			  self.accelerometerData.acceleration.y,
			  self.accelerometerData.acceleration.z];
}

-(void)stopAccelerometer:(CMMotionManager *)motionMgr
{
	if([motionMgr isAccelerometerActive] == TRUE)
		[motionMgr stopAccelerometerUpdates];
}

-(BOOL)startAccelerometer:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr
{
	BOOL bRetStat = TRUE;

	if([motionMgr isAccelerometerActive] == TRUE)
		return bRetStat;
	
	if ([motionMgr isAccelerometerAvailable] == YES)
	{
		STAccelerometerMonitor *__weak weakSelf = self;

		[motionMgr setAccelerometerUpdateInterval:tmInterval];

		[motionMgr startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
			[weakSelf updateAccelerometer:accelerometerData];
		}];
	}

	return bRetStat;
}

-(void)updateAccelerometer:(CMAccelerometerData *)accelerometerData
{
	self.accelerometerData = accelerometerData;
	
	CMotionLogger *logger = [CMotionLogger theLogger];
	[logger writeCurrentSamplesToLogFile];
}

@end
