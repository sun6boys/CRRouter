//
//  CRRouter.h
//  CRRouter
//
//  Created by user on 17/4/27.
//  Copyright © 2017年 Charon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRRouteNode;
@interface CRRouter : NSObject

+ (CRRouteNode *)registURLPattern:(NSString *)URLPattern;

+ (void)deregistRouteForURL:(NSString *)URLPattern;
+ (void)deregistRouteForRouteNode:(CRRouteNode *)routeNode;

+ (BOOL)hasRegistURL:(NSString *)URLPattern;

+ (id)objectForURL:(NSString *)URLPattern;

@end



typedef BOOL (^CRRouteParamsValidator)(NSDictionary *originParams);
typedef NSDictionary *(^CRRouteParamsMapper)(NSDictionary *originParams);
typedef id (^CRRouteObjectHandler)(NSDictionary *routeParams);

@interface CRRouteNode : NSObject

@property (nonatomic, copy, readonly) NSString *scheme;
@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly) NSString *path;

/**
 配置相关方法
 */
- (instancetype)paramsValidate:(CRRouteParamsValidator)paramsValidator;
- (instancetype)paramsMap:(CRRouteParamsMapper)paramsMapper;
- (void)objectHandler:(CRRouteObjectHandler)objectHandler;

@end
