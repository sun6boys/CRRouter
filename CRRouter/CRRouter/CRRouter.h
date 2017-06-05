//
//  CRRouter.h
//  CRRouter
//
//  Created by user on 17/4/27.
//  Copyright © 2017年 Charon. All rights reserved.
//

/** CRRouter
 CRRouter is a way to manage URL routes and invoke them from a URL.
 */

#import <Foundation/Foundation.h>

@class CRRouteNode;
@interface CRRouter : NSObject

//Regist a URLPattern or CRRouteNode.
//URLPattern must contain scheme，host and path at least.
//RouteNode scheme host and path can't be nil.
+ (CRRouteNode *)registURLPattern:(NSString *)URLPattern;
+ (void)registRouteNode:(CRRouteNode *)routeNode;

//Remove a URLPattern or routeNode from the registry.
+ (void)deregistRouteForURL:(NSString *)URLPattern;
+ (void)deregistRouteForRouteNode:(CRRouteNode *)routeNode;

//Returns whether the route has been registered?
+ (BOOL)hasRegistURL:(NSString *)URLPattern;

//Call a route and return object if the route has registed and implement 'objectHandler'.
+ (id)objectForURL:(NSString *)URLPattern;
+ (id)objectForURL:(NSString *)URLPattern withParams:(NSDictionary *)params;
+ (id)objectForRouteNode:(CRRouteNode *)routeNode withParams:(NSDictionary *)params;

//Call a route 'openHandler' if the route has registed and implement 'openHandler'.
+ (BOOL)openURL:(NSString *)URLPattern;
+ (BOOL)openURL:(NSString *)URLPattern withParams:(NSDictionary *)params;
+ (BOOL)openRouteNode:(CRRouteNode *)routeNode withParams:(NSDictionary *)params;

//Allow CRRouter Printf log. Default is NO.
+ (void)setEnablePrintfLog:(BOOL)enablePrintfLog;
@end


typedef BOOL (^CRRouteParamsValidator)(NSDictionary *originParams,NSDictionary *routeParams);
typedef NSDictionary *(^CRRouteParamsMapper)(NSDictionary *originParams);
typedef id (^CRRouteObjectHandler)(NSDictionary *routeParams);
typedef void (^CRRouteOpenHandler)(NSDictionary *routeParams);

/**
 CRRouteNode is converted from URLPattern to record in the registry
 */
@interface CRRouteNode : NSObject

@property (nonatomic, copy, readonly) NSString *scheme;
@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly) NSString *path;

+ (instancetype)routeNodeWithURLScheme:(NSString *)scheme URLHost:(NSString *)host URLPath:(NSString *)path;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

//Verify that the parameters from caller are correct or not
//If implement 'CRRouteParamsMapper',the converted parameters after map will also be sent
- (instancetype)paramsValidate:(CRRouteParamsValidator)paramsValidator;

//Conversion parameters from caller.
- (instancetype)paramsMap:(CRRouteParamsMapper)paramsMapper;

//Returns an object if validated when call
- (instancetype)objectHandler:(CRRouteObjectHandler)objectHandler;

//Open a page if validated when call
- (instancetype)openHandler:(CRRouteOpenHandler)openHandler;

@end
