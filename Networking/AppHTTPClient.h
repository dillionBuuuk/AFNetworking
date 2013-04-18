//
//  AppHTTPClient.h
//  AFNetworking iOS Example
//
//  Created by Dillion Tan on 18/4/13.
//  Copyright (c) 2013 Gowalla. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AppHTTPClient : AFHTTPClient

+ (AppHTTPClient *)sharedHTTPClient;

/** AFCUSTOM: SPECIAL HANDLING FOR ARRAYs AS PARAMETER (only for FORMURLParameterEncoding) **/
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                    arrays:(NSArray *)array, ...NS_REQUIRES_NIL_TERMINATION;

@end
