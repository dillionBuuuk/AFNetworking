//
//  AppHTTPClient.m
//  AFNetworking iOS Example
//
//  Created by Dillion Tan on 18/4/13.
//  Copyright (c) 2013 Gowalla. All rights reserved.
//

#import "AppHTTPClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAppBaseURLString = @"http://apps.buuuk.in/";

@implementation AppHTTPClient

+ (AppHTTPClient *)sharedHTTPClient {
    static AppHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
	// X-UDID HTTP Header
    //[self setDefaultHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
    
    self.parameterEncoding = AFFormURLParameterEncoding;
    
    return self;
}

/** AFCUSTOM: SPECIAL HANDLING FOR ARRAYS AS PARAMETER (only for FORMURLParameterEncoding) **/
NSString * AFURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding)));
}

/** AFCUSTOM: SPECIAL HANDLING FOR ARRAYS AS PARAMETER (only for FORMURLParameterEncoding) **/
NSString * AFQueryStringFromArrayWithEncoding(NSArray *array, NSStringEncoding encoding) {
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    for (id object in array) {
        NSString *component = [NSString stringWithFormat:@"%@", AFURLEncodedStringFromStringWithEncoding([object description], encoding)];
        [mutableParameterComponents addObject:component];
    }
    
    return [mutableParameterComponents componentsJoinedByString:@"&"];
}

/** AFCUSTOM: SPECIAL HANDLING FOR ARRAYS AS PARAMETER (only for FORMURLParameterEncoding) **/
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                    arrays:(NSArray *)array, ...NS_REQUIRES_NIL_TERMINATION
{
    NSParameterAssert(method);
    
    if (!path) {
        path = @"";
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:nil];
    
    if (parameters) {
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            NSError *error = nil;
            
            switch (self.parameterEncoding) {
                case AFFormURLParameterEncoding: {
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    NSString *queryString = AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding);
                    
                    va_list args;
                    va_start(args, array);
                    
                    for (NSArray *arg = array; arg != nil; arg = va_arg(args, NSArray *)) {
                        queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&%@", AFQueryStringFromArrayWithEncoding(arg, self.stringEncoding)]];
                    }
                    
                    va_end(args);
                    
                    [request setHTTPBody:[queryString dataUsingEncoding:self.stringEncoding]];
                }
                    break;
                case AFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
                    break;
                case AFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    break;
            }
            
            if (error) {
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
    }
    
	return request;
}

@end
