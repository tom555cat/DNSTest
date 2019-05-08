//
//  ViewController.m
//  DNSTest
//
//  Created by tongleiming on 2019/5/6.
//  Copyright © 2019 tongleiming. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "RootTableViewController.h"
#import "PostTestViewController.h"

@interface ViewController () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *ownSession;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *url = [NSString stringWithFormat:@"http://119.29.29.29/d?dn=djia.daling.com&ttl=1"];
    //NSString *url = @"http://www.baidu.com";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSArray *ipArray = [result componentsSeparatedByString:@";"];
        if (ipArray.count > 0) {
            NSString *ip = ipArray[0];
            [[NSUserDefaults standardUserDefaults] setObject:ip forKey:@"DNS_TO_IP"];
        }
    }];
    [dataTask resume];
}

- (IBAction)HTTPTestClick:(id)sender {
    TestViewController *vc = [[TestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)AVPlayerTestClick:(id)sender {
    RootTableViewController *vc = [[RootTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)PostTestClick:(id)sender {
    PostTestViewController *vc = [[PostTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
