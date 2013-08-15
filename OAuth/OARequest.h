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

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OASignatureProviding.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OARequestParameter.h"
#import "NSURL+Base.h"

@interface OARequest : NSObject {
 @private
    NSURL *url_; 
    OAConsumer *consumer_; 
    OAToken *token_;
    OAHMAC_SHA1SignatureProvider* signatureProvider_;
    NSString *nonce_;
    NSString *timestamp_;
	
    NSArray *otherParams_;
}


- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken;

- (void)setParameters: (NSArray *) aParams;

- (NSString *)getTheUrl:(NSString *)aMethodType;
- (NSString *)getSignature:(NSString *)aMethodType;
- (NSArray *)allRequestParameters;


@end
