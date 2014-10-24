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

#import "CSensorSampleInfoContainer.h"

@interface CViewController ()

@property(nonatomic) BOOL bIsRunning;
@property(nonatomic, weak) IBOutlet UIButton *btnStopRecording;
@property(nonatomic, weak) IBOutlet UIButton *btnStartRecording;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityWheel;
@property(nonatomic, strong) CSensorSampleInfoContainer *currSample;

@property (nonatomic) CMAttitudeReferenceFrame attitudeReferenceFrame;
@property(nonatomic, readonly) NSTimeInterval updateInterval;
@property (weak, nonatomic) IBOutlet UITextField *txtvwMotion;
@property (weak, nonatomic) IBOutlet UITextField *txtvwAccel;
@property (weak, nonatomic) IBOutlet UITextField *txtvwGyro;
@property (weak, nonatomic) IBOutlet UITextField *txtvwLocation;

-(void)updateGyro:(CMGyroData *)gyroData;
-(void)updateMotionInfo:(CMDeviceMotion *)motionData;
-(void)updateMagnetrometer:(CMMagnetometerData *)magData;
-(void)updateAccelerometer:(CMAccelerometerData *)accelerometerData;

-(void)configureGyro:(CViewController *)vc;
-(void)configureMotion:(CViewController *)vc;
-(void)configureLocationGps:(CViewController *)vc;
-(void)configureMagnetometer:(CViewController *)vc;
-(void)configureAccelerometer:(CViewController *)vc;

-(IBAction)onStart:(UIButton *)sender;
-(IBAction)onStop:(UIButton *)sender forEvent:(UIEvent *)event;

@end

@implementation CViewController

@synthesize txtvwGyro = _txtvwGyro;
@synthesize lblAppInfo = _lblAppInfo;
@synthesize currSample = _currSample;
@synthesize txtvwAccel = _txtvwAccel;
@synthesize bIsRunning = _bIsRunning;
@synthesize txtvwMotion = _txtvwMotion;
@synthesize activityWheel = _activityWheel;
@synthesize txtvwLocation = _txtvwLocation;
@synthesize btnStopRecording = _btnStopRecording;
@synthesize btnStartRecording = _btnStartRecording;
@synthesize attitudeReferenceFrame = _attitudeReferenceFrame;

-(NSTimeInterval) updateInterval
{
	//NSTimeInterval delta = 0.005;
	//NSTimeInterval updateInterval = 0.03125;// + delta * 0.05;
	return 0.03125;// + delta * 0.05;
}

-(CSensorSampleInfoContainer *)currSample
{
	if(_currSample == nil)
		_currSample = [[CSensorSampleInfoContainer alloc]init];
	
	return _currSample;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	NSString *bundleName = [[NSBundle mainBundle] bundleIdentifier];
	
	id localizedValue = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *strVersion =  (localizedValue != nil) ? localizedValue : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	
	NSString *strVer = [NSString stringWithFormat:@"Ver: %@", strVersion];
	NSString *strName = [[bundleName componentsSeparatedByString:@"."] lastObject];

	self.lblAppInfo.text = [NSString stringWithFormat:@"%@ - %@", strName, strVer];
	
	// Do any additional setup after loading the view, typically from a nib.
	self.bIsRunning = FALSE;
	
	self.attitudeReferenceFrame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
}

-(IBAction)onStart:(UIButton *)sender
{
	if(self.bIsRunning == TRUE)
		return;

	//Before anything else happens - mark the start recording time!
	CSensorSampleInfoContainer.startRecTime = [NSDate date];

	[CMotionLogger theLogger].logDelegate = self;
	[[CMotionLogger theLogger] markAsStartDataCaptureTime];

	self.bIsRunning = TRUE;
	CViewController * __weak weakSelf = self;

	[self configureLocationGps:nil];

	[self configureGyro:weakSelf];
	[self configureMotion:weakSelf];
	[self configureMagnetometer:weakSelf];

	//Initialize last since once this updates, we save the record. This is just to
	//increase our chances all the other data will be populated before an acceleration
	//update. It doesn't really matter, but it just may allow for a clean first record.
	[self configureAccelerometer:weakSelf];
}

-(IBAction)onStop:(UIButton *)sender forEvent:(UIEvent *)event
{
	if(self.bIsRunning == FALSE)
		return;

	[self.activityWheel startAnimating];
	self.btnStopRecording.enabled = self.btnStartRecording.enabled = FALSE;

	self.bIsRunning = FALSE;

	CLLocationManager *locationManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedLocationManger];
	CMMotionManager *mManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];

	if ([mManager isDeviceMotionActive] == YES)
		[mManager stopDeviceMotionUpdates];

	if ([mManager isAccelerometerActive] == YES)
		[mManager stopAccelerometerUpdates];

	if ([mManager isGyroActive] == YES)
		[mManager stopGyroUpdates];

	if([mManager isMagnetometerActive] == YES)
		[mManager stopMagnetometerUpdates];

	[locationManager stopUpdatingLocation];

	//Stop everything before you get here
	CMotionLogger *logger = [CMotionLogger theLogger];
	[logger finishWritingCurrentDataSet];

	self.txtvwAccel.text = self.txtvwGyro.text = self.txtvwLocation.text = self.txtvwMotion.text = nil;
}

