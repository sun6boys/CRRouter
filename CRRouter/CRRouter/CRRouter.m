//
//  CRRouter.m
//  CRRouter
//
//  Created by user on 17/4/27.
//  Copyright © 2017年 Charon. All rights reserved.
//

#import "CRRouter.h"

@interface CRRouteNode()

- (BOOL)validateWithOriginParams:(NSDictionary *)params routeParams:(NSDictionary *)routeParams;
- (NSDictionary *)mapParams:(NSDictionary *)params;
- (id)objectForRouteParams:(NSDictionary *)routeParams;
- (BOOL)openPageWithRouteParams:(NSDictionary *)routeParams;
@end

static BOOL enableLog = NO;

@interface CRRouter()

@property (nonatomic, strong) NSMutableDictionary *routesStorage;
@property (nonatomic, strong) dispatch_semaphore_t lock;
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

- (instancetype)init
{
    self = [super init];
    if(self == nil) { return nil; }
    _lock = dispatch_semaphore_create(1);
    _routesStorage = [[NSMutableDictionary alloc] init];
    return self;
}

#pragma mark - public methods
+ (CRRouteNode *)registURLPattern:(NSString *)URLPatten
{
    NSURL *URL = [NSURL URLWithString:URLPatten];
    CRRouteNode *routeNode = [[self sharedInstance] routeNodeForURL:URL];
    if(routeNode)
        return routeNode;
    
    NSAssert(URL.scheme.length > 0 && URL.host.length > 0 && URL.path.length > 0, @"scheme nor host nor path can't be nil for URLPatten");
    return [[self sharedInstance] addURLPatternForURL:URL];
}

+ (void)registRouteNode:(CRRouteNode *)routeNode
{
    NSAssert(routeNode.scheme.length > 0 && routeNode.host.length > 0 && routeNode.path.length > 0, @"scheme nor host nor path can't be nil for routeNode");
    [[self sharedInstance] addRouteNode:routeNode];
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
    return [self objectForURL:URLPattern withParams:nil];
}

+ (id)objectForURL:(NSString *)URLPattern withParams:(NSDictionary *)params
{
    NSURL *URL = [NSURL URLWithString:URLPattern];
    NSDictionary *originParams = [self paramsForURL:URL withCustomParams:params];
    
    CRRouteNode *node = [[self sharedInstance] routeNodeForURL:URL];
    
    if(node == nil){
        [self routerLogWithFormat:@"!!!!!!!!!!  Not found router for scheme: %@  host : %@  path :%@ has registed  !!!!!!!!!!",URL.scheme,URL.host,URL.path];
        return nil;
    }
    [self routerLogWithFormat:@"Successfully  find a router for scheme: %@  host : %@  path :%@",URL.scheme,URL.host,URL.path];
    return [self objectForRouteNode:node withParams:[originParams copy]];
}

+ (id)objectForRouteNode:(CRRouteNode *)routeNode withParams:(NSDictionary *)params
{
    [self routerLogWithFormat:@"params before mapping are %@",params];
    NSDictionary *routeParams = [routeNode mapParams:params];
    [self routerLogWithFormat:@"params after mapping are %@",routeParams];
    
    if([routeNode validateWithOriginParams:params routeParams:routeParams] == NO){
        [self routerLogWithFormat:@"!!!!!!!!!!  Params error for route scheme: %@  host : %@  path :%@  !!!!!!!!!!",routeNode.scheme,routeNode.host,routeNode.path];
        return nil;
    }
    
    return [routeNode objectForRouteParams:routeParams];
}

+ (BOOL)openURL:(NSString *)URLPattern
{
    return [self openURL:URLPattern withParams:nil];
}

+ (BOOL)openURL:(NSString *)URLPattern withParams:(NSDictionary *)params
{
    NSURL *URL = [NSURL URLWithString:URLPattern];
    CRRouteNode *node = [[self sharedInstance] routeNodeForURL:URL];
    if(node == nil){
        [self routerLogWithFormat:@"!!!!!!!!!!  Not found router for scheme: %@  host : %@  path :%@ has registed  !!!!!!!!!!",URL.scheme,URL.host,URL.path];
        return NO;
    }
    NSDictionary *mergeParams = [self paramsForURL:URL withCustomParams:params];
    [self routerLogWithFormat:@"params before mapping are %@",mergeParams];
    NSDictionary *routeParams = [node mapParams:mergeParams];
    [self routerLogWithFormat:@"params after mapping are %@",routeParams];
    
    if([node validateWithOriginParams:params routeParams:routeParams] == NO){
        [self routerLogWithFormat:@"!!!!!!!!!!  Params error for route scheme: %@  host : %@  path :%@  !!!!!!!!!!",node.scheme,node.host,node.path];
        return NO;
    }
    return [node openPageWithRouteParams:routeParams];
}

