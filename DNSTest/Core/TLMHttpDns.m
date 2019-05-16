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

@interface TLMHttpDns ()

@property (nonatomic, assign) BOOL async;

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

- (void)replaceHostWithIPAsync:(BOOL)async {
    self.async = async;
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
}

//- (void)replaceHostWithIP {
//    [NSURLProtocol registerClass:[CustomURLProtocol class]];
//}


@end
