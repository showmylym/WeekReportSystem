//
//  FSSendReportHTTP.h
//  BusinessLogic
//
//  Created by Leiyiming on 13-7-9.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSHTTPResultCallBack <NSObject>

- (void)httpFinishedWithSuccess:(BOOL)success ifErrorWithMessage:(NSString *)errorMessage;

@end

@interface FSSendReportHTTP : NSObject
<NSURLConnectionDataDelegate>

@property (weak)    id<FSHTTPResultCallBack>    target;
@property           NSMutableURLRequest         * muRequest;

- (id)initWithRequest:(NSMutableURLRequest *)muRequest;
- (void)connect;
@end
