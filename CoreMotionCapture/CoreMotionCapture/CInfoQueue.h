/*
//  CInfoQueue.h
//  CoreMotionCapture
//
//  Created by Jeff Behrbaum on 10/22/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import <Foundation/Foundation.h>

@interface CInfoQueue : NSObject

	-(NSObject *)dequeue;
	-(void)enquue:(NSObject *)infoObj;

@end
