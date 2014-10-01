#import "CMotionLogger.h"
#import "CMatrixInfo.h"
#import "CSensorSampleInfoContainer.h"

@interface CMotionLogger()

@property(nonatomic, strong) NSObject *mtxObj;
@property(nonatomic, strong) NSMutableArray *arrAttitudeInfo;

@end

@implementation CMotionLogger

@synthesize mtxObj = _mtxObj;
@synthesize arrAttitudeInfo = _arrAttitudeInfo;

-(NSObject *)mtxObj
{
	if(_mtxObj == nil)
		_mtxObj = [[NSObject alloc]init];
	
	return _mtxObj;
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

-(void)writeCurrentDataSet
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
	
	NSMutableArray *arrSensorData = nil;
	@synchronized(self.mtxObj)
	{
		arrSensorData = self.arrAttitudeInfo;
		_arrAttitudeInfo = nil;//So the next component goes into a different array
	}
	
	NSMutableString *strFileInfo = [[NSMutableString alloc]init];
	//save content to the documents directory
	for(CSensorSampleInfoContainer *sensorInfo in arrSensorData)
	{
		[strFileInfo appendString:[sensorInfo printableString]];
	}
	
	[strFileInfo writeToFile:fileName
					  atomically:NO
						 encoding:NSStringEncodingConversionAllowLossy
							 error:nil];
}

-(void)addSensorSample:(CSensorSampleInfoContainer *)sensorInfo
{
	if(sensorInfo == nil)
		return;
	
	@synchronized(self.mtxObj)
	{
		[self.arrAttitudeInfo addObject:sensorInfo];
	}
}


-(void)addMatrix:(CMatrixInfo *)matrixInfo
{
	if(matrixInfo == nil)
		return;
	
	@synchronized(self.mtxObj)
	{
		[self.arrAttitudeInfo addObject:matrixInfo];
	}
}

@end
