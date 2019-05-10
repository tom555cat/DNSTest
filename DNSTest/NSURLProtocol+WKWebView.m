//
//  NSURLProtocol+WKWebView.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/9.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "NSURLProtocol+WKWebView.h"

@implementation NSURLProtocol (WKWebView)

+ (void)wk_registerScheme:(NSString *)scheme {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([cls respondsToSelector:sel]) {
        [cls performSelector:sel withObject:scheme];
    }
}

+ (void)wk_unregisterScheme:(NSString *)scheme {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    if ([cls respondsToSelector:sel]) {
        [cls performSelector:sel withObject:scheme];
    }
}

@end
