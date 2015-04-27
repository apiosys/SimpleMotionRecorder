//
//  STMagnetrometerMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
//
#import <CoreMotion/CoreMotion.h>

#import "STMagnetrometerMonitor.h"

@interface STMagnetrometerMonitor()
@property(nonatomic, strong) CMMagnetometerData *magnetrometerData;

@end

@implementation STMagnetrometerMonitor

@synthesize magnetrometerData = _magnetrometerData;

-(CMMagnetometerData *)latestMagnetometerReading
{
	return self.magnetrometerData;
}


-(NSString *)printableMagnetometerInfo
{
	if(self.magnetrometerData == nil)
		return @"- - -";

	//UnCalibrated/raw magnetrometer - Fields 16, 17, 18
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
			  self.magnetrometerData.magneticField.x,
			  self.magnetrometerData.magneticField.y,
			  self.magnetrometerData.magneticField.z];
}




-(void)stopMagnetrometer:(CMMotionManager *)motionMgr
{
	if([motionMgr isMagnetometerActive] == TRUE)
		[motionMgr stopMagnetometerUpdates];
}

-(BOOL)startMagnetrometer:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr
{
	BOOL bRetStat = TRUE;
	
	if([motionMgr isMagnetometerActive] == TRUE)
		return bRetStat;
	
	if([motionMgr isMagnetometerAvailable] == TRUE)
	{
		STMagnetrometerMonitor *__weak weakSelf = self;

		[motionMgr setMagnetometerUpdateInterval:tmInterval];
	
		[motionMgr startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
			[weakSelf updateMagnetrometer:magnetometerData];
		}];
	}
	else
	{
		bRetStat = FALSE;
	}
	
	return bRetStat;
}


-(void)updateMagnetrometer:(CMMagnetometerData *)magData
{
	self.magnetrometerData = magData;
}

@end
