//
//  CustomURLProtocol.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/6.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "CustomURLProtocol.h"

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // Determines whether the protocol subclass can handle the specified request.
    // 拦截对域名的请求：http://fe.corp.daling.com/
    NSURL *url = request.URL;
    if ([url.host isEqualToString:@"djia.daling.com"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    // 如果上面的方法返回YES，那么request会传到这里
    // 通常什么都不做，直接返回request
    return request;
}

- (void)startLoading {
    // 对拦截的请求做一些处理，比如进行域名替换IP地址
    NSString *ip = [[NSUserDefaults standardUserDefaults] stringForKey:@"DNS_TO_IP"];
    
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    NSURL *url = mutableRequest.URL;
    NSRange hostRange = [url.absoluteString rangeOfString:url.host];
    NSMutableString *urlStr = [NSMutableString stringWithString:url.absoluteString];
    [urlStr stringByReplacingCharactersInRange:hostRange withString:ip];
    [mutableRequest setURL:[NSURL URLWithString:urlStr]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"请求成功");
    }];
    [task resume];
}

- (void)stopLoading {

}

@end
