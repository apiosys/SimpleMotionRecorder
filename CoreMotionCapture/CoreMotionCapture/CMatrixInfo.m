#import <CoreMotion/CoreMotion.h>

#import "CMatrixInfo.h"

@implementation CMatrixInfo

@synthesize cmAtt = _cmAtt;
@synthesize dYaw = _dYaw;
@synthesize dRoll = _dRoll;
@synthesize dPitch = _dPitch;

@synthesize dRotationRateX = _dRotationRateX;
@synthesize dRotationRateY = _dRotationRateY;
@synthesize dRotationRateZ = _dRotationRateZ;

@synthesize dGravityX = _dGravityX;
@synthesize dGravityY = _dGravityY;
@synthesize dGravityZ = _dGravityZ;

@synthesize dUserAccelerationX = _dUserAccelerationX;
@synthesize dUserAccelerationY = _dUserAccelerationY;
@synthesize dUserAccelerationZ = _dUserAccelerationZ;

-(NSString *)printableString
{
	NSString *strInfo;
	
	NSString *strYawPitchRollInfo = [NSString stringWithFormat:@"Yaw: %.9lf - Pitch: %.9lf - Roll: %.9lf\n", self.dYaw, self.dPitch, self.dRoll];
	
	NSString *strGravityXYZ = [NSString stringWithFormat:@"Gravity: X: %.9lf - Y: %.9lf - Z: %.9lf\n", self.dGravityX, self.dGravityY, self.dGravityZ];
	
	NSString *strRotationXYZ = [NSString stringWithFormat:@"Rotations: X: %.9lf - Y: %.9lf - Z: %.9lf\n", self.dRotationRateX, self.dRotationRateY, self.dRotationRateZ];

	NSString *strAcceleration = [NSString stringWithFormat:@"User Accelerations: X: %.9lf - Y: %.9lf - Z: %.9lf\n\n", self.dUserAccelerationX, self.dUserAccelerationY, self.dUserAccelerationZ];
	
	NSString *strHdrMatrix = [NSString stringWithFormat:@"CMAttidue Data:\nYaw: %.9lf - Pitch: %.9lf - Roll: %.9lf\n\nRotation Matrix:\n", self.cmAtt.yaw, self.cmAtt.pitch, self.cmAtt.roll];

	NSString *strMatrix = [NSString stringWithFormat:@" [m11 m12 m13]\n [m21 m22 m23]\n [m31 m32 m33]\n [%.9lf %.9lf %.9lf]\n [%.9lf %.9lf %.9lf]\n [%.9lf %.9lf %.9lf]\n\n\n",
								  self.cmAtt.rotationMatrix.m11,
								  self.cmAtt.rotationMatrix.m12,
								  self.cmAtt.rotationMatrix.m13,

								  self.cmAtt.rotationMatrix.m21,
								  self.cmAtt.rotationMatrix.m22,
								  self.cmAtt.rotationMatrix.m23,
	
								  self.cmAtt.rotationMatrix.m31,
								  self.cmAtt.rotationMatrix.m32,
								  self.cmAtt.rotationMatrix.m33
								  ];

	strInfo = [NSString stringWithFormat:@"************Next Record**************\n%@%@%@%@%@%@", strYawPitchRollInfo, strGravityXYZ, strRotationXYZ, strAcceleration, strHdrMatrix, strMatrix];
	
	return strInfo;
}

@end
