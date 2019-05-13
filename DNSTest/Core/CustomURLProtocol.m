//
//  CustomURLProtocol.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/6.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "CustomURLProtocol.h"

static NSString *const kCustomURLProtocolKey = @"kCustomURLProtocolKey";
static NSString *kIP = nil;

@interface CustomURLProtocol () <NSURLSessionDelegate>

@property (nonnull,strong) NSURLSessionDataTask *task;

@end

@implementation CustomURLProtocol

+ (void)setIP:(NSString *)ip {
    kIP = ip;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kCustomURLProtocolKey inRequest:request]) {
        // 自己复制的request也会走到这里，如果不排除就会进入死循环
        return NO;
    }
    
    // Determines whether the protocol subclass can handle the specified request.
    // 拦截对域名的请求
    NSURL *url = request.URL;
    if ([url.host isEqualToString:kCurrentHost]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    // 如果上面的方法返回YES，那么request会传到这里，通常什么都不做，直接返回request
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *mutableRequest;
    if ([self.request.HTTPMethod isEqualToString:@"POST"]) {  // 由于拷贝HTTP body的原因，单独处理
        mutableRequest = [self handlePostRequestBodyWithRequest:self.request];
    } else {
        mutableRequest = [[self request] mutableCopy];
    }
    
    // 给复制的请求打标记，打过标记的请求直接放行
    [NSURLProtocol setProperty:@YES forKey:kCustomURLProtocolKey inRequest:mutableRequest];
    
    // 获取域名解析后的IP地址
    NSString *ip = kIP;
    NSURL *url = mutableRequest.URL;
    NSRange hostRange = [url.absoluteString rangeOfString:url.host];
    NSMutableString *urlStr = [NSMutableString stringWithString:url.absoluteString];
    [urlStr stringByReplacingCharactersInRange:hostRange withString:ip];
    [mutableRequest setURL:[NSURL URLWithString:urlStr]];
    
    // 在header中增加域名，防止运营商懵逼
    [mutableRequest setValue:kCurrentHost forHTTPHeaderField:@"HOST"];
    
    // 重新进行请求
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.task = [session dataTaskWithRequest:mutableRequest];
    [self.task resume];
}

- (void)stopLoading {

}



#pragma mark -
#pragma mark 处理POST请求相关POST  用HTTPBodyStream来处理BODY体
// A HTTP body stream is preserved when copying an NSURLRequest object
- (NSMutableURLRequest *)handlePostRequestBodyWithRequest:(NSURLRequest *)request {
    NSMutableURLRequest * req = [request mutableCopy];
    if ([request.HTTPMethod isEqualToString:@"POST"]) {
        if (!request.HTTPBody) {
            uint8_t d[1024] = {0};
            NSInputStream *stream = request.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:d maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [data appendBytes:(void *)d length:len];
                }
            }
            req.HTTPBody = [data copy];
            [stream close];
        }
    }
    return req;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
