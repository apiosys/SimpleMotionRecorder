#import <Foundation/Foundation.h>

@class CMAttitude;

@interface CMatrixInfo : NSObject

@property(nonatomic, strong) CMAttitude *cmAtt;

@property(nonatomic) double dYaw;
@property(nonatomic) double dRoll;
@property(nonatomic) double dPitch;

@property(nonatomic) double dRotationRateX;
@property(nonatomic) double dRotationRateY;
@property(nonatomic) double dRotationRateZ;

@property(nonatomic) double dGravityX;
@property(nonatomic) double dGravityY;
@property(nonatomic) double dGravityZ;

@property(nonatomic) double dUserAccelerationX;
@property(nonatomic) double dUserAccelerationY;
@property(nonatomic) double dUserAccelerationZ;

-(NSString *)printableString;


@end
