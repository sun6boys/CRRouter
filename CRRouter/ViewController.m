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
    [self registRouteNode];
    [self registURL];
        
}

- (void)registRouteNode
{
    CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:@"bl" URLHost:@"goods" URLPath:@"/goodsDetail"];
    [routeNode paramsMap:^NSDictionary *(NSDictionary *originParams) {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        temp[@"goodsId"] = originParams[@"p1"];
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
}

- (void)registURL
{
    [[[CRRouter registURLPattern:@"bl://goods/goodsList"] paramsValidate:^BOOL(NSDictionary *originParams, NSDictionary *routeParams) {
        
        return routeParams[@"categoryId"] != nil;
        
    }] objectHandler:^id(NSDictionary *routeParams) {
        
        CRGoodsListViewController *listVC = [[CRGoodsListViewController alloc] init];
        listVC.categoryId = routeParams[@"categoryId"];
        return listVC;
        
    }];
}


#pragma mark - action
- (IBAction)test1:(id)sender
{
//    UIViewController *vc = [CRRouter objectForURL:@"bl://goods/goodsDetail?p1=1"];
//    if(vc){
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    [CRRouter openURL:@"bl://goods/goodsDetail?p1=1"];
}

- (IBAction)test2:(id)sender
{
    UIViewController *vc = [CRRouter objectForURL:@"bl://goods/goodsList?categoryId=1"];
    if(vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)test3:(id)sender
{
    UIViewController *vc = [CRRouter objectForURL:@"bl://goods/goodsList" withParams:@{@"categoryId" : @"1"}];
    if(vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