#pragma mark - Configure the sensor capturing.

-(void)configureGyro:(CViewController *)vc
{
	CMMotionManager *motionManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];

	if ([motionManager isGyroAvailable] == YES)
	{
		[motionManager setGyroUpdateInterval:self.updateInterval];
		[motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error){
			[vc updateGyro:gyroData];
		}];
	}
}

-(void)configureMotion:(CViewController *)vc
{
	CMMotionManager *motionManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];

	if ([motionManager isDeviceMotionAvailable] == YES)
	{
		[motionManager setDeviceMotionUpdateInterval:self.updateInterval];

		[motionManager startDeviceMotionUpdatesUsingReferenceFrame:self.attitudeReferenceFrame toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
			[vc updateMotionInfo:deviceMotion];
		}];
	}
}

-(void)configureLocationGps:(CViewController *)vc
{
	CLLocationManager *locationManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedLocationManger];

	if([CLLocationManager locationServicesEnabled] == TRUE)
	{
		// Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
		if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
			[locationManager requestAlwaysAuthorization];

		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
	}
}

-(void)configureMagnetometer:(CViewController *)vc
{
	CMMotionManager *motionManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];
	
	if([motionManager isMagnetometerAvailable] == TRUE)
	{
		[motionManager setMagnetometerUpdateInterval:self.updateInterval];
		
		[motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
			[vc updateMagnetrometer:magnetometerData];
		}];
	}
	
}

-(void)configureAccelerometer:(CViewController *)vc
{
	CMMotionManager *motionManager = [(CAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];
	
	if ([motionManager isAccelerometerAvailable] == YES)
	{
		[motionManager setAccelerometerUpdateInterval:self.updateInterval];
		
		[motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
			[vc updateAccelerometer:accelerometerData];
		}];
	}
	
}

#pragma mark - Device Delegate update block calls

-(void)updateGyro:(CMGyroData *)gyroData
{
	if(self.bIsRunning == FALSE)
		return;

	self.currSample.gyroData = gyroData;
	self.txtvwGyro.text = [NSString stringWithFormat:@"X - %.5lf Y - %.5lf Z - %.5lf", gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z];
}

-(void)updateMagnetrometer:(CMMagnetometerData *)magData
{
	if(self.bIsRunning == FALSE)
		return;

	self.currSample.magnetrometerData = magData;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	if(self.bIsRunning == FALSE)
		return;

	if( (locations == nil) || (locations.count <= 0) )
		return;

	CLLocation *currLoc = [locations lastObject];

	self.currSample.locationData = currLoc;

	self.txtvwLocation.text = [NSString stringWithFormat:@"%.5lf %.5lf", currLoc.coordinate.latitude, currLoc.coordinate.longitude];
}

-(void)updateAccelerometer:(CMAccelerometerData *)accelerometerData
{
	if(self.bIsRunning == FALSE)
		return;

	self.txtvwAccel.text = [NSString stringWithFormat:@"X: %.2lf - Y: %.2lf - Z: %.2lf", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z];
	
	self.currSample.dateOfRecord = [NSDate date];//Date is set when accelerometer data is retreived
	self.currSample.rawAcceleration = accelerometerData;

	CMotionLogger *logger = [CMotionLogger theLogger];
	[logger addSensorSample:self.currSample];
	
	CSensorSampleInfoContainer *tmp = self.currSample;
	self.currSample = nil;//Loose the pointer to the logger - be sure to call the constructor again.
	
	//We keep the most recent samples around
	self.currSample.gyroData = tmp.gyroData;
	self.currSample.motionData = tmp.motionData;
	self.currSample.locationData = tmp.locationData;
	self.currSample.magnetrometerData = tmp.magnetrometerData;
}

-(void)updateMotionInfo:(CMDeviceMotion *)motionData
{
	if(self.bIsRunning == FALSE)
		return;

	self.currSample.motionData = motionData;

	self.txtvwMotion.text = [NSString stringWithFormat:@"X: %.2lf - Y: %.2lf - Z: %.2lf", motionData.magneticField.field.x, motionData.magneticField.field.y, motionData.magneticField.field.z];
	//self.txtvwMotion.text = [NSString stringWithFormat:@"X: %.2lf - Y: %.2lf - Z: %.2lf", motionData.gravity.x, motionData.gravity.y, motionData.gravity.z];
}

#pragma mark - when all data has been written

-(void)allDataWritten
{
	if([NSThread isMainThread] == FALSE)
	{
		[self performSelectorOnMainThread:@selector(allDataWritten) withObject:nil waitUntilDone:FALSE];
		return;
	}

	NSLog(@"All data written");
	[self.activityWheel stopAnimating];
	self.btnStopRecording.enabled = self.btnStartRecording.enabled = TRUE;
}


@end
