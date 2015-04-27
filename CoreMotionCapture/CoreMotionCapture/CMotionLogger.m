#import "CMotionLogger.h"
#import "CSensorSampleInfoContainer.h"
#import "STSensorManager.h"

@interface CMotionLogger()
	@property(nonatomic, strong) NSDateFormatter *dtFmtr;
	@property(nonatomic, strong) NSFileHandle *fileHandle;
	@property(nonatomic, strong) NSString *deviceNameStr;

	-(NSString *)retreiveCurrentFilePathAndName;
	-(NSData *)dataForFileWrite:(NSString *)dataString;
	-(NSFileHandle *)createAndOpenFileAtPath:(NSString *)path;
	-(BOOL)writeCurrentData:(NSString *)sensorInfo;
@end

@implementation CMotionLogger

@synthesize fileHandle = _fileHandle;

-(NSDateFormatter *)dtFmtr
{
	if(_dtFmtr == nil)
	{
		_dtFmtr = [[NSDateFormatter alloc]init];
		[_dtFmtr setDateFormat:@"yyyyMMdd HHmmss.SSS"];
	}
	
	return _dtFmtr;
}

-(NSString *)deviceNameStr
{
	if(_deviceNameStr == nil)
	{
		NSCharacterSet *unallowedFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"_'\":*&^%$#@!~`<>?/\\{}[]=+ "];
		_deviceNameStr = [[[UIDevice currentDevice].name componentsSeparatedByCharactersInSet:unallowedFileNameCharacters] componentsJoinedByString:@""];
	}

	return _deviceNameStr;
}

+(CMotionLogger *)theLogger
{
	static CMotionLogger *loggerMgr;
	
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		loggerMgr = [[CMotionLogger alloc] init];
	});
	
	return loggerMgr;
}

-(void)markAsStartDataCaptureTime
{
	if(self.fileHandle != nil)
		[self.fileHandle closeFile];

	self.fileHandle = [self createAndOpenFileAtPath:[self retreiveCurrentFilePathAndName]];
}

-(void)logTexting:(BOOL)bIsStarting
{
	NSString *eventStr = @"EVENT:Texting:";
	eventStr = [eventStr stringByAppendingString:[NSString stringWithFormat:@"%@\n", (bIsStarting == TRUE) ? @"STARTED" : @"STOPPED"]];
	
	@try
	{
		if([self writeCurrentData:eventStr] == FALSE)
			NSLog(@"Error writing the texting information");
	}
	@catch (NSException *exception)
	{
		NSLog(@"Execption on write attempt: %@", exception.debugDescription);
	}
}

-(void)logPhoneCall:(BOOL)bIsStarting
{
	NSString *eventStr = @"EVENT:PhoneCall:";
	eventStr = [eventStr stringByAppendingString:[NSString stringWithFormat:@"%@\n", (bIsStarting == TRUE) ? @"STARTED" : @"STOPPED"]];
	
	@try
	{
		if([self writeCurrentData:eventStr] == FALSE)
			NSLog(@"Error writing the Phone Call information");
	}
	@catch (NSException *exception)
	{
		NSLog(@"Execption on write attempt: %@", exception.debugDescription);
	}
}

-(void)logGeneralHandling:(BOOL)bIsStarting
{
	NSString *eventStr = @"EVENT:GeneralHandling:";
	eventStr = [eventStr stringByAppendingString:[NSString stringWithFormat:@"%@\n", (bIsStarting == TRUE) ? @"STARTED" : @"STOPPED"]];
	
	@try
	{
		if([self writeCurrentData:eventStr] == FALSE)
			NSLog(@"Error writing the Phone Call information");
	}
	@catch (NSException *exception)
	{
		NSLog(@"Execption on write attempt: %@", exception.debugDescription);
	}
}

-(void)writeCurrentSamplesToLogFile
{
	STSensorManager *sensorMgr = [STSensorManager theSensorManager];
	
	@try
	{
		[self writeCurrentData:[sensorMgr printableString:[self.dtFmtr stringFromDate:[NSDate date]]]];
	}
	@catch (NSException *exception)
	{
		NSLog(@"Execption on write attempt: %@", exception.debugDescription);
	}
}

-(BOOL)writeCurrentData:(NSString *)sensorInfo
{
	if(sensorInfo == nil)
		return FALSE;

	NSData *fileData = [self dataForFileWrite:sensorInfo];

	BOOL bRetStat = TRUE;
	if(self.fileHandle != nil)
		[self.fileHandle writeData:fileData];
	else
		return bRetStat;
	
	return bRetStat;
}

-(NSString *)retreiveCurrentFilePathAndName
{
	//get the documents directory:
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	NSString *documentsDirectory = [paths objectAtIndex:0];

	NSLocale *usLocal = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	NSDateFormatter *fmtr = [[NSDateFormatter alloc]init];
	[fmtr setDateFormat:@"yyyy-MM-dd-HHmmss"];
	[fmtr setLocale:usLocal];

	//make a file name to write the data to using the documents directory:
	NSString *fileName = [NSString stringWithFormat:@"%@_%@_log.txt", self.deviceNameStr, [fmtr stringFromDate:[NSDate date]]];
	fileName = [documentsDirectory stringByAppendingPathComponent:fileName];

	return fileName;
}

-(NSData *)dataForFileWrite:(NSString *)dataString
{
	NSData *fileData;

	@try
	{
		//Making a copy of the string because there were several instances of
		//"writeData" exceptions with the data string.
		NSString *strDataCopy = [NSString stringWithFormat:@"%@", dataString];
	
		if([strDataCopy canBeConvertedToEncoding:NSUTF8StringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUTF8StringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSASCIIStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSASCIIStringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSISOLatin1StringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSISOLatin1StringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUnicodeStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUnicodeStringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUTF16BigEndianStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUTF16BigEndianStringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUTF16LittleEndianStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUTF32StringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUTF32StringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUnicodeStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUnicodeStringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUTF32BigEndianStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUTF32BigEndianStringEncoding];
		else if([strDataCopy canBeConvertedToEncoding:NSUTF32LittleEndianStringEncoding] == TRUE)
			fileData = [strDataCopy dataUsingEncoding:NSUTF32LittleEndianStringEncoding];
		else
			fileData = nil;
	}
	@catch (NSException *exception)
	{
		fileData = nil;
	}
	@finally
	{}
	
	return fileData;
}

-(NSFileHandle *)createAndOpenFileAtPath:(NSString *)path
{
	BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
	
	if (! fileCreated)
	{
		NSLog(@"Path: %@", path);
		NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
		return nil;
	}
	
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
	
	if (fileHandle == nil)
		return nil;
	
	return fileHandle;
}

@end
