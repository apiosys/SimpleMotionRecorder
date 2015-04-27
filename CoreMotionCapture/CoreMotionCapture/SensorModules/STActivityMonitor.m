/*
//  STActivityMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 2/24/15.
//  Copyright (c) 2015 Apio Systems. All rights reserved.
*/

#import <CoreMotion/CoreMotion.h>

#import "STActivityMonitor.h"

@interface STActivityMonitor()
	@property(nonatomic, strong) CMMotionActivity *latestActivity;
	@property(nonatomic, strong) CMMotionActivityManager *activityManager;

	-(void)onMotionActivity:(CMMotionActivity *)activity;
@end

@implementation STActivityMonitor

@synthesize latestActivity = _latestActivity;
@synthesize activityManager = _activityManager;

-(BOOL)bHasNativeMotionActivityDetection
{
	return [CMMotionActivityManager isActivityAvailable];
}

-(CMMotionActivity *)currActivity
{
	@synchronized(self)
	{
		return self.latestActivity;
	}
}

-(NSString *)printableActivityInfo
{
	if(self.latestActivity == nil)
		return @"-:-";
	
	NSString *strConfidence = @"UnknownConfidence";
	switch (self.latestActivity.confidence)
	{
		case CMMotionActivityConfidenceLow:
			strConfidence = @"LowConfidence";
			break;
		case CMMotionActivityConfidenceMedium:
			strConfidence = @"MedConfidence";
			break;
		case CMMotionActivityConfidenceHigh:
			strConfidence = @"HighConfidence";
			break;
		default:
			break;
	}
	
	NSString *strEvent= @":";
	
	if(self.latestActivity.unknown)
		strEvent = [strEvent stringByAppendingString:@"EventUnknown"];
	
	if(self.latestActivity.stationary)
		strEvent = [strEvent stringByAppendingString:@"EventStationary"];
	
	if(self.latestActivity.walking)
		strEvent = [strEvent stringByAppendingString:@"EventWalking"];
	
	if(self.latestActivity.running)
		strEvent = [strEvent stringByAppendingString:@"EventRunning"];
	
	if(self.latestActivity.cycling)
		strEvent = [strEvent stringByAppendingString:@"EventCycling"];
	
	if(self.latestActivity.automotive)
		strEvent = [strEvent stringByAppendingString:@"EventAutomotive"];

	return [NSString stringWithFormat:@"%@%@", strConfidence, strEvent];
}


-(void)stopActivityMonitoring
{
	if(self.activityManager == nil)
		return;//Not much to do.

	[self.activityManager stopActivityUpdates];
	self.activityManager = nil;
}

-(BOOL)startUpActivityMonitoring
{
	if([CMMotionActivityManager isActivityAvailable] == FALSE)
		return FALSE;

	if(self.activityManager != nil)
		return TRUE;//Means you've already started up your activity monitoring.

	self.activityManager = [[CMMotionActivityManager alloc]init];

	STActivityMonitor *__weak weakSelf = self;

	[self.activityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
		[weakSelf onMotionActivity:activity];
	}];

	return TRUE;
}

-(void)onMotionActivity:(CMMotionActivity *)activity
{
	@synchronized(self)
	{
		self.latestActivity = activity;
		
		//if(isLoggingAllowed() == true)
		//	[self activityToString:activity];
	}
}

@end
