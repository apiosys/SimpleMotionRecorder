/*
//  STMotionMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <CoreMotion/CoreMotion.h>

#import "STMotionMonitor.h"

@interface STMotionMonitor()
	@property(nonatomic, strong) CMDeviceMotion *deviceMotionData;
	@property (nonatomic) CMAttitudeReferenceFrame attitudeReferenceFrame;

	-(void)updateMotionInfo:(CMDeviceMotion *)motionData;
@end

@implementation STMotionMonitor

@synthesize updateDelegate = _updateDelegate;
@synthesize deviceMotionData = _deviceMotionData;
@synthesize attitudeReferenceFrame = _attitudeReferenceFrame;

-(CMDeviceMotion *)latestDeviceMotionData
{
	return self.deviceMotionData;
}

-(id)init
{
	self = [super init];

	if(self)
		self.attitudeReferenceFrame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;

	return self;
}

-(NSString *)printableMotionRateInfo
{
	if( (self.deviceMotionData == nil) || (self.deviceMotionData.attitude == nil) )
		return @"- - -";

	//Motion rate - Fields 13, 14, 15
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
						  self.deviceMotionData.attitude.roll,
						  self.deviceMotionData.attitude.pitch,
						  self.deviceMotionData.attitude.yaw];
}

-(NSString *)printableCalibratedMagnetometerInfo
{
	if(self.deviceMotionData == nil)
		return @"- - -";

	//Calibrated magnetic field - Fields 1, 2, 3
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
			  self.deviceMotionData.magneticField.field.x,
			  self.deviceMotionData.magneticField.field.y,
			  self.deviceMotionData.magneticField.field.z];
}

-(NSString *)printableCalibratedAccelerometerInfo
{
	if(self.deviceMotionData == nil)
		return @"- - -";

	//Calibrated accelerometer - Fields 4, 5, 6
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
			  self.deviceMotionData.userAcceleration.x,
			  self.deviceMotionData.userAcceleration.y,
			  self.deviceMotionData.userAcceleration.z];
}

-(void)stopMotionMonitoring:(CMMotionManager *)motionMgr
{
	if([motionMgr isDeviceMotionActive] == TRUE)
		[motionMgr stopDeviceMotionUpdates];
}

-(BOOL)startMotionMonitoring:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr
{
	BOOL bRetStat = TRUE;

	if([motionMgr isDeviceMotionActive] == TRUE)
		return bRetStat;

	if ([motionMgr isDeviceMotionAvailable] == YES)
	{
		STMotionMonitor *__weak weakSelf = self;

		[motionMgr setDeviceMotionUpdateInterval:tmInterval];
		
		[motionMgr startDeviceMotionUpdatesUsingReferenceFrame:self.attitudeReferenceFrame toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
			[weakSelf updateMotionInfo:deviceMotion];
		}];
	}
	else
	{
		bRetStat = FALSE;
	}

	return bRetStat;
}

-(void)updateMotionInfo:(CMDeviceMotion *)motionData
{
	self.deviceMotionData = motionData;

	if(self.updateDelegate != nil)
		[self.updateDelegate motionDataUpdated:motionData];
}

@end
