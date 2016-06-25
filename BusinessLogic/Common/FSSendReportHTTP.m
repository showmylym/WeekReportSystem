//
//  FSSendReportHTTP.m
//  BusinessLogic
//
//  Created by Leiyiming on 13-7-9.
//  Copyright (c) 2013年 FormsSyntron. All rights reserved.
//

#import "FSSendReportHTTP.h"

@implementation FSSendReportHTTP

- (id)initWithRequest:(NSMutableURLRequest *)muRequest {
    if (self = [super init]) {
        self.muRequest = muRequest;
    }
    return self;
}

- (void)connect {
    NSURLConnection * connection = [NSURLConnection connectionWithRequest:self.muRequest delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse * httpRes = (NSHTTPURLResponse *)response;
    if (httpRes.statusCode != 200) {
        [self.target httpFinishedWithSuccess:NO ifErrorWithMessage:[NSString stringWithFormat:@"错误代码%ld", httpRes.statusCode]];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString * responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([responseString isEqualToString:@"success\r\n"]) {
        [self.target httpFinishedWithSuccess:YES ifErrorWithMessage:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (error != nil) {
        [self.target httpFinishedWithSuccess:NO ifErrorWithMessage:error.localizedDescription];
    }
}

@end
