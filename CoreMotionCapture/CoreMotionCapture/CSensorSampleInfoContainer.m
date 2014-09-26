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

@end

@implementation CSensorSampleInfoContainer

@synthesize dtFmtr = _dtFmtr;
@synthesize motionData = _motionData;
@synthesize locationData = _locationData;
@synthesize rawAcceleration = _rawAcceleration;

-(NSDateFormatter *)dtFmtr
{
	if(_dtFmtr == nil)
	{
		_dtFmtr = [[NSDateFormatter alloc]init];
		[_dtFmtr setDateStyle:NSDateFormatterShortStyle];
		[_dtFmtr setTimeStyle:NSDateFormatterShortStyle];
	}

	return _dtFmtr;
}

-(NSString *)printableString
{
	NSString *strInfo;
	
	NSString *strMotion;
	NSString *strLocation;
	NSString *strAcceleration;

	if(self.locationData != nil)
		strLocation = [NSString stringWithFormat:@"%@ %.5lf %.5lf %.5lf", [self.dtFmtr stringFromDate:self.locationData.timestamp], self.locationData.coordinate.latitude, self.locationData.coordinate.longitude, self.locationData.speed];

	if(self.rawAcceleration != nil)
		strAcceleration = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.rawAcceleration.acceleration.x, self.rawAcceleration.acceleration.y, self.rawAcceleration.acceleration.z];

	if(self.motionData != nil)
		strMotion = [NSString stringWithFormat:@"%.5lf %.5lf %.5lf", self.motionData.attitude.roll, self.motionData.attitude.pitch, self.motionData.attitude.yaw];

	strInfo = [NSString stringWithFormat:@"%@ %@ %@\n", strLocation, strAcceleration, strMotion];

	return strInfo;
}

@end
