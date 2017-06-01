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
    
    [self test1];
//    [self test3];
    
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
    [[[[CRRouter registURLPattern:@"bl://home/homePage"] paramsValidate:^BOOL(NSDictionary *originParams, NSDictionary *routeParams) {
        
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
    
    //举例 bl://goods/goodsDetail
    // 上面是对应商品详情页的路由（商品详情页面需要一个参数 goodsId）
    // 例子1 ： bl://goods/goodsDetail?p1=23232  通过这个url获取到商品详情页的控制器，如果你写了validate 显示参数p1 不是goodsId 不能让你通过
    // 但是上面这个url有可能是给到第三方调用的，此时我们不想给我们页面需要用到真正参数名 所以让第三方用p1代码，那这个时候paramsMap的block就起作用了，他可以把第三方给过来的参数mapping成我模块真正需要的参数
}

@end
