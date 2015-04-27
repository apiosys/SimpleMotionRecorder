/*
//  SensorModuleProtocols.h
//  SALTester
//
//  Created by Jeff Behrbaum on 10/17/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#pragma once

@protocol deviceMotionNotifications <NSObject>
@required
	-(void)motionDataUpdated:(CMDeviceMotion *)devMotion;
@end
