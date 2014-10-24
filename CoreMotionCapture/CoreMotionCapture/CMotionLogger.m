#import "CMotionLogger.h"
#import "CInfoQueue.h"
#import "CSensorSampleInfoContainer.h"

@interface CMotionLogger()
	@property(atomic) BOOL bFinishWritingData;
	@property(nonatomic, strong) NSCondition *semaphore;

	@property(nonatomic, strong) NSObject *mtxArrObj;
	@property(nonatomic, strong) NSObject *mtxFileObj;
	@property(nonatomic, strong) CInfoQueue *queEntries;
	@property(nonatomic, strong) NSThread *writingThread;
	@property(nonatomic, strong) NSFileHandle *fileHandle;
	@property(nonatomic, strong) NSMutableArray *arrAttitudeInfo;
	@property(nonatomic, strong) NSMutableArray *arrHashTableOfInfo;

	-(void)writeOutEntries;
	-(NSString *)retreiveCurrentFilePathAndName;
	-(NSData *)dataForFileWrite:(NSString *)dataString;
	-(NSFileHandle *)createAndOpenFileAtPath:(NSString *)path;
	-(BOOL)writeCurrentData:(CSensorSampleInfoContainer *)sensorInfo;
@end

@implementation CMotionLogger

@synthesize mtxArrObj = _mtxArrObj;
@synthesize semaphore = _semaphore;
@synthesize mtxFileObj = _mtxFileObj;
@synthesize fileHandle = _fileHandle;
@synthesize queEntries = _queEntries;
@synthesize logDelegate = _logDelegate;
@synthesize arrAttitudeInfo = _arrAttitudeInfo;
@synthesize arrHashTableOfInfo = _arrHashTableOfInfo;

-(NSObject *)mtxArrObj
{
	if(_mtxArrObj == nil)
		_mtxArrObj = [[NSObject alloc]init];
	
	return _mtxArrObj;
}

-(NSObject *)mtxFileObj
{
	if(_mtxFileObj == nil)
		_mtxFileObj = [[NSObject alloc]init];

	return _mtxFileObj;
}

-(NSCondition *)semaphore
{
	if(_semaphore == nil)
		_semaphore = [[NSCondition alloc]init];
	
	return _semaphore;
}

-(CInfoQueue *)queEntries
{
	if(_queEntries == nil)
		_queEntries = [[CInfoQueue alloc]init];

	return _queEntries;
}

-(NSMutableArray *)arrHashTableOfInfo
{
	if(_arrHashTableOfInfo == nil)
		_arrHashTableOfInfo = [[NSMutableArray alloc]init];

	return _arrHashTableOfInfo;
}

-(NSMutableArray *)arrAttitudeInfo
{
	if(_arrAttitudeInfo == nil)
		_arrAttitudeInfo = [[NSMutableArray alloc]init];
	
	return _arrAttitudeInfo;
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
	self.bFinishWritingData = FALSE;

	if(self.fileHandle != nil)
		[self.fileHandle closeFile];
	
	if( (self.arrHashTableOfInfo != nil) || (self.arrHashTableOfInfo.count > 0) )
		[self.arrHashTableOfInfo removeAllObjects];
	
	if( (self.arrAttitudeInfo != nil) || (self.arrAttitudeInfo.count > 0) )
		[self.arrAttitudeInfo removeAllObjects];

	self.fileHandle = [self createAndOpenFileAtPath:[self retreiveCurrentFilePathAndName]];
	
	self.writingThread = [[NSThread alloc] initWithTarget:self selector:@selector(writeOutEntries) object:nil];
	//[self.writingThread start];
}

-(void)finishWritingCurrentDataSet
{
	self.bFinishWritingData = TRUE;
//	[self.semaphore signal];
}

-(void)writeOutEntries
{
	[self.semaphore lock];

	while( ([[NSThread currentThread] isCancelled] == NO) && (self.bFinishWritingData == FALSE) )
	{
		[self.semaphore wait];

		@synchronized(self.mtxFileObj)
		{
			[self writeCurrentData:(CSensorSampleInfoContainer *)[self.queEntries dequeue]];
		}

		if(self.bFinishWritingData == TRUE)
		{
			BOOL bWriteStat = FALSE;

			do
			{
				@synchronized(self.mtxFileObj)
				{
					bWriteStat = [self writeCurrentData:(CSensorSampleInfoContainer *)[self.queEntries dequeue]];
				}
			}while (bWriteStat != FALSE);
		}
	}

	@synchronized(self.mtxFileObj)
	{
		[self.fileHandle closeFile];
		self.fileHandle = nil;
	}

	[self.semaphore unlock];

	if(self.logDelegate != nil)
		[self.logDelegate allDataWritten];
}

-(void)addSensorSample:(CSensorSampleInfoContainer *)sensorInfo
{
	if(sensorInfo == nil)
		return;
	
	@try
	{
		if([self writeCurrentData:sensorInfo] == FALSE)
			return;
	}
	@catch(NSException *exception)
	{
		NSLog(@"All jacked!: %@", exception.description);
	}
	@finally
	{}

//	[self.queEntries enqueue:sensorInfo];
//	[self.semaphore signal];
}

-(BOOL)writeCurrentData:(CSensorSampleInfoContainer *)sensorInfo
{
	if(sensorInfo == nil)
		return FALSE;

	NSData *fileData = [self dataForFileWrite:[sensorInfo printableString]];

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
	NSString *fileName = [NSString stringWithFormat:@"%@_log.txt", [fmtr stringFromDate:[NSDate date]]];
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
