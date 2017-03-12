//
//  NaviViewController.h
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/3/10.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface NaviViewController : UIViewController

/**
  导航起点经度
 */
@property (nonatomic, assign)CGFloat startPointLat;

/**
 导航起点纬度
 */
@property (nonatomic, assign)CGFloat startPointLog;

/**
  导航终点经度
 */
@property (nonatomic, assign)CGFloat  endPointLat;

/**
 导航终点纬度
 */
@property (nonatomic, assign)CGFloat  endPointLog;

@end
