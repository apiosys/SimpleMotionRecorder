/*
//  STActivityMonitor.h
//  SALTester
//
//  Created by Jeff Behrbaum on 2/24/15.
//  Copyright (c) 2015 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class CMMotionActivity;

@interface STActivityMonitor : NSObject
	@property(nonatomic, readonly) CMMotionActivity *currActivity;

	@property(nonatomic, readonly) BOOL bHasNativeMotionActivityDetection;

	@property(nonatomic, readonly) NSString *printableActivityInfo;

	/**
	 Stops listening for M7 activity updates provided by the CoreMotion
	 */
	-(void)stopActivityMonitoring;

	/**
	 Starts listening for M7 Activity updates from the CoreMotion.

	 @return True if the Activity services are available and the activity monitoring
			is successfully initialized. False otherwise.
	 */
	-(BOOL)startUpActivityMonitoring;

@end
