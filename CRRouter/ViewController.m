//
//  ViewController.m
//  CRRouter
//
//  Created by user on 17/4/27.
//  Copyright © 2017年 Charon. All rights reserved.
//

#import "ViewController.h"
#import "CRRouter.h"

#import "CRGoodsViewController.h"
#import "CRGoodsListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CRRouter setEnablePrintfLog:YES];
    
    //regist
    [self registGoodsDetailRoute];
    [self registGoodsListPageRoute];
    
}

- (void)registGoodsDetailRoute
{
    
    //There are two ways to register Route, and you can choose just one of them
    //The first registration way
    CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:@"cr" URLHost:@"goods" URLPath:@"/goodsDetail"];
    [routeNode paramsMap:^NSDictionary *(NSDictionary *originParams) {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        if(originParams[@"p1"]){
            //说明是第三方调用
            temp[@"goodsId"] = originParams[@"p1"];
        }
        [temp addEntriesFromDictionary:originParams];
        return temp;
    }];
    
    [routeNode paramsValidate:^BOOL(NSDictionary *originParams, NSDictionary *routeParams) {
        NSString *goodsId = routeParams[@"goodsId"];
        return goodsId.length > 0;
    }];
    
    [routeNode objectHandler:^id(NSDictionary *routeParams) {
        CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
        goodsVC.goodsId = routeParams[@"goodsId"];
        return goodsVC;
    }];
    
    [routeNode openHandler:^(NSDictionary *routeParams) {
        CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
        goodsVC.goodsId = routeParams[@"goodsId"];
        UINavigationController *navigationVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [navigationVC pushViewController:goodsVC animated:YES];
    }];
    
    [CRRouter registRouteNode:routeNode];
    
    
    //The second registration way
    [[[[[CRRouter registURLPattern:@"cr://goods/goodsDetail"] paramsMap:^NSDictionary *(NSDictionary *originParams) {
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        if(originParams[@"p1"]){
            //说明是第三方调用
            temp[@"goodsId"] = originParams[@"p1"];
        }
        [temp addEntriesFromDictionary:originParams];
        return temp;
        
    }] paramsValidate:^BOOL(NSDictionary *originParams, NSDictionary *routeParams) {
        
        NSString *goodsId = routeParams[@"goodsId"];
        return goodsId.length > 0;
        
    }] objectHandler:^id(NSDictionary *routeParams) {
        
        CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
        goodsVC.goodsId = routeParams[@"goodsId"];
        return goodsVC;
        
    }] openHandler:^(NSDictionary *routeParams) {
        
        CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
        goodsVC.goodsId = routeParams[@"goodsId"];
        UINavigationController *navigationVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [navigationVC pushViewController:goodsVC animated:YES];
        
    }];
    
    
    //If you don't need validation params and mapping params，you can do it like this
    
//    [[CRRouter registURLPattern:@"cr://goods/goodsDetail"] objectHandler:^id(NSDictionary *routeParams) {
//        CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
//        goodsVC.goodsId = routeParams[@"goodsId"];
//        return goodsVC;
//    }];
    
}

- (void)registGoodsListPageRoute
{
    [[[CRRouter registURLPattern:@"cr://goods/goodsList"] paramsValidate:^BOOL(NSDictionary *originParams, NSDictionary *routeParams) {
        
        return routeParams[@"categoryId"] != nil;
        
    }] objectHandler:^id(NSDictionary *routeParams) {
        
        CRGoodsListViewController *listVC = [[CRGoodsListViewController alloc] init];
        listVC.categoryId = routeParams[@"categoryId"];
        return listVC;
        
    }];
}

#pragma mark - event
- (IBAction)openRouteDeomo1:(id)sender
{
    UIViewController *vc = nil;
    vc = [CRRouter objectForURL:@"cr://goods/goodsDetail?p1=1"]; //Verify by parameters after mapping
//    vc = [CRRouter objectForURL:@"cr://goods/goodsDetail?goodsId=1"]; //Verify by parameters
//    vc = [CRRouter objectForURL:@"cr://goods/goodsDetail?asa=25"];  //Cannot verify by parameter
//    vc = [CRRouter objectForURL:@"cr://goods/goodsDetail" withParams:@{@"goodsId" : @"1"}]; //Verify by parameters
    
    if(vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    //or
//    [CRRouter openURL:@"cr://goods/goodsDetail?p1=1"];
}

- (IBAction)openRouteDemo2:(id)sender
{
    UIViewController *vc = [CRRouter objectForURL:@"cr://goods/goodsList" withParams:@{@"categoryId" : @"1"}];
    if(vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)openRouteDemo3:(id)sender
{
    //支持中文测试
//    UIViewController *vc = [CRRouter objectForURL:@"cr://goods/goodsDetail?p1=你好啊&p2=测试123"];
//    [self.navigationController pushViewController:vc animated:YES];
    
    [CRRouter openURL:@"cr://goods/goodsDetail?p1=你好啊&p2=测试123&p3=nihao"];
}

@end
