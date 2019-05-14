//
//  CustomURLProtocol.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/6.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "CustomURLProtocol.h"
#import "NSURLSession+SynchronousTask.h"
#import "TLMHttpDns.h"

static NSString *const kCustomURLProtocolKey = @"kCustomURLProtocolKey";
static NSString *kIP = nil;
static NSMutableDictionary *domainIPMap = nil;


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
    // 该方法在Queue:com.apple.NSURLSession-work(serial)队列中调用，所以在这一层级做同步调用HTTPDNS请求
    
    // 解析request的域名对应的IP地址
    if ([[TLMHttpDns sharedInstance].resolveHosts containsObject:request.URL.host]) {
        [self ipForDomain:request.URL.host];
    }
    
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
    NSString *ip = [[self class] ipForDomain:mutableRequest.URL.host];
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

+ (NSString *)ipForDomain:(NSString *)domain {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        domainIPMap = [[NSMutableDictionary alloc] init];
    });
    
    NSString *ip = domainIPMap[domain];
    if (!ip) {
        ip = [self getHostByName:domain];
        domainIPMap[domain] = ip;
    }
    
    return ip;
}

+ (NSString *)getHostByName:(NSString *)domain {
    NSString *url = [NSString stringWithFormat:@"http://119.29.29.29/d?dn=%@&ttl=1", domain];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [session sendSynchronousDataTaskWithRequest:request returningResponse:&response error:&error];
    
    // 解析ip地址
    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *ipArray = [result componentsSeparatedByString:@";"];
    if (ipArray.count > 0) {
        //NSString *ip = ipArray[0];
#warning 检查IP地址是否合规
        //self.ip = ipArray[0];
        return [NSString stringWithFormat:@"%@", ipArray[0]];
    }
    return nil;
}

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
