#import <Foundation/Foundation.h>

@class CSensorSampleInfoContainer;

@protocol PLogerDelegate <NSObject>
@required
	-(void)allDataWritten;

@end

@interface CMotionLogger : NSObject

@property(nonatomic, strong) id<PLogerDelegate> logDelegate;

+(CMotionLogger *)theLogger;

-(void)finishWritingCurrentDataSet;
-(void)markAsStartDataCaptureTime;//Used to name the log file
-(void)addSensorSample:(CSensorSampleInfoContainer *)sensorInfo;


@end
