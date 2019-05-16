//
//  TLMHttpDns.h
//  DNSTest
//
//  Created by tongleiming on 2019/5/13.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLMHttpDns : NSObject

+ (instancetype)sharedInstance;

/**
  域名同步解析

 @param domain 域名
 @return 查询到的IP数组，超时(1s)或者未查询到返回@[]数组
 */
//- (NSArray *)getHostByName:(NSString *)domain;

/**
 域名使用IP地址替换同步方法

 @param domain 域名
 */
- (void)replaceHostWithIPAsync:(BOOL)async;

@property (nonatomic, copy) NSArray *resolveHosts;
@property (nonatomic, assign, readonly) BOOL async;


@end

NS_ASSUME_NONNULL_END
