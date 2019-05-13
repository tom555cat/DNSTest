//
//  TestViewController.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/6.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *url = [NSString stringWithFormat:@"https://%@/api/cartnew/add", kCurrentHost];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSArray *ipArray = [result componentsSeparatedByString:@";"];
        if (ipArray.count > 0) {
            NSString *ip = ipArray[0];
            [[NSUserDefaults standardUserDefaults] setObject:ip forKey:kDNS2IP];
        }
    }];
    [dataTask resume];
}

@end
