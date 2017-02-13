//
//  CustomAnnotationView.h
//  高德地图
//
//  Created by dingping on 2017/2/10.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CustomAnnotation.h"


@interface CustomAnnotationView : MAAnnotationView

+ (instancetype)annotationViewWithMap:(MAMapView *)mapView;

@end