+ (BOOL)openRouteNode:(CRRouteNode *)routeNode withParams:(NSDictionary *)params
{
    if(routeNode.scheme.length == 0 ||
       routeNode.host.length == 0 ||
       routeNode.path.length == 0)
        return NO;
    
    NSString *URLPattern = [NSString stringWithFormat:@"%@://%@%@",routeNode.scheme,routeNode.host,routeNode.path];
    return [self openURL:URLPattern withParams:params];
}

+ (void)setEnablePrintfLog:(BOOL)enablePrintfLog
{
    enableLog = enablePrintfLog;
}

#pragma mark - private methods
#pragma mark - class methods
+ (NSDictionary *)paramsForURL:(NSURL *)URL withCustomParams:(NSDictionary *)customParams
{
    NSDictionary *queryParams = [self queryDictonaryWithURL:URL];
    [self routerLogWithFormat:@"URL.queryItems are %@",queryParams];
    
    NSMutableDictionary *originParams = [[NSMutableDictionary alloc] initWithDictionary:queryParams];
    [originParams addEntriesFromDictionary:customParams];
    return [originParams copy];
}

#pragma mark - private methods
#pragma mark - instance methods
- (CRRouteNode *)addURLPatternForURL:(NSURL *)URL
{
    CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:URL.scheme URLHost:URL.host URLPath:URL.path];
    [self addRouteNode:routeNode];
    return routeNode;
}

- (void)addRouteNode:(CRRouteNode *)routeNode
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    if(self.routesStorage[routeNode.scheme] == nil){
        self.routesStorage[routeNode.scheme] = [[NSMutableDictionary alloc] init];
    }
    if (self.routesStorage[routeNode.scheme][routeNode.host] == nil) {
        self.routesStorage[routeNode.scheme][routeNode.host] = [[NSMutableDictionary alloc] init];
    }
    self.routesStorage[routeNode.scheme][routeNode.host][routeNode.path] = routeNode;
    dispatch_semaphore_signal(self.lock);
}

- (CRRouteNode *)routeNodeForURL:(NSURL *)URL
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    CRRouteNode * routeNode = self.routesStorage[URL.scheme][URL.host][URL.path];
    dispatch_semaphore_signal(self.lock);
    
    return routeNode;
}

- (void)removeRouteNode:(CRRouteNode *)routeNode
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    
    NSMutableDictionary *schemeRoutes = self.routesStorage[routeNode.scheme];
    NSMutableDictionary *hostRoutes = schemeRoutes[routeNode.host];

    [hostRoutes removeObjectForKey:routeNode.path];
    if(hostRoutes.count == 0)  [schemeRoutes removeObjectForKey:routeNode.host];
    if(schemeRoutes.count == 0)  [self.routesStorage removeObjectForKey:routeNode.scheme];
    
    dispatch_semaphore_signal(self.lock);
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

+ (void)routerLogWithFormat:(NSString *)format, ... {
    if (enableLog && format) {
        va_list argsList;
        va_start(argsList, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
        NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
        
        va_end(argsList);
        NSLog(@"[CRRouter]: %@", formattedLogMessage);
    }
}

@end


@interface CRRouteNode()

@property (nonatomic, copy) CRRouteParamsValidator validator;
@property (nonatomic, copy) CRRouteParamsMapper mapper;
@property (nonatomic, copy) CRRouteObjectHandler objectHandler;
@property (nonatomic, copy) CRRouteOpenHandler openHandler;

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

- (instancetype)objectHandler:(CRRouteObjectHandler)objectHandler
{
    _objectHandler = objectHandler;
    return self;
}

- (instancetype)openHandler:(CRRouteOpenHandler)openHandler
{
    _openHandler = openHandler;
    return self;
}

#pragma mark - private methods
- (BOOL)validateWithOriginParams:(NSDictionary *)params routeParams:(NSDictionary *)routeParams
{
    return self.validator ? self.validator(params,routeParams) : YES;
}

- (NSDictionary *)mapParams:(NSDictionary *)params
{
    return self.mapper ? self.mapper(params) : params;
}

- (id)objectForRouteParams:(NSDictionary *)routeParams
{
    return self.objectHandler ? self.objectHandler(routeParams) : nil;
}

- (BOOL)openPageWithRouteParams:(NSDictionary *)routeParams
{
    if(self.openHandler == nil)
        return NO;
    
    self.openHandler(routeParams);
    return YES;
}

@end
