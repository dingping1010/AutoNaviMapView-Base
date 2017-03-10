//
//  DPNetworkService.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/3/7.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import "DPNetworkService.h"
#import "AFNetworkActivityIndicatorManager.h"


static AFHTTPSessionManager *_manager;
static NSMutableDictionary * _mutParamares;
@implementation DPNetworkService

+ (DPNetworkService *)sharedInstance
{
    static DPNetworkService *request;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         request = [[DPNetworkService alloc] init];
        _mutParamares = [NSMutableDictionary dictionary];
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.requestSerializer.timeoutInterval = 30.0f;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json",
                                                              @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    });
    
    return request;
}

- (void)getDataWithUrl:(NSString *)url paramaters:(NSDictionary *)paramarers success:(success)success failure:(failure)failure
{
    //添加请求参数
    [_mutParamares setValue:@"" forKey:@""];
    
    //设置请求头
    // [_manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    
    [_manager GET:url parameters:paramarers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success? success(responseObject) :nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure? failure(error) :nil;
    }];
}


- (void)postDataWithUrl:(NSString *)url paramaters:(NSDictionary *)paramarers success:(success)success failure:(failure)failure
{
    [_manager POST:url parameters:paramarers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success? success(responseObject) :nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure? failure(error) :nil;
    }];
}

@end
