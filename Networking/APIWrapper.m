//
//  APIWrapper.m
//  AFNetworking iOS Example
//
//  Created by Dillion Tan on 18/4/13.
//  Copyright (c) 2013 Gowalla. All rights reserved.
//

#import "APIWrapper.h"
#import "AppHTTPClient.h"

@implementation APIWrapper

+ (APIWrapper *)defaultWrapper
{
	static dispatch_once_t pred = 0;
    __strong static id _defaultWrapper = nil;
    dispatch_once(&pred, ^{
        _defaultWrapper = [[self alloc] init];
    });
    return _defaultWrapper;
}

- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}

@end
