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
+ (void)registRouteNode:(CRRouteNode *)routeNode;

+ (void)deregistRouteForURL:(NSString *)URLPattern;
+ (void)deregistRouteForRouteNode:(CRRouteNode *)routeNode;

+ (BOOL)hasRegistURL:(NSString *)URLPattern;

+ (id)objectForURL:(NSString *)URLPattern;
+ (id)objectForURL:(NSString *)URLPattern withParams:(NSDictionary *)params;
+ (id)objectForRouteNode:(CRRouteNode *)routeNode withParams:(NSDictionary *)params;

+ (BOOL)openURL:(NSString *)URLPattern;
+ (BOOL)openURL:(NSString *)URLPattern withParams:(NSDictionary *)params;

+ (void)setEnablePrintfLog:(BOOL)enablePrintfLog;
@end


typedef BOOL (^CRRouteParamsValidator)(NSDictionary *originParams,NSDictionary *routeParams);
typedef NSDictionary *(^CRRouteParamsMapper)(NSDictionary *originParams);
typedef id (^CRRouteObjectHandler)(NSDictionary *routeParams);
typedef void (^CRRouteOpenHandler)(NSDictionary *routeParams);

@interface CRRouteNode : NSObject

@property (nonatomic, copy, readonly) NSString *scheme;
@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly) NSString *path;

+ (instancetype)routeNodeWithURLScheme:(NSString *)scheme URLHost:(NSString *)host URLPath:(NSString *)path;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 配置相关方法
 */
- (instancetype)paramsValidate:(CRRouteParamsValidator)paramsValidator;
- (instancetype)paramsMap:(CRRouteParamsMapper)paramsMapper;
- (instancetype)objectHandler:(CRRouteObjectHandler)objectHandler;
- (instancetype)openHandler:(CRRouteOpenHandler)openHandler;

@end
