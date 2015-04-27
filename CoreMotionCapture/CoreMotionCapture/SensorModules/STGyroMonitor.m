/*
//  STGyroMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <CoreMotion/CoreMotion.h>
#import "STGyroMonitor.h"

@interface STGyroMonitor()

@property(nonatomic, strong) CMGyroData *gyroData;

@end

@implementation STGyroMonitor

@synthesize gyroData = _gyroData;

-(CMGyroData *)latestGyroData
{
	return self.gyroData;
}

-(NSString *)printableGyroInfo
{
	if(self.gyroData == nil)
		return @"- - -";

	//Rate - Fields, 10, 11, 12
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
			  self.gyroData.rotationRate.x,
			  self.gyroData.rotationRate.y,
			  self.gyroData.rotationRate.z];
}

-(void)stopGyro:(CMMotionManager *)motionMgr
{
	if ([motionMgr isGyroActive] == YES)
		[motionMgr stopGyroUpdates];
}

-(BOOL)startGyro:(NSTimeInterval)tmInterval motion:(CMMotionManager *)motionMgr
{
	BOOL bRetStat = TRUE;
	
	if([motionMgr isGyroActive] == TRUE)
		return bRetStat;

	if ([motionMgr isGyroAvailable] == YES)
	{
		STGyroMonitor * __weak weakSelf = self;

		[motionMgr setGyroUpdateInterval:tmInterval];
		[motionMgr startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error){
			[weakSelf updateGyro:gyroData];
		}];
	}
	else
	{
		bRetStat = FALSE;
	}

	return bRetStat;
}

-(void)updateGyro:(CMGyroData *)gyroData
{
	self.gyroData = gyroData;
}


@end
