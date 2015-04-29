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
#import "STSensorManager.h"

@interface CViewController ()

@property(nonatomic) BOOL bIsRunning;
@property(nonatomic, weak) IBOutlet UIButton *btnAtStop;
@property(nonatomic, weak) IBOutlet UIButton *btnStartMove;

@property(nonatomic, weak) IBOutlet UIButton *btnStopRecording;
@property(nonatomic, weak) IBOutlet UIButton *btnStartRecording;
@property (weak, nonatomic) IBOutlet UIButton *btnStartStopPhoneCall;
@property (weak, nonatomic) IBOutlet UIButton *btnStartStopGeneralHandling;

@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityWheel;

-(IBAction)onAtStop:(UIButton *)sender;
-(IBAction)onStartMove:(UIButton *)sender;

-(IBAction)onStopSensors:(UIButton *)sender;
-(IBAction)onStartSensors:(UIButton *)sender;
-(IBAction)onGeneralHandling:(UIButton *)sender;
-(IBAction)onPhoneCallSimulation:(UIButton *)sender;

@end

@implementation CViewController

@synthesize lblAppInfo = _lblAppInfo;
@synthesize bIsRunning = _bIsRunning;
@synthesize activityWheel = _activityWheel;
@synthesize btnStopRecording = _btnStopRecording;
@synthesize btnStartRecording = _btnStartRecording;

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
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[STSensorManager theSensorManager].deviceOrientation = [[UIDevice currentDevice] orientation];
}

//The return/done button on the keyboard was selected
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	const char LF = 10;
	
	if( (text == nil) || (text.length < 1) )
		return TRUE;
	
	if([text characterAtIndex:0] == LF)
	{
		if(self.bIsRunning == TRUE)
			[[CMotionLogger theLogger] logTexting:FALSE];

		textView.text = @"Start Your Texting";
		[textView resignFirstResponder];
	}

	return TRUE;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if(self.bIsRunning == TRUE)
		[[CMotionLogger theLogger] logTexting:TRUE];

	textView.text = nil;
	return TRUE;
}

-(IBAction)onAtStop:(UIButton *)sender
{
	[[CMotionLogger theLogger] logStartStopMoving:TRUE];
}

-(IBAction)onStartMove:(UIButton *)sender
{
	[[CMotionLogger theLogger] logStartStopMoving:FALSE];
}

-(IBAction)onPhoneCallSimulation:(UIButton *)sender
{
	if(self.bIsRunning == FALSE)
		return;

	static NSString * const stopPhoneCall = @"Stop Phone Call";
	static NSString * const startPhoneCall = @"Start Phone Call";
	
	if([sender.currentTitle caseInsensitiveCompare:startPhoneCall] == NSOrderedSame)
	{
		[[CMotionLogger theLogger]logPhoneCall:TRUE];
		[sender setTitle:stopPhoneCall forState:UIControlStateNormal];
	}
	else
	{
		[[CMotionLogger theLogger]logPhoneCall:FALSE];
		[sender setTitle:startPhoneCall forState:UIControlStateNormal];
	}
}

-(IBAction)onGeneralHandling:(UIButton *)sender
{
	if(self.bIsRunning == FALSE)
		return;
	
	static NSString * const stopGeneralHandling = @"Stop General Handling";
	static NSString * const startGeneralHandling = @"Start General Handling";
	
	if([sender.currentTitle caseInsensitiveCompare:startGeneralHandling] == NSOrderedSame)
	{
		[[CMotionLogger theLogger]logGeneralHandling:TRUE];
		[sender setTitle:stopGeneralHandling forState:UIControlStateNormal];
	}
	else
	{
		[[CMotionLogger theLogger]logGeneralHandling:FALSE];
		[sender setTitle:startGeneralHandling forState:UIControlStateNormal];
	}	
}

-(IBAction)onStartSensors:(UIButton *)sender
{
	if(self.bIsRunning == TRUE)
		return;

	self.btnAtStop.backgroundColor =
	self.btnStartMove.backgroundColor =
	self.btnStopRecording.backgroundColor =
	self.btnStartRecording.backgroundColor =
	self.btnStartStopPhoneCall.backgroundColor =
	self.btnStartStopGeneralHandling.backgroundColor = [UIColor colorWithRed:21.0 / 255.0 green:126.0 / 255.0 blue:251.0 / 255.0 alpha:1.0];

	//Before anything else happens - mark the start recording time!
	CSensorSampleInfoContainer.startRecTime = [NSDate date];

	[[CMotionLogger theLogger] markAsStartDataCaptureTime];

	if ([[STSensorManager theSensorManager] startSensors] == FALSE)
		NSLog(@"Failed to start all the sensors");

	self.bIsRunning = TRUE;
}

-(IBAction)onStopSensors:(UIButton *)sender
{
	if(self.bIsRunning == FALSE)
		return;

	self.btnAtStop.backgroundColor =
	self.btnStartMove.backgroundColor =
	self.btnStopRecording.backgroundColor =
	self.btnStartRecording.backgroundColor =
	self.btnStartStopPhoneCall.backgroundColor =
	self.btnStartStopGeneralHandling.backgroundColor = [UIColor colorWithRed:127.0 / 255.0 green:127.0 / 255.0 blue:127.0 / 255.0 alpha:1.0];

	[self.activityWheel startAnimating];
	self.btnStopRecording.enabled = self.btnStartRecording.enabled = FALSE;

	self.bIsRunning = FALSE;

	[[STSensorManager theSensorManager] stopSensors];

	[self.activityWheel stopAnimating];
	self.btnStopRecording.enabled = self.btnStartRecording.enabled = TRUE;
}

@end
