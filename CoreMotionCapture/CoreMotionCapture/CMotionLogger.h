#import <Foundation/Foundation.h>

@class CSensorSampleInfoContainer;

@interface CMotionLogger : NSObject

+(CMotionLogger *)theLogger;

-(void)logStartStopMoving:(BOOL)bIsAtStop;//If bIsAtStop == FALSE, it means you're moving

/**
 @param: bIsStarting = TRUE (Starting to type/text) FALSE = Completed your typing/texting
 */
-(void)logTexting:(BOOL)bIsStarting;
-(void)logPhoneCall:(BOOL)bIsStarting;
-(void)logGeneralHandling:(BOOL)bIsStarting;

-(void)writeCurrentSamplesToLogFile;
-(void)markAsStartDataCaptureTime;//Used to name the log file. The file is named the start time.

@end
