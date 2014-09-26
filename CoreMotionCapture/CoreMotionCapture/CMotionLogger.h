#import <Foundation/Foundation.h>

@class CMatrixInfo;
@class CSensorSampleInfoContainer;

@interface CMotionLogger : NSObject

+(CMotionLogger *)theLogger;

-(void)writeCurrentDataSet;
-(void)addMatrix:(CMatrixInfo *)matrixInfo;
-(void)addSensorSample:(CSensorSampleInfoContainer *)sensorInfo;


@end
