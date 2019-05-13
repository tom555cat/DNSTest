//
//  TLMHttpDns.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/13.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "TLMHttpDns.h"
#import "NSURLSession+SynchronousTask.h"
#import "CustomURLProtocol.h"

static NSString * const DNSPodIP = @"119.29.29.29";

@interface TLMHttpDns ()

@property (nonatomic, copy) NSString *ip;

@end

@implementation TLMHttpDns

+ (instancetype)sharedInstance {
    static TLMHttpDns *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)replaceDomainWithIP:(NSString *)domain {
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    NSString *ip = [self getHostByName:domain];
    [CustomURLProtocol setIP:ip];
}

- (NSString *)getHostByName:(NSString *)domain {
    NSString *url = [NSString stringWithFormat:@"http://%@/d?dn=%@&ttl=1", DNSPodIP, domain];
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

@end
