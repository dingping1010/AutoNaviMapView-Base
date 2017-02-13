//
//  CustomAnnotation.h
//  高德地图
//
//  Created by dingping on 2017/2/10.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface CustomAnnotation : NSObject<MAAnnotation>

/**
 *  大头针的位置
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 *  大头针标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  大头针的子标题
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;

@end
