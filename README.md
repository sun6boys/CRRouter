CRRouter
====

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)
![](https://img.shields.io/badge/language-objective-orange.svg)
![](https://img.shields.io/cocoapods/v/CRRouter.svg?style=flat)


## CRRouter是什么
CRRouter是一个利用URL注册，通过URL获取对象或者打开一个页面的模块解耦框架。
## CRRouter提供了哪些功能

 - 通过一个URL获取一个对象
 - 通过一个URL打开相应页面
 - 参数验证
 - 参数映射

## 安装
### CocoaPods

1. 在Podfile中添加 pod "CRRouter".
2. 输入命令 `pod install` 或者 `pod update`.
3. Import \<CRRouter/CRRouter.h\>.

## 如何使用
### 注册
**CRRouter**提供了2种注册方式

```
//第一种注册方式
CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:@"cr" URLHost:@"goods" URLPath:@"/goodsDetail"];
[CRRouter registRouteNode:routeNode];
```

```
//第二种注册方式
[CRRouter registURLPattern:@"cr://goods/goodsDetail"]
```
### 参数映射
有时候我们需要从第三方app中打开我们app，并且进入某个页面。我们需要给他们提供scheme、host、path以及所需的参数，比如`cr://goods/goodsDetail?goodsId=12389`，但是我们不想告诉第三方页面所需要的真正参数名，所以我们告诉他们通过`cr://goods/goodsDetail?p1=12389`来打开商品详情页面，而我们真正需要的参数名是`goodsId`,**CRRouter**提供了下面的方式来映射参数。

```
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
```

So,对于我们内部仍然可以通过`cr://goods/goodsDetail?goodsId=12389`来调用，而第三方通过`cr://goods/goodsDetail?p1=12389`也可以调用到相应的模块

### 参数验证
以上面为例，打开一个商品详情页，一个goodsId是必须的，**CRRouter**提供相应的参数验证

```
CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:@"cr" URLHost:@"goods" URLPath:@"/goodsDetail"];

[routeNode paramsValidate:^BOOL(NSDictionary *originParams, NSDictionary *routeParams) {
     NSString *goodsId = routeParams[@"goodsId"];
     return goodsId.length > 0;
 }];
```
如果参数验证失败，将不会继续执行下去。**如果实现了参数映射的block，那验证的是映射后的参数**

### 实现注册的URL相应的获取实例操作
```
CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:@"cr" URLHost:@"goods" URLPath:@"/goodsDetail"];

[routeNode objectHandler:^id(NSDictionary *routeParams) {
     CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
     goodsVC.goodsId = routeParams[@"goodsId"];
     return goodsVC;
 }];
```
如果实现了参数验证，如果这个block被调用，那肯定是参数验证通过了。

### 实现注册的URL打开页面的操作
```
CRRouteNode *routeNode = [CRRouteNode routeNodeWithURLScheme:@"cr" URLHost:@"goods" URLPath:@"/goodsDetail"];

[routeNode openHandler:^(NSDictionary *routeParams) {
     CRGoodsViewController *goodsVC = [[CRGoodsViewController alloc] init];
     goodsVC.goodsId = routeParams[@"goodsId"];
     UINavigationController *navigationVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
     [navigationVC pushViewController:goodsVC animated:YES];
 }];
```
如果实现了参数验证，如果这个block被调用，那肯定是参数验证通过了。

### 如何调用
**通过URL获取一个实例**

```
UIViewController *vc = [CRRouter objectForURL:@"cr://goods/goodsDetail?p1=1"];
```
如果一些参数不方便通过URL query传递（比如block）可以用下面的方式获取实例

```
dispatch_block_t completionHandler = ^{
        
};
UIViewController *vc = [CRRouter objectForURL:@"cr://goods/goodsDetail?goodsId=1" withParams:@{@"block" : completionHandler}];
```
**通过URL打开一个页面**

```
[CRRouter openURL:@"cr://goods/goodsDetail?p1=1"];
```
或

```
dispatch_block_t completionHandler = ^{
        
};
[CRRouter openURL:@"cr://goods/goodsDetail?goodsId=1" withParams:@{@"block" : completionHandler}];
```

### 支持链式语法
如果你不喜欢上面的调用方式，**CRRouter**也提供类似[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)那样的调用方式

```
[[[[[CRRouter registURLPattern:@"cr://goods/goodsDetail"] paramsMap:^NSDictionary *(NSDictionary *originParams) {
        
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    temp[@"goodsId"] = originParams[@"p1"];
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

```

## TODO
 1. [x] 添加参数验证
 2. [x] 添加参数映射
 3. [x] 通过URL可以打开一个页面
 4. [x] 通过URL可以获取一个对象
 5. [ ] 通过URL可以调用相应Target的Action


 如果大家有好的建议也可以通过Issues的方式或者邮件[邮件](mailto:sun6boys@126.com)的方式告诉我。
 
  
## 协议
CRRouter被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。
