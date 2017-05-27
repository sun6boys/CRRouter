//
//  ViewController.m
//  CRRouter
//
//  Created by user on 17/4/27.
//  Copyright © 2017年 Charon. All rights reserved.
//

#import "ViewController.h"

#import "CRRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test1];
    [self test3];
    
}

- (void)test1
{
    [[[CRRouter registURLPattern:@"bl://home/homePage"] paramsMap:^NSDictionary *(NSDictionary *originParams) {
        NSString *p1 = originParams[@"p1"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"pageId"] = p1;
        return params;
    }]objectHandler:^id(NSDictionary *routeParams) {
        NSLog(@"routeParams : %@",routeParams);
        return @"测试成功";
    }];
    
    
    NSString *result = [CRRouter objectForURL:@"bl://home/homePage?p1=234&p2=asas"];
    NSLog(@"result = %@",result);
}


- (void)test2
{
    [[[[CRRouter registURLPattern:@"bl://home/homePage"] paramsValidate:^BOOL(NSDictionary *originParams) {
        NSString *p1 = originParams[@"p1"];
        return p1.length > 0;
    }] paramsMap:^NSDictionary *(NSDictionary *originParams) {
        NSString *p1 = originParams[@"p1"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"pageId"] = p1;
        return params;
    }] objectHandler:^id(NSDictionary *routeParams) {
        NSLog(@"routeParams : %@",routeParams);
        return @"测试成功";
    }];
    
    NSString *result = [CRRouter objectForURL:@"bl://home/homePage?p3=234&p1=asas"];
    NSLog(@"result = %@",result);
}


- (void)test3
{
    [CRRouter registURLPattern:@"bl://home/homePage"];
    [CRRouter registURLPattern:@"bl://home/homePage"];
    [CRRouter registURLPattern:@"bl://home/homePage"];
    [CRRouter registURLPattern:@"bl://home/homePage"];
    [CRRouter registURLPattern:@"bl://home/homePage1"];
    [CRRouter registURLPattern:@"bl://home/homePage2"];
    [CRRouter registURLPattern:@"bl://home/homePage3"];
    [CRRouter registURLPattern:@"bl1://bs/homePage"];
    [CRRouter registURLPattern:@"bl1://ab/homePage"];
    [CRRouter registURLPattern:@"bl://asasas/homePage"];
    [CRRouter registURLPattern:@"bl://asasas/homePage"];
}

@end
