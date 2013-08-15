//
//  OAToken.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
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


#import "NSString+URLEncoding.h"
#import "OAToken.h"


@implementation OAToken

#pragma mark init

- (id)init {
	return [self initWithKey: nil secret: nil];
}

- (id)initWithKey: (NSString *) aKey secret: (NSString *) aSecret {
	self = [super init];
    if(self) {
        self.key = aKey;
        self.secret = aSecret;  
    }
	return self;
}


- (id)initWithCoder: (NSCoder *) aDecoder {
	OAToken *t = [self initWithKey: [aDecoder decodeObjectForKey: @"key"]
	                        secret: [aDecoder decodeObjectForKey: @"secret"]];
	[t setVerifier: [aDecoder decodeObjectForKey: @"verifier"]];
	return t;
}




#pragma mark settings
- (void)encodeWithCoder: (NSCoder *) aCoder {
	[aCoder encodeObject: [self key] forKey: @"key"];
	[aCoder encodeObject: [self secret] forKey: @"secret"];
	[aCoder encodeObject: [self verifier] forKey: @"verifier"];
}





- (NSDictionary *)parameters {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

	if (self.key) {
		[params setObject: self.key forKey: @"oauth_token"];
	}
	
	if (self.verifier) {
		[params setObject: self.verifier forKey: @"oauth_verifier"];
	}
	return params;
}

#pragma mark comparisions

- (BOOL)isEqual: (id) object {
	if ([object isKindOfClass: [self class]]) {
		return [self isEqualToToken: (OAToken *)object];
	}
	return NO;
}

- (BOOL)isEqualToToken: (OAToken *) aToken {
	/* Since ScalableOAuth determines that the token may be
	   renewed using the same key and secret, we must also
	   check the creation date */
	if ([self.key isEqualToString: aToken.key] &&
	    [self.secret isEqualToString: aToken.secret]) {
		/* May be nil */
        return YES;
		
	}

	return NO;
}


#pragma mark description

- (NSString *)description {
	return [NSString stringWithFormat: @"Key \"%@\" Secret:\"%@\"", self.key, self.secret];
}

@end