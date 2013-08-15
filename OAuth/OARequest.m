//
//  OARequest.h
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

#import "OARequest.h"

@interface OARequest (private)

- (void)generateTimestamp;
- (void)generateNonce;
- (NSArray *)oauthParameters;
- (NSString *)signatureBaseString:(NSString *)aType;

@end

@implementation OARequest (private)

- (void)generateTimestamp {
	timestamp_ = [[NSString alloc] initWithFormat: @"%ld", time(NULL)];
}

- (void)generateNonce {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	nonce_ = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, theUUID));
	CFRelease(theUUID);
	
}

- (NSArray *)oauthParameters {
	NSDictionary *tokenParameters = [token_ parameters];
	NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity: (5 +[tokenParameters count])];
    
	OARequestParameter *parameter;
	parameter = [[OARequestParameter alloc] initWithName: @"oauth_consumer_key" value: consumer_.key];
	[parameterPairs addObject: parameter];
	parameter = [[OARequestParameter alloc] initWithName: @"oauth_signature_method" value: [signatureProvider_ name]];
	[parameterPairs addObject: parameter];
	parameter = [[OARequestParameter alloc] initWithName: @"oauth_timestamp" value: timestamp_];
	[parameterPairs addObject: parameter];
	parameter = [[OARequestParameter alloc] initWithName: @"oauth_nonce" value: nonce_];
	[parameterPairs addObject: parameter];
	parameter = [[OARequestParameter alloc] initWithName: @"oauth_version" value: @"1.0"];
	[parameterPairs addObject: parameter];
    
	for (NSString *k in tokenParameters) {
		[parameterPairs addObject: [OARequestParameter requestParameter: k value: [tokenParameters objectForKey: k]]];
	}
	return parameterPairs;
}


- (NSString *)signatureBaseString:(NSString *)aType{
	NSArray *parameters = otherParams_;
	NSArray *oauthParameters = [self oauthParameters];
    
	NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity: ([parameters count] +[oauthParameters count])];
	for (OARequestParameter *param in parameters) {
		[parameterPairs addObject: [param URLEncodedNameValuePair]];
	}
	for (OARequestParameter *param in oauthParameters) {
		[parameterPairs addObject: [param URLEncodedNameValuePair]];
	}
    
	NSArray *sortedPairs = [parameterPairs sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
        NSArray *nameAndValue1 = [obj1 componentsSeparatedByString: @"="];
        NSArray *nameAndValue2 = [obj2 componentsSeparatedByString: @"="];
        
        NSString *name1 = [nameAndValue1 objectAtIndex: 0];
        NSString *name2 = [nameAndValue2 objectAtIndex: 0];
        
        NSComparisonResult comparisonResult = [name1 compare: name2];
        if (comparisonResult == NSOrderedSame) {
            NSString *value1 = [nameAndValue1 objectAtIndex: 1];
            NSString *value2 = [nameAndValue2 objectAtIndex: 1];
            
            comparisonResult = [value1 compare: value2];
        }
        
        return comparisonResult;
    }
                            ];
    
	NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString: @"&"];
    
	return [NSString stringWithFormat: @"%@&%@&%@",
	        aType,
	        [[url_ URLStringWithoutQuery] encodedURLParameterString],
	        [normalizedRequestParameters encodedURLString]];
}

@end

@implementation OARequest


#pragma mark init / dealloc

- (id)initWithURL: (NSURL *) aUrl
         consumer: (OAConsumer *) aConsumer
            token: (OAToken *) aToken {
    self = [super init];
    if (self)
    {
        url_ = aUrl;    
        
        consumer_ = aConsumer;
        if (aToken == nil) {
            token_ = [[OAToken alloc] init];
        }
        else {
            token_ = aToken;
        }

        signatureProvider_ = [[OAHMAC_SHA1SignatureProvider alloc] init];
       
        
        [self generateTimestamp];
        [self generateNonce];
	}
	return self;
}


#pragma mark -

// to diff with oauth parameters
- (void)setParameters: (NSArray *) aParams {
    otherParams_ = aParams;
}

- (NSString *)getTheUrl:(NSString *)aMethodType
{
    NSString *signature = [self getSignature:aMethodType];
    
	NSArray *oauthParameters = [self oauthParameters];
    
	NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity: ([otherParams_ count] +[oauthParameters count])];
	for (OARequestParameter *param in otherParams_) {
		[parameterPairs addObject: [param URLEncodedNameValuePair]];
	}
	for (OARequestParameter *param in oauthParameters) {
		[parameterPairs addObject: [param URLEncodedNameValuePair]];
	}
	[parameterPairs addObject: [NSString stringWithFormat: @"oauth_signature=%@", [signature encodedURLParameterString]]];
    
	NSMutableString *urlstring = [NSString stringWithFormat: @"%@?%@", [[url_ URLStringWithoutQuery] encodedURLString], [parameterPairs componentsJoinedByString: @"&"]];
    
    return urlstring;
}

- (NSString *)getSignature:(NSString *)aMethodType
{
    [self generateNonce];
	[self generateTimestamp];
	NSString *signature = [signatureProvider_ signClearText: [self signatureBaseString:aMethodType]
                                                 withSecret: [NSString stringWithFormat: @"%@&%@",
                                                              consumer_.secret,
                                                              token_.secret ? token_.secret: @""]];
    return signature;
}

- (NSArray *)allRequestParameters
{
    NSArray *parameters = otherParams_;
	NSArray *oauthParameters = [self oauthParameters];
    NSMutableArray *requestParameters = [NSMutableArray arrayWithArray:parameters];
    [requestParameters addObjectsFromArray:oauthParameters];
    return requestParameters;
}





@end
