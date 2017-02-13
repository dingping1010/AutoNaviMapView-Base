//
//  MainViewController.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/2/13.
//  Copyright © 2017年 dingping. All rights reserved.
//


#import "MainViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "CustomAnnotationView.h"

@interface MainViewController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAPointAnnotation *userAnnotation;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic ,strong) CLGeocoder *geocoder;  // 地理编码对象
@property (nonatomic, strong) UIButton *gpsLocationBtn;
@property (nonatomic, strong) NSMutableArray *pointArr;           // 大头针数组

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"首页地图";
    UIButton *leftBarButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, 40, 40)];
    leftBarButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftBarButton setImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(pushToMenu) forControlEvents:UIControlEventTouchUpInside];

    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.gpsLocationBtn];
    
    CGFloat paddingX = 25;
    CGFloat paddingY = 40;
    CGFloat gpsWidth = 45;
    CGFloat gpsHeight = 45;
    
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    self.gpsLocationBtn.frame = CGRectMake(paddingX, screenH - paddingY*2, gpsWidth, gpsHeight);
    
}

- (void)pushToMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

// 添加大头针，在需要的地方添加大头针
- (void)addAnnotationWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude
{
    if(self.pointArr) {
        [self.mapView removeAnnotations:self.pointArr];
        [self.pointArr removeAllObjects];
    }
    
    CustomAnnotation *anno = [[CustomAnnotation alloc] init];
    anno.title = @"自定义大头针1号";
    anno.subtitle = @"我的名字叫啦啦";
    anno.coordinate = CLLocationCoordinate2DMake(latitude , longitude);
    anno.icon = @"userLocation_icon";
    
    // 添加大头针
    [self.mapView addAnnotation:anno];
    [self.pointArr addObject:anno];
}

- (MAAnnotationView *)createSystemAnnotationWithMapView:(MAMapView *)mapView Annotaion:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

- (void)gpsAction:(id)sender
{
    self.mapView.showsUserLocation = YES;
    [self.mapView setZoomLevel:(17.2f) animated:YES];
}


// 当大头针被加入到地图中的时候就会调用这个方法
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    // 自定义大头针
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotationView *annoView = [CustomAnnotationView annotationViewWithMap:mapView];
        annoView.canShowCallout= YES;
        annoView.draggable = YES;
        annoView.annotation = annotation;
        return annoView;
    }
    // 如果用系统的大头针--->>>(MAAnnotationView *)createSystemAnnotationWithMapView:(MAMapView *)mapView Annotaion:(id <MAAnnotation>)annotation
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        CLLocation *newLocation = userLocation.location;
        
        //判断时间
        NSTimeInterval locationAge = [newLocation.timestamp timeIntervalSinceNow];
        if (locationAge > 5.0) {
            return;
        }
        
        //判断水平精度是否有效
        if(newLocation.horizontalAccuracy >0 && newLocation.horizontalAccuracy < 150) {
            CLLocationCoordinate2D myCoorDinate = [newLocation coordinate];
            _mapView.centerCoordinate = myCoorDinate;
            _mapView.showsUserLocation = NO;
            
            [self addAnnotationWithLatitude:myCoorDinate.latitude Longitude:myCoorDinate.longitude];
            
            // 反地理编码，根据定位到的经纬度转换成城市街道名称等信息
            [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks firstObject];
                NSLog(@"获取地理位置成功 name = %@ locality = %@", placemark.name, placemark.locality);
                userLocation.title = placemark.name;
                userLocation.subtitle = placemark.locality;
            }];
        }
    }
}

#pragma mark - init -
- (MAMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(22.547,114.085947);
        _mapView.showsCompass = NO;
        _mapView.mapType = MAMapTypeStandard;
        _mapView.showsScale = NO;
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeNone;
        _mapView.delegate = self;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_mapView setZoomLevel:(17.2f) animated:YES];
        _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(22.547,114.085947);
    }
    return _mapView;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (UIButton*)gpsLocationBtn
{
    if (!_gpsLocationBtn) {
        UIButton * ret = [[UIButton alloc] init];
        ret.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [ret setImage:[UIImage imageNamed:@"GPS_location"] forState:UIControlStateNormal];
        [ret addTarget:self action:@selector(gpsAction:) forControlEvents:UIControlEventTouchUpInside];
        _gpsLocationBtn = ret;
    }
    return _gpsLocationBtn;
}

- (NSMutableArray *)pointArr
{
    if(!_pointArr) {
        _pointArr = [[NSMutableArray alloc]init];
    }
    return _pointArr;
}

// 设置地图的一些参数
- (void)test
{
    //    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    //    _mapView.delegate = self;
    //    [self.view addSubview:_mapView];
    
    //    _mapView.showsUserLocation = YES;   // 开启定位
    //    _mapView.userTrackingMode = MAUserTrackingModeFollow;  // 定位的模式，显示蓝点
    //    _mapView.showsCompass= NO;  // 是否开启地图右上角的指南针
    //    _mapView.showsScale = NO;
    //    _mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 60);  // 设置地图的比例尺尺寸
    
    //    _mapView.zoomEnabled = YES;  // 是否可以缩放地图
    //    [_mapView setZoomLevel:17.5f animated:YES];   // 地图的缩放级别，范围是【 3-19 】
    //    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //    _mapView.scrollEnabled = YES; // 是否可以滑动地图
    //    地图平移时，缩放级别不变，可通过改变地图的中心点来移动地图，示例代码如下：杭州经纬度:(120.20000,30.26667)
    //    CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake(120.20000, 30.26667);
    //    [_mapView setCenterCoordinate:coordinate animated:YES];
    
    //     _mapView.rotateEnabled = NO;    //NO表示禁用旋转手势，YES表示开启,3D地图
    //    [_mapView setRotationDegree:60.f animated:YES duration:0.5]; //旋转角度，范围是[0.f 360.f]，逆时针为正方向
    
    //      _mapView.rotateCameraEnabled= NO;    //NO表示禁用倾斜手势，YES表示开启
    //    [_mapView setCameraDegree:30.f animated:YES duration:0.5];  // 倾斜角度，范围是[0.f, 45.f]
    
    
    // 还可以限制地图的显示范围，比如只显示北京区域的地图。与“禁用旋转手势”配合使用。详情参考高德开发文档。
    // 地图可以截屏，只有当地图上的内容显示完成后，才可以截屏。
    
    //    _mapView.showsUserLocation = YES;
    //    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(22.547,114.085947);
    //    _mapView.centerCoordinate = centerCoordinate;
}


@end
