//
//  CustomAnnotationView.m
//  高德地图
//
//  Created by dingping on 2017/2/10.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import "CustomAnnotationView.h"

static NSString *identifier = @"CustomAnnotationView";
@implementation CustomAnnotationView

+ (instancetype)annotationViewWithMap:(MAMapView *)mapView
{
    CustomAnnotationView *annoView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annoView == nil) {
        annoView = [[CustomAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:identifier];
    }
    return annoView;
}

- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        // 可以自定义控件
    }
    return self;
}

- (void)setAnnotation:(CustomAnnotation *)annotation
{
    [super setAnnotation:annotation];
    self.image = [UIImage imageNamed:annotation.icon];
}

@end
