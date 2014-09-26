/*
//  CSensorSampleInfoContainer.h
//  CoreMotionCapture
//
//  Created by Jeff Behrbaum on 9/26/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class CLLocation;
@class CMDeviceMotion;
@class CMAccelerometerData;

@interface CSensorSampleInfoContainer : NSObject

@property(nonatomic, strong) CLLocation *locationData;
@property(nonatomic, strong) CMDeviceMotion *motionData;
@property(nonatomic, strong) CMAccelerometerData *rawAcceleration;

-(NSString *)printableString;

@end
