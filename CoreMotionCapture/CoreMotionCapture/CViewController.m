/*
//  CViewController.m
//  CoreMotionCapture
//
//  Created by Jeff Behrbaum on 7/14/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Coremotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "CViewController.h"
#import "CAppDelegate.h"
#import "CMatrixInfo.h"
#import "CMotionLogger.h"

#import "CSensorSampleInfoContainer.h"

@interface CViewController ()

@property(nonatomic, strong) CSensorSampleInfoContainer *currSample;

@property (weak, nonatomic) IBOutlet UITextField *txtvwMotion;
@property (weak, nonatomic) IBOutlet UITextField *txtvwAccel;
@property (weak, nonatomic) IBOutlet UITextField *txtvwGyro;

-(void)updateGyro:(double)x Y:(double)y Z:(double)z;

-(void)updateMotionInfo:(CMDeviceMotion *)motionData;
-(void)updateAccelerometer:(CMAccelerometerData *)accelerometerData;

-(void)updateMotion:(double)UserAccelX uaY:(double)UserAccelY uaZ:(double)UserAccelZ
					 grX:(double)gravityX grY:(double)gravityY grZ:(double)gravityZ
					 rtX:(double)rotationX rtY:(double)rotationY rtZ:(double)rotationZ
					roll:(double)Roll pitch:(double)Pitch yaw:(double)Yaw
		 attitudeInfo:(CMAttitude *)cmAttitude;

-(IBAction)onStart:(UIButton *)sender;
-(IBAction)onStop:(UIButton *)sender forEvent:(UIEvent *)event;

@end

@implementation CViewController

@synthesize txtvwGyro = _txtvwGyro;
@synthesize currSample = _currSample;
@synthesize txtvwAccel = _txtvwAccel;
@synthesize txtvwMotion = _txtvwMotion;

-(CSensorSampleInfoContainer *)currSample
{
	if(_currSample == nil)
		_currSample = [[CSensorSampleInfoContainer alloc]init];
	
	return _currSample;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onStart:(UIButton *)sender
{
	//NSTimeInterval delta = 0.005;
	NSTimeInterval updateInterval = 0.03125;// + delta * 0.05;

	CViewController * __weak weakSelf = self;
	
	CLLocationManager *locationManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedLocationManger];
	CMMotionManager *motionManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];

	if([CLLocationManager locationServicesEnabled] == TRUE)
	{
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
	}
	
	if ([motionManager isAccelerometerAvailable] == YES)
	{
		[motionManager setAccelerometerUpdateInterval:updateInterval];
		
		[motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
			[weakSelf updateAccelerometer:accelerometerData];
		}];
	}
	
	if ([motionManager isDeviceMotionAvailable] == YES)
	{
		[motionManager setDeviceMotionUpdateInterval:updateInterval];
		[motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
			[weakSelf updateMotionInfo:deviceMotion];
		}];
	}

	if ([motionManager isGyroAvailable] == YES)
	{
		[motionManager setGyroUpdateInterval:updateInterval];
		[motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error){
			[weakSelf updateGyro:gyroData.rotationRate.x Y:gyroData.rotationRate.y Z:gyroData.rotationRate.z];
		}];
	}
}

-(IBAction)onStop:(UIButton *)sender forEvent:(UIEvent *)event
{
	CLLocationManager *locationManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedLocationManger];
	CMMotionManager *mManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];

	if ([mManager isDeviceMotionActive] == YES)
		[mManager stopDeviceMotionUpdates];

	if ([mManager isAccelerometerActive] == YES)
		[mManager stopAccelerometerUpdates];

	if ([mManager isGyroActive] == YES)
		[mManager stopGyroUpdates];

	[locationManager stopUpdatingLocation];

	//Stop everything before you get here
	CMotionLogger *logger = [CMotionLogger theLogger];
	
	[logger writeCurrentDataSet];
}

-(void)updateGyro:(double)x Y:(double)y Z:(double)z
{
	self.txtvwGyro.text = [NSString stringWithFormat:@"X: %.2lf - Y: %.2lf - Z: %.2lf", x, y, z];
}

#pragma mark - GPS Delegate update location 

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	if( (locations == nil) || (locations.count <= 0) )
		return;

	CLLocation *currLoc = [locations lastObject];
	
	self.currSample.locationData = currLoc;
}

-(void)updateAccelerometer:(CMAccelerometerData *)accelerometerData
{
	self.txtvwAccel.text = [NSString stringWithFormat:@"X: %.2lf - Y: %.2lf - Z: %.2lf", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z];

	self.currSample.rawAcceleration = accelerometerData;
	
	CMotionLogger *logger = [CMotionLogger theLogger];
	[logger addSensorSample:self.currSample];

	CSensorSampleInfoContainer *tmp = self.currSample;
	self.currSample = nil;//Loose the pointer to the logger

	//We keep the most recent samples around
	self.currSample.motionData = tmp.motionData;
	self.currSample.locationData = tmp.locationData;
}

-(void)updateMotionInfo:(CMDeviceMotion *)motionData
{
	self.currSample.motionData = motionData;
}

/*
//[weakSelf updateMotion:deviceMotion.userAcceleration.x uaY:deviceMotion.userAcceleration.y uaZ:deviceMotion.userAcceleration.z
//						 grX:deviceMotion.gravity.x grY:deviceMotion.gravity.y grZ:deviceMotion.gravity.z
//						 rtX:deviceMotion.rotationRate.x rtY:deviceMotion.rotationRate.y rtZ:deviceMotion.rotationRate.z
//						roll:deviceMotion.attitude.roll pitch:deviceMotion.attitude.pitch yaw:deviceMotion.attitude.yaw
//			 attitudeInfo:deviceMotion.attitude];
*/
-(void)updateMotion:(double)UserAccelX uaY:(double)UserAccelY uaZ:(double)UserAccelZ
					 grX:(double)gravityX grY:(double)gravityY grZ:(double)gravityZ
					 rtX:(double)rotationX rtY:(double)rotationY rtZ:(double)rotationZ
					roll:(double)Roll pitch:(double)Pitch yaw:(double)Yaw attitudeInfo:(CMAttitude *)cmAttitude
{
	self.txtvwGyro.text = [NSString stringWithFormat:@"Yaw: %.2lf - Ptc: %.2lf - RL: %.2lf", Yaw, Pitch, Roll];
	
	CMotionLogger *logger = [CMotionLogger theLogger];

	CMatrixInfo *latestInfo = [[CMatrixInfo alloc]init];

	latestInfo.cmAtt = cmAttitude;

	latestInfo.dYaw = Yaw;
	latestInfo.dRoll = Roll;
	latestInfo.dPitch = Pitch;

	latestInfo.dRotationRateX = rotationX;
	latestInfo.dRotationRateY = rotationY;
	latestInfo.dRotationRateZ = rotationZ;

	latestInfo.dGravityX = gravityX;
	latestInfo.dGravityY = gravityY;
	latestInfo.dGravityZ = gravityZ;

	latestInfo.dUserAccelerationX = UserAccelX;
	latestInfo.dUserAccelerationY = UserAccelY;
	latestInfo.dUserAccelerationZ = UserAccelZ;

	[logger addMatrix:latestInfo];
}

@end
