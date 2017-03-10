//
//  DPNetworkService.h
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/3/7.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


/** 请求成功的Block **/
typedef void(^success)(id response);

/**  请求失败的Block **/
typedef void(^failure)(NSError *error);


@interface DPNetworkService : NSObject

+ (DPNetworkService *)sharedInstance;

- (void)getDataWithUrl:(NSString *)url paramaters:(NSDictionary *)paramarers success:(success)success failure:(failure)failure;
- (void)postDataWithUrl:(NSString *)url paramaters:(NSDictionary *)paramarers success:(success)success failure:(failure)failure;

@end
