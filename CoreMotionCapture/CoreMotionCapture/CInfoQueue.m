/*
//  CInfoQueue.m
//  CoreMotionCapture
//
//  Created by Jeff Behrbaum on 10/22/14.
//  Copyright (c) 2014 Apio Systems. All rights reserved.
*/

#import "CInfoQueue.h"

@interface CInfoQueue()
	@property(nonatomic, strong) NSObject *enqueueMtx;
	@property(nonatomic, strong) NSMutableArray *arrInfo;
@end

@implementation CInfoQueue

@synthesize arrInfo = _arrInfo;
@synthesize enqueueMtx = _enqueueMtx;

-(NSMutableArray *)arrInfo
{
	if(_arrInfo == nil)
		_arrInfo = [[NSMutableArray alloc]init];

	return _arrInfo;
}

-(NSObject *)enqueueMtx
{
	if(_enqueueMtx == nil)
		_enqueueMtx = [[NSObject alloc]init];

	return _enqueueMtx;
}

-(NSObject *)dequeue
{
	NSObject *topElement = nil;
	
	@synchronized(self.enqueueMtx)
	{
		if(self.arrInfo.count > 0)
		{
			topElement = [self.arrInfo objectAtIndex:0];
			[self.arrInfo removeObjectAtIndex:0];
		}
	}

	return topElement;
}

-(void)enqueue:(NSObject *)infoObj
{
	if(infoObj == nil)
		return;

	@synchronized(self.enqueueMtx)
	{
		[self.arrInfo addObject:infoObj];
	}
}

@end
