/*
//  STProximityMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 4/20/15.
//  Copyright (c) 2015 Apio Systems. All rights reserved.
*/


#import <UIKit/UIKit.h>

#import "STProximityMonitor.h"

@implementation STProximityMonitor

/**
 The actual Magnetometer as provided by Core Motion
 */
-(BOOL) latestProximityReading
{
	return [UIDevice currentDevice].proximityState;
}

-(void)stopProximitySensor
{
	[UIDevice currentDevice].proximityMonitoringEnabled = FALSE;
}

-(BOOL)startProximitySensor
{
	if([UIDevice currentDevice].proximityMonitoringEnabled == FALSE)
		[UIDevice currentDevice].proximityMonitoringEnabled = TRUE;

	return [UIDevice currentDevice].proximityMonitoringEnabled;
}

-(NSString *)printableProximityInfo
{
	return (self.latestProximityReading == TRUE) ? @"CloseProximity" : @"DistantProximity";
}

@end
