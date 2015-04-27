/*
//  STGpsMonitor.m
//  SALTester
//
//  Created by Jeff Behrbaum on 10/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <CoreLocation/CoreLocation.h>

#import "STGpsMonitor.h"

@interface STGpsMonitor()

@property(nonatomic, strong) CLLocationManager *locMgr;

@end

@implementation STGpsMonitor

@synthesize locMgr = _locMgr;

-(CLLocationManager *)locMgr
{
	if(_locMgr == nil)
		_locMgr = [[CLLocationManager alloc]init];
	
	return _locMgr;
}

-(CLLocation *)latestLocation
{
	return self.locMgr.location;
}

-(NSString *)printableLocationInfo
{
	if(self.locMgr.location == nil)
		return @"- - -";

	//Lat lon alt - Fields 7, 8, 9
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf",
			  self.locMgr.location.coordinate.latitude,
			  self.locMgr.location.coordinate.longitude,
			  self.locMgr.location.altitude];
}

-(NSString *)printableLocationMetaDataInfo
{
	if(self.locMgr.location == nil)
		return @"- - - - -";

	//... - Fields 19, 20, 21, 22, 23
	return [NSString stringWithFormat:@"%.5lf %.5lf %.5lf %.5lf 0.0",
			  [self.locMgr.location.timestamp timeIntervalSince1970],
			  self.locMgr.location.horizontalAccuracy,
			  self.locMgr.location.verticalAccuracy,
			  self.locMgr.location.speed];
}

-(void)stopGps
{
	[self.locMgr stopUpdatingLocation];
}

-(BOOL)startUpGps
{
	[self stopGps];

	BOOL bRetStat = TRUE;

	if([CLLocationManager locationServicesEnabled] == TRUE)
	{
		// Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
		if ([self.locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
			[self.locMgr requestAlwaysAuthorization];

		self.locMgr.delegate = self;
		self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
		[self.locMgr startUpdatingLocation];
	}
	else
	{
		bRetStat = FALSE;
	}

	return bRetStat;
}

-(void)startGpsInLowPowerMode
{
	[self stopGps];

	if([CLLocationManager locationServicesEnabled] == TRUE)
	{
		// Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
		if ([self.locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
			[self.locMgr requestAlwaysAuthorization];
		
		self.locMgr.delegate = self;
		[self.locMgr startMonitoringSignificantLocationChanges];
	}
}

/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{}

/*
 *  locationManager:didUpdateHeading:
 *
 *  Discussion:
 *    Invoked when a new heading is available.
*/
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	
}

/*
 *  locationManagerShouldDisplayHeadingCalibration:
 *
 *  Discussion:
 *    Invoked when a new heading is available. Return YES to display heading calibration info. The display
 *    will remain until heading is calibrated, unless dismissed early via dismissHeadingCalibrationDisplay.
 */
//- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	
}

/*
 *  locationManager:monitoringDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
 */
-(void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
				 withError:(NSError *)error
{}

/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{}

/*
 *  Discussion:
 *    Invoked when location updates are automatically paused.
 */
-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{}

/*
 *  Discussion:
 *    Invoked when location updates are automatically resumed.
 *
 *    In the event that your application is terminated while suspended, you will
 *	  not receive this notification.
 */
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
	
}

/*
 *  locationManager:didFinishDeferredUpdatesWithError:
 *
 *  Discussion:
 *    Invoked when deferred updates will no longer be delivered. Stopping
 *    location, disallowing deferred updates, and meeting a specified criterion
 *    are all possible reasons for finishing deferred updates.
 *
 *    An error will be returned if deferred updates end before the specified
 *    criteria are met (see CLError).
 */
- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error{}



@end
