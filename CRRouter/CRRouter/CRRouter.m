//
//  CRRouter.m
//  CRRouter
//
//  Created by user on 17/4/27.
//  Copyright © 2017年 Charon. All rights reserved.
//

#import "CRRouter.h"

@interface CRRouteNode()

+ (instancetype)routeNodeWithURLScheme:(NSString *)scheme URLHost:(NSString *)host URLPath:(NSString *)path;
- (BOOL)validate:(NSDictionary *)params;
- (NSDictionary *)mapParams:(NSDictionary *)params;
- (id)objectForRouteParams:(NSDictionary *)routeParams;
@end

@interface CRRouter()

@property (nonatomic, strong) NSMutableDictionary *routesStorage;
@end

@implementation CRRouter

+ (instancetype)sharedInstance
{
    static CRRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - public methods
+ (CRRouteNode *)registURLPattern:(NSString *)URLPatten
{
    NSURL *URL = [NSURL URLWithString:URLPatten];
    CRRouteNode *routeNode = [[self sharedInstance] routeNodeForURL:URL];
    if(routeNode)
        return routeNode;
    
    if(URL.scheme.length == 0||
       URL.host.length == 0 ||
       URL.path.length == 0)
        return nil;
    
    return [[self sharedInstance] addURLPatternForURL:URL];
}

+ (void)deregistRouteForURL:(NSString *)URLPattern
{
    CRRouteNode *node = [[self sharedInstance] routeNodeForURL:[NSURL URLWithString:URLPattern]];
    [self deregistRouteForRouteNode:node];
}

+ (void)deregistRouteForRouteNode:(CRRouteNode *)routeNode
{
    [[self sharedInstance] removeRouteNode:routeNode];
}

+ (BOOL)hasRegistURL:(NSString *)URLPattern
{
    return [[self sharedInstance] routeNodeForURL:[NSURL URLWithString:URLPattern]] != nil;
}

+ (id)objectForURL:(NSString *)URLPattern
{
    NSURL *URL = [NSURL URLWithString:URLPattern];
    NSDictionary *params = [self queryDictonaryWithURL:URL];
    
    CRRouteNode *node = [[self sharedInstance] routeNodeForURL:URL];
    if([node validate:params] == NO)
        return nil;
    
    NSDictionary *routeParams = [node mapParams:params];
    return [node objectForRouteParams:routeParams];
}

#pragma mark - instance method
- (CRRouteNode *)addURLPatternForURL:(NSURL *)URL
{
    CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:URL.scheme URLHost:URL.host URLPath:URL.path];
    
    if(self.routesStorage[URL.scheme] == nil){
        self.routesStorage[URL.scheme] = [[NSMutableDictionary alloc] init];
    }
    
    if (self.routesStorage[URL.scheme][URL.host] == nil) {
        self.routesStorage[URL.scheme][URL.host] = [[NSMutableDictionary alloc] init];
    }
    
    self.routesStorage[URL.scheme][URL.host][URL.path] = routeNode;
    
    NSLog(@"%@",self.routesStorage);
    return routeNode;
}


- (CRRouteNode *)routeNodeForURL:(NSURL *)URL
{
    return self.routesStorage[URL.scheme][URL.host][URL.path];
}

- (void)removeRouteNode:(CRRouteNode *)routeNode
{
    NSMutableDictionary *schemeRoutes = self.routesStorage[routeNode.scheme];
    NSMutableDictionary *hostRoutes = schemeRoutes[routeNode.host];

    [hostRoutes removeObjectForKey:routeNode.path];
    if(hostRoutes.count == 0)  [schemeRoutes removeObjectForKey:routeNode.host];
    if(schemeRoutes.count == 0)  [self.routesStorage removeObjectForKey:routeNode.scheme];
}

#pragma mark - Utils
+ (NSDictionary *)queryDictonaryWithURL:(NSURL *)URL
{
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [URL.query componentsSeparatedByString:@"&"]) {
        NSArray *components = [query componentsSeparatedByString:@"="];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByRemovingPercentEncoding];
        id value = nil;
        if (components.count == 1) {
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByRemovingPercentEncoding];
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            continue;
        }
        mute[key] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;
}

#pragma mark - getters
- (NSMutableDictionary *)routesStorage
{
    if (_routesStorage == nil) {
        _routesStorage = [[NSMutableDictionary alloc] init];
    }
    return _routesStorage;
}
@end


@interface CRRouteNode()

@property (nonatomic, copy) CRRouteParamsValidator validator;
@property (nonatomic, copy) CRRouteParamsMapper mapper;
@property (nonatomic, copy) CRRouteObjectHandler handler;

@property (nonatomic, copy, readwrite) NSString *scheme;
@property (nonatomic, copy, readwrite) NSString *host;
@property (nonatomic, copy, readwrite) NSString *path;
@end

@implementation CRRouteNode

+ (instancetype)routeNodeWithURLScheme:(NSString *)scheme URLHost:(NSString *)host URLPath:(NSString *)path
{
    return [[self alloc] initWithURLScheme:scheme URLHost:host URLPath:path];
}

- (instancetype)initWithURLScheme:(NSString *)scheme URLHost:(NSString *)host URLPath:(NSString *)path
{
    self = [super init];
    if(self == nil)
        return nil;
    _scheme = scheme;
    _host = host;
    _path = path;
    return self;
}

- (instancetype)paramsValidate:(CRRouteParamsValidator)paramsValidator
{
    _validator = paramsValidator;
    return self;
}

- (instancetype)paramsMap:(CRRouteParamsMapper)paramsMapper
{
    _mapper = paramsMapper;
    return self;
}

- (void)objectHandler:(CRRouteObjectHandler)objectHandler
{
    _handler = objectHandler;
}

#pragma mark - private methods
- (BOOL)validate:(NSDictionary *)params
{
    return self.validator ? self.validator(params) : YES;
}

- (NSDictionary *)mapParams:(NSDictionary *)params
{
    return self.mapper ? self.mapper(params) : params;
}

- (id)objectForRouteParams:(NSDictionary *)routeParams
{
    return self.handler ? self.handler(routeParams) : nil;
}

@end
