//
//  CHAPIHTTPRequest.m
//  OAuthAPIRequest
//  Copyright (c) 2013 Hang Chen (https://github.com/cyndibaby905)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "CHAPIHTTPRequest.h"
#import "OAToken.h"
#import "OAConsumer.h"
#import "OARequest.h"


#warning write your key and secretKey here

NSString * const kConsumerKey = nil;
NSString * const kConsumerSecret = nil;
NSString * const kBaseURL = nil;

@interface CHAPIHTTPRequest()

@property (nonatomic, retain) AFHTTPRequestOperation *operation;
@end

@implementation CHAPIHTTPRequest

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void) startRequestUsingPath:(NSString*)path andParameters:(NSDictionary*)args withCompletion:(void (^)(CHAPIHTTPRequest *request, NSData *data))success failure:(void (^)(CHAPIHTTPRequest *request, NSError *error))failure {
    
    NSMutableDictionary *requestArgs = [NSMutableDictionary dictionaryWithDictionary:args];
    NSAssert(kConsumerSecret && kConsumerKey && kBaseURL, @"Please use your own key and secret key");
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey secret:kConsumerSecret];
	
    //OAuth Token
    OAToken *token = requestArgs[@"token"];
    [requestArgs removeObjectForKey:@"token"];
    NSString *url = kBaseURL;
	NSURL *restURL = [NSURL URLWithString: url];
	OARequest *oaRequest = [[OARequest alloc] initWithURL: restURL
                                                  consumer: consumer
                                                     token: token];

    OARequestParameter *p0 = [[OARequestParameter alloc] initWithName: @"method" value:path];
    
    NSMutableArray *params = [[NSMutableArray alloc] initWithObjects:p0, nil];
    
    
   
    NSArray *keys = [requestArgs allKeys];
	for (NSString *key in keys) {        
		OARequestParameter *p = [[OARequestParameter alloc] initWithName:key value:(NSString *)requestArgs[key]];
		[params addObject:p];
	}
	[oaRequest setParameters: params];
    
    url = [oaRequest getTheUrl:@"GET"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [operation_ cancel];
    operation_ = [[AFHTTPRequestOperation alloc] initWithRequest:request];
   
    __block CHAPIHTTPRequest *blockSelf = self;
    
    [operation_ setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(blockSelf,responseObject);
        }
        blockSelf.operation = nil;
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(blockSelf,error);
        }
        blockSelf.operation = nil;
    }];
    
   
    self.operation = operation_;
    [self.operation start];
}

- (void) cancelRequest
{
    [self.operation cancel];
    
}

- (void)dealloc
{
    [self.operation cancel];
}

@end
